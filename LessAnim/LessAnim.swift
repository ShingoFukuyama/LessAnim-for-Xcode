//
//  LessAnim.swift
//  LessAnim
//
//  Created by Shingo Fukuyama on 6/12/16.
//  Copyright © 2016 Shingo Fukuyama. All rights reserved.
//

import Foundation
import Cocoa

class LessAnim: NSObject {
    class func pluginDidLoad(plugin: NSBundle) {
        NSAnimationContext.swizzle()
    }
}

extension NSAnimationContext {
    
    public class func swizzle() {
        struct Static {
            static var token: dispatch_once_t = 0
        }
        dispatch_once(&Static.token) {
            let swizzleClassMethod = { (original: Selector, swizzled: Selector) in
                let methodOriginal1 = class_getClassMethod(self, original)
                let methodSwizzled1 = class_getClassMethod(self, swizzled)
                method_exchangeImplementations(methodOriginal1, methodSwizzled1)
            }
            swizzleClassMethod(#selector(NSAnimationContext.runAnimationGroup(_:completionHandler:)), #selector(NSAnimationContext.ext_runAnimationGroup(_:completionHandler:)))
            swizzleClassMethod(#selector(NSAnimationContext.beginGrouping), #selector(NSAnimationContext.ext_beginGrouping))
            swizzleClassMethod(#selector(NSAnimationContext.endGrouping), #selector(NSAnimationContext.ext_endGrouping))
            swizzleClassMethod(#selector(NSAnimationContext.currentContext), #selector(NSAnimationContext.ext_currentContext))
        }
    }
    
    public class func ext_runAnimationGroup(changes: (NSAnimationContext) -> Void, completionHandler: (() -> Void)?) {
        self.ext_runAnimationGroup({ (context) in
            changes(context)
            context.duration = 0
        }) {  completionHandler?() }
    }
    
    public class func ext_currentContext() -> NSAnimationContext {
        let context = ext_currentContext()
        context.duration = 0
        return context
    }
    
    public class func ext_beginGrouping() {
        self.ext_beginGrouping()
        NSAnimationContext.currentContext().duration = 0
        NSAnimationContext.currentContext().allowsImplicitAnimation = false
    }
    
    public class func ext_endGrouping() {
        NSAnimationContext.currentContext().duration = 0
        NSAnimationContext.currentContext().allowsImplicitAnimation = false
        self.ext_endGrouping()
    }
    
}

