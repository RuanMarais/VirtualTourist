//
//  FlickrImageRetrieve.swift
//  Virtual Tourist
//
//  Created by Dr GJK Marais on 2016/12/04.
//  Copyright © 2016 RuanMarais. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func flickrImageArrayLocationPopulate(pageNumber: Int, latitude: Double?, longitude: Double?, completionHandlerForArray: @escaping (_ photoArray: [[String: AnyObject]]?, _ error: NSError?) -> Void) {
        
        let bbox = self.bboxString(latitude: latitude, longitude: longitude)
        let pageNumber = pageNumber
        
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod as AnyObject,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey as AnyObject,
            Constants.FlickrParameterKeys.BoundingBox: bbox as AnyObject,
            Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch as AnyObject,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL as AnyObject,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat as AnyObject,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback as AnyObject,
            Constants.FlickrParameterKeys.Page: pageNumber as AnyObject
        ] as [String : AnyObject]

        taskForGETMethod(parameters: methodParameters){(results, error) in
        
            guard let stat = results?[Constants.FlickrResponseKeys.Status] as? String, stat == Constants.FlickrResponseValues.OKStatus else {
                completionHandlerForArray(nil, error)
                return
            }
            
            
            guard let photosDictionary = results?[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                completionHandlerForArray(nil, error)
                return
            }
            
            
            guard let photosArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String: AnyObject]] else {
                completionHandlerForArray(nil, error)
                return
            }
            
            if photosArray.count == 0 {
                completionHandlerForArray(nil, error)
                return
            } else {
                
            completionHandlerForArray(photosArray, nil)
            }
        }
    }
    
    func LoadPhotoCoreDataForPin(pageNumber: Int, pin: Pin, completionHandlerForLoadPhotoCoreDataForPin: @escaping (_ success: Bool, _ error: NSError?) -> Void) {
        
        let pinBbox = FlickrClient.sharedInstance.bboxString(latitude: pin.latitude, longitude: pin.longitude)
        
        flickrImageArrayLocationPopulate(pageNumber: pageNumber, latitude: pin.latitude, longitude: pin.longitude){(results, error) in
            
            func sendError(errorPhotos: String) {
                let userInfo = [NSLocalizedDescriptionKey : errorPhotos]
                completionHandlerForLoadPhotoCoreDataForPin(false, NSError(domain: "LoadPhotoCoreData", code: 1, userInfo: userInfo))
            }

            guard (error == nil) else {
                completionHandlerForLoadPhotoCoreDataForPin(false, error)
                return
            }
            
            guard let photosArray = results else {
                completionHandlerForLoadPhotoCoreDataForPin(false, error)
                return
            }
            
            if photosArray.count == 0 {
                sendError(errorPhotos: "no Photos found")
                return
            } else {
                
                    for index in 0...40 {
                        
                        let photoDictionary = photosArray[index]
                        let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String
                        
                        guard let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String else {
                            continue
                        }
                        
                        let collectionPhoto = CollectionPhoto(name: photoTitle!, locationStringBbox: pinBbox, urlString: imageUrlString, context: self.stack.context)
                        collectionPhoto.ownerPin = pin
                        
                    }

                completionHandlerForLoadPhotoCoreDataForPin(true, nil)
                
            }

        }
    }
}
