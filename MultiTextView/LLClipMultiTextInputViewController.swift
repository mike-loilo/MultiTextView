//
//  LLClipMultiTextInputViewController.swift
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

import UIKit

class LLClipMultiTextInputViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var closeButton: LLBorderedButton!
    @IBOutlet weak var backgroundColorButton: UIButton!
    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var insertButton: LLBorderedButton!
    @IBOutlet weak var addClipButton: UIButton!

    private var _topButtons = [UIView]()
    private var _textHandleViews = [LLTextHandleView]()
    private var _tapGesture: UITapGestureRecognizer?
    
    private var _clipItem: LLClipItem?
    private var _playView: LLFullScreenPlayView?
    private var _changeBGColorBlock: ((color: UIColor?) -> ())?
    private var _addClipBlock: ((item: LLClipItem?) -> ())?
    private var _closeCallback: (() -> ())?
    
    init(clipItem: LLClipItem!, playView: LLFullScreenPlayView!, changeBGColorBlock: ((color: UIColor?) -> ())?, addClipBlock: ((item: LLClipItem?) -> ())?, closeCallback: (() -> ())?) {
        super.init(nibName: "LLClipMultiTextInputViewController", bundle: nil)

        _clipItem = clipItem
        _playView = playView
        _changeBGColorBlock = changeBGColorBlock
        _addClipBlock = addClipBlock
        _closeCallback = closeCallback
        
        _tapGesture = UITapGestureRecognizer(target: self, action: #selector(LLClipMultiTextInputViewController.tapGesture(_:)))
        _tapGesture!.delegate = self
        _playView?.currentPageContentView.addGestureRecognizer(_tapGesture!)
    }
    
    /** ボタンの親になるビューを設定 */
    var controllerParent: UIView? {
        willSet {
            (_topButtons as NSArray).enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                obj.removeFromSuperview()
            }
        }
        didSet {
            if (nil != self.controllerParent) {
                (_topButtons as NSArray).enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
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

        _topButtons.append(self.closeButton)
        _topButtons.append(self.backgroundColorButton)
        _topButtons.append(self.backgroundColorView)
        _topButtons.append(self.insertButton)
        _topButtons.append(self.addClipButton)
        
        self.closeButton.setTitle(NSLocalizedString("026", comment: "") /* 完了 */, forState: .Normal)
        self.closeButton.setWhiteStyle()
        self.insertButton.setTitle(NSLocalizedString("689", comment: "") /* 挿入 */, forState: .Normal)
        self.insertButton.setWhiteStyle()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.frame = self.view.superview!.bounds
    }
    
    private var className: String {
        get {
            return NSStringFromClass(self.dynamicType).stringByReplacingOccurrencesOfString(NSBundle.mainBundle().infoDictionary?[kCFBundleNameKey as String] as! String + ".", withString: "", options: .CaseInsensitiveSearch, range: nil)
        }
    }
    deinit {
        NSLog("\(self.className + "." + #function)")
        (_topButtons as NSArray).enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            obj.removeFromSuperview()
        }
        (_textHandleViews as NSArray).enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            obj.removeFromSuperview()
        }
        if (nil != _tapGesture!.view) {
            _tapGesture!.view!.removeGestureRecognizer(_tapGesture!)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool { return true }
    
    @IBAction func closeButtonDidTap(sender: AnyObject) {
        if (nil != _closeCallback) {
            _closeCallback!()
        }
    }
    
    @IBAction func backgroundColorButtonDidTap(sender: AnyObject) {
        if (nil != _changeBGColorBlock) {
            _changeBGColorBlock!(color: UIColor.brownColor())
        }
    }
    
    @IBAction func insertButtonDidTap(sender: AnyObject) {
        weak var w = self
        let textHandleView = LLTextHandleView(frame: CGRectMake(0, 0, 200, 50), type: .Normal, tapBlock: { (view) in
            guard let s = w else { return }
            s.organizeTextObjects(view)
        }) { (view) in
            guard let s = w else { return }
            //TODO:- 編集状態にする
            view.enterEditMode()
        }
        _playView!.currentPageContentView.addSubview(textHandleView)
        textHandleView.center = CGPointMake(CGRectGetWidth(self.view.bounds) * 0.5, CGRectGetHeight(self.view.bounds) * 0.5)
        _textHandleViews.append(textHandleView)
        self.organizeTextObjects(textHandleView)
    }
    
    @IBAction func addClipButtonDidTap(sender: AnyObject) {
        if (nil != _addClipBlock) {
            _addClipBlock!(item: nil);
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        // テキストハンドルで、シングルタップを検出させないようにする
        var receive = true
        (_textHandleViews as NSArray).enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if (!obj.isKindOfClass(LLTextHandleView)) { return }
            let textHandleView = obj as! LLTextHandleView
            let point = touch.locationInView(textHandleView)
            if (CGRectContainsPoint(textHandleView.bounds, point)) {
                receive = false
                stop.initialize(true)
            }
        }
        return receive
    }
    
    func tapGesture(sender: UIGestureRecognizer) {
        self.organizeTextObjects(nil)
    }
    
    /** テキストボックスを整理する */
    private func organizeTextObjects(movable: LLTextHandleView?) {
        // 種別を確認して、ノーマルの場合はハンドル自体を削除、タイトル / サブタイトルの場合はテキストがなくなったらプリセット文言を表示する
        var removeTextHandleViews = [LLTextHandleView]()
        (_textHandleViews as NSArray).enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if (!obj.isKindOfClass(LLTextHandleView)) { return }
            let textHandleView = obj as! LLTextHandleView
            textHandleView.movable = textHandleView == movable
            if (!textHandleView.movable && textHandleView.type == .Normal) {
                if (!textHandleView.hasText) {
                    textHandleView.removeFromSuperview()
                    removeTextHandleViews.append(textHandleView)
                }
            }
        }
        (removeTextHandleViews as NSArray).enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            self._textHandleViews.removeAtIndex(self._textHandleViews.indexOf(obj as! LLTextHandleView)!)
        }
    }
}
