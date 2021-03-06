//
//  FlickrImageRetrieve.swift
//  Virtual Tourist
//
//  Created by Dr GJK Marais on 2016/12/04.
//  Copyright © 2016 RuanMarais. All rights reserved.
//

import Foundation
import CoreData
import UIKit

extension FlickrClient {
    
    func flickrMethodParameterOptimisation(latitude: Double?, longitude: Double?, completionHandlerForMethodParameterOptimisation: @escaping (_ parameters: [String: AnyObject]?, _ error: NSError?) -> Void) {
        
        func sendError(errorPhotos: String) {
            let userInfo = [NSLocalizedDescriptionKey : errorPhotos]
            completionHandlerForMethodParameterOptimisation(nil, NSError(domain: "flickrMethodParameterOptimisation", code: 1, userInfo: userInfo))
        }

        var methodParameters = self.methodBaseParameters
        
        guard let latitude = latitude else {
            sendError(errorPhotos: "Couldnt retrieve location")
            return
        }
        guard let longitude = longitude else {
            sendError(errorPhotos: "Couldnt retrieve location")
            return
        }
        
        let bBox = self.bboxString(latitude: latitude, longitude: longitude)
        methodParameters[Constants.FlickrParameterKeys.BoundingBox] = bBox as AnyObject?
        
        taskForGETMethod(parameters: methodParameters) {(results, error) in
            
            guard (error == nil) else {
                sendError(errorPhotos: error?.userInfo[NSLocalizedDescriptionKey] as! String)
                return
            }
            
            guard let stat = results?[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                sendError(errorPhotos: "Status response not OK")
                return
            }
            
            guard let photosDictionary = results?[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                sendError(errorPhotos: "No Photos Dictionary retrieved")
                return
            }
            
            guard let totalPages = photosDictionary[Constants.FlickrResponseKeys.Pages] as? Int else {
                sendError(errorPhotos: "Cannot find key '\(Constants.FlickrResponseKeys.Pages)' in \(photosDictionary)")
                return
            }
            
            // pick a random page!
            let pageLimit = min(totalPages, 40)
            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
            methodParameters[Constants.FlickrParameterKeys.Page] = randomPage as AnyObject
            completionHandlerForMethodParameterOptimisation(methodParameters, nil)
        }
    }


    func flickrImageArrayLocationPopulate(latitude: Double?, longitude: Double?, completionHandlerForArray: @escaping (_ photoArray: [[String: AnyObject]]?, _ error: NSError?) -> Void) {
        
        func sendError(errorPhotos: String) {
            let userInfo = [NSLocalizedDescriptionKey : errorPhotos]
            completionHandlerForArray(nil, NSError(domain: "flickrImageArrayLocationPopulate", code: 1, userInfo: userInfo))
        }

        self.flickrMethodParameterOptimisation(latitude: latitude, longitude: longitude){(parameters, error) in
            
            guard (error == nil) else {
                sendError(errorPhotos: error?.userInfo[NSLocalizedDescriptionKey] as! String)
                return
            }

            FlickrClient.sharedInstance.taskForGETMethod(parameters: parameters!){(results, error) in
                
                guard (error == nil) else {
                    sendError(errorPhotos: error?.userInfo[NSLocalizedDescriptionKey] as! String)
                    return
                }

                guard let stat = results?[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                    sendError(errorPhotos: "Status code not OK")
                    return
                }
                
                guard let photosDictionary = results?[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                    sendError(errorPhotos: "Could not retrieve photos dictionary")
                    return
                }
                
                guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                    sendError(errorPhotos: "Could not retrieve photos array")
                    return
                }
                
                guard (photosArray.count != 0) else {
                    sendError(errorPhotos: "PhotoArray Empty")
                    return
                }
                
                completionHandlerForArray(photosArray, nil)
                
            }
        }
    }
    
    func loadPhotoCoreDataForPin(pin: Pin, context: NSManagedObjectContext, replacementNumber: Int?, completionHandlerForLoadPhotoCoreDataForPin: @escaping (_ success: Bool, _ pinPhotos: [[String: AnyObject?]]?, _ error: NSError?) -> Void) {
        
        let pinBbox = FlickrClient.sharedInstance.bboxString(latitude: pin.latitude, longitude: pin.longitude)
        
        flickrImageArrayLocationPopulate(latitude: pin.latitude, longitude: pin.longitude){(results, error) in
            
            func sendError(errorPhotos: String) {
                let userInfo = [NSLocalizedDescriptionKey : errorPhotos]
                completionHandlerForLoadPhotoCoreDataForPin(false, nil, NSError(domain: "LoadPhotoCoreDataForPin", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(errorPhotos: error?.userInfo[NSLocalizedDescriptionKey] as! String)
                return
            }
            
            guard let photosArray = results else {
                sendError(errorPhotos: "Could not unwrap photosArray optional")
                return
            }
            
            guard (photosArray.count != 0) else {
                sendError(errorPhotos: "PhotoArray Empty")
                return
            }
            
            var collectionPhotoArray = [[String: AnyObject?]]()
            var topIndex = min((photosArray.count), 30)
            if let numberToReplace = replacementNumber {
                topIndex = min((numberToReplace), topIndex)
            }
            topIndex -= 1
            
            for index in 0...topIndex {
                
                var collectionPhotoDictionary = [String: AnyObject?]()
                let photoDictionary = photosArray[index]
                let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
                
                guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                    continue
                }
                
                collectionPhotoDictionary["name"] = photoTitle as AnyObject?
                collectionPhotoDictionary["locationStringBbox"] = pinBbox as AnyObject?
                collectionPhotoDictionary["urlString"] = imageUrlString as AnyObject?
                collectionPhotoArray.append(collectionPhotoDictionary)
            }
            
            completionHandlerForLoadPhotoCoreDataForPin(true, collectionPhotoArray, nil)
        }
    }
    
    
    func loadPhotoCoreDataSingle(pin: Pin, completionHandlerForLoadPhotoCoreDataSingle: @escaping (_ success: Bool, _ pinPhotos: [String: AnyObject?]?, _ error: NSError?) -> Void) {
        
        let pinBbox = FlickrClient.sharedInstance.bboxString(latitude: pin.latitude, longitude: pin.longitude)
        
        flickrImageArrayLocationPopulate(latitude: pin.latitude, longitude: pin.longitude){(results, error) in
            
            func sendError(errorPhotos: String) {
                let userInfo = [NSLocalizedDescriptionKey : errorPhotos]
                completionHandlerForLoadPhotoCoreDataSingle(false, nil, NSError(domain: "LoadPhotoCoreDataSingle", code: 1, userInfo: userInfo))
            }
            
            guard (error == nil) else {
                sendError(errorPhotos: error?.userInfo[NSLocalizedDescriptionKey] as! String)
                return
            }
            
            guard let photosArray = results else {
                sendError(errorPhotos: "Could not unwrap photosArray optional")
                return
            }
            
            guard (photosArray.count != 0) else {
                sendError(errorPhotos: "PhotoArray Empty")
                return
            }
            
            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
            let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
            var collectionPhotoDictionary = [String: AnyObject?]()
            let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
            
            guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                sendError(errorPhotos: "no URL for Photo")
                return
            }
                
            collectionPhotoDictionary["name"] = photoTitle as AnyObject?
            collectionPhotoDictionary["locationStringBbox"] = pinBbox as AnyObject?
            collectionPhotoDictionary["urlString"] = imageUrlString as AnyObject?
                
            completionHandlerForLoadPhotoCoreDataSingle(true, collectionPhotoDictionary, nil)
        }
    }
}
