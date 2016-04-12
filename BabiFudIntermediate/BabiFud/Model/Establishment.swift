/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation
import CloudKit
import MapKit

struct ChangingTableLocation : RawOptionSetType, BooleanType {
	var rawValue: UInt = 0
	var boolValue:Bool {
		get {
			return self.rawValue != 0
		}
	}
	init(rawValue: UInt) { self.rawValue = rawValue }
	init(nilLiteral: ()) { self.rawValue = 0 }
	func toRaw() -> UInt { return self.rawValue }
	static func convertFromNilLiteral() -> ChangingTableLocation { return .None}
	static func fromRaw(raw: UInt) -> ChangingTableLocation? { return self(rawValue: raw) }
	static func fromMask(raw: UInt) -> ChangingTableLocation { return self(rawValue: raw) }
	static var allZeros: ChangingTableLocation { return self(rawValue: 0) }
	
	static var None: ChangingTableLocation   { return self(rawValue: 0) }      //0
	static var Mens: ChangingTableLocation   { return self(rawValue: 1 << 0) } //1
	static var Womens: ChangingTableLocation { return self(rawValue: 1 << 1) } //2
	static var Family: ChangingTableLocation { return self(rawValue: 1 << 2) } //4
	
	func images() -> [UIImage] {
		var images = [UIImage]()
		if self & .Mens {
			images.append(UIImage(named: "man")!)
		}
		if self & .Womens {
			images.append(UIImage(named: "woman")!)
		}
		
		return images
	}
}

func == (lhs: ChangingTableLocation, rhs: ChangingTableLocation) -> Bool     { return lhs.rawValue == rhs.rawValue }
func | (lhs: ChangingTableLocation, rhs: ChangingTableLocation) -> ChangingTableLocation { return ChangingTableLocation(rawValue: lhs.rawValue | rhs.rawValue) }
func & (lhs: ChangingTableLocation, rhs: ChangingTableLocation) -> ChangingTableLocation { return ChangingTableLocation(rawValue: lhs.rawValue & rhs.rawValue) }
func ^ (lhs: ChangingTableLocation, rhs: ChangingTableLocation) -> ChangingTableLocation { return ChangingTableLocation(rawValue: lhs.rawValue ^ rhs.rawValue) }


struct SeatingType : RawOptionSetType, BooleanType {
	var rawValue: UInt = 0
	var boolValue:Bool {
		get {
			return self.rawValue != 0
		}
	}
	init(rawValue: UInt) { self.rawValue = rawValue }
	init(nilLiteral: ()) { self.rawValue = 0 }
	func toRaw() -> UInt { return self.rawValue }
	static func convertFromNilLiteral() -> SeatingType { return .None}
	static func fromRaw(raw: UInt) -> SeatingType? { return self(rawValue: raw) }
	static func fromMask(raw: UInt) -> SeatingType { return self(rawValue: raw) }
	static var allZeros: SeatingType { return self(rawValue: 0) }
	
	static var None:      SeatingType { return self(rawValue: 0) }      //0
	static var Booster:   SeatingType { return self(rawValue: 1 << 0) } //1
	static var HighChair: SeatingType { return self(rawValue: 1 << 1) } //2
	
	func images() -> [UIImage] {
		var images = [UIImage]()
		if self & .Booster {
			images.append(UIImage(named: "booster")!)
		}
		if self & .HighChair {
			images.append(UIImage(named: "highchair")!)
		}
		
		return images
	}
}

func == (lhs: SeatingType, rhs: SeatingType) -> Bool     { return lhs.rawValue == rhs.rawValue }
func | (lhs: SeatingType, rhs: SeatingType) -> SeatingType { return SeatingType(rawValue: lhs.rawValue | rhs.rawValue) }
func & (lhs: SeatingType, rhs: SeatingType) -> SeatingType { return SeatingType(rawValue: lhs.rawValue & rhs.rawValue) }
func ^ (lhs: SeatingType, rhs: SeatingType) -> SeatingType { return SeatingType(rawValue: lhs.rawValue ^ rhs.rawValue) }

class Establishment : NSObject, MKAnnotation, Equatable, NSCoding {
	
	//	MARK: NSCoding Methods
	
	required init(coder aDecoder: NSCoder) {
		super.init()
		
		let recordName = aDecoder.decodeObjectForKey("recordName") as! String
		let recordID = CKRecordID(recordName: recordName)
		record = CKRecord(recordType: "Estalishment", recordID: recordID)
		
		database = Model.sharedInstance().publicDB
		
		let kidsMenu = aDecoder.decodeBoolForKey("kidsMenu")
		record.setObject(kidsMenu, forKey: "KidsMenu")
		
		let healthyOption = aDecoder.decodeBoolForKey("healthyOption")
		record.setObject(healthyOption, forKey: "HealthyOption")
		
		let latitude = aDecoder.decodeDoubleForKey("latitude")
		let longitude = aDecoder.decodeDoubleForKey("longitude")
		location = CLLocation(latitude: latitude, longitude: longitude)
		record.setObject(location, forKey: "Location")
		
		name = aDecoder.decodeObjectForKey("name") as! String
		record.setObject(name, forKey: "Name")
	}
	
	func encodeWithCoder(aCoder: NSCoder) {
		aCoder.encodeObject(record.recordID.recordName, forKey:"recordName")
		
		aCoder.encodeBool(kidsMenu, forKey: "kidsMenu")
		aCoder.encodeBool(healthyChoice, forKey: "healthyOption")
		
		aCoder.encodeDouble(location.coordinate.latitude, forKey: "latitude")
		aCoder.encodeDouble(location.coordinate.longitude, forKey: "longitude")
		
		aCoder.encodeObject(name, forKey: "name")
	}
	
	//	MARK: Caching
	
	private func imageCachePath() -> String {
		let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
		let path = paths.first!.stringByAppendingPathComponent(record.recordID.recordName)
		return path
	}
	
	private func processAsset(records: [NSObject: AnyObject]?, error: NSError?, completion: (photo: UIImage?) -> ()) {
		
		if let updatedRecord = records?[record.recordID] as? CKRecord,
			let asset = updatedRecord.objectForKey("CoverPhoto") as? CKAsset where error == nil {
				let URL = asset.fileURL
				let image = UIImage(contentsOfFile: URL.path!)
				
				NSFileManager.defaultManager().copyItemAtPath(URL.path!, toPath: imageCachePath(), error: nil)
				
				NSOperationQueue.mainQueue().addOperationWithBlock {
					completion(photo: image)
				}
		} else {
			completion(photo: nil)
		}
	}
	
	var record : CKRecord! {
		didSet {
			name = record.objectForKey("Name") as! String
			location = record.objectForKey("Location") as! CLLocation
		}
	}
	
	var name : String!
	var location : CLLocation!
	weak var database : CKDatabase!
	
	var assetCount = 0
	
	var healthyChoice : Bool {
		get {
			let obj: AnyObject! = record.objectForKey("HealthyOption")
			if (obj != nil) {
				return obj.boolValue
			}
			return false
			
		}
	}
	
	var kidsMenu: Bool {
		get {
			let obj: AnyObject! = record.objectForKey("KidsMenu")
			if (obj != nil) {
				return obj.boolValue
			}
			return false
		}
	}
	
	init(record : CKRecord, database: CKDatabase) {
		super.init()
		
		self.record = record
		self.database = database
		
		self.name = record.objectForKey("Name") as! String
		self.location = record.objectForKey("Location") as! CLLocation
	}
	
	func fetchRating(completion: (rating: Double, isUser: Bool) -> ()) {
		Model.sharedInstance().userInfo.userID() { userRecord, error in
			self.fetchRating(userRecord, completion: completion)
		}
	}
	
	func fetchRating(userRecord: CKRecordID!,
		completion: (rating: Double, isUser: Bool) -> ()) {
			// 1
			let predicate = NSPredicate(format: "Establishment == %@", record)
			// 2
			let query = CKQuery(recordType: "Rating", predicate: predicate)
			database.performQuery(query, inZoneWithID: nil) {
				results, error in
				if error != nil {
					completion(rating: 0, isUser: false)
				} else {
					let resultsArray = results as NSArray
					// 3
					if let rating = resultsArray.valueForKeyPath("@avg.Rating") as? Double {
						completion(rating: rating, isUser: false)
					} else {
						completion(rating: 0, isUser: false)
					}
				}
			}
	}
	
	
	func fetchNote(completion: (note: String!) -> ()) {
		Model.sharedInstance().fetchNote(self) { note, error in
			completion(note: note)
		}
	}
	
	func fetchPhotos(completion:(assets: [CKRecord]!)->()) {
		let predicate = NSPredicate(format: "Establishment == %@", record)
		let query = CKQuery(recordType: "EstablishmentPhoto", predicate: predicate);
		//Intermediate Extension Point - with cursors
		database.performQuery(query, inZoneWithID: nil) { results, error in
			if error == nil {
				self.assetCount = results.count
			}
			completion(assets: results as! [CKRecord])
		}
	}
	
	func changingTable() -> ChangingTableLocation {
		let changingTable = record?.objectForKey("ChangingTable") as? NSNumber
		var val:UInt = 0
		if let changingTableNum = changingTable {
			val = changingTableNum.unsignedLongValue
		}
		return ChangingTableLocation(rawValue: val)
	}
	
	func seatingType() -> SeatingType {
		let seatingType = record?.objectForKey("SeatingType") as? NSNumber
		var val:UInt = 0
		if let seatingTypeNum = seatingType {
			val = seatingTypeNum.unsignedLongValue
		}
		return SeatingType(rawValue: val)
	}
	
	func loadCoverPhoto(completion:(photo: UIImage?) -> ()) {
		
		let backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
		dispatch_async(backgroundQueue) {
			if NSFileManager.defaultManager().fileExistsAtPath(self.imageCachePath()) {
				let image = UIImage(contentsOfFile: self.imageCachePath())
				NSOperationQueue.mainQueue().addOperationWithBlock {
					completion(photo: image)
				}
			} else {
				let fetchOperation = CKFetchRecordsOperation(recordIDs: [self.record.recordID])
				fetchOperation.desiredKeys = ["CoverPhoto"]
				fetchOperation.fetchRecordsCompletionBlock = { records, error in
					self.processAsset(records, error: error, completion: completion)
				}
				
				self.database.addOperation(fetchOperation)
			}
		}
	}
	
	//MARK: - map annotation
	
	var coordinate : CLLocationCoordinate2D {
		get {
			return location.coordinate
		}
	}
	var title : String! {
		get {
			return name
		}
	}
	
}

//Mark: Equatable

func == (lhs: Establishment, rhs: Establishment) -> Bool {
	return lhs.record.recordID == rhs.record.recordID
}
