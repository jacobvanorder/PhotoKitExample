//
//  ViewController.swift
//  PhotoKitExample
//
//  Created by mrJacob on 6/30/14.
//  Copyright (c) 2014 Vokal Interactive. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
                            
    @IBOutlet var mainCollectionView: UICollectionView
    
    let collectionViewCellIdentifier : String = "Cell"
    
    var currentPhotoFetch : PHFetchResult
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    init(coder aDecoder: NSCoder!) {
        currentPhotoFetch = PHAsset.fetchAssetsWithOptions(nil)
        super.init(coder: aDecoder)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // #pragma mark UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView?) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView?, numberOfItemsInSection section: Int) -> Int {
        return currentPhotoFetch.count
    }
    
    func collectionView(collectionView: UICollectionView?, cellForItemAtIndexPath indexPath: NSIndexPath?) -> UICollectionViewCell? {
        let cell = collectionView?.dequeueReusableCellWithReuseIdentifier(collectionViewCellIdentifier, forIndexPath: indexPath) as PhotoCollectionViewCell
        
        self.fetchImageAtIndex(indexPath!, withSize: cell.cellSize, completionHandler: {(returnImage: UIImage!, info: NSDictionary!) in
            cell.mainImageView.image = returnImage
            })
        
        let cellAsset = currentPhotoFetch.objectAtIndex(indexPath!.row) as? PHAsset
        if let checkedCellAsset = cellAsset {
            PHImageManager.defaultManager().requestImageForAsset(checkedCellAsset, targetSize: cell.cellSize, contentMode: .AspectFill, options: nil, resultHandler: {(image: UIImage!, info: NSDictionary!) -> Void in
                cell.mainImageView.image = image
                }
            )
        }
    
        return cell
    }
    
    func fetchImageAtIndex(index: NSIndexPath, withSize size: CGSize, completionHandler:(returnImage: UIImage!, info: NSDictionary!) -> Void) {
        let asset = self.currentPhotoFetch.objectAtIndex(index.row) as? PHAsset
        if let checkedAsset = asset {
            PHImageManager.defaultManager().requestImageForAsset(checkedAsset, targetSize: size, contentMode: .AspectFill, options: nil, resultHandler: completionHandler)
        }
    }
    
    func replaceImageAtIndexPath(indexPath: NSIndexPath, withImage image: UIImage) {
        let asset = self.currentPhotoFetch.objectAtIndex(indexPath.row) as? PHAsset
        if let checkedAsset = asset {
            //Call the asset’s requestContentEditingInputWithOptions:completionHandler: method. The PHContentEditingInputRequestOptions object you provide for the options parameter controls whether your app can handle the asset’s adjustment data.
            checkedAsset.requestContentEditingInputWithOptions(nil, completionHandler:{(input: PHContentEditingInput!, info: NSDictionary!) in
                //Photos calls your completionHandler block, providing a PHContentEditingInput object you can use for retrieving the image or video data to be edited.
                //Apply your edits to the asset. To allow a user to continue working with your edits later, create a PHAdjustmentData object describing the changes.
                let output = PHContentEditingOutput(contentEditingInput: input)
                //Initialize a PHContentEditingOutput object and use its properties to provide the edited asset and adjustment data.

                let outputData = UIImagePNGRepresentation(image)
                let derpString = "derp!" as NSString
                let adjustmentData = PHAdjustmentData(formatIdentifier: "Derp", formatVersion: "1.0", data: derpString.dataUsingEncoding(NSUTF8StringEncoding))

                outputData.writeToURL(output.renderedContentURL, atomically: true)
                output.adjustmentData = adjustmentData
                //Commit your edits to the photo library by posting a change block to the shared PHPhotoLibrary object. In the block, create a PHAssetChangeRequest object and set its contentEditingOutput property to the editing output you created.
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    var assetRequest = PHAssetChangeRequest(forAsset: asset)
                    assetRequest.contentEditingOutput = output
                    }, completionHandler:{(completion: Bool, error :NSError!) in
                        println(completion)
                        println(error)
                        dispatch_async(dispatch_get_main_queue(), {
                            self.currentPhotoFetch = PHAsset.fetchAssetsWithOptions(nil)
                            self.mainCollectionView.reloadData()
                            })
                    })
                })
        }
        
//        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
//            // Create a change request from the asset to be modified.
//            PHAssetChangeRequest *request = [PHAssetChangeRequest changeRequestForAsset:asset]
        }
    
    // pragma mark <UICollectionViewDelegate>
    
    func collectionView(collectionView: UICollectionView!, didSelectItemAtIndexPath indexPath: NSIndexPath!) {
        self.fetchImageAtIndex(indexPath, withSize: PHImageManagerMaximumSize, completionHandler:{(assetImage: UIImage!, info: NSDictionary!) in
            let shareSheet = UIActivityViewController(activityItems: [assetImage], applicationActivities: nil)
            shareSheet.completionWithItemsHandler = {(activityType :String!, completed :Bool, returnedItems :AnyObject[]!, error :NSError!) -> Void in
                if completed {
                    var extensionItem = returnedItems[0] as NSExtensionItem
                    var itemProvider = extensionItem.attachments[0] as NSItemProvider
                    if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage) {
                        itemProvider.loadItemForTypeIdentifier(kUTTypeImage, options: nil, completionHandler:{(image, error) in
                            if let checkedImage = image {
                                self.replaceImageAtIndexPath(indexPath, withImage: checkedImage as UIImage)
                            }
                        })
                    }
                }
            }
            self.presentViewController(shareSheet, animated: true, completion: nil)
        })
    }
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    func collectionView(collectionView: UICollectionView?, shouldHighlightItemAtIndexPath indexPath: NSIndexPath?) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    func collectionView(collectionView: UICollectionView?, shouldSelectItemAtIndexPath indexPath: NSIndexPath?) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    func collectionView(collectionView: UICollectionView?, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath?) -> Bool {
    return false
    }
    
    func collectionView(collectionView: UICollectionView?, canPerformAction action: String?, forItemAtIndexPath indexPath: NSIndexPath?, withSender sender: AnyObject) -> Bool {
    return false
    }
    
    func collectionView(collectionView: UICollectionView?, performAction action: String?, forItemAtIndexPath indexPath: NSIndexPath?, withSender sender: AnyObject) {
    
    }
    */


}

