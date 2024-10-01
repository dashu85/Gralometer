//
//  Utilities.swift
//  Gralometer
//
//  Created by Marcus Benoit on 28.09.24.
//

import Foundation
import UIKit

final class Utilities {
    static let shared = Utilities() // the instance can be shared across the whole app easily
    private init() { } // only instance of this class can exist
    
    // find the top ViewController presented to the user right now
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        
        var rootViewController: UIViewController?
        
        // Get the active window's root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            for window in windowScene.windows {
                if window.isKeyWindow {
                    rootViewController = window.rootViewController
                    print("Key window found: \(window)")
                    break
                }
            }
        }
        
        let controller = controller ?? rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        
        return controller
    }
}
