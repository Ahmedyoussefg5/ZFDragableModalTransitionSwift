# ZFDragableModalTransition


###  Objective-C Version [ZFDragableModalTransition](https://github.com/zoonooz/ZFDragableModalTransition)

<p align="center"><img src="https://raw.githubusercontent.com/zoonooz/ZFDragableModalTransition/master/Screenshot/ss.gif"/></p>

## Usage

```swift
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
```
###ScrollView
If you have scrollview in the modal and you want to dismiss modal by drag it, you need to set scrollview to ZFModalTransitionAnimator instance.
```swift
self.animator.setContentScrollView(modalVC.scrollView)
```

###Direction
You can set that which direction will our modal present. (default is ZFModalTransitonDirectionBottom)
```swift
self.animator.direction = ZFModalTransitonDirection.Bottom
```
P.S. Now you can set content scrollview only with ZFModalTransitonDirection.Bottom



## Installation

Soon ZFDragableModalTransitionSwift is available through [CocoaPods](http://cocoapods.org).


## Author

Ahmed Hamdy, [@dimohamdy](https://twitter.com/dimohamdy)

## Thanks
Amornchai Kanokpullwad, [@zoonref](https://twitter.com/zoonref)

## License

ZFDragableModalTransitionSwift is available under the MIT license. See the LICENSE file for more info.
