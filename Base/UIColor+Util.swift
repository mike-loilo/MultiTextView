//
//  UIColor+Util.swift
//  LoiloPad
//
//  Created by mike on 2014/12/12.
//
//

import Foundation

extension UIColor {
    class func loadVirtually() {
        method_exchangeImplementations(class_getInstanceMethod(UIColor.self, #selector(UIColor.getRed(_:green:blue:alpha:))), class_getInstanceMethod(UIColor.self, #selector(UIColor.getRedSwizzled(_:green:blue:alpha:))))
    }
    
    /** iOS7のgetRed:green:blue:alpha:では、whiteColor/blackColorのRGBAが取得できないので、iOSのバージョンに依らず失敗時はgetWhiteに回すようにする */
    func getRedSwizzled(red: UnsafeMutablePointer<CGFloat>, green: UnsafeMutablePointer<CGFloat>, blue: UnsafeMutablePointer<CGFloat>, alpha: UnsafeMutablePointer<CGFloat>) -> Bool {
        var result = self.getRedSwizzled(red, green: green, blue: blue, alpha: alpha)
        if !result {
            result = self.getWhite(red, alpha: alpha)
            if result {
                green.memory = red.memory
                blue.memory = red.memory
            }
            return result
        }
        return result
    }
    
    func blackOrWhiteContrastingColor() -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        self.getRed(&r, green:&g, blue:&b, alpha:nil)
        let c = 1 - ((0.299 * r) + (0.587 * g) + (0.114 * b))
        return c < 0.5 ? UIColor.blackColor() : UIColor.whiteColor()
    }
    
    /** 概ね同じかどうかを判別する */
    func maybeEqual(obj: UIColor) -> Bool {
        if self.isEqual(obj) { return true }
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        var ro: CGFloat = 0.0
        var go: CGFloat = 0.0
        var bo: CGFloat = 0.0
        var ao: CGFloat = 0.0
        obj.getRed(&ro, green:&go, blue:&bo, alpha:&ao)
        // 小数点以下いくつかが合っていれば同じとみなす
        func same(o1: CGFloat, o2: CGFloat, p: Float) -> Bool {
            let pow = powf(10, p)
            return round(Float(o1) * pow) == round(Float(o2) * pow)
        }
        return same(r, o2: ro, p: 2) && same(g, o2: go, p: 2) && same(b, o2: bo, p: 2) && same(a, o2: ao, p: 2)
    }
}