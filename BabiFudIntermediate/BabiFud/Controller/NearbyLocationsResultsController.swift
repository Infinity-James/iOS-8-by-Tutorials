import Foundation
import UIKit
import CloudKit

//	MARK: Nearby Location Results Controller Delegate Protocol
protocol NearbyLocationsResultsControllerDelegate {
	func nearbyLocationsResultsController(nearbyLocationsResultsController: NearbyLocationsResultsController, didEndUpdatingWithError error: NSError!)
	func nearbyLocationsResultsControllerWillBeginUpdating(nearbyLocationsResultsController: NearbyLocationsResultsController)
	func nearbyLocationsResultsController(nearbyLocationsResultsController: NearbyLocationsResultsController, addedEstablishment establishment: Establishment, atIndex index: Int)
	func nearbyLocationsResultsController(nearbyLocationsResultsController: NearbyLocationsResultsController, updatedEstablishment establishment: Establishment, atIndex index: Int)
	func nearbyLocationsResultsController(nearbyLocationsResultsController: NearbyLocationsResultsController, removedEstablishmentAtIndex index: Int)
	func nearbyLocationsResultsControllerUpdated(nearbyLocationsResultsController: NearbyLocationsResultsController)
}

//	MARK: Nearby Locations Results Controller Class
class NearbyLocationsResultsController {
	
	//	MARK: Properties
	
	///	Will handle results of the search as they're changed / updated.
	private let delegate: NearbyLocationsResultsControllerDelegate
	///	Whether a fetch is in progress.
	private var inProgress = false
	///	Will hold the reference to the predicate used to get necessary records
	var predicate: NSPredicate?
	///	The public iCloud database.
	private let publicDatabase: CKDatabase
	///
	private let recordType = "Establishment"
	///	The limit of the number of results we want
	private let resultLimit = 30
	///	Stores search results
	var results = [Establishment]()
	///	Whether we have started to receive results
	private var startedGettingResults = false
	///	Whether or not we are subscribed yet.
	private var subscribed = false
	///	The identifier for the subscription to updates for nearby locations
	private let subscriptionID = "subscription_id"
	
	private func cachePath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
		let path = paths.first!.stringByAppendingPathComponent("establishments.cache")
		return path
	}
	
	init(delegate: NearbyLocationsResultsControllerDelegate) {
		self.delegate = delegate
		publicDatabase = CKContainer.defaultContainer().publicCloudDatabase
	}
	
	private func itemMatching(recordID: CKRecordID) -> (item: Establishment?, index: Int) {
		var index = NSNotFound
		var establishment: Establishment?
		
		for (resultIndex, value) in enumerate(results) {
			if value.record.recordID == recordID {
				establishment = value
				index = resultIndex
				break
			}
		}
		
		return (establishment, index)
	}
	
	private func fetchAndUpdateOrAdd(recordID: CKRecordID) {
		publicDatabase.fetchRecordWithID(recordID) { record, error in
			if error == nil {
				var (establishment, index) = self.itemMatching(recordID)
				//	if the establishment does not exist, we create it and add it
				if index == NSNotFound {
					establishment = Establishment(record: record, database: self.publicDatabase)
					NSOperationQueue.mainQueue().addOperationWithBlock {
						self.delegate.nearbyLocationsResultsControllerWillBeginUpdating(self)
						self.results.append(establishment!)
						self.delegate.nearbyLocationsResultsController(self, addedEstablishment: establishment!, atIndex: self.results.count - 1)
						self.delegate.nearbyLocationsResultsController(self, didEndUpdatingWithError: nil)
					}
					//	otherwise we update it
				} else {
					NSOperationQueue.mainQueue().addOperationWithBlock {
						self.delegate.nearbyLocationsResultsControllerWillBeginUpdating(self)
						establishment!.record = record
						self.delegate.nearbyLocationsResultsController(self, updatedEstablishment: establishment!, atIndex: index)
						self.delegate.nearbyLocationsResultsController(self, didEndUpdatingWithError: nil)
					}
				}
			}
		}
	}
	
	private func fetchNextResults(cursor: CKQueryCursor) {
		let queryOperation = CKQueryOperation(cursor: cursor)
		sendOperation(queryOperation)
	}
	
	private func getOutstandingNotifications() {
		let operation = CKFetchNotificationChangesOperation(previousServerChangeToken: nil)
		operation.notificationChangedBlock = { notification in
			if let notification = notification as? CKQueryNotification {
				self.handleNotification(notification)
			}
		}
		operation.fetchNotificationChangesCompletionBlock = { serverChangeToken, error in
			if error != nil {
				println("Error fetching notifications: \(error)")
			}
		}
		
		CKContainer.defaultContainer().addOperation(operation)
	}
	
	func handleNotification(notification: CKQueryNotification) {
		let recordID = notification.recordID
		switch notification.queryNotificationReason {
		case .RecordCreated:
			fetchAndUpdateOrAdd(notification.recordID)
		case .RecordDeleted:
			remove(notification.recordID)
		case .RecordUpdated:
			fetchAndUpdateOrAdd(notification.recordID)
		}
		
		markNotificationsAsRead([notification.notificationID])
	}
	
	private func listenForBecomeActive() {
		NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: NSOperationQueue.mainQueue()) { notification in
			self.getOutstandingNotifications()
		}
	}
	
	func loadCache() {
		if let data = NSData(contentsOfFile: cachePath()) where data.length > 0 {
			let decoder = NSKeyedUnarchiver(forReadingWithData: data)
			if let rootObject = decoder.decodeObject() as? [Establishment] {
				results = rootObject
				NSOperationQueue.mainQueue().addOperationWithBlock {
					self.delegate.nearbyLocationsResultsControllerUpdated(self)
				}
			}
		}
	}
	
	private func markNotificationsAsRead(notifications: [CKNotificationID]) {
		let markOperation = CKMarkNotificationsReadOperation(notificationIDsToMarkRead: notifications)
		CKContainer.defaultContainer().addOperation(markOperation)
	}
	
	private func persist() {
		//	use the archiver to encode the results to the data
		let data = NSMutableData()
		let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
		archiver.encodeRootObject(results)
		archiver.finishEncoding()
		
		//	write the archived data to the cache path
		data.writeToFile(cachePath(), atomically: true)
	}
	
	private func queryCompleted(cursor: CKQueryCursor?, error: NSError?) {
		startedGettingResults = false
		
		NSOperationQueue.mainQueue().addOperationWithBlock {
			self.delegate.nearbyLocationsResultsController(self, didEndUpdatingWithError: error)
		}
	}
	
	private func recordFetched(record: CKRecord) {
		if !startedGettingResults {
			startedGettingResults = true
			NSOperationQueue.mainQueue().addOperationWithBlock {
				self.delegate.nearbyLocationsResultsControllerWillBeginUpdating(self)
			}
		}
		
		var index = NSNotFound
		var establishment: Establishment?
		var newItem = true
		
		for (resultIndex, value) in enumerate(results) {
			if value.record.recordID == record.recordID {
				index = resultIndex
				establishment = value
				establishment!.record = record
				newItem = false
				break
			}
		}
		
		if index == NSNotFound {
			establishment = Establishment(record: record, database: publicDatabase)
			results.append(establishment!)
			index = results.count - 1
		}
		
		NSOperationQueue.mainQueue().addOperationWithBlock {
			if newItem {
				self.delegate.nearbyLocationsResultsController(self, addedEstablishment: establishment!, atIndex: index)
			} else {
				self.delegate.nearbyLocationsResultsController(self, updatedEstablishment: establishment!, atIndex: index)
			}
		}
	}
	
	private func remove(recordID: CKRecordID) {
		NSOperationQueue.mainQueue().addOperationWithBlock {
			let (_, index) = self.itemMatching(recordID)
			if index == NSNotFound {
				return
			}
			
			self.delegate.nearbyLocationsResultsControllerWillBeginUpdating(self)
			
			self.results.removeAtIndex(index)
			self.delegate.nearbyLocationsResultsController(self, removedEstablishmentAtIndex: index)
			self.delegate.nearbyLocationsResultsController(self, didEndUpdatingWithError: nil)
		}
	}
	
	private func sendOperation(queryOperation: CKQueryOperation) {
		queryOperation.queryCompletionBlock = { cursor, error in
			
			if isRetryableCKError(error) {
				let userInfo = error.userInfo!
				
				if let retryAfter = userInfo[CKErrorRetryAfterKey] as? NSNumber {
					let delay = retryAfter.doubleValue * Double(NSEC_PER_SEC)
					let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
					
					dispatch_after(time, dispatch_get_main_queue()) {
						self.sendOperation(queryOperation)
					}
				}
				
				return
			}
			
			self.queryCompleted(cursor, error: error)
			if cursor != nil {
				self.fetchNextResults(cursor)
			} else {
				self.inProgress = false
				self.persist()
			}
		}
		queryOperation.recordFetchedBlock = { record in
			self.recordFetched(record)
		}
		queryOperation.resultsLimit = resultLimit
		startedGettingResults = false
		publicDatabase.addOperation(queryOperation)
	}
	
	func start() {
		if inProgress {
			return
		}
		
		inProgress = true
		
		let query = CKQuery(recordType: recordType, predicate: predicate)
		let queryOperation = CKQueryOperation(query: query)
		queryOperation.desiredKeys = ["Name", "Location", "HealthyOption", "KidsMenu"]
		
		sendOperation(queryOperation)
		
		subscribe()
		
//		getOutstandingNotifications()
	}
	
	func subscribe() {
		if subscribed {
			return
		}
		
		let options: CKSubscriptionOptions = .FiresOnRecordCreation | .FiresOnRecordDeletion | .FiresOnRecordUpdate
		let subscription = CKSubscription(recordType: recordType, predicate: predicate, subscriptionID: subscriptionID, options: options)
		subscription.notificationInfo = CKNotificationInfo()
		subscription.notificationInfo.alertBody = ""
		
		publicDatabase.saveSubscription(subscription) { subscription, error in
			if error != nil {
				println("Error subscribing: \(error)")
			} else {
				self.subscribed = true
				self.listenForBecomeActive()
			}
		}
	}
}

func isRetryableCKError(error: NSError?) -> Bool {
	var isRetryable = false
	
	if let error = error {
		let isErrorDomain = error.domain == CKErrorDomain
		
		let errorCode = error.code
		let isUnavailable = errorCode == CKErrorCode.ServiceUnavailable.rawValue
		let isRateLimited = errorCode == CKErrorCode.RequestRateLimited.rawValue
		let errorCodeIsRetryable = isUnavailable || isRateLimited
		
		isRetryable = isErrorDomain && errorCodeIsRetryable
	}
	
	return isRetryable
}