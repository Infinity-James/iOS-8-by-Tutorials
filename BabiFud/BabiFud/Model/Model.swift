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
import CoreLocation

//	MARK: Global Constants

let EstablishmentType = "Establishment"
let NoteType = "Note"

//	MARK: Model Delegate Protocol

protocol ModelDelegate {
	func errorUpdating(error: NSError)
	func modelUpdated()
}

//	MARK: Model Class

@objc class Model {
	
	
	class func sharedInstance() -> Model {
		return modelSingletonGlobal
	}
	
	var delegate : ModelDelegate?
	
	var items = [Establishment]()
	let userInfo : UserInfo
	
	let container : CKContainer
	let publicDB : CKDatabase
	let privateDB : CKDatabase
	
	init() {
		container = CKContainer.defaultContainer() //1
		publicDB = container.publicCloudDatabase //2
		privateDB = container.privateCloudDatabase //3
		
		userInfo = UserInfo(container: container)
	}
	
	func refresh() {
		let predicate = NSPredicate(value: true)
		let query = CKQuery(recordType: "Establishment", predicate: predicate)
		publicDB.performQuery(query, inZoneWithID: nil) { results, error in
			if error != nil {
				dispatch_async(dispatch_get_main_queue()) {
					self.delegate?.errorUpdating(error)
					println("error loading: \(error)")
				}
			} else {
				self.items.removeAll(keepCapacity: true)
				for record in results {
					let establishment = Establishment(record: record as! CKRecord, database:self.publicDB)
					self.items.append(establishment)
				}
				dispatch_async(dispatch_get_main_queue()) {
					self.delegate?.modelUpdated()
					println()
				}
			}
		}
	}
	
	func establishment(ref: CKReference) -> Establishment! {
		let matching = items.filter {$0.record.recordID == ref.recordID}
		var e : Establishment!
		if matching.count > 0 {
			e = matching[0]
		}
		return e
	}
	
	func fetchEstablishments(location:CLLocation, radiusInMeters:CLLocationDistance) {
		//	create a query that finds establishments within the given radius of the location
		let radiusInKilometers = radiusInMeters / 1000.0
		let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(%K,%@) < %f", "Location", location, radiusInKilometers)
		let query = CKQuery(recordType: EstablishmentType, predicate: locationPredicate)
		
		//	execute query, storing results if there are any, and reporting error otherwise
		publicDB.performQuery(query, inZoneWithID: nil) { results, error in
			if error != nil {
				NSOperationQueue.mainQueue().addOperationWithBlock {
					self.delegate?.errorUpdating(error)
				}
			} else {
				self.items.removeAll(keepCapacity: true)
				for record in results as! [CKRecord] {
					let establishment = Establishment(record: record, database: self.publicDB)
					self.items.append(establishment)
				}
				NSOperationQueue.mainQueue().addOperationWithBlock {
					self.delegate?.modelUpdated()
				}
			}
		}
	}
	
	func fetchEstablishments(location:      CLLocation,
		radiusInMeters:CLLocationDistance,
		completion:    (results:[Establishment]!, error:NSError!) -> ()) {
			let radiusInKilometers = radiusInMeters / 1000.0 //1
			//Apple Campus location = 37.33182, -122.03118
			var location = CLLocation(latitude: 37.33182, longitude: -122.03118)
			
			let locationPredicate = NSPredicate(format: "distanceToLocation:fromLocation:(%K,%@) < %f",
				"Location",
				location,
				radiusInKilometers) //2
			let query = CKQuery(recordType: EstablishmentType,
				predicate:  locationPredicate) //3
			publicDB.performQuery(query, inZoneWithID: nil) { //4
				results, error in
				var res = [Establishment]()
				if let records = results {
					for record in records {
						let establishment = Establishment(record: record as! CKRecord, database:self.publicDB)
						res.append(establishment)
					}
				}
				
				dispatch_async(dispatch_get_main_queue()) {
					completion(results: res, error: error)
				}
			}
	}
	
	// #pragma mark - Notes
	
	func fetchNotes( completion : (notes : NSArray!, error : NSError!) -> () ) {
		let query = CKQuery(recordType: NoteType, predicate: NSPredicate(value: true))
		privateDB.performQuery(query, inZoneWithID: nil) { results, error in
			completion(notes: results, error: error)
		}
	}
	
	func fetchNote(establishment: Establishment, completion:(note: String!, error: NSError!) ->()) {
		let predicate = NSPredicate(format: "Establishment == %@", establishment.record)
		let query = CKQuery(recordType: "Note", predicate: predicate)
		
		privateDB.performQuery(query, inZoneWithID: nil) { results, error in
			let note = results.first?.objectForKey("Note") as? String
			completion(note: note, error: error)
		}
	}
	
	func addNote(note: String, establishment: Establishment!, completion: (error : NSError!)->()) {
		if establishment == nil {
			return
		}
		
		//	create the note record
		let noteRecord = CKRecord(recordType: "Note")
		noteRecord.setObject(note, forKey: "Note")
		let establishmentReference = CKReference(record: establishment.record, action: .DeleteSelf)
		noteRecord.setObject(establishmentReference, forKey: "Establishment")
		
		//	save the note to the user's private db
		privateDB.saveRecord(noteRecord) { record, error in
			NSOperationQueue.mainQueue().addOperationWithBlock {
				completion(error: error)
			}
		}
	}
}

let modelSingletonGlobal = Model()