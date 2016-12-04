//
//  GCD.swift
//  Virtual Tourist
//
//  Created by Dr GJK Marais on 2016/12/04.
//  Copyright © 2016 RuanMarais. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(updates: @escaping () -> Void) {
    DispatchQueue.main.async(execute: updates)
}
