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


protocol ModelDelegate {
  func errorUpdating(error: NSError)
  
  func modelUpdatesWillBegin()
  func modelUpdatesDone()
  func recordAdded(indexPath:NSIndexPath!)
  func recordUpdated(indexPath:NSIndexPath!)
}

@objc class Model {
  
  class func sharedInstance() -> Model {
    return modelSingletonGlobal
  }
  
  var delegate : ModelDelegate!
  
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
  
  //MARK: - Batch Loading
  
  
  func establishment(ref: CKReference) -> Establishment! {
    let matching = items.filter {$0.record.recordID == ref.recordID}
    var e : Establishment!
    if matching.count > 0 {
      e = items[0]
    }
    return e
  }
  
  func fetchEstablishments(location:CLLocation, radiusInMeters:CLLocationDistance) {
    let locationPredicate = createLocationPredicate(location, radiusInMeters: radiusInMeters)
    let query = CKQuery(recordType: "Establishment",
                        predicate:  locationPredicate) //3
    publicDB.performQuery(query, inZoneWithID: nil) { //4
      results, error in
      if error != nil {
        dispatch_async(dispatch_get_main_queue()) {
          self.delegate?.errorUpdating(error)
          println("error loading: \(error)")
        }
      } else {
        self.items.removeAll(keepCapacity: true)
        for record in results{
          let establishment = Establishment(record: record as! CKRecord, database:self.publicDB)
          self.items.append(establishment)
        }
        dispatch_async(dispatch_get_main_queue()) {
          //TODO  self.delegate?.modelUpdated()
          println("model updated")
        }
      }
    }
  }
  
  func fetchEstablishments(location:      CLLocation,
                           radiusInMeters:CLLocationDistance,
                           completion:    (results:[Establishment]!, error:NSError!) -> ()) {

      let locationPredicate = createLocationPredicate(location, radiusInMeters: radiusInMeters)
      let query = CKQuery(recordType: "Establishment", predicate: locationPredicate) //3
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
  
  func createLocationPredicate(location: CLLocation, radiusInMeters:CLLocationDistance) -> NSPredicate {
    let radiusInKilometers = radiusInMeters / 1000.0

    return NSPredicate(format: "distanceToLocation:fromLocation:(%K,%@) < %f",
      "Location",
      location,
      radiusInKilometers)
  }
  
  //MARK: - Streaming Results
  
  func establishmentForRecord(record:CKRecord) -> (establishment: Establishment, isNew:Bool) {
    let matches = items.filter { $0.record == record }
    if matches.count > 0 {
      return (matches[0], false)
    }
    let e = Establishment(record: record, database: publicDB)
    items.append(e)
    return (e, true)
  }
  
  //MARK: - Notes
  
  func fetchNotes( completion : (notes : NSArray!, error : NSError!) -> () ) {
    let query = CKQuery(recordType: "Note", predicate: NSPredicate(value: true))
    privateDB.performQuery(query, inZoneWithID: nil) { results, error in
      completion(notes: results, error: error)
    }
  }
  
  
  func fetchNote(establishment: Establishment,
                 completion:(note: String!, error: NSError!) ->()) {
    let predicate = NSPredicate(format: "Establishment == %@", establishment.record) //1
    let query = CKQuery(recordType: "Note", predicate: predicate)
    privateDB.performQuery(query, inZoneWithID: nil) { //2
      results, error in
      var note: String!
      if results.count > 0 {
        note = results[0].objectForKey("Note") as! String //3
      }
      completion(note: note, error: error)
    }
  }
  
  func addNote(note: String,
               establishment: Establishment!,
               completion: (error : NSError!)->()) {
    if establishment == nil {
      return
    }
    
    let noteRecord = CKRecord(recordType: "Note") //1
    noteRecord.setObject(note, forKey: "Note")
    
    let ref = CKReference(record: establishment.record,
                          action: .DeleteSelf) //2
    noteRecord.setObject(ref, forKey: "Establishment")
    
    privateDB.saveRecord(noteRecord) { record, error in //3
      dispatch_async(dispatch_get_main_queue()) {
        completion(error: error)
      }
    }
  }
}

let modelSingletonGlobal = Model()
