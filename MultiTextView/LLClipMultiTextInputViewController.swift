//
//  LLClipMultiTextInputViewController.swift
//  MultiTextView
//
//  Created by mike on 2016/09/12.
//  Copyright © 2016年 loilo. All rights reserved.
//

import UIKit

class LLClipMultiTextInputViewController: UIViewController {

    @IBOutlet weak var _closeButton: LLBorderedButton!
    private var _closeCallback: (() -> ())?
    
    init(closeCallback: (() -> ())?) {
        super.init(nibName: "LLClipMultiTextInputViewController", bundle: nil)
        
        self._closeCallback = closeCallback
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self._closeButton.setTitle(NSLocalizedString("026", comment: "") /* 完了 */, forState: .Normal)
        self._closeButton.setWhiteStyle()
    }
    
    deinit { NSLog("\(NSStringFromClass(self.dynamicType) + "." + #function)") }
    
    override func prefersStatusBarHidden() -> Bool { return true }
    
    @IBAction func closeButtonDidTap(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { 
            if (nil != self._closeCallback) {
                self._closeCallback!()
            }
        }
    }
}
