//
//  UIScreen+LandscapeSize.swift
//  LoiloPad
//
//  Created by mike on 2015/08/14.
//
//

import Foundation
import UIKit

extension UIScreen {
    private struct ClassProperty {
        static var landscapeSizeStore: NSValue!
        static var scaleXtoStandardStore: NSNumber!
        static var scaleYtoStandardStore: NSNumber!
    }
    
    class func landscapeSize() -> CGSize {
        if ClassProperty.landscapeSizeStore != nil {
            // iPad Proの場合は意図したサイズが取れていない場合があるので注意
            if UI_USER_INTERFACE_IDIOM() != .Pad || ClassProperty.landscapeSizeStore.CGSizeValue().width != 1366 {
                return ClassProperty.landscapeSizeStore.CGSizeValue()
            }
        }
        var size = UIScreen.mainScreen().bounds.size
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            if (size.width < size.height) {
                size = CGSizeMake(size.height, size.width)
            }
            ClassProperty.landscapeSizeStore = NSValue(CGSize: size)
        }
        return size
    }
    
    class func standardSize() -> CGSize {
        return CGSizeMake(1024, 768)
    }
    
    class func scaleXtoStandard() -> Float {
        if ClassProperty.scaleXtoStandardStore != nil {
            return ClassProperty.scaleXtoStandardStore.floatValue
        }
        ClassProperty.scaleXtoStandardStore = NSNumber(float: (Float)(landscapeSize().width / self.standardSize().width))
        return ClassProperty.scaleXtoStandardStore.floatValue
    }
    
    class func scaleYtoStandard() -> Float {
        if ClassProperty.scaleYtoStandardStore != nil {
            return ClassProperty.scaleYtoStandardStore.floatValue
        }
        ClassProperty.scaleYtoStandardStore = NSNumber(float: (Float)(landscapeSize().height / self.standardSize().height))
        return ClassProperty.scaleYtoStandardStore.floatValue
    }
    
    class func scaleToStandard() -> Float {
        return min(self.scaleXtoStandard(), self.scaleYtoStandard())
    }
}
