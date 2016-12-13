//
//  Constants.swift
//  Virtual Tourist
//
//  Created by Dr GJK Marais on 2016/12/04.
//  Copyright © 2016 RuanMarais. All rights reserved.
//

import Foundation

struct Constants {
    
    struct AppFunctionality {
        static let AutosaveInterval = 60
    }
    
    struct ErrorMessages {
        static let emptyArray = "PhotoArray Empty"
        static let flickrError = "Status response not OK"
    }
    
    struct AlertMessages {
        static let networkError = "There was a network error"
        static let retryNetwork = "Please check your internet connection and retry"
        static let noPhotosAtPin = "There are no photos at this location"
        static let APIError = "There was a problem getting photos"
        static let continuePinPlacementIfNoPhotos = "Continue placing pin without photos?"
        static let accept = "Continue"
        static let cancel = "Cancel"
        static let OK = "OK"
    }
    
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
    }
    
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "e7018f487fcc5eaca3171678cddd460a"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" 
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
    }
    
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }
    
}
