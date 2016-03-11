//
//  ZFDetectScrollViewEndGestureRecognizer.swift
//  ZFDragableModalTransitionSwift
//
//  Created by binaryboy on 3/10/16.
//  Copyright © 2016 AhmedHamdy. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

enum ZFModalTransitonDirection: Int{
    case Bottom
    case Left
    case Right
}


class ZFDetectScrollViewEndGestureRecognizer: UIPanGestureRecognizer {
    var scrollview :UIScrollView?
    private var  isFail :Bool?
    
    override init(target: AnyObject?, action: Selector) {
        super.init(target: target, action: action)
    }
    override func reset(){
        super.reset()
        self.isFail = false
    }
    
    
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        super.touchesMoved(touches, withEvent:event!)
        
        if self.scrollview == nil {
            return;
        }
        
        if self.state == UIGestureRecognizerState.Failed{
            return
        }
        let velocity:CGPoint = self.velocityInView(self.view)
        let nowPoint:CGPoint = touches.first!.locationInView(self.view)
        let prevPoint:CGPoint = touches.first!.previousLocationInView(self.view)
        
        if ((self.isFail) != nil) {
            if (self.isFail!.boolValue) {
                self.state = UIGestureRecognizerState.Failed
            }
            return;
        }
        
        let topVerticalOffset:CGFloat = -self.scrollview!.contentInset.top
        
        if ((fabs(velocity.x) < fabs(velocity.y)) && (nowPoint.y > prevPoint.y) && (self.scrollview!.contentOffset.y <= topVerticalOffset)) {
            self.isFail = false;
        } else if (self.scrollview!.contentOffset.y >= topVerticalOffset) {
            self.state = UIGestureRecognizerState.Failed
            self.isFail = true
        } else {
            self.isFail = false
        }
    }
    
    
}
class ZFModalTransitionAnimator: UIPercentDrivenInteractiveTransition,UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {
    private var _dragable: Bool? = true
    
    
    var dragable: Bool{
        set {
            self._dragable = dragable
            
            if dragable {
                
                self.removeGestureRecognizerFromModalController()
                
                self.gesture = ZFDetectScrollViewEndGestureRecognizer(target: self, action: "handlePan:")
                
                self.gesture!.delegate = self
                
                self.modalController!.view.addGestureRecognizer(self.gesture!)
                
            } else {
                
                
                self.removeGestureRecognizerFromModalController()
            }
            
        }
        get {
            
            return self._dragable!
            
            
            
        }
    }
    
    func removeGestureRecognizerFromModalController(){
        
        
        //        
        //        if (self.gesture != nil ) && self.modalController!.view.gestureRecognizers!.contains(self.gesture!) {
        //            
        //            self.modalController!.view.removeGestureRecognizer(self.gesture!)
        //            self.gesture = nil;
        //        }
    }
    //    private(set) var gesture: ZFDetectScrollViewEndGestureRecognizer
    var  gestureRecognizerToFailPan: UIGestureRecognizer?
    var bounces: Bool
    var direction: ZFModalTransitonDirection = ZFModalTransitonDirection.Bottom
    var behindViewScale,behindViewAlpha,transitionDuration :CGFloat
    
    weak private var modalController: UIViewController?
    private var gesture: ZFDetectScrollViewEndGestureRecognizer?
    private var transitionContext: UIViewControllerContextTransitioning?
    private var panLocationStart: CGFloat = 0.0
    private var isDismiss = true,isInteractive:Bool = false
    
    private var tempTransform: CATransform3D?
    
    
    init(modalViewController: UIViewController){
        
        
        self.bounces = true
        self.behindViewScale = 0.9
        self.behindViewAlpha = 1.0
        self.transitionDuration = 0.8
        
        self.gestureRecognizerToFailPan = UIGestureRecognizer()
        self.gesture = ZFDetectScrollViewEndGestureRecognizer()
        
        super.init()
        
        self.modalController = modalViewController
        //        self.dragable = true
        
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged", name:UIApplicationDidChangeStatusBarFrameNotification, object: nil)
        
    }
    deinit {
        // perform the deinitialization
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
    }
    func setContentScrollView(scrollView: UIScrollView?){
        // always enable drag if scrollview is set
        if !self.dragable {
            self.dragable = true
        }
        // and scrollview will work only for bottom mode
        self.direction = ZFModalTransitonDirection.Bottom;
        self.gesture!.scrollview = scrollView;
    }
    
    func setDirection(direction :ZFModalTransitonDirection){
        self.direction = direction;
        // scrollview will work only for bottom mode
        if self.direction != ZFModalTransitonDirection.Bottom {
            self.gesture!.scrollview = nil;
        }
    }
    
    func animationEnded(transitionCompleted: Bool){
        // Reset to our default state
        self.isInteractive = false
        self.transitionContext = nil
    }
    
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) ->NSTimeInterval{
        return NSTimeInterval(self.transitionDuration)
    }
    
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning)
    {
        if self.isInteractive {
            return;
        }
        // Grab the from and to view controllers from the context
        let  fromViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        
        
        let toViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        let containerView: UIView = transitionContext.containerView()!
        
        if !self.isDismiss {
            
            var startRect: CGRect
            
            containerView.addSubview(toViewController.view)
            
            toViewController.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            
            switch self.direction{
            case ZFModalTransitonDirection.Bottom:
                startRect = CGRectMake(0,
                    CGRectGetHeight(containerView.frame),
                    CGRectGetWidth(containerView.bounds),
                    CGRectGetHeight(containerView.bounds))
                
            case ZFModalTransitonDirection.Left:
                startRect = CGRectMake(-CGRectGetWidth(containerView.frame),
                    0,
                    CGRectGetWidth(containerView.bounds),
                    CGRectGetHeight(containerView.bounds));
                
            case ZFModalTransitonDirection.Right:
                
                startRect = CGRectMake(CGRectGetWidth(containerView.frame),
                    0,
                    CGRectGetWidth(containerView.bounds),
                    CGRectGetHeight(containerView.bounds));
                
            }
            
            let transformedPoint: CGPoint = CGPointApplyAffineTransform(startRect.origin, toViewController.view.transform);
            toViewController.view.frame = CGRectMake(transformedPoint.x, transformedPoint.y, startRect.size.width, startRect.size.height);
            
            if (toViewController.modalPresentationStyle == UIModalPresentationStyle.Custom) {
                fromViewController.beginAppearanceTransition(false ,animated:true)
            }
            
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0,usingSpringWithDamping: 0.8,initialSpringVelocity: 0.1,options:UIViewAnimationOptions.CurveEaseOut,animations:{
                fromViewController.view.transform = CGAffineTransformScale(fromViewController.view.transform, self.behindViewScale, self.behindViewScale)
                fromViewController.view.alpha = self.behindViewAlpha
                
                toViewController.view.frame = CGRectMake(0,0,
                    CGRectGetWidth(toViewController.view.frame),
                    CGRectGetHeight(toViewController.view.frame))
                
                },completion: {(finished: Bool) in
                    if toViewController.modalPresentationStyle == UIModalPresentationStyle.Custom {
                        fromViewController.endAppearanceTransition()
                    }
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
        }else{
            
            if fromViewController.modalPresentationStyle == UIModalPresentationStyle.FullScreen {
                containerView.addSubview(toViewController.view)
            }
            
            containerView.bringSubviewToFront(fromViewController.view)
            
            if !self.isPriorToIOS8() {
                toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, self.behindViewScale, self.behindViewScale, 1);
            }
            
            toViewController.view.alpha = self.behindViewAlpha;
            
            var endRect: CGRect
            
            
            switch self.direction{
            case ZFModalTransitonDirection.Bottom:
                endRect = CGRectMake(0,
                    CGRectGetHeight(fromViewController.view.bounds),
                    CGRectGetWidth(fromViewController.view.frame),
                    CGRectGetHeight(fromViewController.view.frame));
                
            case ZFModalTransitonDirection.Left:
                endRect = CGRectMake(-CGRectGetWidth(fromViewController.view.bounds),
                    0,
                    CGRectGetWidth(fromViewController.view.frame),
                    CGRectGetHeight(fromViewController.view.frame));
                
            case ZFModalTransitonDirection.Right:
                endRect = CGRectMake(CGRectGetWidth(fromViewController.view.bounds),
                    0,
                    CGRectGetWidth(fromViewController.view.frame),
                    CGRectGetHeight(fromViewController.view.frame))
                
            }
            
            let transformedPoint: CGPoint = CGPointApplyAffineTransform(endRect.origin, fromViewController.view.transform);
            endRect = CGRectMake(transformedPoint.x, transformedPoint.y, endRect.size.width, endRect.size.height);
            
            if fromViewController.modalPresentationStyle == UIModalPresentationStyle.Custom {
                toViewController.beginAppearanceTransition(true, animated:true)
            }
            
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                let scaleBack:CGFloat = (1 / self.behindViewScale)
                toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, scaleBack, scaleBack, 1)
                toViewController.view.alpha = 1.0
                fromViewController.view.frame = endRect
                }, completion: { (finished: Bool) -> Void in
                    toViewController.view.layer.transform = CATransform3DIdentity;
                    
                    //FIXME: This is WRONG!
                    
                    if (fromViewController.modalPresentationStyle == UIModalPresentationStyle.Custom) {
                        toViewController.endAppearanceTransition()
                    }
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
            })
            
            
        }
    }
    
    //MARK: Utils
    
    func isPriorToIOS8()-> Bool{
        
        switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
        case .OrderedSame, .OrderedDescending:
            return false
        case .OrderedAscending:
            return true
        }
    }
    
    
    //MARK: - Gesture
    
    //    - (void)handlePan:(UIPanGestureRecognizer *)recognizer
    func handlePan(recognizer:UIPanGestureRecognizer){
        
        // Location reference
        var location: CGPoint = recognizer.locationInView(self.modalController!.view.window)
        location = CGPointApplyAffineTransform(location, CGAffineTransformInvert(recognizer.view!.transform))
        // Velocity reference
        var velocity:CGPoint = recognizer.velocityInView(self.modalController!.view.window)
        velocity = CGPointApplyAffineTransform(velocity, CGAffineTransformInvert(recognizer.view!.transform))
        
        
        
        switch recognizer.state{
        case UIGestureRecognizerState.Began:
            self.isInteractive = true
            if (self.direction == ZFModalTransitonDirection.Bottom) {
                self.panLocationStart = location.y;
            } else {
                self.panLocationStart = location.x;
            }
            self.modalController?.dismissViewControllerAnimated(true, completion: nil)
            
        case UIGestureRecognizerState.Changed:
            var animationRatio:CGFloat = 0;
            
            if (self.direction == ZFModalTransitonDirection.Bottom) {
            } else if (self.direction == ZFModalTransitonDirection.Left) {
            } else if (self.direction == ZFModalTransitonDirection.Right) {
            }
            
            switch self.direction{
            case ZFModalTransitonDirection.Bottom:
                animationRatio = (location.y - self.panLocationStart) / (CGRectGetHeight(self.modalController!.view.bounds))
            case ZFModalTransitonDirection.Left:
                animationRatio = (self.panLocationStart - location.x) / (CGRectGetWidth(self.modalController!.view.bounds))
            case ZFModalTransitonDirection.Right:
                animationRatio = (location.x - self.panLocationStart) / (CGRectGetWidth(self.modalController!.view.bounds))
                
            }
            
            self.updateInteractiveTransition(animationRatio)
            
        case UIGestureRecognizerState.Ended:
            
            var velocityForSelectedDirection:CGFloat
            
            if (self.direction == ZFModalTransitonDirection.Bottom) {
                velocityForSelectedDirection = velocity.y;
            } else {
                velocityForSelectedDirection = velocity.x;
            }
            
            if (velocityForSelectedDirection > 100
                && (self.direction == ZFModalTransitonDirection.Right
                    || self.direction == ZFModalTransitonDirection.Bottom)) {
                        self.finishInteractiveTransition()
            } else if (velocityForSelectedDirection < -100 && self.direction == ZFModalTransitonDirection.Left) {
                self.finishInteractiveTransition()
            } else {
                self.cancelInteractiveTransition()
            }
            self.isInteractive = false
            
            
        default: break
            
        }
    }
    
    //MARK:  -
    
    
    override func startInteractiveTransition(transitionContext: UIViewControllerContextTransitioning){
        
        self.transitionContext = transitionContext;
        
        let fromViewController:UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController:UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        if (!self.isPriorToIOS8()) {
            toViewController.view.layer.transform = CATransform3DScale(toViewController.view.layer.transform, self.behindViewScale, self.behindViewScale, 1);
        }
        
        self.tempTransform = toViewController.view.layer.transform;
        
        toViewController.view.alpha = self.behindViewAlpha;
        
        if (fromViewController.modalPresentationStyle == UIModalPresentationStyle.FullScreen) {
            transitionContext.containerView()!.addSubview(toViewController.view)
        }
        transitionContext.containerView()!.bringSubviewToFront(fromViewController.view)
    }
    
    override func updateInteractiveTransition(var percentComplete: CGFloat){
        
        
        if !self.bounces && percentComplete < 0 {
            percentComplete = 0
        }
        
        let transitionContext:UIViewControllerContextTransitioning = self.transitionContext!
        
        let fromViewController:UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController:UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let transform:CATransform3D = CATransform3DMakeScale(
            1 + (((1 / self.behindViewScale) - 1) * percentComplete),
            1 + (((1 / self.behindViewScale) - 1) * percentComplete), 1);
        toViewController.view.layer.transform = CATransform3DConcat(self.tempTransform!, transform);
        
        toViewController.view.alpha = self.behindViewAlpha + ((1 - self.behindViewAlpha) * percentComplete);
        
        var updateRect:CGRect
        
        
        switch self.direction {
        case ZFModalTransitonDirection.Bottom:
            updateRect = CGRectMake(0,
                (CGRectGetHeight(fromViewController.view.bounds) * percentComplete),
                CGRectGetWidth(fromViewController.view.frame),
                CGRectGetHeight(fromViewController.view.frame));
        case ZFModalTransitonDirection.Left:
            updateRect = CGRectMake(-(CGRectGetWidth(fromViewController.view.bounds) * percentComplete),
                0,
                CGRectGetWidth(fromViewController.view.frame),
                CGRectGetHeight(fromViewController.view.frame));
        case ZFModalTransitonDirection.Right:
            updateRect = CGRectMake(CGRectGetWidth(fromViewController.view.bounds) * percentComplete,
                0,
                CGRectGetWidth(fromViewController.view.frame),
                CGRectGetHeight(fromViewController.view.frame));
        }
        
        
        // reset to zero if x and y has unexpected value to prevent crash
        if (isnan(updateRect.origin.x) || isinf(updateRect.origin.x)) {
            updateRect.origin.x = 0;
        }
        if (isnan(updateRect.origin.y) || isinf(updateRect.origin.y)) {
            updateRect.origin.y = 0;
        }
        
        let transformedPoint:CGPoint = CGPointApplyAffineTransform(updateRect.origin, fromViewController.view.transform);
        updateRect = CGRectMake(transformedPoint.x, transformedPoint.y, updateRect.size.width, updateRect.size.height);
        
        fromViewController.view.frame = updateRect;
    }
    override func finishInteractiveTransition(){
        let transitionContext:UIViewControllerContextTransitioning = self.transitionContext!;
        
        let fromViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController: UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        var endRect:CGRect
        
        switch self.direction {
        case ZFModalTransitonDirection.Bottom:
            endRect = CGRectMake(0,
                CGRectGetHeight(fromViewController.view.bounds),
                CGRectGetWidth(fromViewController.view.frame),
                CGRectGetHeight(fromViewController.view.frame));
        case ZFModalTransitonDirection.Left:
            endRect = CGRectMake(-CGRectGetWidth(fromViewController.view.bounds),
                0,
                CGRectGetWidth(fromViewController.view.frame),
                CGRectGetHeight(fromViewController.view.frame));
        case ZFModalTransitonDirection.Right:
            endRect = CGRectMake(CGRectGetWidth(fromViewController.view.bounds),
                0,
                CGRectGetWidth(fromViewController.view.frame),
                CGRectGetHeight(fromViewController.view.frame));
            
        }
        
        
        let transformedPoint:CGPoint = CGPointApplyAffineTransform(endRect.origin, fromViewController.view.transform);
        endRect = CGRectMake(transformedPoint.x, transformedPoint.y, endRect.size.width, endRect.size.height);
        
        if fromViewController.modalPresentationStyle == UIModalPresentationStyle.Custom {
            toViewController.beginAppearanceTransition(true, animated:true)
        }
        
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            let scaleBack:CGFloat = (1 / self.behindViewScale);
            toViewController.view.layer.transform = CATransform3DScale(self.tempTransform!, scaleBack, scaleBack, 1);
            toViewController.view.alpha = 1.0
            fromViewController.view.frame = endRect;
            }, completion: { (finished: Bool) -> Void in
                    if (fromViewController.modalPresentationStyle == UIModalPresentationStyle.Custom) {
                        toViewController.endAppearanceTransition()
                    }
                    transitionContext.completeTransition(true)
        })
    }
    
    override func cancelInteractiveTransition(){
        
        
        let transitionContext: UIViewControllerContextTransitioning = self.transitionContext!;
        transitionContext.cancelInteractiveTransition()
        
        let fromViewController:UIViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController:UIViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.1, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            toViewController.view.layer.transform = self.tempTransform!;
            toViewController.view.alpha = self.behindViewAlpha;
            
            fromViewController.view.frame = CGRectMake(0,0,
                CGRectGetWidth(fromViewController.view.frame),
                CGRectGetHeight(fromViewController.view.frame));
            }, completion: { (finished: Bool) -> Void in
                transitionContext.completeTransition(false)
                if fromViewController.modalPresentationStyle == UIModalPresentationStyle.FullScreen {
                    toViewController.view.removeFromSuperview()
                }
        })
    }
    
    //MARK: - UIViewControllerTransitioningDelegate Methods
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        self.isDismiss = false
        return self
    }
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        
        self.isDismiss = true
        return self
    }
    
    func interactionControllerForPresentation(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
        
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        // Return nil if we are not interactive
        if self.isInteractive && self.dragable {
            self.isDismiss = true
            return self
        }
        
        return nil;
        
    }
    
    
    
    //MARK: - Gesture Delegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.direction == ZFModalTransitonDirection.Bottom {
            return true
        }
        return false
    }
    
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (self.direction == ZFModalTransitonDirection.Bottom) {
            return true
        }
        return false
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (self.gestureRecognizerToFailPan != nil)  && (self.gestureRecognizerToFailPan == otherGestureRecognizer) {
            return true
        }
        
        return false
    }
    
    
    
    func orientationChanged(notification: NSNotification) {
        let backViewController: UIViewController? = self.modalController!.presentingViewController
        backViewController!.view.transform = CGAffineTransformIdentity
        backViewController!.view.frame = self.modalController!.view.bounds
        backViewController!.view.transform = CGAffineTransformScale(backViewController!.view.transform, self.behindViewScale, self.behindViewScale)
    }
    
}
