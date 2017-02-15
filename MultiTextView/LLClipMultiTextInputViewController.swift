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

    fileprivate var _topButtons = [UIView]()
    fileprivate var _textHandleViews = [LLTextHandleView]()
    var textHandleViews: [LLTextHandleView] { return _textHandleViews }
    fileprivate var _tapGesture: UITapGestureRecognizer?
    
    fileprivate var _clipItem: LLClipItem?
    fileprivate var _playView: LLFullScreenPlayView?
    fileprivate var _changeBGColorBlock: ((_ color: UIColor?) -> ())?
    fileprivate var _addClipBlock: ((_ item: LLClipItem?) -> ())?
    fileprivate var _closeCallback: (() -> ())?
    
    /** カット/コピー中のテキストボックス */
    fileprivate var _copiedData: LLRichText?
    /** 長押し */
    fileprivate var _longPressGesture: UILongPressGestureRecognizer?
    /** 最後に長押しメニューを表示した位置 */
    fileprivate var _locationWithLongPress: CGPoint?
    
    init(clipItem: LLClipItem!, playView: LLFullScreenPlayView!, changeBGColorBlock: ((_ color: UIColor?) -> ())?, addClipBlock: ((_ item: LLClipItem?) -> ())?, closeCallback: (() -> ())?) {
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
            (_topButtons as AnyObject).enumerateObjects({ (obj, idx, stop) in
                (obj as! UIView).removeFromSuperview()
            })
        }
        didSet {
            if nil != self.controllerParent {
                (_topButtons as AnyObject).enumerateObjects({ (obj, idx, stop) in
                    self.controllerParent!.addSubview(obj as! UIView)
                })
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
        
        self.closeButton.setTitle(NSLocalizedString("026", comment: "") /* 完了 */, for: UIControlState())
        self.closeButton.setWhiteStyle()
        self.insertButton.setTitle(NSLocalizedString("707", comment: "") /* 挿入 */, for: UIControlState())
        self.insertButton.setWhiteStyle()
        
        //TODO:- テキストカード特別対応
        // テキスト編集時以外はLLTextHandleViewを画像化する場合は、この時点でオブジェクト化する必要があるが、常時LLTextHandleViewオブジェクトを保持しておくため、操作可能にして_textHandleViewsに加える
//        //TODO:- 数が多くなるとUIに影響を与えかねないので、実際には少しずつ追加する
//        _clipItem!.clip.richTexts.enumerateObjects({ (obj, idx, stop) in
//            if !(obj is LLRichText) { return }
//            let richText = obj as! LLRichText
//            let textHandleView = LLTextHandleView(richText: richText, type: .normal)
//            textHandleView.viewDelegate = self
//            self._playView!.currentPageContentView.addSubview(textHandleView)
//            self._textHandleViews.append(textHandleView)
//        })
        (self._playView!.currentPageContentView.subviews as AnyObject).enumerateObjects { (obj, idx, stop) in
            if obj is LLTextHandleView {
                let textHandleView = obj as! LLTextHandleView
                textHandleView.viewDelegate = self
                self._textHandleViews.append(textHandleView)
            }
        }
        self.organizeTextObjects(nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.view.frame = self.view.superview!.bounds
    }
    
    fileprivate var className: String {
        get {
            return NSStringFromClass(type(of: self)).replacingOccurrences(of: Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String + ".", with: "", options: .caseInsensitive, range: nil)
        }
    }
    deinit {
        NSLog("\(self.className + "." + #function)")
        (_topButtons as AnyObject).enumerateObjects({ (obj, idx, stop) in
            (obj as! UIView).removeFromSuperview()
        })
        //TODO:- テキストカード特別対応
        // テキスト編集時以外もLLTextHandleViewを保持したまま
//        (_textHandleViews as AnyObject).enumerateObjects({ (obj, idx, stop) in
//            (obj as! UIView).removeFromSuperview()
//        })
        if nil != _tapGesture!.view {
            _tapGesture!.view!.removeGestureRecognizer(_tapGesture!)
        }
        if nil != _longPressGesture!.view {
           _longPressGesture!.view!.removeGestureRecognizer(_longPressGesture!)
        }
    }
    
    override var prefersStatusBarHidden : Bool { return true }
    
    @IBAction func closeButtonDidTap(_ sender: AnyObject) {
        self.organizeTextObjects(nil)
        if nil != _closeCallback {
            _closeCallback!()
        }
    }
    
    @IBAction func backgroundColorButtonDidTap(_ sender: AnyObject) {
        if nil != _changeBGColorBlock {
            _changeBGColorBlock!(UIColor.brown)
        }
    }
    
    @IBAction func insertButtonDidTap(_ sender: AnyObject) {
        //TODO:- 本当は既存のHTML文字列を読み込ませる
        let htmlString = "<!-- This is an HTML comment --><p>This is a test of the <strong>ZSSRichTextEditor</strong> by <a title=\"Zed Said\" href=\"http://www.zedsaid.com\">Zed Said Studio</a></p>"
        let richText = LLRichText()
        richText.text = htmlString
        richText.origin = CGPoint.zero
        richText.size = CGSize(width: 400, height: 200)
        let textHandleView = LLTextHandleView(richText: richText, type: .normal)
        textHandleView.viewDelegate = self
        _playView!.currentPageContentView.addSubview(textHandleView)
        textHandleView.center = CGPoint(x: self.view.bounds.width * 0.5, y: self.view.bounds.height * 0.5)
        _textHandleViews.append(textHandleView)
        self.organizeTextObjects(textHandleView)
        // 起動後の初回だけ、即時に編集状態にすると、かなり時間がかかることがあるため、遅延実行する
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { () -> Void in
            textHandleView.enterEditMode()
        })
    }
    
    @IBAction func addClipButtonDidTap(_ sender: AnyObject) {
        if (nil != _addClipBlock) {
            _addClipBlock!(nil);
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if _tapGesture == gestureRecognizer {
            // テキストハンドル上で、シングルタップを検出しないようにする
            var receive = true
            (_textHandleViews as AnyObject).enumerateObjects({ (obj, idx, stop) in
                if !(obj is LLTextHandleView) { return }
                let textHandleView = obj as! LLTextHandleView
                let point = touch.location(in: textHandleView)
                if (textHandleView.bounds.contains(point)) {
                    receive = false
                    stop.initialize(to: true)
                }
            })
            return receive
        }
        return true
    }
    
    func tapGesture(_ sender: UIGestureRecognizer) {
        // テキストボックスを整理する
        var didEdit = false
        self.organizeTextObjects(nil, didEdit: &didEdit)
        
        if !didEdit {
            // タップした位置にテキストボックスを配置する
            let location = sender.location(in: _playView!.currentPageContentView)
            let richText = LLRichText()
            richText.origin = location
            richText.size = CGSize(width: 80, height: 40)
            let textHandleView = LLTextHandleView(richText: richText, type: .normal)
            textHandleView.viewDelegate = self
            _playView!.currentPageContentView.addSubview(textHandleView)
            _textHandleViews.append(textHandleView)
            textHandleView.enterEditMode()
        }
    }
    
    /** テキストボックスを整理する */
    fileprivate func organizeTextObjects(_ movable: LLTextHandleView?) {
        var didEdit = false
        self.organizeTextObjects(movable, didEdit: &didEdit)
    }
    fileprivate func organizeTextObjects(_ movable: LLTextHandleView?, didEdit: inout Bool) {
        didEdit = false
        // 種別を確認して、ノーマルの場合はハンドル自体を削除する
        var removeTextHandleViews = [LLTextHandleView]()
        (_textHandleViews as AnyObject).enumerateObjects({ (obj, idx, stop) in
            if !(obj is LLTextHandleView) { return }
            let textHandleView = obj as! LLTextHandleView
            textHandleView.movable = textHandleView == movable
            textHandleView.hiddenBorder = !textHandleView.movable
            if textHandleView.isEditingText {
                textHandleView.leaveEditMode()
                // スクロールしている場合があるため元に戻す
                var frame = self._playView!.currentPageContentView.frame
                frame.origin.y = 0
                UIView.animate(withDuration: 0.1, animations: {
                    self._playView!.currentPageContentView.frame = frame
                })
                didEdit = true
            }
            if !textHandleView.movable && textHandleView.type == .normal {
                if !textHandleView.hasText {
                    textHandleView.removeFromSuperview()
                    removeTextHandleViews.append(textHandleView)
                }
            }
        })
        (removeTextHandleViews as AnyObject).enumerateObjects({ (obj, idx, stop) in
            self._textHandleViews.remove(at: self._textHandleViews.index(of: obj as! LLTextHandleView)!)
        })
        self.syncRichTexts()
    }
    
    /** LLClip.richTextsを同期する */
    func syncRichTexts() {
        _clipItem!.clip.richTexts.removeAllObjects()
        (_textHandleViews as AnyObject).enumerateObjects({ (obj, idx, stop) in
            if !(obj is LLTextHandleView) { return }
            let textHandleView = obj as! LLTextHandleView
            if nil == textHandleView.richText { return }
            self._clipItem!.clip.richTexts.add(textHandleView.richText!)
        })
    }
    
    func longPressGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .began { return }
        if nil == _copiedData { return }
        // カット/コピー中のものがあればメニューを表示してペーストできるようにする
        _locationWithLongPress = sender.location(in: _playView!.currentPageContentView)
        self.becomeFirstResponder()
        let menuItemPaste = UIMenuItem(title: NSLocalizedString("710", comment: "") /* ペースト */, action: #selector(LLClipMultiTextInputViewController.menuPaste(_:)))
        UIMenuController.shared.menuItems = [menuItemPaste]
        UIMenuController.shared.setTargetRect(CGRect(x: _locationWithLongPress!.x, y: _locationWithLongPress!.y, width: 0, height: 0), in: _playView!.currentPageContentView)
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(LLClipMultiTextInputViewController.menuPaste(_:)) {
            return true
        }
        return false
    }

    func menuPaste(_ sender: AnyObject) {
        if nil == _copiedData || nil == _locationWithLongPress {
            // 万が一、不正なデータを含んでいてデシリアライズできない場合はデータ自体を破棄しておく
            _copiedData = nil
            _locationWithLongPress = nil
            return
        }
        let textHandleView = self.textHandleViewFrom(_copiedData!.copy() as! LLRichText, type: .normal)
        textHandleView.frame = CGRect(x: _locationWithLongPress!.x, y: _locationWithLongPress!.y, width: textHandleView.frame.width, height: textHandleView.frame.height)
        textHandleView.viewDelegate = self
        _playView!.currentPageContentView.addSubview(textHandleView)
        _textHandleViews.append(textHandleView)
        organizeTextObjects(textHandleView)
        textHandleView.enterEditMode()
    }
    
    /** LLTextHandleViewをLLRichTextに変換する */
    func richTextFrom(_ textHandleView: LLTextHandleView) -> LLRichText {
        let frame = textHandleView.convert(textHandleView.bounds, to: (UIApplication.shared.delegate?.window)!)
        let richText = LLRichText()
        richText.text = textHandleView.htmlString
        richText.zIndex = textHandleView.superview!.subviews.index(of: textHandleView)!
        richText.origin = frame.origin
        richText.size = frame.size
        return richText
    }
    
    /** LLRichTextからLLTextHandleViewに変換する */
    func textHandleViewFrom(_ richText: LLRichText, type: LLTextHandleViewType) -> LLTextHandleView {
        return LLTextHandleView(richText: richText, type: type)
    }
    
    //MARK:- LLTextHandleViewDelegate
    func textHandleViewTap(_ textHandleView: LLTextHandleView, tapCount: Int) {
        if !_textHandleViews.contains(textHandleView) { return }
        if 1 == tapCount {
            self.organizeTextObjects(textHandleView)
        }
        else if 2 == tapCount {
            textHandleView.enterEditMode()
        }
    }
    
    func textHandleViewMenuCut(_ textHandleView: LLTextHandleView) {
        if !_textHandleViews.contains(textHandleView) { return }
        _copiedData = self.richTextFrom(textHandleView).copy() as? LLRichText
        textHandleView.removeFromSuperview()
        _textHandleViews.remove(at: _textHandleViews.index(of: textHandleView)!)
        self.syncRichTexts()
    }
    
    func textHandleViewMenuCopy(_ textHandleView: LLTextHandleView) {
        if !_textHandleViews.contains(textHandleView) { return }
        _copiedData = self.richTextFrom(textHandleView).copy() as? LLRichText
    }
    
    func textHandleViewMenuDelete(_ textHandleView: LLTextHandleView) {
        if !_textHandleViews.contains(textHandleView) { return }
        textHandleView.removeFromSuperview()
        _textHandleViews.remove(at: _textHandleViews.index(of: textHandleView)!)
        self.syncRichTexts()
    }
    
    func textHandleViewDidChangeStatus(_ textHandleView: LLTextHandleView, isEditing: Bool) {
        if !_textHandleViews.contains(textHandleView) { return }
    }
    
    func textHandleViewDidChangeText(_ textHandleView: LLTextHandleView, text: String?, html: String?, caretRect: CGRect) {
        if !_textHandleViews.contains(textHandleView) { return }
        // 該当するhtmlHandleViewがキーボードを除く部分に見えるようにスクロールする
        let rect = textHandleView.convert(caretRect, to: _playView!.currentPageContentView)
        let toolbarRect = textHandleView.toolbar!.convert(textHandleView.toolbar!.bounds, to: _playView!.currentPageContentView)
        if toolbarRect.minY < rect.maxY {
            var frame = _playView!.currentPageContentView.frame
            frame.origin.y -= rect.maxY - toolbarRect.minY
            UIView.animate(withDuration: 0.2, animations: {
                self._playView!.currentPageContentView.frame = frame
            })
        }
    }
    
    func textHandleViewDidChangeContentSize(_ textHandleView: LLTextHandleView, contentSize: CGSize) {
        if !_textHandleViews.contains(textHandleView) { return }
        // コンテントサイズが大きくなったら、それに合わせて大きくする
        var frame = textHandleView.frame
        frame.size.width = max(frame.width, contentSize.width)
        frame.size.height = max(frame.height, contentSize.height)
        textHandleView.frame = frame
    }
}
