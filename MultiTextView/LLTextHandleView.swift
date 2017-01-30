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
    case circle
    case rectangle
}

/** サイズ変更ハンドル */
private class LLSizeChangerView: UIView {

    /** 種別 */
    fileprivate var _type: LLSizeChangerViewType = .circle
    
    fileprivate var _touchesBegan: ((_ view: LLSizeChangerView, _ touches: Set<UITouch>, _ event: UIEvent?) -> ())?
    fileprivate var _touchesMoved: ((_ view: LLSizeChangerView, _ touches: Set<UITouch>, _ event: UIEvent?) -> ())?
    fileprivate var _touchesEnded: ((_ view: LLSizeChangerView, _ touches: Set<UITouch>, _ event: UIEvent?) -> ())?
    fileprivate var _touchesCancelled: ((_ view: LLSizeChangerView, _ touches: Set<UITouch>?, _ event: UIEvent?) -> ())?
    
    init(frame: CGRect, type: LLSizeChangerViewType, touchesBegan: ((_ view: LLSizeChangerView, _ touches: Set<UITouch>, _ event: UIEvent?) -> ())?, touchesMoved: ((_ view: LLSizeChangerView, _ touches: Set<UITouch>, _ event: UIEvent?) -> ())?, touchesEnded: ((_ view: LLSizeChangerView, _ touches: Set<UITouch>, _ event: UIEvent?) -> ())?, touchesCancelled: ((_ view: LLSizeChangerView, _ touches: Set<UITouch>?, _ event: UIEvent?) -> ())?) {
        _type = type
        _touchesBegan = touchesBegan
        _touchesMoved = touchesMoved
        _touchesEnded = touchesEnded
        _touchesCancelled = touchesCancelled
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.gray
        self.layer.borderColor = UIColor.white.cgColor
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
            case .circle:
                self.layer.cornerRadius = min(self.bounds.width, self.bounds.height) * 0.5
                break
            case .rectangle:
                self.layer.cornerRadius = 4 / UIScreen.main.scale
                break
            }
        }
    }
    
    fileprivate override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if nil != _touchesBegan { _touchesBegan!(self, touches, event) }
    }
    
    fileprivate override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if nil != _touchesMoved { _touchesMoved!(self, touches, event) }
    }
    
    fileprivate override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if nil != _touchesEnded { _touchesEnded!(self, touches, event) }
    }
    
    fileprivate override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if nil != _touchesCancelled { _touchesCancelled!(self, touches, event) }
    }
}

//MARK:- LLTextHandleView

/** テキストのハンドル種別 */
@objc enum LLTextHandleViewType: Int {
    case normal
    case unDeletable
}

/** プロトコル */
@objc protocol LLTextHandleViewDelegate {
    /** タップ */
    @objc optional func textHandleViewTap(_ textHandleView: LLTextHandleView, tapCount: Int)
    /** メニュー：カット */
    @objc optional func textHandleViewMenuCut(_ textHandleView: LLTextHandleView)
    /** メニュー：コピー */
    @objc optional func textHandleViewMenuCopy(_ textHandleView: LLTextHandleView)
    /** メニュー：削除 */
    @objc optional func textHandleViewMenuDelete(_ textHandleView: LLTextHandleView)
    /** メニュー：編集 */
    @objc optional func textHandleViewMenuEditText(_ textHandleView: LLTextHandleView)
    /** テキスト編集状態の変化 */
    @objc optional func textHandleViewDidChangeStatus(_ textHandleView: LLTextHandleView, isEditing: Bool)
    /** テキストの変化 */
    func textHandleViewDidChangeText(_ textHandleView: LLTextHandleView, text: String?, html: String?, caretRect: CGRect)
    /** コンテントサイズの変化 */
    func textHandleViewDidChangeContentSize(_ textHandleView: LLTextHandleView, contentSize: CGSize)
}

/** テキストのハンドル */
class LLTextHandleView: ZSSRichTextViewer, ZSSRichTextEditorDelegate {

    /** 種別（ノーマルの場合はハンドル自体を削除、タイトル / サブタイトルの場合はテキストがなくなったらプリセット文言を表示する） */
    fileprivate var _type: LLTextHandleViewType = .normal
    var type: LLTextHandleViewType { return _type }
    
    /** ボーダー用レイヤー */
    fileprivate var _borderLayerInner: CAShapeLayer?
    fileprivate var _borderLayerOuter: CAShapeLayer?
    
    /** サイズ変更ハンドル */
    fileprivate var _tlHandle: LLSizeChangerView?
    fileprivate var _tcHandle: LLSizeChangerView?
    fileprivate var _trHandle: LLSizeChangerView?
    fileprivate var _lcHandle: LLSizeChangerView?
    fileprivate var _rcHandle: LLSizeChangerView?
    fileprivate var _blHandle: LLSizeChangerView?
    fileprivate var _bcHandle: LLSizeChangerView?
    fileprivate var _brHandle: LLSizeChangerView?
    
    /** タップジェスチャー */
    fileprivate var _tapGesture: UITapGestureRecognizer?
    var tapGesture: UITapGestureRecognizer? { return _tapGesture }
    fileprivate var _doubleTapGesture: UITapGestureRecognizer?
    var doubleTapGesture: UITapGestureRecognizer? { return _doubleTapGesture! }
    
    /** テキストがあるかどうか */
    var hasText: Bool {
        if nil != _richTextEditor {
            return 0 < _richTextEditor!.getHTML().lengthOfBytes(using: String.Encoding.utf8)
        }
        else if nil != _htmlString {
            return 0 < _htmlString!.lengthOfBytes(using: String.Encoding.utf8)
        }
        return false
    }
    fileprivate var _htmlString: String?
    var htmlString: String? { return _htmlString }
    
    /** 動かせるかどうか */
    var movable: Bool = false {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            _tlHandle?.isHidden = !movable
            _tcHandle?.isHidden = !movable
            _trHandle?.isHidden = !movable
            _lcHandle?.isHidden = !movable
            _rcHandle?.isHidden = !movable
            _blHandle?.isHidden = !movable
            _bcHandle?.isHidden = !movable
            _brHandle?.isHidden = !movable
            CATransaction.commit()
        }
    }
    
    /** ボーダーの表示 */
    var hiddenBorder: Bool = true {
        didSet {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            _borderLayerInner?.isHidden = hiddenBorder
            _borderLayerOuter?.isHidden = hiddenBorder
            CATransaction.commit()
        }
    }
    
    fileprivate var _richTextEditor: ZSSRichTextEditor?
    
    /** デリゲート */
    weak var viewDelegate: LLTextHandleViewDelegate?
    
    /** LLRichText */
    fileprivate var _richText: LLRichText?
    var richText: LLRichText? { return _richText }
    
    convenience init(richText: LLRichText, type: LLTextHandleViewType) {
        self.init(frame: CGRect(x: richText.origin.x, y: richText.origin.y, width: richText.size.width, height: richText.size.height), type: type, htmlString: richText.text)
        _richText = richText
    }
    init(frame: CGRect, type: LLTextHandleViewType, htmlString: String?) {
        super.init(frame: frame, configuration:WKWebViewConfiguration())
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.isUserInteractionEnabled = false

        _htmlString = htmlString
        if nil == _htmlString {
            _htmlString = ""
        }
        self.setHTML(_htmlString!)
        
        _borderLayerInner = CAShapeLayer()
        _borderLayerInner!.fillColor = UIColor.clear.cgColor
        _borderLayerInner!.strokeColor = UIColor.white.cgColor
        let borderWidth = 2 / UIScreen.main.scale
        _borderLayerInner!.lineWidth = borderWidth
        _borderLayerInner!.frame = self.bounds
        _borderLayerInner!.lineDashPattern = [8, 4]
        _borderLayerInner!.path = UIBezierPath(rect: _borderLayerInner!.bounds).cgPath
        self.layer.addSublayer(_borderLayerInner!)
        
        _borderLayerOuter = CAShapeLayer()
        _borderLayerOuter!.fillColor = UIColor.clear.cgColor
        _borderLayerOuter!.strokeColor = UIColor.gray.cgColor
        _borderLayerOuter!.lineWidth = _borderLayerInner!.lineWidth
        _borderLayerOuter!.frame = CGRect(x: -borderWidth, y: -borderWidth, width: self.bounds.width + borderWidth * 2, height: self.bounds.height + borderWidth * 2)
        _borderLayerOuter!.lineDashPattern = _borderLayerInner!.lineDashPattern
        _borderLayerOuter!.path = UIBezierPath(rect: _borderLayerOuter!.bounds).cgPath
        self.layer.addSublayer(_borderLayerOuter!)
        
        _type = type
        
        let circleHandleSize = CGSize(width: 16, height: 16)
        let rectangleHandleSize = CGSize(width: 14, height: 14)
        let minSize = CGSize(width: 6, height: 6)
        weak var w = self
        var startRect: CGRect = self.frame
        _tlHandle = LLSizeChangerView(frame: CGRect(x: 0, y: 0, width: circleHandleSize.width, height: circleHandleSize.height), type: .circle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.location(in: s.superview))!
                let size = CGSize(width: startRect.maxX - point.x, height: startRect.maxY - point.y)
                if minSize.width <= abs(size.width) && minSize.height <= abs(size.height) {
                    s.frame = CGRect(x: point.x, y: point.y, width: size.width, height: size.height)
                }
            }, touchesEnded: nil, touchesCancelled: nil)
        _tlHandle!.center = CGPoint(x: 0, y: 0)
        self.addSubview(_tlHandle!)
        _tcHandle = LLSizeChangerView(frame: CGRect(x: 0, y: 0, width: rectangleHandleSize.width, height: rectangleHandleSize.height), type: .rectangle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.location(in: s.superview))!
                let size = CGSize(width: startRect.width, height: startRect.maxY - point.y)
                if minSize.width <= abs(size.width) && minSize.height <= abs(size.height) {
                    s.frame = CGRect(x: startRect.minX, y: point.y, width: size.width, height: size.height)
                }
            }, touchesEnded: nil, touchesCancelled: nil)
        _tcHandle!.center = CGPoint(x: self.bounds.width * 0.5, y: 0)
        self.addSubview(_tcHandle!)
        _trHandle = LLSizeChangerView(frame: CGRect(x: 0, y: 0, width: circleHandleSize.width, height: circleHandleSize.height), type: .circle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.location(in: s.superview))!
                let size = CGSize(width: point.x - startRect.minX, height: startRect.maxY - point.y)
                if minSize.width <= abs(size.width) && minSize.height <= abs(size.height) {
                    s.frame = CGRect(x: startRect.minX, y: point.y, width: size.width, height: size.height)
                }
            }, touchesEnded: nil, touchesCancelled: nil)
        _trHandle!.center = CGPoint(x: self.bounds.width, y: 0)
        self.addSubview(_trHandle!)
        _lcHandle = LLSizeChangerView(frame: CGRect(x: 0, y: 0, width: rectangleHandleSize.width, height: rectangleHandleSize.height), type: .rectangle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.location(in: s.superview))!
                let size = CGSize(width: startRect.maxX - point.x, height: startRect.height)
                if minSize.width <= abs(size.width) && minSize.height <= abs(size.height) {
                    s.frame = CGRect(x: point.x, y: startRect.minY, width: size.width, height: size.height)
                }
            }, touchesEnded: nil, touchesCancelled: nil)
        _lcHandle!.center = CGPoint(x: 0, y: self.bounds.height * 0.5)
        self.addSubview(_lcHandle!)
        _rcHandle = LLSizeChangerView(frame: CGRect(x: 0, y: 0, width: rectangleHandleSize.width, height: rectangleHandleSize.height), type: .rectangle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.location(in: s.superview))!
                let size = CGSize(width: point.x - startRect.minX, height: startRect.height)
                if minSize.width <= abs(size.width) && minSize.height <= abs(size.height) {
                    s.frame = CGRect(x: startRect.minX, y: startRect.minY, width: size.width, height: size.height)
                }
            }, touchesEnded: nil, touchesCancelled: nil)
        _rcHandle!.center = CGPoint(x: self.bounds.width, y: self.bounds.height * 0.5)
        self.addSubview(_rcHandle!)
        _blHandle = LLSizeChangerView(frame: CGRect(x: 0, y: 0, width: circleHandleSize.width, height: circleHandleSize.height), type: .circle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.location(in: s.superview))!
                let size = CGSize(width: startRect.maxX - point.x, height: point.y - startRect.minY)
                if minSize.width <= abs(size.width) && minSize.height <= abs(size.height) {
                    s.frame = CGRect(x: point.x, y: startRect.minY, width: size.width, height: size.height)
                }
            }, touchesEnded: nil, touchesCancelled: nil)
        _blHandle!.center = CGPoint(x: 0, y: self.bounds.height)
        self.addSubview(_blHandle!)
        _bcHandle = LLSizeChangerView(frame: CGRect(x: 0, y: 0, width: rectangleHandleSize.width, height: rectangleHandleSize.height), type: .rectangle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.location(in: s.superview))!
                let size = CGSize(width: startRect.width, height: point.y - startRect.minY)
                if minSize.width <= abs(size.width) && minSize.height <= abs(size.height) {
                    s.frame = CGRect(x: startRect.minX, y: startRect.minY, width: size.width, height: size.height)
                }
            }, touchesEnded: nil, touchesCancelled: nil)
        _bcHandle!.center = CGPoint(x: self.bounds.width * 0.5, y: self.bounds.height)
        self.addSubview(_bcHandle!)
        _brHandle = LLSizeChangerView(frame: CGRect(x: 0, y: 0, width: circleHandleSize.width, height: circleHandleSize.height), type: .circle, touchesBegan: { (view, touches, event) in
                guard let s = w else { return }
                startRect = s.frame
            }, touchesMoved: { (view, touches, event) in
                guard let s = w else { return }
                let point = (touches.first?.location(in: s.superview))!
                let size = CGSize(width: point.x - startRect.minX, height: point.y - startRect.minY)
                if minSize.width <= abs(size.width) && minSize.height <= abs(size.height) {
                    s.frame = CGRect(x: startRect.minX, y: startRect.minY, width: size.width, height: size.height)
                }
            }, touchesEnded: nil, touchesCancelled: nil)
        _brHandle!.center = CGPoint(x: self.bounds.width, y: self.bounds.height)
        self.addSubview(_brHandle!)

        _tapGesture = UITapGestureRecognizer(target: self, action: #selector(LLTextHandleView.tapGesture(_:)))
        self.addGestureRecognizer(_tapGesture!)
        _doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(LLTextHandleView.doubleTapGesture(_:)))
        _doubleTapGesture?.numberOfTapsRequired = 2
        self.addGestureRecognizer(_doubleTapGesture!)
        
        self.movable = true
        self.hiddenBorder = !self.movable
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var className: String {
        get {
            return NSStringFromClass(type(of: self)).replacingOccurrences(of: Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String + ".", with: "", options: .caseInsensitive, range: nil)
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
            if nil != _borderLayerInner {
                _borderLayerInner!.path = UIBezierPath(rect: _borderLayerInner!.bounds).cgPath
            }
            let borderWidth = nil != _borderLayerInner ? _borderLayerInner!.borderWidth : 0
            _borderLayerOuter?.frame = CGRect(x: -borderWidth, y: -borderWidth, width: self.bounds.width + borderWidth * 2, height: self.bounds.height + borderWidth * 2)
            if nil != _borderLayerOuter {
                _borderLayerOuter!.path = UIBezierPath(rect: _borderLayerOuter!.bounds).cgPath
            }
            CATransaction.commit()
            
            _tlHandle?.center = CGPoint(x: 0, y: 0)
            _tcHandle?.center = CGPoint(x: self.bounds.width * 0.5, y: 0)
            _trHandle?.center = CGPoint(x: self.bounds.width, y: 0)
            _lcHandle?.center = CGPoint(x: 0, y: self.bounds.height * 0.5)
            _rcHandle?.center = CGPoint(x: self.bounds.width, y: self.bounds.height * 0.5)
            _blHandle?.center = CGPoint(x: 0, y: self.bounds.height)
            _bcHandle?.center = CGPoint(x: self.bounds.width * 0.5, y: self.bounds.height)
            _brHandle?.center = CGPoint(x: self.bounds.width, y: self.bounds.height)
            
            _richText?.origin = self.frame.origin
            _richText?.size = self.frame.size
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // 各サイズ変更ハンドルは、ビューの外にはみ出ている部分があるので、そこを触ってもイベントが発生するようにしておく必要がある
        var pointForTargetView = _tlHandle!.convert(point, from: self)
        if _tlHandle!.bounds.contains(pointForTargetView) {
            return _tlHandle!.hitTest(pointForTargetView, with: event)
        }
        pointForTargetView = _tcHandle!.convert(point, from: self)
        if _tcHandle!.bounds.contains(pointForTargetView) {
            return _tcHandle!.hitTest(pointForTargetView, with: event)
        }
        pointForTargetView = _trHandle!.convert(point, from: self)
        if _trHandle!.bounds.contains(pointForTargetView) {
            return _trHandle!.hitTest(pointForTargetView, with: event)
        }
        pointForTargetView = _lcHandle!.convert(point, from: self)
        if _lcHandle!.bounds.contains(pointForTargetView) {
            return _lcHandle!.hitTest(pointForTargetView, with: event)
        }
        pointForTargetView = _rcHandle!.convert(point, from: self)
        if _rcHandle!.bounds.contains(pointForTargetView) {
            return _rcHandle!.hitTest(pointForTargetView, with: event)
        }
        pointForTargetView = _blHandle!.convert(point, from: self)
        if _blHandle!.bounds.contains(pointForTargetView) {
            return _blHandle!.hitTest(pointForTargetView, with: event)
        }
        pointForTargetView = _bcHandle!.convert(point, from: self)
        if _bcHandle!.bounds.contains(pointForTargetView) {
            return _bcHandle!.hitTest(pointForTargetView, with: event)
        }
        pointForTargetView = _brHandle!.convert(point, from: self)
        if _brHandle!.bounds.contains(pointForTargetView) {
            return _brHandle!.hitTest(pointForTargetView, with: event)
        }
        return super.hitTest(point, with: event)
    }
    
    fileprivate var _startDiff: CGVector = CGVector(dx: 0, dy: 0)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.movable { return }
        let point = (touches.first?.location(in: self.superview))!
        _startDiff = CGVector(dx: self.frame.minX - point.x, dy: self.frame.minY - point.y)
        self.hideMenu()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !self.movable { return }
        let point = (touches.first?.location(in: self.superview))!
        self.frame = CGRect(x: _startDiff.dx + point.x, y: _startDiff.dy + point.y, width: self.frame.width, height: self.frame.height)
    }
    
    func tapGesture(_ gesture: UIGestureRecognizer) {
        self.showMenu()
        self.viewDelegate?.textHandleViewTap!(self, tapCount: 1)
    }
    
    func doubleTapGesture(_ gesture: UIGestureRecognizer) {
        self.viewDelegate?.textHandleViewTap!(self, tapCount: 2)
    }
    
    /** 編集状態にする直前のZIndex */
    fileprivate var _zIndex:Int?
    /** 編集状態にする */
    func enterEditMode() {
        self.movable = false
        self.hideMenu()
        _tapGesture?.isEnabled = false
        _doubleTapGesture?.isEnabled = false
        
        if nil != _richTextEditor {
            _richTextEditor!.removeFromParentViewController()
            _richTextEditor!.view.removeFromSuperview()
        }
        _richTextEditor = ZSSRichTextEditor()
        _richTextEditor!.view.autoresizingMask = [.flexibleLeftMargin, .flexibleWidth, .flexibleRightMargin, .flexibleTopMargin, .flexibleHeight, .flexibleBottomMargin];
        _richTextEditor!.view.frame = self.bounds
        self.addSubview(_richTextEditor!.view)
        // ツールバーは最前面に配置しておく
        var topController = UIApplication.shared.keyWindow?.rootViewController
        while nil != topController?.presentedViewController {
            topController = topController?.presentedViewController
        }
        _richTextEditor!.parentViewForToolbar = topController?.view
        _richTextEditor!.viewWithKeyboard = self
        _richTextEditor!.alwaysShowToolbar = false
        _richTextEditor!.receiver = self
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
        _zIndex = self.superview!.subviews.index(of: self)
        self.superview!.bringSubview(toFront: self)
        
        viewDelegate?.textHandleViewDidChangeStatus?(self, isEditing: true)
    }
    
    var isEditingText: Bool { return nil != _richTextEditor }
    
    /** ツールバー */
    var toolbar: UIView? { return _richTextEditor?.toolbarHolder }
    
    /** 編集状態を抜ける */
    func leaveEditMode() {
        if nil != _richTextEditor {
            _htmlString = _richTextEditor!.getHTML()
            _richTextEditor!.removeFromParentViewController()
            _richTextEditor!.view.removeFromSuperview()
        }
        _richText?.text = _htmlString
        _richTextEditor = nil
        
        _tapGesture?.isEnabled = true
        _doubleTapGesture?.isEnabled = true
        
        if nil != _htmlString {
            self.setHTML(_htmlString!)
        }
        
        // 元の位置に戻す
        if nil != _zIndex && nil != self.superview {
            self.superview!.insertSubview(self, at: _zIndex!)
            _zIndex = nil
        }
        
        viewDelegate?.textHandleViewDidChangeStatus?(self, isEditing: false)
    }
    
    /** メニューを表示する */
    func showMenu() {
        self.becomeFirstResponder()
        let menuItemCut: UIMenuItem = UIMenuItem(title: NSLocalizedString("708", comment: "") /* カット */, action: #selector(LLTextHandleView.menuCut(_:)))
        let menuItemCopy: UIMenuItem = UIMenuItem(title: NSLocalizedString("052", comment: "") /* コピー */, action: #selector(LLTextHandleView.menuCopy(_:)))
        let menuItemDelete: UIMenuItem = UIMenuItem(title: NSLocalizedString("114", comment: "") /* 削除 */, action: #selector(LLTextHandleView.menuDelete(_:)))
        let menuItemEditText: UIMenuItem = UIMenuItem(title: NSLocalizedString("709", comment: "") /* テキストの編集 */, action: #selector(LLTextHandleView.menuEditText(_:)))
        UIMenuController.shared.menuItems = [menuItemCut, menuItemCopy, menuItemDelete, menuItemEditText]
        UIMenuController.shared.setTargetRect(CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height), in: self)
        UIMenuController.shared.setMenuVisible(true, animated: true)
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if (action == #selector(LLTextHandleView.menuCut(_:))
            || action == #selector(LLTextHandleView.menuCopy(_:))
            || action == #selector(LLTextHandleView.menuDelete(_:))
            || action == #selector(LLTextHandleView.menuEditText(_:))) && !self.isEditingText {
            return true
        }
        return false
    }
    
    func menuCut(_ sender: AnyObject) {
        viewDelegate?.textHandleViewMenuCut?(self)
    }
    
    func menuCopy(_ sender: AnyObject) {
        viewDelegate?.textHandleViewMenuCopy?(self)
    }
    
    func menuDelete(_ sender: AnyObject) {
        viewDelegate?.textHandleViewMenuDelete?(self)
    }
    
    func menuEditText(_ sender: AnyObject) {
        self.enterEditMode()
        viewDelegate?.textHandleViewMenuEditText?(self)
    }
    
    /** メニューを消す */
    func hideMenu() {
        self.resignFirstResponder()
        UIMenuController.shared.isMenuVisible = false
    }
    
    //MARK:- ZSSRichTextEditorDelegate
    func richTextEditor(_ editor: ZSSRichTextEditor, didChangeWith text: String?, html: String?, caretRect: CGRect) {
        if editor == _richTextEditor {
            viewDelegate?.textHandleViewDidChangeText(self, text: text, html: html, caretRect: caretRect)
        }
    }

    func richTextEditor(_ editor: ZSSRichTextEditor!, didChangeContentSize contentSize: CGSize) {
        if editor == _richTextEditor {
            viewDelegate?.textHandleViewDidChangeContentSize(self, contentSize: contentSize)
        }
    }
}
