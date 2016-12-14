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
    
    func loadPhotoCoreDataForPin(pin: Pin, context: NSManagedObjectContext, replacementNumber: Int?, completionHandlerForLoadPhotoCoreDataForPin: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        let pinBbox = FlickrClient.sharedInstance.bboxString(latitude: pin.latitude, longitude: pin.longitude)
        
        flickrImageArrayLocationPopulate(latitude: pin.latitude, longitude: pin.longitude){(results, error) in
            
            func sendError(errorPhotos: String) {
                let userInfo = [NSLocalizedDescriptionKey : errorPhotos]
                completionHandlerForLoadPhotoCoreDataForPin(false, NSError(domain: "LoadPhotoCoreDataForPin", code: 1, userInfo: userInfo))
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
                
            var topIndex = min((photosArray.count - 1), 29)
            if let numberToReplace = replacementNumber {
                topIndex = min((numberToReplace - 1), topIndex)
            }
            
            for index in 0...topIndex {
                        
                let photoDictionary = photosArray[index]
                let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
                        
                guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                    continue
                }
                
                guard let data = NSData(contentsOf: URL(string: imageUrlString)!) else {
                    continue
                }
                
                let collectionPhoto = CollectionPhoto(name: photoTitle!, locationStringBbox: pinBbox, urlString: imageUrlString, context: context, data: data)
                        collectionPhoto.ownerPin = pin
                
            }
            
            do {
                try context.save()
            } catch {
                fatalError("Error while saving main context: \(error)")
            }
            completionHandlerForLoadPhotoCoreDataForPin(true, nil)
        }
    }
}
