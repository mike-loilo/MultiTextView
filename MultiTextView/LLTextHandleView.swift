//
//  LLTextHandleView.swift
//  MultiTextView
//
//  Created by mike on 2016/09/14.
//  Copyright © 2016年 loilo. All rights reserved.
//

import UIKit

//MARK:- LLSizeChangerView

/** サイズ変更ハンドル種別 */
enum LLSizeChangerViewType {
    case Circle
    case Rectangle
}

/** サイズ変更ハンドル */
private class LLSizeChangerView: UIView {

    /** 種別 */
    private var _type: LLSizeChangerViewType = .Circle
    
    private var _touchesBegan: ((view: LLSizeChangerView, touches: Set<UITouch>, event: UIEvent?) -> ())?
    private var _touchesMoved: ((view: LLSizeChangerView, touches: Set<UITouch>, event: UIEvent?) -> ())?
    private var _touchesEnded: ((view: LLSizeChangerView, touches: Set<UITouch>, event: UIEvent?) -> ())?
    private var _touchesCancelled: ((view: LLSizeChangerView, touches: Set<UITouch>?, event: UIEvent?) -> ())?
    
    init(frame: CGRect, type: LLSizeChangerViewType, touchesBegan: ((view: LLSizeChangerView, touches: Set<UITouch>, event: UIEvent?) -> ())?, touchesMoved: ((view: LLSizeChangerView, touches: Set<UITouch>, event: UIEvent?) -> ())?, touchesEnded: ((view: LLSizeChangerView, touches: Set<UITouch>, event: UIEvent?) -> ())?, touchesCancelled: ((view: LLSizeChangerView, touches: Set<UITouch>?, event: UIEvent?) -> ())?) {
        _type = type
        _touchesBegan = touchesBegan
        _touchesMoved = touchesMoved
        _touchesEnded = touchesEnded
        _touchesCancelled = touchesCancelled
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.grayColor()
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        get { return super.frame }
        set {
            super.frame = frame
            
            switch _type {
            case .Circle:
                self.layer.cornerRadius = min(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) * 0.5
                break
            case .Rectangle:
                self.layer.cornerRadius = 4 / UIScreen.mainScreen().scale
                break
            }
        }
    }
    
    private override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (nil != _touchesBegan) { _touchesBegan!(view: self, touches: touches, event: event) }
    }
    
    private override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (nil != _touchesMoved) { _touchesMoved!(view: self, touches: touches, event: event) }
    }
    
    private override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (nil != _touchesEnded) { _touchesEnded!(view: self, touches: touches, event: event) }
    }
    
    private override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if (nil != _touchesCancelled) { _touchesCancelled!(view: self, touches: touches, event: event) }
    }
}

//MARK:- LLTextHandleView

/** テキストのハンドル種別 */
@objc enum LLTextHandleViewType: Int {
    case Normal
    case Title
    case SubTitle
}

/** テキストのハンドル */
class LLTextHandleView: ZSSRichTextViewer {

    /** 種別（ノーマルの場合はハンドル自体を削除、タイトル / サブタイトルの場合はテキストがなくなったらプリセット文言を表示する） */
    private var _type: LLTextHandleViewType = .Normal
    var type: LLTextHandleViewType { return _type }
    
    /** ボーダー用レイヤー */
    private var _borderLayerInner: CALayer?
    private var _borderLayerOuter: CALayer?
    
    /** サイズ変更ハンドル */
    private var _tlHandle: LLSizeChangerView?
    private var _tcHandle: LLSizeChangerView?
    private var _trHandle: LLSizeChangerView?
    private var _lcHandle: LLSizeChangerView?
    private var _rcHandle: LLSizeChangerView?
    private var _blHandle: LLSizeChangerView?
    private var _bcHandle: LLSizeChangerView?
    private var _brHandle: LLSizeChangerView?
    
    /** タップジェスチャー */
    private var _tapGesture: UITapGestureRecognizer?
    var tapGesture: UITapGestureRecognizer? { return _tapGesture }
    private var _doubleTapGesture: UITapGestureRecognizer?
    var doubleTapGesture: UITapGestureRecognizer? { return _doubleTapGesture! }
    
    /** テキストがあるかどうか */
    var hasText: Bool {
        if (nil != _richTextEditor) {
            return 0 < _richTextEditor!.getHTML().lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        }
        else if (nil != _htmlString) {
            return 0 < _htmlString!.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        }
        return false
    }
    private var _htmlString: String?
    
    /** 動かせるかどうか */
    var movable: Bool = false {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            _tlHandle?.hidden = !movable
            _tcHandle?.hidden = !movable
            _trHandle?.hidden = !movable
            _lcHandle?.hidden = !movable
            _rcHandle?.hidden = !movable
            _blHandle?.hidden = !movable
            _bcHandle?.hidden = !movable
            _brHandle?.hidden = !movable
            CATransaction.commit()
        }
    }
    
    /** ボーダーの表示 */
    var hiddenBorder: Bool = true {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            _borderLayerInner?.hidden = hiddenBorder
            _borderLayerOuter?.hidden = hiddenBorder
            CATransaction.commit()
        }
    }
    
    private var _tapBlock: ((view: LLTextHandleView) -> ())?
    private var _doubleTapBlock: ((view: LLTextHandleView) -> ())?
    
    private var _richTextEditor: ZSSRichTextEditor?

    init(frame: CGRect, type: LLTextHandleViewType, htmlString: String?, tapBlock: ((view: LLTextHandleView) -> ())?, doubleTapBlock: ((view: LLTextHandleView) -> ())?) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.opaque = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.userInteractionEnabled = false

        _htmlString = htmlString
        if (nil == _htmlString) {
            _htmlString = ""
        }
        self.setHTML(_htmlString!)
        
        _borderLayerInner = CALayer()
        _borderLayerInner!.backgroundColor = UIColor.clearColor().CGColor
        _borderLayerInner!.borderColor = UIColor.whiteColor().CGColor
        let borderWidth = 1 / UIScreen.mainScreen().scale
        _borderLayerInner!.borderWidth = borderWidth
        _borderLayerInner!.frame = self.bounds
        self.layer.addSublayer(_borderLayerInner!)
        
        _borderLayerOuter = CALayer()
        _borderLayerOuter!.backgroundColor = UIColor.clearColor().CGColor
        _borderLayerOuter!.borderColor = UIColor.grayColor().CGColor
        _borderLayerOuter!.borderWidth = _borderLayerInner!.borderWidth
        _borderLayerOuter!.frame = CGRectMake(-borderWidth, -borderWidth, CGRectGetWidth(self.bounds) + borderWidth * 2, CGRectGetHeight(self.bounds) + borderWidth * 2)
        self.layer.addSublayer(_borderLayerOuter!)
        
        _type = type
        _tapBlock = tapBlock
        _doubleTapBlock = doubleTapBlock
        
        let circleHandleSize = CGSizeMake(16, 16)
        let rectangleHandleSize = CGSizeMake(14, 14)
        let minSize = CGSizeMake(6, 6)
        weak var w = self
        var startRect: CGRect = self.frame
        _tlHandle = LLSizeChangerView(frame: CGRectMake(0, 0, circleHandleSize.width, circleHandleSize.height), type: .Circle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.locationInView(s.superview))!
                let size = CGSizeMake(CGRectGetMaxX(startRect) - point.x, CGRectGetMaxY(startRect) - point.y)
                if (minSize.width <= abs(size.width) && minSize.height <= abs(size.height)) {
                    s.frame = CGRectMake(point.x, point.y, size.width, size.height)
                }
            }, touchesEnded: { (view, touches, event) in

            }, touchesCancelled: { (view, touches, event) in

        })
        _tlHandle!.center = CGPointMake(0, 0)
        self.addSubview(_tlHandle!)
        _tcHandle = LLSizeChangerView(frame: CGRectMake(0, 0, rectangleHandleSize.width, rectangleHandleSize.height), type: .Rectangle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.locationInView(s.superview))!
                let size = CGSizeMake(CGRectGetWidth(startRect), CGRectGetMaxY(startRect) - point.y)
                if (minSize.width <= abs(size.width) && minSize.height <= abs(size.height)) {
                    s.frame = CGRectMake(CGRectGetMinX(startRect), point.y, size.width, size.height)
                }
            }, touchesEnded: { (view, touches, event) in
                
            }, touchesCancelled: { (view, touches, event) in
                
        })
        _tcHandle!.center = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, 0)
        self.addSubview(_tcHandle!)
        _trHandle = LLSizeChangerView(frame: CGRectMake(0, 0, circleHandleSize.width, circleHandleSize.height), type: .Circle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.locationInView(s.superview))!
                let size = CGSizeMake(point.x - CGRectGetMinX(startRect), CGRectGetMaxY(startRect) - point.y)
                if (minSize.width <= abs(size.width) && minSize.height <= abs(size.height)) {
                    s.frame = CGRectMake(CGRectGetMinX(startRect), point.y, size.width, size.height)
                }
            }, touchesEnded: { (view, touches, event) in
                
            }, touchesCancelled: { (view, touches, event) in
                
        })
        _trHandle!.center = CGPointMake(CGRectGetWidth(self.bounds), 0)
        self.addSubview(_trHandle!)
        _lcHandle = LLSizeChangerView(frame: CGRectMake(0, 0, rectangleHandleSize.width, rectangleHandleSize.height), type: .Rectangle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.locationInView(s.superview))!
                let size = CGSizeMake(CGRectGetMaxX(startRect) - point.x, CGRectGetHeight(startRect))
                if (minSize.width <= abs(size.width) && minSize.height <= abs(size.height)) {
                    s.frame = CGRectMake(point.x, CGRectGetMinY(startRect), size.width, size.height)
                }
            }, touchesEnded: { (view, touches, event) in
                
            }, touchesCancelled: { (view, touches, event) in
                
        })
        _lcHandle!.center = CGPointMake(0, CGRectGetHeight(self.bounds) * 0.5)
        self.addSubview(_lcHandle!)
        _rcHandle = LLSizeChangerView(frame: CGRectMake(0, 0, rectangleHandleSize.width, rectangleHandleSize.height), type: .Rectangle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.locationInView(s.superview))!
                let size = CGSizeMake(point.x - CGRectGetMinX(startRect), CGRectGetHeight(startRect))
                if (minSize.width <= abs(size.width) && minSize.height <= abs(size.height)) {
                    s.frame = CGRectMake(CGRectGetMinX(startRect), CGRectGetMinY(startRect), size.width, size.height)
                }
            }, touchesEnded: { (view, touches, event) in
                
            }, touchesCancelled: { (view, touches, event) in
                
        })
        _rcHandle!.center = CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) * 0.5)
        self.addSubview(_rcHandle!)
        _blHandle = LLSizeChangerView(frame: CGRectMake(0, 0, circleHandleSize.width, circleHandleSize.height), type: .Circle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.locationInView(s.superview))!
                let size = CGSizeMake(CGRectGetMaxX(startRect) - point.x, point.y - CGRectGetMinY(startRect))
                if (minSize.width <= abs(size.width) && minSize.height <= abs(size.height)) {
                    s.frame = CGRectMake(point.x, CGRectGetMinY(startRect), size.width, size.height)
                }
            }, touchesEnded: { (view, touches, event) in
                
            }, touchesCancelled: { (view, touches, event) in
                
        })
        _blHandle!.center = CGPointMake(0, CGRectGetHeight(self.bounds))
        self.addSubview(_blHandle!)
        _bcHandle = LLSizeChangerView(frame: CGRectMake(0, 0, rectangleHandleSize.width, rectangleHandleSize.height), type: .Rectangle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.locationInView(s.superview))!
                let size = CGSizeMake(CGRectGetWidth(startRect), point.y - CGRectGetMinY(startRect))
                if (minSize.width <= abs(size.width) && minSize.height <= abs(size.height)) {
                    s.frame = CGRectMake(CGRectGetMinX(startRect), CGRectGetMinY(startRect), size.width, size.height)
                }
            }, touchesEnded: { (view, touches, event) in
                
            }, touchesCancelled: { (view, touches, event) in
                
        })
        _bcHandle!.center = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds))
        self.addSubview(_bcHandle!)
        _brHandle = LLSizeChangerView(frame: CGRectMake(0, 0, circleHandleSize.width, circleHandleSize.height), type: .Circle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.locationInView(s.superview))!
                let size = CGSizeMake(point.x - CGRectGetMinX(startRect), point.y - CGRectGetMinY(startRect))
                if (minSize.width <= abs(size.width) && minSize.height <= abs(size.height)) {
                    s.frame = CGRectMake(CGRectGetMinX(startRect), CGRectGetMinY(startRect), size.width, size.height)
                }
            }, touchesEnded: { (view, touches, event) in
                
            }, touchesCancelled: { (view, touches, event) in
                
        })
        _brHandle!.center = CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))
        self.addSubview(_brHandle!)

        _tapGesture = UITapGestureRecognizer(target: self, action: #selector(LLTextHandleView.tapGesture(_:)))
        self.addGestureRecognizer(_tapGesture!)
        _doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(LLTextHandleView.doubleTapGesture(_:)))
        _doubleTapGesture?.numberOfTapsRequired = 2
        self.addGestureRecognizer(_doubleTapGesture!)
        
        self.movable = true
        self.hiddenBorder = !self.movable
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var className: String {
        get {
            return NSStringFromClass(self.dynamicType).stringByReplacingOccurrencesOfString(NSBundle.mainBundle().infoDictionary?[kCFBundleNameKey as String] as! String + ".", withString: "", options: .CaseInsensitiveSearch, range: nil)
        }
    }
    deinit {
        NSLog("\(self.className + "." + #function)")
        self.leaveEditMode()
    }
    
    override var frame: CGRect {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            _borderLayerInner?.frame = self.bounds
            let borderWidth = nil != _borderLayerInner ? _borderLayerInner!.borderWidth : 0
            _borderLayerOuter?.frame = CGRectMake(-borderWidth, -borderWidth, CGRectGetWidth(self.bounds) + borderWidth * 2, CGRectGetHeight(self.bounds) + borderWidth * 2)
            CATransaction.commit()
            
            _tlHandle?.center = CGPointMake(0, 0)
            _tcHandle?.center = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, 0)
            _trHandle?.center = CGPointMake(CGRectGetWidth(self.bounds), 0)
            _lcHandle?.center = CGPointMake(0, CGRectGetHeight(self.bounds) * 0.5)
            _rcHandle?.center = CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) * 0.5)
            _blHandle?.center = CGPointMake(0, CGRectGetHeight(self.bounds))
            _bcHandle?.center = CGPointMake(CGRectGetWidth(self.bounds) * 0.5, CGRectGetHeight(self.bounds))
            _brHandle?.center = CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        // 各サイズ変更ハンドルは、ビューの外にはみ出ている部分があるので、そこを触ってもイベントが発生するようにしておく必要がある
        var pointForTargetView = _tlHandle!.convertPoint(point, fromView: self)
        if (CGRectContainsPoint(_tlHandle!.bounds, pointForTargetView)) {
            return _tlHandle!.hitTest(pointForTargetView, withEvent: event)
        }
        pointForTargetView = _tcHandle!.convertPoint(point, fromView: self)
        if (CGRectContainsPoint(_tcHandle!.bounds, pointForTargetView)) {
            return _tcHandle!.hitTest(pointForTargetView, withEvent: event)
        }
        pointForTargetView = _trHandle!.convertPoint(point, fromView: self)
        if (CGRectContainsPoint(_trHandle!.bounds, pointForTargetView)) {
            return _trHandle!.hitTest(pointForTargetView, withEvent: event)
        }
        pointForTargetView = _lcHandle!.convertPoint(point, fromView: self)
        if (CGRectContainsPoint(_lcHandle!.bounds, pointForTargetView)) {
            return _lcHandle!.hitTest(pointForTargetView, withEvent: event)
        }
        pointForTargetView = _rcHandle!.convertPoint(point, fromView: self)
        if (CGRectContainsPoint(_rcHandle!.bounds, pointForTargetView)) {
            return _rcHandle!.hitTest(pointForTargetView, withEvent: event)
        }
        pointForTargetView = _blHandle!.convertPoint(point, fromView: self)
        if (CGRectContainsPoint(_blHandle!.bounds, pointForTargetView)) {
            return _blHandle!.hitTest(pointForTargetView, withEvent: event)
        }
        pointForTargetView = _bcHandle!.convertPoint(point, fromView: self)
        if (CGRectContainsPoint(_bcHandle!.bounds, pointForTargetView)) {
            return _bcHandle!.hitTest(pointForTargetView, withEvent: event)
        }
        pointForTargetView = _brHandle!.convertPoint(point, fromView: self)
        if (CGRectContainsPoint(_brHandle!.bounds, pointForTargetView)) {
            return _brHandle!.hitTest(pointForTargetView, withEvent: event)
        }
        return super.hitTest(point, withEvent: event)
    }
    
    private var _startDiff: CGVector = CGVectorMake(0, 0)
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (!self.movable) { return }
        let point = (touches.first?.locationInView(self.superview))!
        _startDiff = CGVectorMake(CGRectGetMinX(self.frame) - point.x, CGRectGetMinY(self.frame) - point.y)
        self.hideMenu()
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (!self.movable) { return }
        let point = (touches.first?.locationInView(self.superview))!
        self.frame = CGRectMake(_startDiff.dx + point.x, _startDiff.dy + point.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))
    }
    
    func tapGesture(gesture: UIGestureRecognizer) {
        self.showMenu()
        if (nil != _tapBlock) {
            _tapBlock!(view: self)
        }
    }
    
    func doubleTapGesture(gesture: UIGestureRecognizer) {
        if (nil != _doubleTapBlock) {
            _doubleTapBlock!(view: self)
        }
    }
    
    /** 編集状態にする直前のZIndex */
    private var _zIndex:Int?
    /** 編集状態にする */
    func enterEditMode() {
        self.movable = false
        self.hideMenu()
        _tapGesture?.enabled = false
        _doubleTapGesture?.enabled = false
        
        if (nil != _richTextEditor) {
            _richTextEditor!.removeFromParentViewController()
            _richTextEditor!.view.removeFromSuperview()
        }
        _richTextEditor = ZSSRichTextEditor()
        _richTextEditor!.view.autoresizingMask = [.FlexibleLeftMargin, .FlexibleWidth, .FlexibleRightMargin, .FlexibleTopMargin, .FlexibleHeight, .FlexibleBottomMargin];
        _richTextEditor!.view.frame = self.bounds
        self.addSubview(_richTextEditor!.view)
//        findViewControllerInResponderChain(self).addChildViewController(_richTextEditor!)
        _richTextEditor!.parentViewForToolbar = self.superview!
        _richTextEditor!.viewWithKeyboard = self
        _richTextEditor!.alwaysShowToolbar = false
        _richTextEditor!.receiveEditorDidChangeEvents = false
        _richTextEditor!.enabledToolbarItems = [ZSSRichTextEditorToolbarBold,
                                                ZSSRichTextEditorToolbarFonts,
                                                ZSSRichTextEditorToolbarFontSize,
                                                ZSSRichTextEditorToolbarTextColor,
                                                ZSSRichTextEditorToolbarJustifyLeft,
                                                ZSSRichTextEditorToolbarJustifyCenter,
                                                ZSSRichTextEditorToolbarJustifyRight,
                                                ZSSRichTextEditorToolbarJustifyFull,
                                                ZSSRichTextEditorToolbarUnorderedList,
                                                ZSSRichTextEditorToolbarOrderedList,
                                                ZSSRichTextEditorToolbarIndent,
                                                ZSSRichTextEditorToolbarOutdent]
        _richTextEditor!.setHTML(_htmlString!)
        
        // 最前面に持ってくる
        _zIndex = self.superview!.subviews.indexOf(self)
        self.superview!.bringSubviewToFront(self)
    }
    
    var isEditingText: Bool { return nil != _richTextEditor }
    
    /** 編集状態を抜ける */
    func leaveEditMode() {
        if (nil != _richTextEditor) {
            _htmlString = _richTextEditor!.getHTML()
            _richTextEditor!.removeFromParentViewController()
            _richTextEditor!.view.removeFromSuperview()
        }
        _richTextEditor = nil
        
        _tapGesture?.enabled = true
        _doubleTapGesture?.enabled = true
        
        if (nil != _htmlString) {
            self.setHTML(_htmlString!)
        }
        
        // 元の位置に戻す
        if nil != _zIndex && nil != self.superview {
            self.superview!.insertSubview(self, atIndex: _zIndex!)
            _zIndex = nil
        }
    }
    
    /** メニューを表示する */
    func showMenu() {
        self.becomeFirstResponder()
        let menuItemCut: UIMenuItem = UIMenuItem(title: NSLocalizedString("690", comment: "") /* カット */, action: #selector(LLTextHandleView.menuCut(_:)))
        let menuItemCopy: UIMenuItem = UIMenuItem(title: NSLocalizedString("052", comment: "") /* コピー */, action: #selector(LLTextHandleView.menuCopy(_:)))
        let menuItemDelete: UIMenuItem = UIMenuItem(title: NSLocalizedString("114", comment: "") /* 削除 */, action: #selector(LLTextHandleView.menuDelete(_:)))
        let menuItemEditText: UIMenuItem = UIMenuItem(title: NSLocalizedString("691", comment: "") /* テキストの編集 */, action: #selector(LLTextHandleView.menuEditText(_:)))
        UIMenuController.sharedMenuController().menuItems = [menuItemCut, menuItemCopy, menuItemDelete, menuItemEditText]
        UIMenuController.sharedMenuController().setTargetRect(CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)), inView: self)
        UIMenuController.sharedMenuController().setMenuVisible(true, animated: true)
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        if ((action == #selector(LLTextHandleView.menuCut(_:))
            || action == #selector(LLTextHandleView.menuCopy(_:))
            || action == #selector(LLTextHandleView.menuDelete(_:))
            || action == #selector(LLTextHandleView.menuEditText(_:))) && !self.isEditingText) {
            return true
        }
        return false
    }
    
    func menuCut(sender: AnyObject) {
        NSLog("\(self.className + "." + #function)")
    }
    
    func menuCopy(sender: AnyObject) {
        NSLog("\(self.className + "." + #function)")
    }
    
    func menuDelete(sender: AnyObject) {
        NSLog("\(self.className + "." + #function)")
    }
    
    func menuEditText(sender: AnyObject) {
        self.enterEditMode()
    }
    
    /** メニューを消す */
    func hideMenu() {
        self.resignFirstResponder()
        UIMenuController.sharedMenuController().menuVisible = false
    }
}
