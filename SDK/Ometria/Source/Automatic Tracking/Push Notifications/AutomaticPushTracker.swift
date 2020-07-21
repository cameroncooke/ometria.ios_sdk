//
//  PushNotificationTracker.swift
//  Ometria
//
//  Created by Cata on 7/17/20.
//  Copyright © 2020 Cata. All rights reserved.
//

import Foundation
import UIKit

open class AutomaticPushTracker {
    open var isRunning: Bool = false
    
    open func startTracking() {
        guard !isRunning else {
            return
        }
        
        isRunning = true
        swizzleDidRegisterForRemoteNotificationsWithDeviceToken()
        swizzleDidFailToRegisterForRemoteNotificationsWithError()
        swizzleDidReceiveRemoteNotification()
    }
    
    open func stopTracking() {
        guard isRunning else {
            return
        }
        
        isRunning = false
    }
    
    private func swizzleDidRegisterForRemoteNotificationsWithDeviceToken() {
        let newSelector = #selector(UIResponder.om_application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        let originalSelector = #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        
        Swizzler.swizzleSelector(originalSelector,
                                 withSelector: newSelector,
                                 for: delegateClass,
                                 name: "OmetriaRegisterForRemoteNotifications") { (_, _, _, _) in
        }
    }
    
    private func swizzleDidFailToRegisterForRemoteNotificationsWithError() {
        let newSelector = #selector(UIResponder.om_application(_:didFailToRegisterForRemoteNotificationsWithError:))
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        let originalSelector = #selector(UIApplicationDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:))
        
        Swizzler.swizzleSelector(originalSelector,
                                 withSelector: newSelector,
                                 for: delegateClass,
                                 name: "OmetriaDidFailToRegisterForRemoteNotificationsWithError") { (_, _, _, _) in
        }
    }
    
    private func swizzleDidReceiveRemoteNotification() {
        let newSelector = #selector(UIResponder.om_application(_:didReceiveRemoteNotification:fetchCompletionHandler:))
        let delegateClass: AnyClass! = object_getClass(UIApplication.shared.delegate)
        let originalSelector = #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:))
        
        Swizzler.swizzleSelector(originalSelector,
                                 withSelector: newSelector,
                                 for: delegateClass,
                                 name: "OmetriaDidReceiveRemoteNotification") { (_, _, _, _) in
        }
    }
}

// MARK: -

extension UIResponder {
    @objc func om_application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard let applicationDelegate = Ometria.sharedUIApplication()?.delegate else {
            return
        }
        
        let aClass: AnyClass! = object_getClass(applicationDelegate)
        let originalSelector = #selector(UIApplicationDelegate.application(_:didRegisterForRemoteNotificationsWithDeviceToken:))
        
        if let originalMethod: Method = class_getInstanceMethod(aClass, originalSelector),
            let swizzle = Swizzler.swizzles[originalMethod] {
            typealias MyCFunction = @convention(c) (AnyObject, Selector, UIApplication, Data) -> Void
            let originalImplementation = unsafeBitCast(swizzle.originalMethod, to: MyCFunction.self)
            
            originalImplementation(applicationDelegate, originalSelector, application, deviceToken)
            
            for (_, block) in swizzle.blocks {
                block(self, swizzle.selector, application, deviceToken as AnyObject)
            }
        }
    }
    
    @objc func om_application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        guard let applicationDelegate = Ometria.sharedUIApplication()?.delegate else {
            return
        }
        
        let aClass: AnyClass! = object_getClass(applicationDelegate)
        let originalSelector = #selector(UIApplicationDelegate.application(_:didFailToRegisterForRemoteNotificationsWithError:))
        
        if let originalMethod: Method = class_getInstanceMethod(aClass, originalSelector),
            let swizzle = Swizzler.swizzles[originalMethod] {
            typealias MyCFunction = @convention(c) (AnyObject, Selector, UIApplication, Error) -> Void
            let originalImplementation = unsafeBitCast(swizzle.originalMethod, to: MyCFunction.self)
            
            originalImplementation(applicationDelegate, originalSelector, application, error)
            
            for (_, block) in swizzle.blocks {
                block(self, swizzle.selector, application, error as AnyObject)
            }
        }
    }
    
    @objc func om_application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let applicationDelegate = Ometria.sharedUIApplication()?.delegate else {
            return
        }
        
        let aClass: AnyClass! = object_getClass(applicationDelegate)
        let originalSelector = #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:))
        
        if let originalMethod: Method = class_getInstanceMethod(aClass, originalSelector),
            let swizzle = Swizzler.swizzles[originalMethod] {
            typealias MyCFunction = @convention(c) (AnyObject, Selector, UIApplication, [AnyHashable : Any], ((UIBackgroundFetchResult) -> Void)) -> Void
            let originalImplementation = unsafeBitCast(swizzle.originalMethod, to: MyCFunction.self)
            
            originalImplementation(applicationDelegate, originalSelector, application, userInfo, completionHandler)
            
            for (_, block) in swizzle.blocks {
                block(self, swizzle.selector, application, userInfo as AnyObject)
            }
        }
    }
}
