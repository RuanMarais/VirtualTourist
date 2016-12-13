//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Dr GJK Marais on 2016/12/03.
//  Copyright © 2016 RuanMarais. All rights reserved.
//

import UIKit
import CoreData
import MapKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Virtual_Tourist")!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        stack.autoSave(Constants.AppFunctionality.AutosaveInterval)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        stack.save()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        stack.save()
    }

}

