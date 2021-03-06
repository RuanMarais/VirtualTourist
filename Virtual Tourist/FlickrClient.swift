//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Dr GJK Marais on 2016/12/04.
//  Copyright © 2016 RuanMarais. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class FlickrClient {
    
    // MARK: Properties 
    
    static let sharedInstance = FlickrClient()
    let session = URLSession.shared
    var appDelegate: AppDelegate!
    var stack: CoreDataStack!
    
    let methodBaseParameters = [
        Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod as AnyObject,
        Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey as AnyObject,
        Constants.FlickrParameterKeys.SafeSearch: Constants.FlickrParameterValues.UseSafeSearch as AnyObject,
        Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL as AnyObject,
        Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat as AnyObject,
        Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback as AnyObject
        ] as [String : AnyObject]
    
    // MARK: class initialiser
    
    init() {
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        stack = appDelegate.stack
    }
    
    func taskForGETMethod(parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        // Base parameter dictionary
        var parameters = parameters
        let session = self.session
        
        // request from URL
        let request = NSMutableURLRequest(url: flickrURLFromParameters(parameters: parameters))
        
        // request made
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(error: String) {
                
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            // request error
            guard (error == nil) else {
                sendError(error: "Request Error: \(error)")
                return
            }
            
            // response code error
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(error: "Status code not 2xx")
                return
            }
            
            // no data returned error
            guard let data = data else {
                sendError(error: "No data was returned")
                return
            }
            
            // parse the data
            self.convertDataWithCompletionHandler(data: data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        //start request
        task.resume()
        
    }
    
    func bboxString(latitude: Double?, longitude: Double?) -> String {
        // ensure bbox is bounded by minimum and maximums
        if let latitude = latitude, let longitude = longitude {
            let minimumLon = max(longitude - Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.0)
            let minimumLat = max(latitude - Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.0)
            let maximumLon = min(longitude + Constants.Flickr.SearchBBoxHalfWidth, Constants.Flickr.SearchLonRange.1)
            let maximumLat = min(latitude + Constants.Flickr.SearchBBoxHalfHeight, Constants.Flickr.SearchLatRange.1)
            return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
        } else {
            return "0,0,0,0"
        }
    }
    
    private func flickrURLFromParameters(parameters: [String:AnyObject]) -> URL {
        
        let components = NSURLComponents()
        components.scheme = Constants.Flickr.APIScheme
        components.host = Constants.Flickr.APIHost
        components.path = Constants.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    private func convertDataWithCompletionHandler(data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult as AnyObject!, nil)
    }
    
}

extension FlickrClient {
    func performUIUpdatesOnMain(updates: @escaping () -> Void) {
        DispatchQueue.main.async(execute: updates)
    }
    
    func performDataUpdatesOnBackground(updates: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async(execute: updates)
    }
}
