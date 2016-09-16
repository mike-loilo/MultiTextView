//
//  LLClipMultiTextInputViewController.swift
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

import UIKit

class LLClipMultiTextInputViewController: UIViewController {

    @IBOutlet weak var closeButton: LLBorderedButton!
    @IBOutlet weak var backgroundColorButton: UIButton!
    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var addClipButton: UIButton!

    private var topButtons = [UIView]()
    
    private var clipItem: LLClipItem?
    private var playView: LLFullScreenPlayView?
    private var changeBGColorBlock: ((color: UIColor?) -> ())?
    private var addClipBlock: ((item: LLClipItem?) -> ())?
    private var closeCallback: (() -> ())?
    
    init(clipItem: LLClipItem!, playView: LLFullScreenPlayView!, changeBGColorBlock: ((color: UIColor?) -> ())?, addClipBlock: ((item: LLClipItem?) -> ())?, closeCallback: (() -> ())?) {
        super.init(nibName: "LLClipMultiTextInputViewController", bundle: nil)

        self.clipItem = clipItem
        self.playView = playView
        self.changeBGColorBlock = changeBGColorBlock
        self.addClipBlock = addClipBlock
        self.closeCallback = closeCallback
    }
    
    /** ボタンの親になるビューを設定 */
    var controllerParent: UIView? {
        willSet {
            (self.topButtons as NSArray).enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                obj.removeFromSuperview()
            }
        }
        didSet {
            if (nil != self.controllerParent) {
                (self.topButtons as NSArray).enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                    self.controllerParent!.addSubview(obj as! UIView)
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.topButtons.append(self.closeButton)
        self.topButtons.append(self.backgroundColorButton)
        self.topButtons.append(self.backgroundColorView)
        self.topButtons.append(self.addClipButton)
        
        self.closeButton.setTitle(NSLocalizedString("026", comment: "") /* 完了 */, forState: .Normal)
        self.closeButton.setWhiteStyle()
        
        //MARK:- TEST
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
            let test = LLTextHandleView(frame: CGRectMake(0, 0, 200, 50), type: .Normal)
            self.playView!.currentPageContentView.addSubview(test)
            test.center = CGPointMake(CGRectGetWidth(self.view.bounds) * 0.5, CGRectGetHeight(self.view.bounds) * 0.5)
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.frame = self.view.superview!.bounds
    }
    
    deinit {
        NSLog("\(NSStringFromClass(self.dynamicType) + "." + #function)")
        (self.topButtons as NSArray).enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            obj.removeFromSuperview()
        }
    }
    
    override func prefersStatusBarHidden() -> Bool { return true }
    
    @IBAction func closeButtonDidTap(sender: AnyObject) {
        if (nil != self.closeCallback) {
            self.closeCallback!()
        }
    }
    
    @IBAction func backgroundColorButtonDidTap(sender: AnyObject) {
        if (nil != self.changeBGColorBlock) {
            self.changeBGColorBlock!(color: UIColor.brownColor())
        }
    }
    
    @IBAction func addClipButtonDidTap(sender: AnyObject) {
        if (nil != self.addClipBlock) {
            self.addClipBlock!(item: nil);
        }
    }
}
