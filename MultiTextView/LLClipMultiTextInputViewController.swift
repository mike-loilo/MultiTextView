//
//  LLClipMultiTextInputViewController.swift
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

import UIKit

class LLClipMultiTextInputViewController: UIViewController, UIGestureRecognizerDelegate, LLTextHandleViewDelegate {

    @IBOutlet weak var closeButton: LLBorderedButton!
    @IBOutlet weak var backgroundColorButton: UIButton!
    @IBOutlet weak var backgroundColorView: UIView!
    @IBOutlet weak var insertButton: LLBorderedButton!
    @IBOutlet weak var addClipButton: UIButton!

    private var _topButtons = [UIView]()
    private var _textHandleViews = [LLTextHandleView]()
    var textHandleViews: [LLTextHandleView] { return _textHandleViews }
    private var _tapGesture: UITapGestureRecognizer?
    
    private var _clipItem: LLClipItem?
    private var _playView: LLFullScreenPlayView?
    private var _changeBGColorBlock: ((color: UIColor?) -> ())?
    private var _addClipBlock: ((item: LLClipItem?) -> ())?
    private var _closeCallback: (() -> ())?
    
    /** カット/コピー中のテキストボックス */
    private var _copiedData: LLRichText?
    /** 長押し */
    private var _longPressGesture: UILongPressGestureRecognizer?
    /** 最後に長押しメニューを表示した位置 */
    private var _locationWithLongPress: CGPoint?
    
    init(clipItem: LLClipItem!, playView: LLFullScreenPlayView!, changeBGColorBlock: ((color: UIColor?) -> ())?, addClipBlock: ((item: LLClipItem?) -> ())?, closeCallback: (() -> ())?) {
        super.init(nibName: "LLClipMultiTextInputViewController", bundle: nil)

        _clipItem = clipItem
        _playView = playView
        _changeBGColorBlock = changeBGColorBlock
        _addClipBlock = addClipBlock
        _closeCallback = closeCallback
        
        _tapGesture = UITapGestureRecognizer(target: self, action: #selector(LLClipMultiTextInputViewController.tapGesture(_:)))
        _tapGesture!.delegate = self
        _playView!.currentPageContentView.addGestureRecognizer(_tapGesture!)
        
        _longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(LLClipMultiTextInputViewController.longPressGesture(_:)))
        _longPressGesture!.delegate = self
        _playView!.currentPageContentView.addGestureRecognizer(_longPressGesture!)
    }
    
    /** ボタンの親になるビューを設定 */
    var controllerParent: UIView? {
        willSet {
            (_topButtons as NSArray).enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
                obj.removeFromSuperview()
            }
        }
        didSet {
            if nil != self.controllerParent {
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
        self.insertButton.setTitle(NSLocalizedString("707", comment: "") /* 挿入 */, forState: .Normal)
        self.insertButton.setWhiteStyle()
        
        //TODO:- 数が多くなるとUIに影響を与えかねないので、実際には少しずつ追加する
        _clipItem!.clip.richTexts.enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if !obj.isKindOfClass(LLRichText) { return }
            let richText = obj as! LLRichText
            let textHandleView = LLTextHandleView(richText: richText, type: .Normal)
            textHandleView.viewDelegate = self
            self._playView!.currentPageContentView.addSubview(textHandleView)
            self._textHandleViews.append(textHandleView)
        }
        self.organizeTextObjects(nil)
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
        if nil != _tapGesture!.view {
            _tapGesture!.view!.removeGestureRecognizer(_tapGesture!)
        }
        if nil != _longPressGesture!.view {
           _longPressGesture!.view!.removeGestureRecognizer(_longPressGesture!)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool { return true }
    
    @IBAction func closeButtonDidTap(sender: AnyObject) {
        self.organizeTextObjects(nil)
        if nil != _closeCallback {
            _closeCallback!()
        }
    }
    
    @IBAction func backgroundColorButtonDidTap(sender: AnyObject) {
        if nil != _changeBGColorBlock {
            _changeBGColorBlock!(color: UIColor.brownColor())
        }
    }
    
    @IBAction func insertButtonDidTap(sender: AnyObject) {
        //TODO:- 本当は既存のHTML文字列を読み込ませる
        let htmlString = "<!-- This is an HTML comment --><p>This is a test of the <strong>ZSSRichTextEditor</strong> by <a title=\"Zed Said\" href=\"http://www.zedsaid.com\">Zed Said Studio</a></p>"
        let richText = LLRichText()
        richText.text = htmlString
        richText.origin = CGPointZero
        richText.size = CGSizeMake(400, 200)
        let textHandleView = LLTextHandleView(richText: richText, type: .Normal)
        textHandleView.viewDelegate = self
        _playView!.currentPageContentView.addSubview(textHandleView)
        textHandleView.center = CGPointMake(CGRectGetWidth(self.view.bounds) * 0.5, CGRectGetHeight(self.view.bounds) * 0.5)
        _textHandleViews.append(textHandleView)
        self.organizeTextObjects(textHandleView)
        // 起動後の初回だけ、即時に編集状態にすると、かなり時間がかかることがあるため、遅延実行する
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
            textHandleView.enterEditMode()
        })
    }
    
    @IBAction func addClipButtonDidTap(sender: AnyObject) {
        if (nil != _addClipBlock) {
            _addClipBlock!(item: nil);
        }
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if _tapGesture == gestureRecognizer {
            // テキストハンドル上で、シングルタップを検出しないようにする
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
        return true
    }
    
    func tapGesture(sender: UIGestureRecognizer) {
        // テキストボックスを整理する
        var didEdit = false
        self.organizeTextObjects(nil, didEdit: &didEdit)
        
        if !didEdit {
            // タップした位置にテキストボックスを配置する
            let location = sender.locationInView(_playView!.currentPageContentView)
            let richText = LLRichText()
            richText.origin = location
            richText.size = CGSizeMake(80, 40)
            let textHandleView = LLTextHandleView(richText: richText, type: .Normal)
            textHandleView.viewDelegate = self
            _playView!.currentPageContentView.addSubview(textHandleView)
            _textHandleViews.append(textHandleView)
            textHandleView.enterEditMode()
        }
    }
    
    /** テキストボックスを整理する */
    private func organizeTextObjects(movable: LLTextHandleView?) {
        var didEdit = false
        self.organizeTextObjects(movable, didEdit: &didEdit)
    }
    private func organizeTextObjects(movable: LLTextHandleView?, inout didEdit: Bool) {
        didEdit = false
        // 種別を確認して、ノーマルの場合はハンドル自体を削除する
        var removeTextHandleViews = [LLTextHandleView]()
        (_textHandleViews as NSArray).enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if !obj.isKindOfClass(LLTextHandleView) { return }
            let textHandleView = obj as! LLTextHandleView
            textHandleView.movable = textHandleView == movable
            textHandleView.hiddenBorder = !textHandleView.movable
            if textHandleView.isEditingText {
                textHandleView.leaveEditMode()
                // スクロールしている場合があるため元に戻す
                var frame = self._playView!.currentPageContentView.frame
                frame.origin.y = 0
                UIView.animateWithDuration(0.1, animations: {
                    self._playView!.currentPageContentView.frame = frame
                })
                didEdit = true
            }
            if !textHandleView.movable && textHandleView.type == .Normal {
                if !textHandleView.hasText {
                    textHandleView.removeFromSuperview()
                    removeTextHandleViews.append(textHandleView)
                }
            }
        }
        (removeTextHandleViews as NSArray).enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            self._textHandleViews.removeAtIndex(self._textHandleViews.indexOf(obj as! LLTextHandleView)!)
        }
        self.syncRichTexts()
    }
    
    /** LLClip.richTextsを同期する */
    func syncRichTexts() {
        _clipItem!.clip.richTexts.removeAllObjects()
        (_textHandleViews as NSArray).enumerateObjectsUsingBlock { (obj: AnyObject, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            if !obj.isKindOfClass(LLTextHandleView) { return }
            let textHandleView = obj as! LLTextHandleView
            if nil == textHandleView.richText { return }
            self._clipItem!.clip.richTexts.addObject(textHandleView.richText!)
        }
    }
    
    func longPressGesture(sender: UILongPressGestureRecognizer) {
        if sender.state != .Began { return }
        if nil == _copiedData { return }
        // カット/コピー中のものがあればメニューを表示してペーストできるようにする
        _locationWithLongPress = sender.locationInView(_playView!.currentPageContentView)
        self.becomeFirstResponder()
        let menuItemPaste = UIMenuItem(title: NSLocalizedString("710", comment: "") /* ペースト */, action: #selector(LLClipMultiTextInputViewController.menuPaste(_:)))
        UIMenuController.sharedMenuController().menuItems = [menuItemPaste]
        UIMenuController.sharedMenuController().setTargetRect(CGRectMake(_locationWithLongPress!.x, _locationWithLongPress!.y, 0, 0), inView: _playView!.currentPageContentView)
        UIMenuController.sharedMenuController().setMenuVisible(true, animated: true)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if action == #selector(LLClipMultiTextInputViewController.menuPaste(_:)) {
            return true
        }
        return false
    }

    func menuPaste(sender: AnyObject) {
        if nil == _copiedData || nil == _locationWithLongPress {
            // 万が一、不正なデータを含んでいてデシリアライズできない場合はデータ自体を破棄しておく
            _copiedData = nil
            _locationWithLongPress = nil
            return
        }
        let textHandleView = self.textHandleViewFrom(_copiedData!.copy() as! LLRichText, type: .Normal)
        textHandleView.frame = CGRectMake(_locationWithLongPress!.x, _locationWithLongPress!.y, CGRectGetWidth(textHandleView.frame), CGRectGetHeight(textHandleView.frame))
        textHandleView.viewDelegate = self
        _playView!.currentPageContentView.addSubview(textHandleView)
        _textHandleViews.append(textHandleView)
        organizeTextObjects(textHandleView)
        textHandleView.enterEditMode()
    }
    
    /** LLTextHandleViewをLLRichTextに変換する */
    func richTextFrom(textHandleView: LLTextHandleView) -> LLRichText {
        let frame = textHandleView.convertRect(textHandleView.bounds, toView: (UIApplication.sharedApplication().delegate?.window)!)
        let richText = LLRichText()
        richText.text = textHandleView.htmlString
        richText.zIndex = textHandleView.superview!.subviews.indexOf(textHandleView)!
        richText.origin = frame.origin
        richText.size = frame.size
        return richText
    }
    
    /** LLRichTextからLLTextHandleViewに変換する */
    func textHandleViewFrom(richText: LLRichText, type: LLTextHandleViewType) -> LLTextHandleView {
        return LLTextHandleView(richText: richText, type: type)
    }
    
    //MARK:- LLTextHandleViewDelegate
    func textHandleViewTap(textHandleView: LLTextHandleView, tapCount: Int) {
        if !_textHandleViews.contains(textHandleView) { return }
        if 1 == tapCount {
            self.organizeTextObjects(textHandleView)
        }
        else if 2 == tapCount {
            textHandleView.enterEditMode()
        }
    }
    
    func textHandleViewMenuCut(textHandleView: LLTextHandleView) {
        if !_textHandleViews.contains(textHandleView) { return }
        _copiedData = self.richTextFrom(textHandleView).copy() as? LLRichText
        textHandleView.removeFromSuperview()
        _textHandleViews.removeAtIndex(_textHandleViews.indexOf(textHandleView)!)
        self.syncRichTexts()
    }
    
    func textHandleViewMenuCopy(textHandleView: LLTextHandleView) {
        if !_textHandleViews.contains(textHandleView) { return }
        _copiedData = self.richTextFrom(textHandleView).copy() as? LLRichText
    }
    
    func textHandleViewMenuDelete(textHandleView: LLTextHandleView) {
        if !_textHandleViews.contains(textHandleView) { return }
        textHandleView.removeFromSuperview()
        _textHandleViews.removeAtIndex(_textHandleViews.indexOf(textHandleView)!)
        self.syncRichTexts()
    }
    
    func textHandleViewDidChangeStatus(textHandleView: LLTextHandleView, isEditing: Bool) {
        if !_textHandleViews.contains(textHandleView) { return }
    }
    
    func textHandleViewDidChangeText(textHandleView: LLTextHandleView, text: String?, html: String?, caretRect: CGRect) {
        if !_textHandleViews.contains(textHandleView) { return }
        // 該当するhtmlHandleViewがキーボードを除く部分に見えるようにスクロールする
        let rect = textHandleView.convertRect(caretRect, toView: _playView!.currentPageContentView)
        let toolbarRect = textHandleView.toolbar!.convertRect(textHandleView.toolbar!.bounds, toView: _playView!.currentPageContentView)
        if CGRectGetMinY(toolbarRect) < CGRectGetMaxY(rect) {
            var frame = _playView!.currentPageContentView.frame
            frame.origin.y -= CGRectGetMaxY(rect) - CGRectGetMinY(toolbarRect)
            UIView.animateWithDuration(0.2, animations: {
                self._playView!.currentPageContentView.frame = frame
            })
        }
    }
    
    func textHandleViewDidChangeContentSize(textHandleView: LLTextHandleView, contentSize: CGSize) {
        if !_textHandleViews.contains(textHandleView) { return }
        // コンテントサイズが大きくなったら、それに合わせて大きくする
        var frame = textHandleView.frame
        frame.size.width = max(CGRectGetWidth(frame), contentSize.width)
        frame.size.height = max(CGRectGetHeight(frame), contentSize.height)
        textHandleView.frame = frame
    }
}
