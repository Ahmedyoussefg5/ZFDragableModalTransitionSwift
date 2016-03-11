//
//  ViewController.swift
//  ZFDragableModalTransitionSwift
//
//  Created by binaryboy on 3/10/16.
//  Copyright © 2016 AhmedHamdy. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var dragableSwitch: UISwitch!
    @IBOutlet var scrollViewSwitch: UISwitch!
    var  animator: ZFModalTransitionAnimator!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let modalVC:ModalViewController = segue.destinationViewController as! ModalViewController
        
        
        self.animator =   ZFModalTransitionAnimator(modalViewController: modalVC)
        // create animator object with instance of modal view controller
        // we need to keep it in property with strong reference so it will not get release
        self.animator.dragable = true;
        self.animator.setContentScrollView(modalVC.scrollView)
        self.animator.direction = ZFModalTransitonDirection.Bottom
        
        // set transition delegate of modal view controller to our object
        modalVC.transitioningDelegate = self.animator;
        
        // if you modal cover all behind view controller, use UIModalPresentationFullScreen
        modalVC.modalPresentationStyle = UIModalPresentationStyle.Custom;
    }
    
}

