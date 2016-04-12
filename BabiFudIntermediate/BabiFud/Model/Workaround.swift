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
import UIKit
import CloudKit
import CoreLocation

func upload(db: CKDatabase,
  imageName: String,
  placeName: String,
  latitude:  CLLocationDegrees,
  longitude: CLLocationDegrees,
  changingTable : ChangingTableLocation,
  seatType:  SeatingType,
  healthy: Bool,
  kidsMenu: Bool,
  ratings: [UInt]) {
    let imURL = NSBundle.mainBundle().URLForResource(imageName, withExtension: "jpeg")
    let coverPhoto = CKAsset(fileURL: imURL)
    let location = CLLocation(latitude: latitude, longitude: longitude)
    
    let establishment = CKRecord(recordType: "Establishment")
    establishment.setObject(coverPhoto, forKey: "CoverPhoto")
    establishment.setObject(placeName, forKey: "Name")
    establishment.setObject(location, forKey: "Location")
    establishment.setObject(changingTable.toRaw(), forKey: "ChangingTable")
    establishment.setObject(changingTable.toRaw(), forKey: "SeatingType")
    establishment.setObject(healthy, forKey: "HealthyOption")
    establishment.setObject(kidsMenu, forKey: "KidsMenu")
    
    
    db.saveRecord(establishment) { record, error in
      if error != nil {
        println("error setting up record \(error)")
        return
      }
      println("saved: \(record)")
      for rating in ratings {
        let ratingRecord = CKRecord(recordType: "Rating")
        ratingRecord.setObject(rating, forKey: "Rating")
        
        let ref = CKReference(record: record, action: CKReferenceAction.DeleteSelf)
        ratingRecord.setObject(ref, forKey: "Establishment")
        db.saveRecord(ratingRecord) { record, error in
          if error != nil {
            println("error setting up record \(error)")
            return
          }
        }
      }
      
    }
}

func uploadSampleData() {
  let container = CKContainer.defaultContainer()
  let db = container.publicCloudDatabase
  
  //Apple Campus location = 37.33182, -122.03118
  upload(db, "pizza", "Caesar's Pizza Palace", 37.332, -122.03, ChangingTableLocation.Womens, SeatingType.HighChair | SeatingType.Booster, false, true, [0, 1, 2])
  upload(db, "chinese", "King Wok", 37.1, -122.1, ChangingTableLocation.None, SeatingType.HighChair, true, false, [])
  upload(db, "steak", "The Back Deck", 37.4, -122.03, ChangingTableLocation.Womens | ChangingTableLocation.Mens, SeatingType.HighChair | SeatingType.Booster, true, true, [5, 5, 4])
  upload(db, "burgers", "Five Guys", 37.335, -122.028, ChangingTableLocation.Family, SeatingType.HighChair, false, true, [5, 5, 5, 5, 4, 2, 1, 1])
  upload(db, "falafel", "Falafel King", 37.310, -122.03, ChangingTableLocation.None, SeatingType.None, true, false, [3, 3, 4])
  upload(db, "coffee", "Common Coffee", 37.26, -122.038, ChangingTableLocation.Mens, SeatingType.Booster, true, false, [5, 4, 2])
  upload(db, "vietnamese", "Sapa", 37.6, -122.026, ChangingTableLocation.None, SeatingType.Booster | SeatingType.HighChair, true, true, [])
  upload(db, "italian", "Lolas", 37.0, -121.9, ChangingTableLocation.Womens, SeatingType.HighChair | SeatingType.Booster, false, false, [3, 3, 5, 1])
}
