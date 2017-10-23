//
//  UIViewController.swift
//  Wishlist
//
//  Created by Alex Tavella on 08/10/17.
//  Copyright © 2017 Alex Tavella. All rights reserved.
//

import CoreData
import UIKit

extension UIViewController {
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
    }
}
