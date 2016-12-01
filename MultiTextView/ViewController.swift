//
//  ViewController.swift
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var editButton: UIButton!
    private var _clipViewController: LLClipViewController?
    private var _clipItem: LLClipItem?

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.layoutEditButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.layoutEditButton()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    /** editButtonをレイアウトする（AutoLayoutだからなのか、ビューを閉じるときに正しくセンタリングしているにも関わらず位置がずれてしまうので遅延実行する） */
    private func layoutEditButton() {
        weak var w = self
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { () -> Void in
            guard let s = w else { return }
            s.editButton.center = CGPointMake(CGRectGetWidth(self.editButton.superview!.frame) * 0.5, CGRectGetHeight(self.editButton.superview!.frame) * 0.5)
        })
    }

    @IBAction func editButtonDidTap(sender: AnyObject) {
        if nil == _clipItem {
            _clipItem = LLClipItem()
        }
        if nil != _clipViewController {
            _clipViewController!.dismissViewControllerAnimated(false, completion: nil)
        }
        weak var w = self
        _clipViewController = LLClipViewController(clipItem: _clipItem) {
            guard let s = w else { return }
            s._clipViewController = nil
        }
        self.editButton.hidden = true
        self.presentViewController(_clipViewController!, animated: true) {
            guard let s = w else { return }
            s.editButton.hidden = false
        }
    }

}

