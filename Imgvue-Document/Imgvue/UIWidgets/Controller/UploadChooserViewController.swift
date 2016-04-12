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

import UIKit
import MobileCoreServices
import S3Kit

public class UploadChooserViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIDocumentMenuDelegate, UIDocumentPickerDelegate {
  
  @IBOutlet var uploadProgressView: UIProgressView?
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    resetUIState()
  }
  
  func resetUIState() {
    uploadProgressView?.progress = 0.0
    uploadProgressView?.hidden = true
  }
  
  @IBAction func selectImageToUpload(sender: AnyObject) {
    let types = [kUTTypeImage]
    let docMenu = UIDocumentMenuViewController(documentTypes: types, inMode: .Import)
    docMenu.delegate = self
    docMenu.modalPresentationStyle = .Popover;
    
    docMenu.addOptionWithTitle("Saved Photo", image: nil, order: .First) {
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.sourceType = .SavedPhotosAlbum
      self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    if let presentationController = docMenu.popoverPresentationController {
      presentationController.sourceView = self.view;
      presentationController.permittedArrowDirections = .Any
      presentationController.sourceRect = sender.frame
    }
    
    self.presentViewController(docMenu, animated: true, completion: nil)
  }
  
  //MARK: - Doc Menu Delegate
  
  public func documentMenu(documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
    documentPicker.delegate = self;
    presentViewController(documentPicker, animated: true, completion: nil)
  }
  
  //MARK: - Doc Picker Delegate
  
  public func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
    let coordinator = NSFileCoordinator()
    coordinator.coordinateReadingItemAtURL(url, options:.ForUploading, error: nil) { newURL in
      if let fileData = NSData(contentsOfURL: newURL) {
        let bucketInfo = BucketInfo()
        let filename = newURL.lastPathComponent!
        bucketInfo.uploadData(fileData, name: filename) { error in
          if error != nil {
            println("error uploading \(error)")
          }
        }
      }
    }
  }
  
  //MARK: - Image Picker Delegate
  
  public func imagePickerController(picker: UIImagePickerController,
  didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    dismissViewControllerAnimated(true, completion: nil)
    if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
      let bucketInfo = BucketInfo()
      let name = NSUUID().UUIDString
      bucketInfo.uploadImage(selectedImage, name: name) {
        imageObj, error in
        println("Image done uploading. Error? \(error)")
      }
    }
  }
}
