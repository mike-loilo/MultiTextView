//
//  ViewController.swift
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    fileprivate var _clipViewController: LLClipViewController?
    fileprivate var _clipItem: LLClipItem?
    fileprivate var _serialized: NSDictionary?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.layoutEditButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.layoutEditButton()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    /** editButtonをレイアウトする（AutoLayoutだからなのか、ビューを閉じるときに正しくセンタリングしているにも関わらず位置がずれてしまうので遅延実行する） */
    fileprivate func layoutEditButton() {
        weak var w = self
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { () -> Void in
            guard let s = w else { return }
            s.editButton.center = CGPoint(x: self.editButton.superview!.frame.width * 0.5, y: self.editButton.superview!.frame.height * 0.5)
        })
    }

    @IBAction func editButtonDidTap(_ sender: AnyObject) {
        if nil == _clipItem {
            _clipItem = LLClipItem()
        }
        if nil != _serialized {
            _clipItem = LLClipItem.init(savedData: _serialized! as! [AnyHashable: Any], documentId: 0, at: 0)
        }
        if nil != _clipViewController {
            _clipViewController!.dismiss(animated: false, completion: nil)
        }
        weak var w = self
        _clipViewController = LLClipViewController(clipItem: _clipItem, closeCallback: { (image) in
            guard let s = w else { return }
            s._clipViewController = nil
            s._serialized = s._clipItem!.serialize(true, positionOffset: CGPoint.zero) as NSDictionary?
            s.imageView.image = image
        })
        self.editButton.isHidden = true
        self.present(_clipViewController!, animated: true) {
            guard let s = w else { return }
            s.editButton.isHidden = false
        }
    }

}

