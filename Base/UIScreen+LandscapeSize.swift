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
    fileprivate struct ClassProperty {
        static var landscapeSizeStore: NSValue!
        static var scaleXtoStandardStore: NSNumber!
        static var scaleYtoStandardStore: NSNumber!
    }
    
    class func landscapeSize() -> CGSize {
        if ClassProperty.landscapeSizeStore != nil {
            // iPad Proの場合は意図したサイズが取れていない場合があるので注意
            if UI_USER_INTERFACE_IDIOM() != .pad || ClassProperty.landscapeSizeStore.cgSizeValue.width != 1366 {
                return ClassProperty.landscapeSizeStore.cgSizeValue
            }
        }
        var size = UIScreen.main.bounds.size
        if (!size.equalTo(CGSize.zero)) {
            if (size.width < size.height) {
                size = CGSize(width: size.height, height: size.width)
            }
            ClassProperty.landscapeSizeStore = NSValue(cgSize: size)
        }
        return size
    }
    
    class func standardSize() -> CGSize {
        return CGSize(width: 1024, height: 768)
    }
    
    class func scaleXtoStandard() -> Float {
        if ClassProperty.scaleXtoStandardStore != nil {
            return ClassProperty.scaleXtoStandardStore.floatValue
        }
        ClassProperty.scaleXtoStandardStore = NSNumber(value: (Float)(landscapeSize().width / self.standardSize().width) as Float)
        return ClassProperty.scaleXtoStandardStore.floatValue
    }
    
    class func scaleYtoStandard() -> Float {
        if ClassProperty.scaleYtoStandardStore != nil {
            return ClassProperty.scaleYtoStandardStore.floatValue
        }
        ClassProperty.scaleYtoStandardStore = NSNumber(value: (Float)(landscapeSize().height / self.standardSize().height) as Float)
        return ClassProperty.scaleYtoStandardStore.floatValue
    }
    
    class func scaleToStandard() -> Float {
        return min(self.scaleXtoStandard(), self.scaleYtoStandard())
    }
}
