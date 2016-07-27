//
//  SSDrawerViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 6. 5..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

let SSDrawerDefaultOpenStateRevealWidthHorizontal: CGFloat = UIScreen.mainScreen().bounds.size.width * (332.0 / 414.0)
let SSDrawerDefaultOpenStateRevealWidthVertical: CGFloat = 300.0
let SSPaneViewVelocityThreshold: CGFloat = 5.0
let SSPaneViewVelocityMultiplier: CGFloat = 5.0
let SSPaneViewScreenEdgeThreshold: CGFloat = 24.0; // After testing Apple's `UIScreenEdgePanGestureRecognizer` this seems to be the closest value to create an equivalent effect.
let SSPaneStatePositionValidityEpsilon: CGFloat = 2.0

/**
 To respond to the updates to `paneState` for an instance of `MSDynamicsDrawerViewController`, configure a custom class to adopt the `MSDynamicsDrawerViewControllerDelegate` protocol and set it as the `delegate` object.
 */
protocol SSDrawerViewControllerDelegate {
    /**
     Informs the delegate that the drawer view controller will attempt to update to a pane state in the specified direction.

     It is important to note that the user is able to interrupt this change, and therefore is it not guaranteed that this update will occur. If desired, the user can be prevented from interrupting by passing `NO` for the `allowingUserInterruption` parameter in methods that update the `paneState`. For the aforementioned reasons, this method does not always pair with an invocation of `dynamicsDrawerViewController:didUpdateToPaneState:forDirection:`.

     @param drawerViewController The drawer view controller that the delegate is registered with.
     @param paneState The pane state that the view controller will attempt to update to.
     @param direction When the pane state is updating to `MSDynamicsDrawerPaneStateClosed`: the direction that the drawer view controller is transitioning from. When the pane state is updating to `MSDynamicsDrawerPaneStateOpen` or `MSDynamicsDrawerPaneStateOpenWide`: the direction that the drawer view controller is transitioning to.
     */
    func drawerViewController(drawerViewController: SSDrawerViewController, mayUpdateToPaneState paneState: SSDrawerMainState, forDirection direction: SSDrawerDirection)

    /**
     Informs the delegate that the drawer view controller did update to a pane state in the specified direction.

     @param drawerViewController The drawer view controller that the delegate is registered with.
     @param paneState The pane state that the view controller did update to.
     @param direction When the pane state is updating to `MSDynamicsDrawerPaneStateClosed`: the direction that the drawer view controller is transitioning from. When the pane state is updating to `MSDynamicsDrawerPaneStateOpen` or `MSDynamicsDrawerPaneStateOpenWide`: the direction that the drawer view controller is transitioning to.
     */
    func drawerViewController(drawerViewController: SSDrawerViewController, didUpdateToPaneState paneState: SSDrawerMainState, forDirection direction: SSDrawerDirection)

    /**
     Queries the delegate for whether the dynamics drawer view controller should begin a pane pan

     @param drawerViewController The drawer view controller that the delegate is registered with.
     @param panGestureRecognizer The internal pan gesture recognizer that is responsible for panning the pane. The behavior resulting from modifying attributes of this gesture recognizer is undefined and not recommended.

     @return Whether the drawer view controller should begin a pane pan
     */
    func drawerViewController(drawerViewController: SSDrawerViewController, shouldBeginPanePan panGestureRecognizer: UIPanGestureRecognizer) -> Bool
}

extension SSDrawerViewControllerDelegate {
    func drawerViewController(drawerViewController: SSDrawerViewController, shouldBeginPanePan panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return true
    }
}

/**
 The drawer direction defines the direction that a `MSDynamicsDrawerViewController` instance's `paneView` can be opened in.

 The values can be masked in some (but not all) cases. See the parameters of individual methods to ensure compatibility with the `MSDynamicsDrawerDirection` that is being passed.
 */
struct SSDrawerDirection: OptionSetType, Hashable {
    let rawValue: UInt

    /**
     Represents the state of no direction.
     */
    static let None = SSDrawerDirection(rawValue: UIRectEdge.None.rawValue)
    /**
     A drawer that is revealed from underneath the top edge of the pane.
     */
    static let Top = SSDrawerDirection(rawValue: UIRectEdge.Top.rawValue)
    /**
     A drawer that is revealed from underneath the left edge of the pane.
     */
    static let Left = SSDrawerDirection(rawValue: UIRectEdge.Left.rawValue)
    /**
     A drawer that is revealed from underneath the bottom edge of the pane.
     */
    static let Bottom = SSDrawerDirection(rawValue: UIRectEdge.Bottom.rawValue)
    /**
     A drawer that is revealed from underneath the right edge of the pane.
     */
    static let Right = SSDrawerDirection(rawValue: UIRectEdge.Right.rawValue)
    /**
     The drawers that are revealed from underneath both the left and right edges of the pane.
     */
    static let Horizontal = SSDrawerDirection(rawValue: UIRectEdge.Left.rawValue | UIRectEdge.Right.rawValue)
    /**
     The drawers that are revealed from underneath both the top and bottom edges of the pane.
     */
    static let Vertical = SSDrawerDirection(rawValue: UIRectEdge.Top.rawValue | UIRectEdge.Bottom.rawValue)
    /**
     The drawers that are revealed from underneath all edges of the pane.
     */
    static let All = SSDrawerDirection(rawValue: UIRectEdge.All.rawValue)

    static let AllTypes = [None, Top, Left, Bottom, Right, Horizontal, Vertical, All]

    internal var hashValue: Int {
        return Int(self.rawValue)
    }

    static func isValid(direction: SSDrawerDirection) -> Bool {
        switch direction {
        case SSDrawerDirection.None, SSDrawerDirection.Top, SSDrawerDirection.Left, SSDrawerDirection.Bottom, SSDrawerDirection.Right, SSDrawerDirection.Horizontal, SSDrawerDirection.Vertical, SSDrawerDirection.All:
            return true
        default:
            return false
        }
    }

    static func isCardinal(direction: SSDrawerDirection) -> Bool {
        switch direction {
        case SSDrawerDirection.Top, SSDrawerDirection.Left, SSDrawerDirection.Bottom, SSDrawerDirection.Right:
            return true
        default:
            return false
        }
    }

    static func isNonMasked(direction: SSDrawerDirection) -> Bool {
        switch direction {
        case None, Top, Left, Bottom, Right:
            return true
        default:
            return false
        }
    }

    static func drawerDirectionFromRawValue(rawValue: UInt) -> SSDrawerDirection {
        switch rawValue {
        case SSDrawerDirection.None.rawValue:
            return SSDrawerDirection.None
        case SSDrawerDirection.Top.rawValue:
            return SSDrawerDirection.Top
        case SSDrawerDirection.Left.rawValue:
            return SSDrawerDirection.Left
        case SSDrawerDirection.Bottom.rawValue:
            return SSDrawerDirection.Bottom
        case SSDrawerDirection.Right.rawValue:
            return SSDrawerDirection.Right
        case SSDrawerDirection.Horizontal.rawValue:
            return SSDrawerDirection.Horizontal
        case SSDrawerDirection.Vertical.rawValue:
            return SSDrawerDirection.Vertical
        case SSDrawerDirection.All.rawValue:
            return SSDrawerDirection.All
        default:
            return SSDrawerDirection.None
        }
    }

    static func drawerDirectionActionForMaskedValues(direction: SSDrawerDirection, action: SSDrawerActionBlock) -> Void {
        for drawerDirection in SSDrawerDirection.AllTypes {
            if (drawerDirection & direction) != SSDrawerDirection.None {
                action(maskedValue: drawerDirection)
            }
        }
    }

    subscript(indexes: Int...) -> [SSDrawerDirection] {
        var directions = [SSDrawerDirection]()

        for i in indexes {
            directions.append(SSDrawerDirection.AllTypes[i])
        }

        return directions
    }
}

func &(left: SSDrawerDirection, right: SSDrawerDirection) -> SSDrawerDirection {
    return SSDrawerDirection(rawValue: left.rawValue & right.rawValue)
}

func |(left: SSDrawerDirection, right: SSDrawerDirection) -> SSDrawerDirection {
    return SSDrawerDirection(rawValue: left.rawValue | right.rawValue)
}

func |=(inout left: SSDrawerDirection, right: SSDrawerDirection) -> Void {
    left = SSDrawerDirection(rawValue: left.rawValue | right.rawValue)
}

func ^=(inout left: SSDrawerDirection, right: SSDrawerDirection) -> Void {
    left = SSDrawerDirection(rawValue: left.rawValue ^ right.rawValue)
}

func ==(left: SSDrawerDirection, right: SSDrawerDirection) -> Bool {
    return left.rawValue == right.rawValue
}

func !=(left: SSDrawerDirection, right: SSDrawerDirection) -> Bool {
    return left.rawValue != right.rawValue
}

/**
 The possible drawer/pane visibility states of `MSDynamicsDrawerViewController`.
 */
enum SSDrawerMainState: Int {
    case None = 0
    /**
     The the drawer is entirely hidden by the pane.
     */
    case Closed
    /**
     The drawer is revealed underneath the pane to the specified open width.
     */
    case Open
    /**
     The drawer view is entirely visible, with the pane opened wide enough as to no longer be visible.
     */
    case OpenWide

    static let AllValues = [Closed, Open, OpenWide]
}

func &(left: SSDrawerMainState, right: SSDrawerMainState) -> SSDrawerMainState {
    return SSDrawerMainState(rawValue: (left.rawValue & right.rawValue))!
}

func |(left: SSDrawerMainState, right: SSDrawerMainState) -> SSDrawerMainState {
    return SSDrawerMainState(rawValue: (left.rawValue | right.rawValue))!
}

//----------------
// @name Functions
//----------------

/**
 The action block used in @see MSDynamicsDrawerDirectionActionForMaskedValues.
 */
typealias SSDrawerActionBlock = (maskedValue: SSDrawerDirection) -> Void;

/**
 `SSDrawerViewController` is a container view controller that manages the presentation of a single "pane" view controller overlaid over one or two "drawer" view controllers. The drawer view controllers are hidden by default, but can be exposed by a user-initiated swipe in the direction that that drawer view controller is set in.
 */
class SSDrawerViewController: UIViewController, UIDynamicAnimatorDelegate, UIGestureRecognizerDelegate {
    private let SSDrawerBoundaryIdentifier = "SSDrawerBoundaryIdentifier"

    //----------------------
    // @name Container Views
    //----------------------

    /**
     The pane view contains the pane view controller's view.

     The user can slide the `paneView` in any of the directions defined in `possibleDrawerDirection` to reveal the drawer view controller underneath. The frame of the `paneView` is frequently updated by internal dynamics and user gestures.
     */
    var mainView: UIView
    /**
     The drawer view contains the currently visible drawer view controller's view.

     The `drawerView` is always presented underneath the `paneView`. The frame of the `drawerView` never moves, and it is not affected by dynamics.
     */
    var drawerView: UIView

    //------------------------------------
    // @name Accessing the Delegate Object
    //------------------------------------

    /**
     The delegate you want to receive dynamics drawer view controller messages.

     The dynamics drawer view controller informs its delegate of changes to the state of the drawer view controller. For more information about the methods you can implement in your delegate, `MSDynamicsDrawerViewControllerDelegate`.
     */
    var delegate: SSDrawerViewControllerDelegate?

    //------------------------------------------
    // @name Managing the Child View Controllers
    //------------------------------------------

    /**
     The pane view controller is the primary view controller, displayed centered and covering the drawer view controllers.

     @see setPaneViewController:animated:completion:
     @see paneState
     */
    var _mainViewController: UIViewController? = nil
    var mainViewController: UIViewController? {
        get {
            return self._mainViewController
        }
        set {
            self.replaceViewController(self._mainViewController, withViewController: newValue, inContainerView: self.mainView) { [unowned self] in
                self._mainViewController = newValue
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    //----------------------------------
    // @name Accessing & Modifying State
    //----------------------------------

    /**
     The state of the pane view as defined in a `MSDynamicsDrawerPaneState`.

     The possible states are `MSDynamicsDrawerPaneStateClosed`, where the `drawerView` is entirely hidden by the `paneView`, `MSDynamicsDrawerPaneStateOpen`, wherein the `drawerView` is revealed to the reveal width for the specified direction, and `MSDynamicsDrawerPaneStateOpenWide` where the `drawerView` in revealed by the `paneView` in its entirety such that the `paneView` is opened past the edge of the screen. If there is more than one drawer view controller set, use `setPaneState:inDirection:` instead and specify a direction.

     @see setPaneState:inDirection:
     @see setPaneState:animated:allowUserInterruption:completion:
     @see setPaneState:inDirection:animated:allowUserInterruption:completion:
     */
    var _mainState: SSDrawerMainState
    var mainState: SSDrawerMainState {
        get {
            return self.mainState
        }
        set {
            self.setMainState(newValue, animated: false, allowUserInterruption: false, completion: nil)
        }
    }

    /**
     The directions that the `paneView` can be opened in.

     Corresponds to the directions that there are drawer view controllers set for. If more than one drawer view controller is set, this will be a bitmask of the directions that the drawer view controllers are set in.
     */
    var possibleDrawerDirection: SSDrawerDirection
    var mainViewSlideOffAnimationEnabled: Bool
    var shouldAlignStatusBarToPaneView: Bool

    var dynamicAnimator: UIDynamicAnimator?
    var mainPushBehavior: UIPushBehavior?
    var mainElasticityBehavior: UIDynamicItemBehavior?
    var mainGravityBehavior: UIGravityBehavior?
    var mainBoundaryCollisionBehavior: UICollisionBehavior?
    var dynamicAnimatorCompletion: (()->Void)?

    // State
    var _currentDrawerDirection: SSDrawerDirection
    var currentDrawerDirection: SSDrawerDirection {
        get {
            return self._currentDrawerDirection
        }
        set {
            assert(SSDrawerDirection.isNonMasked(newValue), "Only accepts non-masked directions as current reveal direction")
            assert(!((newValue == .None) && (self.mainState != .Closed)), "Can't set direction to none while we have a non-closed pane state")

            if !(self._currentDrawerDirection == newValue) {

                // Inform stylers about the transition between directions when directly transitioning
                if (self._currentDrawerDirection != .None) {
                    let allStylers: NSMutableSet = NSMutableSet();
                    for stylers in self.stylers.values {
                        allStylers.unionSet(stylers as Set<NSObject>)
                    }
                    for styler in allStylers {
                        let drawerStyler: SSDrawerStyler = styler as! SSDrawerStyler
                        drawerStyler.styleDrawerViewController(self, didUpdatePaneClosedFraction: 1.0, forDirection: .None)
                    }
                }

                self._currentDrawerDirection = newValue;

                self.drawerViewController = self.drawerViewControllers[newValue];

                // Disable pane view interaction when not closed
                self.setPaneViewControllerViewUserInteractionEnabled(newValue == .None)

                self.updateStylers()
            }
        }
    }

    var _drawerViewController: UIViewController?
    var drawerViewController: UIViewController? {
        get {
            return self._drawerViewController
        }
        set {
            self.replaceViewController(self._drawerViewController, withViewController: newValue, inContainerView: self.drawerView) { [unowned self] in
                self._drawerViewController = newValue
            }
        }
    }

    // Internal Properties
    var drawerViewControllers: [SSDrawerDirection: UIViewController]
    var revealWidth: [SSDrawerDirection: CGFloat] = [SSDrawerDirection: CGFloat]()
    var openStateRevealWidth: CGFloat {
        return self.revealWidthForDirection(self.currentDrawerDirection)
    }
    var paneDragRevealEnabled: [SSDrawerDirection: Bool] = [SSDrawerDirection: Bool]()
    var paneTapToCloseEnabled: [SSDrawerDirection: Bool] = [SSDrawerDirection: Bool]()
    var stylers: [SSDrawerDirection: NSSet] = [SSDrawerDirection: NSSet]()
    var paneStateOpenWideEdgeOffset: CGFloat
    var potentialPaneState: SSDrawerMainState
    var animatingRotation: Bool

    // Gestures
    var touchForwardingClasses: NSMutableSet = [UISlider.self, UISwitch.self]
    var panePanGestureRecognizer: UIPanGestureRecognizer?
    var paneTapGestureRecognizer: UITapGestureRecognizer?

    ///-------------------------------------
    /// @name Configuring Dynamics Behaviors
    ///-------------------------------------

    /**
     The magnitude of the gravity vector that affects the pane view.

     Default value of `2.0`. A magnitude value of `1.0` represents an acceleration of 1000 points / second².
     */
    var gravityMagnitude: CGFloat

    /**
     The elasticity applied to the pane view.

     Default value of `0.0`. Valid range is from `0.0` for no bounce upon collision, to `1.0` for completely elastic collisions.
     */
    var elasticity: CGFloat

    /**
     The amount of elasticity applied to the pane view when it is bounced open.

     Applies when the pane is bounced open. Default value of `0.5`. Valid range is from `0.0` for no bounce upon collision, to `1.0` for completely elastic collisions.

     @see bouncePaneOpen
     @see bouncePaneOpenInDirection:
     */
    var bounceElasticity: CGFloat

    /**
     The magnitude of the push vector that is applied to the pane view when bouncePaneOpen is called.

     Applies when the pane is bounced open. Default of 60.0. A magnitude value of 1.0 represents an acceleration of 1000 points / second².

     @see bouncePaneOpen
     @see bouncePaneOpenInDirection:
     */
    var bounceMagnitude: CGFloat

    ///--------------------------
    ///@name Configuring Gestures
    ///--------------------------

    /**
     Whether the only pans that can open the drawer should be those that originate from the screen's edges.

     If set to `YES`, pans that originate elsewhere are ignored and have no effect on the drawer. This property is designed to mimic the behavior of the `UIScreenEdgePanGestureRecognizer` as applied to the `MSDynamicsDrawerViewController` interaction paradigm. Setting this property to `YES` yields a similar behavior to that of screen edge pans within a `UINavigationController` in iOS7+. Defaults to `NO`.

     @see screenEdgePanCancelsConflictingGestures
     */
    var paneDragRequiresScreenEdgePan: Bool = false

    /**
     Whether gestures that start at the edge of the screen should be cancelled under the assumption that the user is dragging the pane view to reveal a drawer underneath.

     This behavior only applies to edges that have a corresponding drawer view controller set in the same direction as the edge that the gesture originated in. The primary use of this property is the case of having a `UIScrollView` within the view of the active pane view controller. When the drawers are closed and the user starts a pan-like gesture at the edge of the screen, all other conflicting gesture recognizers will be required to fail, yielding to the internal `UIPanGestureRecognizer` in the `MSDynamicsDrawerViewController` instance. Effectually, this property makes it easier for the user to open the drawers. Defaults to `YES`.

     @see paneDragRequiresScreenEdgePan
     */
    var screenEdgePanCancelsConflictingGestures: Bool = true

    required init?(coder aDecoder: NSCoder) {

        self._mainState = .Closed
        self.mainViewSlideOffAnimationEnabled = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone
        self.shouldAlignStatusBarToPaneView = true
        self._currentDrawerDirection = SSDrawerDirection.None
        self.potentialPaneState = .None
        self.animatingRotation = false
        self.possibleDrawerDirection = SSDrawerDirection.None

        self.mainView = UIView()
        self.drawerView = UIView()

        self.gravityMagnitude = 2.0
        self.elasticity = 0.0
        self.bounceElasticity = 0.5
        self.bounceMagnitude = 60.0
        self.paneStateOpenWideEdgeOffset = 20.0

        self.drawerViewControllers = [SSDrawerDirection: UIViewController]()

        super.init(coder: aDecoder)

        self.mainView.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)

        self.initializeGesture()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {

        self._mainState = .Closed
        self.mainViewSlideOffAnimationEnabled = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone
        self.shouldAlignStatusBarToPaneView = true
        self._currentDrawerDirection = SSDrawerDirection.None
        self.potentialPaneState = .None
        self.animatingRotation = false
        self.possibleDrawerDirection = SSDrawerDirection.None

        self.mainView = UIView()
        self.mainView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        self.drawerView = UIView()
        self.drawerView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]

        self.gravityMagnitude = 2.0
        self.elasticity = 0.0
        self.bounceElasticity = 0.5
        self.bounceMagnitude = 60.0
        self.paneStateOpenWideEdgeOffset = 20.0

        self.drawerViewControllers = [SSDrawerDirection: UIViewController]()

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.mainView.addObserver(self, forKeyPath: "frame", options: NSKeyValueObservingOptions(rawValue: 0), context: nil)

        self.initializeGesture()
    }

    deinit {
        self.mainView.removeObserver(self, forKeyPath: "frame")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.drawerView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.drawerView)
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.drawerView]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": self.drawerView]))

        self.mainView.frame = self.view.bounds
        self.view.addSubview(self.mainView)

        self.dynamicAnimator = UIDynamicAnimator(referenceView: self.view)
        self.dynamicAnimator?.delegate = self

        self.mainBoundaryCollisionBehavior = UICollisionBehavior(items: [self.mainView])
        self.mainGravityBehavior = UIGravityBehavior(items: [self.mainView])
        self.mainPushBehavior = UIPushBehavior(items: [self.mainView], mode: .Instantaneous)
        self.mainElasticityBehavior = UIDynamicItemBehavior(items: [self.mainView])

        self.mainGravityBehavior?.action = { [unowned self] in
            self.didUpdateDynamicAnimatorAction()
        }
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ [unowned self] (transitionCoordinatorContext) in
            self.animatingRotation = true
            }) { [unowned self] (transitionCoordinatorContext) in
                self.animatingRotation = false
                self.updateStylers()
        }

        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    override func shouldAutorotate() -> Bool {
        return (!self.dynamicAnimator!.running && (self.panePanGestureRecognizer!.state == UIGestureRecognizerState.Possible))
    }

    func initializeGesture() -> Void {

        self.panePanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panePanned))
        self.panePanGestureRecognizer?.minimumNumberOfTouches = 1;
        self.panePanGestureRecognizer?.maximumNumberOfTouches = 1;
        self.panePanGestureRecognizer?.delegate = self;
        self.mainView.addGestureRecognizer(self.panePanGestureRecognizer!)

        self.paneTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(paneTapped))
        self.paneTapGestureRecognizer?.numberOfTouchesRequired = 1;
        self.paneTapGestureRecognizer?.numberOfTapsRequired = 1;
        self.paneTapGestureRecognizer?.delegate = self;
        self.mainView.addGestureRecognizer(self.paneTapGestureRecognizer!)
    }

    /**
     Sets the `paneViewController` with an animated transition.

     If the value for the `animated` parameter is `NO`, then this method is functionally equivalent to using the `paneViewController` setter.

     @param paneViewController The `paneViewController` to be added.
     @param animated Whether adding the pane should be animated.
     @param completion An optional completion block called upon the completion of the `paneViewController` being set.

     @see paneViewController
     @see paneViewSlideOffAnimationEnabled
     */
    func setMainViewController(mainViewController: UIViewController, animated: Bool, completion: (()-> Void)?) -> Void {
        if !animated {
            self.mainViewController = mainViewController
            guard let _ = completion?() else {
                return
            }

            return
        }

        if self.mainViewController != mainViewController {
            self.mainViewController?.willMoveToParentViewController(nil)
            self.mainViewController?.beginAppearanceTransition(true, animated: animated)

            let transitionToNewMainViewController: () -> Void = {
                mainViewController.willMoveToParentViewController(self)
                self.mainViewController?.view.removeFromSuperview()
                self.mainViewController?.removeFromParentViewController()
                self.mainViewController?.didMoveToParentViewController(nil)
                self.mainViewController?.endAppearanceTransition()

                self.addChildViewController(mainViewController)
                mainViewController.beginAppearanceTransition(true, animated: animated)
                self.mainView.addSubview(mainViewController.view)
                mainViewController.view.translatesAutoresizingMaskIntoConstraints = false
                self.mainView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": mainViewController.view]))
                self.mainView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": mainViewController.view]))

                self.mainViewController = mainViewController
                self.mainView.setNeedsDisplay()

                CATransaction.flush()

                self.setNeedsStatusBarAppearanceUpdate()

                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    self?.mainViewController = mainViewController
                })
            }

            if self.mainViewSlideOffAnimationEnabled {

            } else {
                transitionToNewMainViewController()
            }
        }
        // If trying to set to the currently visible pane view controller, just close
        else {
            self.setMainState(.Closed, animated: animated, allowUserInterruption: true, completion: {
                guard let _ = completion else {
                    return
                }
            })
        }
    }

// MARK: - Bouncing

    func drawerViewControllerForDirection(direction: SSDrawerDirection) -> UIViewController? {
        assert(SSDrawerDirection.isCardinal(direction), "Only cardinal reveal directions are accepted")
        return self.drawerViewControllers[direction]
    }

// MARK: - Generic View Controller Containment

    func replaceViewController(existingViewController: UIViewController?, withViewController newViewController: UIViewController?, inContainerView containerView: UIView, completion: (()-> Void)?) -> Void {
        // Add initial view controller
        if (existingViewController == nil) && (newViewController != nil) {
            if let newVC = newViewController {
                newVC.willMoveToParentViewController(self)
                newVC.beginAppearanceTransition(true, animated: false)

                self.addChildViewController(newVC)
                containerView.addSubview(newVC.view)
                newVC.view.translatesAutoresizingMaskIntoConstraints = false
                var metrics: [String: CGFloat] = ["left": 0, "right": 0]
                switch self.currentDrawerDirection {
                case SSDrawerDirection.Left:
                    metrics.updateValue(UIScreen.mainScreen().bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "right")
                case SSDrawerDirection.Right:
                    metrics.updateValue(UIScreen.mainScreen().bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "left")
                case SSDrawerDirection.Horizontal:
                    metrics.updateValue(UIScreen.mainScreen().bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "right")
                    metrics.updateValue(UIScreen.mainScreen().bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "left")
                default:
                    break
                }
                containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-left-[view]-right-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: ["view": newVC.view]))
                containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": newVC.view]))

                newVC.didMoveToParentViewController(self)
                newVC.endAppearanceTransition()

                guard let _ = completion?() else {
                    return
                }
            }
        }
        // Remove existing view controller
        else if (existingViewController != nil) && (newViewController == nil) {
            if let existingVC = existingViewController {
                existingVC.willMoveToParentViewController(nil)
                existingVC.beginAppearanceTransition(false, animated: false)
                existingVC.view.removeFromSuperview()
                existingVC.removeFromParentViewController()
                existingVC.didMoveToParentViewController(nil)
                existingVC.endAppearanceTransition()

                guard let _ = completion?() else {
                    return
                }
            }
        }
        // Replace existing view controller with new view controller
        else if (existingViewController !== newViewController) && (newViewController != nil) {
            if let newVC = newViewController, let existingVC = existingViewController {
                newVC.willMoveToParentViewController(self)
                existingVC.willMoveToParentViewController(nil)
                existingVC.beginAppearanceTransition(false, animated: false)
                existingVC.view.removeFromSuperview()
                existingVC.removeFromParentViewController()
                existingVC.didMoveToParentViewController(nil)
                existingVC.endAppearanceTransition()
                newVC.beginAppearanceTransition(true, animated: false)

                self.addChildViewController(newVC)
                containerView.addSubview(newVC.view)
                newVC.view.translatesAutoresizingMaskIntoConstraints = false
                var metrics: [String: CGFloat] = ["left": 0, "right": 0]
                switch self.currentDrawerDirection {
                case SSDrawerDirection.Left:
                    metrics.updateValue(UIScreen.mainScreen().bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "right")
                case SSDrawerDirection.Right:
                    metrics.updateValue(UIScreen.mainScreen().bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "left")
                case SSDrawerDirection.Horizontal:
                    metrics.updateValue(UIScreen.mainScreen().bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "right")
                    metrics.updateValue(UIScreen.mainScreen().bounds.size.width - SSDrawerDefaultOpenStateRevealWidthHorizontal, forKey: "left")
                default:
                    break
                }
                containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-left-[view]-right-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: ["view": newVC.view]))
                containerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[view]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["view": newVC.view]))

                newVC.didMoveToParentViewController(self)
                newVC.endAppearanceTransition()

                guard let _ = completion?() else {
                    return
                }
            }
        }
    }

// MARK: - DrawerViewController

    func setDrawerViewController(drawerViewController: UIViewController?, forDirection direction: SSDrawerDirection) -> Void {
        assert(SSDrawerDirection.isCardinal(direction), "Only accepts cardinal reveal directions")
        for currentDrawerViewController in self.drawerViewControllers.values {
            assert(currentDrawerViewController != drawerViewController, "Unable to add a drawer view controller when it's previously been added")
        }
        if (direction & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            assert(!(self.drawerViewControllers[SSDrawerDirection.Top] != nil || self.drawerViewControllers[SSDrawerDirection.Bottom] != nil), "Unable to simultaneously have top/bottom drawer view controllers while setting left/right drawer view controllers")
        } else if (direction & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            assert(!(self.drawerViewControllers[SSDrawerDirection.Left] != nil || self.drawerViewControllers[SSDrawerDirection.Right] != nil), "Unable to simultaneously have left/right drawer view controllers while setting top/bottom drawer view controllers")
        }

        let existingDrawerViewController = self.drawerViewControllers[direction]
        // New drawer view controller
        if drawerViewController != nil && existingDrawerViewController == nil {
            self.possibleDrawerDirection |= direction
            self.drawerViewControllers[direction] = drawerViewController
        }
        // Removing existing drawer view controller
        else if drawerViewController == nil && existingDrawerViewController != nil {
            self.possibleDrawerDirection ^= direction
            self.drawerViewControllers.removeValueForKey(direction)
        }
        // Replace existing drawer view controller
        else if drawerViewController != nil && existingDrawerViewController != nil {
            self.drawerViewControllers[direction] = drawerViewController
        }
    }

// MARK: - Pane View Controller

    func setPaneViewController(paneViewController: UIViewController, animated: Bool, completion: (()->Void)?) {
        if !animated {
            self.mainViewController = paneViewController
            guard let _ = completion?() else {
                return
            }

            return
        }

        if self.mainViewController != paneViewController {
            self.mainViewController?.willMoveToParentViewController(nil)
            self.mainViewController?.beginAppearanceTransition(false, animated: false)
            let transitionToNewPaneViewController: ()->Void = { [unowned self] in
                paneViewController.willMoveToParentViewController(self)
                self.mainViewController?.view.removeFromSuperview()
                self.mainViewController?.removeFromParentViewController()
                self.mainViewController?.didMoveToParentViewController(nil)
                self.mainViewController?.endAppearanceTransition()
                self.addChildViewController(paneViewController)
                paneViewController.view.frame = self.mainView.bounds
                paneViewController.beginAppearanceTransition(true, animated: animated)
                self.mainViewController = paneViewController
                // Force redraw of the new pane view (drastically smoothes animation)
                self.mainView.setNeedsDisplay()
                CATransaction.flush()
                self.setNeedsStatusBarAppearanceUpdate()
                // After drawing has finished, set new pane view controller view and close
                dispatch_async(dispatch_get_main_queue(), { [weak self] in
                    self?.mainViewController = paneViewController
                    self?.setMainState(.Closed, animated: animated, allowUserInterruption: true, completion: { [weak self] in
                        paneViewController.didMoveToParentViewController(self)
                        paneViewController.endAppearanceTransition()
                        guard let _ = completion else {
                            return
                        }
                    })
                })
            }

            if self.mainViewSlideOffAnimationEnabled {
                self.setMainState(.OpenWide, animated: animated, allowUserInterruption: false, completion: transitionToNewPaneViewController)
            } else {
                transitionToNewPaneViewController()
            }
        }
        // If trying to set to the currently visible pane view controller, just close
        else {
            self.setMainState(.Closed, animated: animated, allowUserInterruption: true, completion: {
                guard let _ = completion else {
                    return
                }
            })
        }
    }

// MARK:- Dynamics

    func didUpdateDynamicAnimatorAction() -> Void {
        self.paneViewDidUpdateFrame()
    }

    func addDynamicsBehaviorsToCreatePaneState(paneState: SSDrawerMainState) -> Void {
        self.addDynamicsBehaviorsToCreatePaneState(paneState, pushMagnitude: 0, pushAngle: 0, pushElasticity: self.elasticity)
    }

    func addDynamicsBehaviorsToCreatePaneState(paneState: SSDrawerMainState, pushMagnitude: CGFloat, pushAngle: CGFloat, pushElasticity: CGFloat) -> Void {
        if self.currentDrawerDirection == SSDrawerDirection.None {
            return
        }

        self.setPaneViewControllerViewUserInteractionEnabled(paneState == SSDrawerMainState.Closed)

        self.mainBoundaryCollisionBehavior?.removeAllBoundaries()
        self.mainBoundaryCollisionBehavior?.addBoundaryWithIdentifier(SSDrawerBoundaryIdentifier, forPath: self.boundaryPathForState(paneState, direction: self.currentDrawerDirection))
        self.dynamicAnimator?.addBehavior(self.mainBoundaryCollisionBehavior!)

        self.mainGravityBehavior?.magnitude = self.gravityMagnitude
        self.mainGravityBehavior?.angle = self.gravityAngleForState(paneState, direction: self.currentDrawerDirection)
        self.dynamicAnimator?.addBehavior(self.mainGravityBehavior!)

        if pushElasticity != 0.0 {
            self.mainElasticityBehavior?.elasticity = elasticity
            self.dynamicAnimator?.addBehavior(self.mainElasticityBehavior!)
        }

        if pushMagnitude != 0.0 {
            self.mainPushBehavior?.angle = CGFloat(pushAngle)
            self.mainPushBehavior?.magnitude = CGFloat(pushMagnitude)
            self.mainPushBehavior?.active = true
            self.dynamicAnimator?.addBehavior(self.mainPushBehavior!)
        }

        self.potentialPaneState = paneState

        guard let _ = self.delegate?.drawerViewController(self, mayUpdateToPaneState: paneState, forDirection: self.currentDrawerDirection) else {
            print("\(#line):This drawerViewController delegate doesn't have the function 'drawerViewController(_:mayUpdateToPaneState:forDirection:)'")
            return
        }
    }

    func boundaryPathForState(state: SSDrawerMainState, direction: SSDrawerDirection) -> UIBezierPath {
        assert(SSDrawerDirection.isCardinal(direction), "Boundary is undefined for a non-cardinal reveal direction")

        var boundary: CGRect = CGRectZero
        boundary.origin = CGPointMake(-1.0, -1.0)
        if (self.possibleDrawerDirection & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            boundary.size.height = CGRectGetHeight(self.mainView.frame) + 1.0
            switch state {
            case SSDrawerMainState.Closed, .OpenWide:
                boundary.size.width = CGRectGetWidth(self.mainView.frame) * 2.0 + self.paneStateOpenWideEdgeOffset + 2.0
            case .Open:
                boundary.size.width = CGRectGetWidth(self.mainView.frame) + self.openStateRevealWidth + 2.0
            default:
                break
            }
        } else if (self.possibleDrawerDirection & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            boundary.size.width = CGRectGetWidth(self.mainView.frame) + 1.0
            switch state {
            case SSDrawerMainState.Closed:
                boundary.size.height = CGRectGetHeight(self.mainView.frame) * 2.0 + self.paneStateOpenWideEdgeOffset + 2.0
            case SSDrawerMainState.Open:
                boundary.size.height = CGRectGetHeight(self.mainView.frame) + self.openStateRevealWidth + 2.0
            case SSDrawerMainState.OpenWide:
                boundary.size.height = CGRectGetHeight(self.mainView.frame) * 2.0 + self.paneStateOpenWideEdgeOffset + 2.0
            default:
                break
            }
        }

        switch direction {
        case SSDrawerDirection.Right:
            boundary.origin.x = CGRectGetWidth(self.mainView.frame) + 1.0 - boundary.size.width
        case SSDrawerDirection.Bottom:
            boundary.origin.y = CGRectGetHeight(self.mainView.frame) + 1.0 - boundary.size.height
        case SSDrawerDirection.None:
            boundary = CGRectZero
        default:
            break
        }

        return UIBezierPath(rect: boundary)
    }

    func gravityAngleForState(state: SSDrawerMainState, direction: SSDrawerDirection) -> CGFloat {
        assert(SSDrawerDirection.isCardinal(direction), "Indeterminate gravity angle for non-cardinal reveal direction")

        switch direction {
        case SSDrawerDirection.Top:
            return CGFloat((state != SSDrawerMainState.Closed) ? M_PI_2 : (3.0 * M_PI_2))
        case SSDrawerDirection.Left:
            return CGFloat((state != SSDrawerMainState.Closed) ? 0.0 : M_PI)
        case SSDrawerDirection.Bottom:
            return CGFloat((state != SSDrawerMainState.Closed) ? (3.0 * M_PI_2) : M_PI_2)
        case SSDrawerDirection.Right:
            return CGFloat((state != SSDrawerMainState.Closed) ? M_PI : 0.0)
        default:
            return 0.0
        }
    }

// MARK: - Closed Fraction
    func paneViewClosedFraction() -> CGFloat {
        var fraction: CGFloat = 0.0

        switch self.currentDrawerDirection {
        case SSDrawerDirection.Top:
            fraction = (self.openStateRevealWidth - self.mainView.frame.origin.y) / self.openStateRevealWidth
        case SSDrawerDirection.Left:
            fraction = (self.openStateRevealWidth - self.mainView.frame.origin.x) / self.openStateRevealWidth
        case SSDrawerDirection.Bottom:
            fraction = (1 - fabs(self.mainView.frame.origin.y)) / self.openStateRevealWidth
        case SSDrawerDirection.Right:
            fraction = (1 - fabs(self.mainView.frame.origin.x)) / self.openStateRevealWidth
        case SSDrawerDirection.None:
            fraction = 1
        default:
            break
        }

        fraction = (fraction < 0) ? 0 : fraction
        fraction = (fraction > 1) ? 1 : fraction

        return fraction
    }

// MARK: - Stylers

    func addStyler(styler: SSDrawerStyler, forDirection direction: SSDrawerDirection) -> Void {
        SSDrawerDirection.drawerDirectionActionForMaskedValues(direction) { [unowned self] (maskedValue) in
            
            if self.stylers[maskedValue] == nil {
                self.stylers[maskedValue] = NSMutableSet()
            }

            if let stylersSet: NSMutableSet = self.stylers[maskedValue] as? NSMutableSet {
                stylersSet.addObject(styler)

                var existsInCurrentStylers: Bool = false
                for currentStylersSet: NSSet in self.stylers.values {
                    existsInCurrentStylers = currentStylersSet.containsObject(styler)
                }

                if existsInCurrentStylers {
                    styler.stylerWasAddedToDrawerViewController(self, forDirection: direction)
                }
            }
        }
    }

    func removeStyler(styler: SSDrawerStyler, forDirection: SSDrawerDirection) -> Void {
        SSDrawerDirection.drawerDirectionActionForMaskedValues(forDirection) { [unowned self] (maskedValue) in
            if let stylersSet: NSMutableSet = self.stylers[maskedValue] as? NSMutableSet {
                stylersSet.removeObject(styler)

                var containedCount: Int = 0
                for currentStylersSet: NSSet in self.stylers.values {
                    if currentStylersSet.containsObject(styler) {
                        containedCount += 1
                    }
                }

                if containedCount == 0 {
                    styler.stylerWasRemovedFromDrawerViewController(self, forDirection: forDirection)
                }
            }
        }
    }

    func addStylerFromArray(stylers: [SSDrawerStyler], forDirection: SSDrawerDirection) -> Void {
        for styler in stylers {
            self.addStyler(styler, forDirection: forDirection)
        }
    }

    func updateStylers() -> Void {
        if self.animatingRotation {
            return
        }

        let activeStylers: NSMutableSet = NSMutableSet()
        if SSDrawerDirection.isCardinal(self.currentDrawerDirection) {
            activeStylers.unionSet(self.stylers[self.currentDrawerDirection] as! Set<NSObject>)
        } else {
            for stylers in self.stylers.values {
                activeStylers.unionSet(stylers as Set<NSObject>)
            }
        }

        for styler in activeStylers {
            let drawerStyler = styler as! SSDrawerStyler
            drawerStyler.styleDrawerViewController(self, didUpdatePaneClosedFraction: self.paneViewClosedFraction(), forDirection: self.currentDrawerDirection)
        }
    }

// MARK:- Pane State

    func paneViewDidUpdateFrame() -> Void {
        if self.shouldAlignStatusBarToPaneView {

            let chars: [CUnsignedChar] = [0x73, 0x74, 0x61, 0x74, 0x75, 0x73, 0x42, 0x61, 0x72]
            let data: NSData = NSData(bytes: chars, length: 9)
            let key: String = String(data: data, encoding: NSASCIIStringEncoding)!

            let application: UIApplication = UIApplication.sharedApplication()
            var statusBar: UIView?;
            if application.respondsToSelector(NSSelectorFromString(key)) {
                statusBar = application.valueForKey(key) as? UIView
            }
            statusBar!.transform = CGAffineTransformMakeTranslation(self.mainView.frame.origin.x, self.mainView.frame.origin.y);
        }

        let openWidePoint: CGPoint = self.paneViewOriginForPaneState(.OpenWide)
        let paneFrame: CGRect = self.mainView.frame
        var openWideLocation: CGFloat = 0
        var paneLocation: CGFloat = 0

        if (self.currentDrawerDirection & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            openWideLocation = openWidePoint.x
            paneLocation = paneFrame.origin.x
        } else if (self.currentDrawerDirection & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            openWideLocation = openWidePoint.y
            paneLocation = paneFrame.origin.y
        }

        var reachedOpenWideState: Bool = false
        if (self.currentDrawerDirection & [SSDrawerDirection.Left, SSDrawerDirection.Top]) != SSDrawerDirection.None {
            if paneLocation != 0 && (paneLocation >= openWideLocation) {
                reachedOpenWideState = true
            }
        } else if (self.currentDrawerDirection & [SSDrawerDirection.Right, SSDrawerDirection.Bottom]) != SSDrawerDirection.None {
            if paneLocation != 0 && (paneLocation <= openWideLocation) {
                reachedOpenWideState = true
            }
        }

        if reachedOpenWideState && (self.potentialPaneState == .OpenWide) {
            self.dynamicAnimator?.removeAllBehaviors()
        }

        self.updateStylers()
    }

    func paneViewOriginForPaneState(paneState: SSDrawerMainState) -> CGPoint {
        var paneViewOrigin: CGPoint = CGPointZero
        switch paneState {
        case .Open:
            switch self.currentDrawerDirection {
            case SSDrawerDirection.Top:
                paneViewOrigin.y = CGFloat(self.openStateRevealWidth)
            case SSDrawerDirection.Left:
                paneViewOrigin.x = CGFloat(self.openStateRevealWidth)
            case SSDrawerDirection.Bottom:
                paneViewOrigin.y = -CGFloat(self.openStateRevealWidth)
            case SSDrawerDirection.Right:
                paneViewOrigin.x = -CGFloat(self.openStateRevealWidth)
            default:
                break
            }
        case .OpenWide:
            switch self.currentDrawerDirection {
            case SSDrawerDirection.Left:
                paneViewOrigin.x = (CGRectGetWidth(self.mainView.frame) + self.paneStateOpenWideEdgeOffset)
            case SSDrawerDirection.Top:
                paneViewOrigin.y = (CGRectGetWidth(self.mainView.frame) + self.paneStateOpenWideEdgeOffset)
            case SSDrawerDirection.Bottom:
                paneViewOrigin.y = (CGRectGetWidth(self.mainView.frame) + self.paneStateOpenWideEdgeOffset)
            case SSDrawerDirection.Right:
                paneViewOrigin.x = -(CGRectGetWidth(self.mainView.frame) + self.paneStateOpenWideEdgeOffset)
            default:
                break
            }
        default:
            break
        }

        return paneViewOrigin
    }

    func setMainState(paneState: SSDrawerMainState, inDirection direction: SSDrawerDirection) -> Void {
        self.setMainState(paneState, inDirection: direction, animated: false, allowUserInterruption: false, completion: nil)
    }

    func setMainState(paneState: SSDrawerMainState, animated: Bool, allowUserInterruption: Bool, completion: (()-> Void)?) -> Void {
        // If the drawer is getting opened and there's more than one possible direction enforce that the directional eqivalent is used
        var direction: SSDrawerDirection?
        if (paneState != .Closed) && (self.currentDrawerDirection == .None) {
            assert(SSDrawerDirection.isCardinal(self.possibleDrawerDirection), "Unable to set the pane to an open state with multiple possible drawer directions, as the drawer direction to open in is indeterminate. Use `setPaneState:inDirection:animated:allowUserInterruption:completion:` instead.")
            direction = self.possibleDrawerDirection
        } else {
            direction = self.currentDrawerDirection
        }

        self.setMainState(paneState, inDirection: direction!, animated: animated, allowUserInterruption: allowUserInterruption, completion: completion)
    }

    func setMainState(paneState: SSDrawerMainState, inDirection direction: SSDrawerDirection, animated: Bool, allowUserInterruption: Bool, completion: (()->Void)?) -> Void {
        assert((self.possibleDrawerDirection & direction) == direction, "Unable to bounce open with impossible or multiple directions")

        // If the pane is already positioned in the desired pane state and direction, don't continue
        var currentPaneState: SSDrawerMainState = .Closed
        if self.paneViewIsPositionedInValidState(&currentPaneState) && (currentPaneState == paneState) {
            // If already closed, *in any direction*, don't continue
            if currentPaneState == .Closed {
                guard let _ = completion else {
                    return
                }
                return
            }
            // If opened, *in the correct direction*, don't continue
            else if direction == self.currentDrawerDirection {
                guard let _ = completion else {
                    return
                }
                return
            }
        }

        // If opening in a specified direction, set the drawer to that direction
        if paneState != .Closed {
            self.currentDrawerDirection = direction
        }

        if animated {
            self.addDynamicsBehaviorsToCreatePaneState(paneState)
            if !allowUserInterruption {
                self.setViewUserInteractionEnabled(false)
            }
            self.dynamicAnimatorCompletion = { [weak self] in
                if !allowUserInterruption {
                    self?.setViewUserInteractionEnabled(true)
                    guard let _ = completion else {
                        return
                    }
                }
            }
        } else {
            self._setMainState(paneState)
            guard let _ = completion else {
                return
            }
        }
    }

    private func _setMainState(paneState: SSDrawerMainState) -> Void {
        let previousDirection: SSDrawerDirection = self.currentDrawerDirection

        // When we've actually upated to a pane state, invalidate the `potentialPaneState`
        self.potentialPaneState = .None

        if self.mainState != paneState {
            self.willChangeValueForKey("mainState")
            self.mainState = paneState
            if (self.mainState & (SSDrawerMainState.Open | SSDrawerMainState.OpenWide)) != .None {
                guard let _ = self.delegate?.drawerViewController(self, didUpdateToPaneState: paneState, forDirection: self.currentDrawerDirection) else {
                    return
                }
            } else {
                guard let _ = self.delegate?.drawerViewController(self, didUpdateToPaneState: paneState, forDirection: previousDirection) else {
                    return
                }
            }
            self.didChangeValueForKey("mainState")
        }

        // Update pane frame regardless of if it's changed
        self.mainView.frame.origin = self.paneViewOriginForPaneState(paneState)

        // Update `currentDirection` to `MSDynamicsDrawerDirectionNone` if the `paneState` is `MSDynamicsDrawerPaneStateClosed`
        if paneState == SSDrawerMainState.Closed {
            self.currentDrawerDirection = SSDrawerDirection.None
        }
    }

    func paneViewIsPositionedInValidState(inout paneState: SSDrawerMainState) -> Bool {
        var validState = false
        for currentPaneState: SSDrawerMainState in SSDrawerMainState.AllValues {
            let paneStatePaneViewOrigin: CGPoint = self.paneViewOriginForPaneState(currentPaneState)
            let currentPaneViewOrigin: CGPoint = CGPoint(x: round(self.mainView.frame.origin.x), y: round(self.mainView.frame.origin.y))

            if (fabs(paneStatePaneViewOrigin.x - currentPaneViewOrigin.x) < SSPaneStatePositionValidityEpsilon)
                && (fabs(paneStatePaneViewOrigin.y - currentPaneViewOrigin.y) < SSPaneStatePositionValidityEpsilon) {
                validState = true
                paneState = currentPaneState
                break
            }
        }

        return validState
    }

    func nearestPaneState() -> SSDrawerMainState {
        var minDistance: CGFloat = CGFloat.max
        var minPaneState: SSDrawerMainState = .None
        for currentPaneState: SSDrawerMainState in SSDrawerMainState.AllValues {
            let paneStatePaneViewOrigin: CGPoint = self.paneViewOriginForPaneState(currentPaneState)
            let currentPaneViewOrigin: CGPoint = CGPointMake(round(self.mainView.frame.origin.x), round(self.mainView.frame.origin.y))
            let distance: CGFloat = sqrt(pow(paneStatePaneViewOrigin.x - currentPaneViewOrigin.x, 2) + pow(paneStatePaneViewOrigin.y - currentPaneViewOrigin.y, 2))
            if distance < minDistance {
                minDistance = distance
                minPaneState = currentPaneState
            }
        }
        return minPaneState
    }

// MARK:- Possible Reveal Direction
//    func setPossibleDrawerDirection(possibleDrawerDirection: SSDrawerDirection) -> Void {
//        assert(SSDrawerDirection().SSDrawerDirectionIsValid(possibleDrawerDirection), "Only accepts valid reveal directions as possible reveal direction")
//        self.possibleDrawerDirection = possibleDrawerDirection
//    }

// MARK: Reveal Width
    func revealWidthForDirection(direction: SSDrawerDirection) -> CGFloat {
        assert(SSDrawerDirection.isValid(direction), "Only accepts cardinal directions when querying for reveal width")
        var revealWidth: CGFloat = 0

        if let width = self.revealWidth[direction] {
            revealWidth = width
        }

        if revealWidth == 0 {
            if (direction & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
                revealWidth = SSDrawerDefaultOpenStateRevealWidthHorizontal
            } else if (direction & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
                revealWidth = SSDrawerDefaultOpenStateRevealWidthVertical
            } else {
                revealWidth = 0.0
            }
        }

        return revealWidth
    }

    func setRevealWidth(revealWidth: CGFloat, forDirection direction:SSDrawerDirection) -> Void {
        assert(self.mainState == SSDrawerMainState.Closed, "Only able to update the reveal width while the pane view is closed")
        SSDrawerDirection.drawerDirectionActionForMaskedValues(direction) { [unowned self] (maskedValue) in
            self.revealWidth[maskedValue] = revealWidth
        }
    }

    func currentRevealWidth() -> CGFloat {
        switch self.currentDrawerDirection {
        case SSDrawerDirection.Left, SSDrawerDirection.Right:
            return fabs(self.mainView.frame.origin.x)
        case SSDrawerDirection.Top, SSDrawerDirection.Bottom:
            return fabs(self.mainView.frame.origin.y)
        default:
            return 0.0
        }
    }

// MARK:- User Interaction
    func setViewUserInteractionEnabled(enabled: Bool) -> Void {
        var disableCount: Int = 0
        if !enabled {
            disableCount += 1
        } else {
            disableCount = max((disableCount - 1), 0)
        }

        self.view.userInteractionEnabled = (disableCount == 0)
    }

    func setPaneViewControllerViewUserInteractionEnabled(enabled: Bool) -> Void {
        self.mainViewController?.view.userInteractionEnabled = enabled
    }

// MARK:- Gestures
    func isPaneDragRevealEnabledForDirection(direction: SSDrawerDirection) -> Bool {
        assert(SSDrawerDirection.isCardinal(direction), "Only accepts singular directions when querying for drag reveal enabled")
        var paneDragRevealEnabled: Bool = false

        if let enabled = self.paneDragRevealEnabled[direction] {
            paneDragRevealEnabled = enabled
        }

        if !paneDragRevealEnabled {
            paneDragRevealEnabled = true
        }

        return paneDragRevealEnabled
    }

    func isPaneTapToCloseEnabledForDirection(direction: SSDrawerDirection) -> Bool {
        assert(SSDrawerDirection.isCardinal(direction), "Only accepts singular directions when querying for drag reveal enabled")
        var paneTapToCloseEnabled: Bool = false

        if let enabled = self.paneTapToCloseEnabled[direction] {
            paneTapToCloseEnabled = enabled
        }

        if !paneTapToCloseEnabled {
            paneTapToCloseEnabled = true
        }

        return paneTapToCloseEnabled
    }

    func deltaForPanWithStartLocation(startLocation: CGPoint, currentLocation: CGPoint) -> CGFloat {
        var panDelta: CGFloat = 0
        if (self.possibleDrawerDirection & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            panDelta = currentLocation.x - startLocation.x
        } else if (self.possibleDrawerDirection & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            panDelta = currentLocation.y - startLocation.y
        }

        return panDelta
    }

    func directionForPanWithStartLocation(startLocation: CGPoint, currentLocation: CGPoint) -> SSDrawerDirection {
        let delta: CGFloat = self.deltaForPanWithStartLocation(startLocation, currentLocation: currentLocation)
        var direction: SSDrawerDirection = SSDrawerDirection.None

        if (self.possibleDrawerDirection & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            if delta > 0.0 {
                direction = SSDrawerDirection.Left
            } else if delta < 0.0 {
                direction = SSDrawerDirection.Right
            }
        } else if (self.possibleDrawerDirection & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            if delta > 0.0 {
                direction = SSDrawerDirection.Top
            } else if delta < 0.0 {
                direction = SSDrawerDirection.Bottom
            }
        }

        return direction
    }

    func paneViewFrameForPanWithStartLocation(startLocation: CGPoint, currentLocation: CGPoint, inout bounded: Bool) -> CGRect {
        let panDelta: CGFloat = self.deltaForPanWithStartLocation(startLocation, currentLocation: currentLocation)
        // Track the pane frame to the pan gesture
        var paneFrame: CGRect = self.mainView.frame
        if (self.possibleDrawerDirection & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            paneFrame.origin.x += panDelta
        } else if (self.possibleDrawerDirection & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            paneFrame.origin.y += panDelta
        }

        // Pane view edge bounding
        var paneBoundOpenLocation: CGFloat = 0.0
        var paneBoundClosedLocation: CGFloat = 0.0
        switch self.currentDrawerDirection {
        case SSDrawerDirection.Left:
            paneBoundOpenLocation = self.openStateRevealWidth
            // Bounded open
            if paneFrame.origin.x <= paneBoundClosedLocation {
                paneFrame.origin.x = CGFloat(paneBoundClosedLocation)
                bounded = true
            } else if paneFrame.origin.x >= paneBoundOpenLocation {
                paneFrame.origin.x = CGFloat(paneBoundOpenLocation)
                bounded = true
            } else {
                bounded = false
            }
        case SSDrawerDirection.Right:
            paneBoundClosedLocation = -self.openStateRevealWidth
            // Bounded open
            if paneFrame.origin.x <= paneBoundClosedLocation {
                paneFrame.origin.x = CGFloat(paneBoundClosedLocation)
                bounded = true
            } else if paneFrame.origin.x >= paneBoundOpenLocation {
                paneFrame.origin.x = CGFloat(paneBoundOpenLocation)
                bounded = true
            } else {
                bounded = false
            }
        case SSDrawerDirection.Top:
            paneBoundOpenLocation = self.openStateRevealWidth
            // Bounded open
            if paneFrame.origin.y <= paneBoundClosedLocation {
                paneFrame.origin.y = CGFloat(paneBoundClosedLocation)
                bounded = true
            } else if paneFrame.origin.y >= paneBoundOpenLocation {
                paneFrame.origin.y = CGFloat(paneBoundOpenLocation)
                bounded = true
            } else {
                bounded = false
            }
        case SSDrawerDirection.Bottom:
            paneBoundClosedLocation = -self.openStateRevealWidth
            // Bounded open
            if paneFrame.origin.y <= paneBoundClosedLocation {
                paneFrame.origin.y = CGFloat(paneBoundClosedLocation)
                bounded = true
            } else if paneFrame.origin.y >= paneBoundOpenLocation {
                paneFrame.origin.y = CGFloat(paneBoundOpenLocation)
                bounded = true
            } else {
                bounded = false
            }
        default:
            break
        }

        return paneFrame
    }

    func velocityForPanWithStartLocation(startLocation: CGPoint, currentLocation: CGPoint) -> CGFloat {
        var velocity: CGFloat = 0.0
        if (self.possibleDrawerDirection & SSDrawerDirection.Horizontal) != SSDrawerDirection.None {
            velocity = -(startLocation.x - currentLocation.x)
        } else if (self.possibleDrawerDirection & SSDrawerDirection.Vertical) != SSDrawerDirection.None {
            velocity = -(startLocation.y - currentLocation.y)
        }

        return velocity
    }

    func paneStateForPanVelocity(panVelocity: CGFloat) -> SSDrawerMainState {
        var state: SSDrawerMainState = .Closed
        if (self.currentDrawerDirection & [SSDrawerDirection.Top, SSDrawerDirection.Left]) != SSDrawerDirection.None {
            state = (panVelocity > 0) ? .Open : .Closed
        } else if (self.currentDrawerDirection & [SSDrawerDirection.Bottom, SSDrawerDirection.Right]) != SSDrawerDirection.None {
            state = (panVelocity < 0) ? .Open : .Closed
        }

        return state
    }

    func panGestureRecognizer(panGestureRecognizer: UIPanGestureRecognizer, didStartAtEdgesOfView view: UIView) -> UIRectEdge {
        let translation: CGPoint = panGestureRecognizer.translationInView(view)
        let currentLocation: CGPoint = panGestureRecognizer.locationInView(view)
        let startLocation: CGPoint = CGPoint(x: (currentLocation.x - translation.x), y: (currentLocation.y - translation.y))
        let distanceToEdges: UIEdgeInsets = UIEdgeInsets(top: startLocation.y, left: startLocation.x, bottom: (view.bounds.size.height - startLocation.y), right: (view.bounds.size.width - startLocation.x))

        var rectEdge: UIRectEdge = UIRectEdge.None
        if distanceToEdges.top < SSPaneViewScreenEdgeThreshold {
            rectEdge = UIRectEdge.Top
        }
        if distanceToEdges.left < SSPaneViewScreenEdgeThreshold {
            rectEdge = UIRectEdge.Left
        }
        if distanceToEdges.right < SSPaneViewScreenEdgeThreshold {
            rectEdge = UIRectEdge.Right
        }
        if distanceToEdges.bottom < SSPaneViewScreenEdgeThreshold {
            rectEdge = UIRectEdge.Bottom
        }

        return rectEdge
    }

// MARK:- UIGestureRecognizer Callbacks
    func paneTapped(gesture: UITapGestureRecognizer) -> Void {
        if self.isPaneTapToCloseEnabledForDirection(self.currentDrawerDirection) {
            self.addDynamicsBehaviorsToCreatePaneState(SSDrawerMainState.Closed)
        }
    }

    func panePanned(gesture: UIPanGestureRecognizer) -> Void {
        var panStartLocation: CGPoint = CGPointZero
        var paneVelocity: CGFloat = 0
        var panDirection: SSDrawerDirection = SSDrawerDirection.None

        switch gesture.state {
        case UIGestureRecognizerState.Began:
            // Initialize static variables
            panStartLocation = gesture.locationInView(self.mainView)
            paneVelocity = 0
            panDirection = self.currentDrawerDirection
        case .Changed:
            let currentPanLocation: CGPoint = gesture.locationInView(self.mainView)
            let currentPanDirection: SSDrawerDirection = self.directionForPanWithStartLocation(panStartLocation, currentLocation: currentPanLocation)
            // If there's no current direction, try to determine it
            if self.currentDrawerDirection == SSDrawerDirection.None {
                var currentDrawerDirection: SSDrawerDirection = SSDrawerDirection.None
                // If a direction has not yet been previousy determined, use the pan direction
                if panDirection == SSDrawerDirection.None {
                    currentDrawerDirection = currentPanDirection
                } else {
                    // Only allow a new direction to be in the same direction as before to prevent swiping between drawers in one gesture
                    if currentDrawerDirection == panDirection {
                        currentDrawerDirection = panDirection
                    }
                }
                // If the new direction is still none, don't continue
                if currentDrawerDirection == SSDrawerDirection.None {
                    return
                }
                // Ensure that the new current direction is:
                if (self.possibleDrawerDirection & currentDrawerDirection) != SSDrawerDirection.None &&
                    self.isPaneDragRevealEnabledForDirection(currentDrawerDirection) {
                    self.currentDrawerDirection = currentDrawerDirection
                    // Establish the initial drawer direction if there was none
                    if panDirection == SSDrawerDirection.None {
                        panDirection = self.currentDrawerDirection
                    }
                }
                // If these criteria aren't met, cancel the gesture
                else {
                    gesture.enabled = false
                    gesture.enabled = true
                    return
                }
            }
            // If the current reveal direction's pane drag reveal is disabled, cancel the gesture
            else if !self.isPaneDragRevealEnabledForDirection(self.currentDrawerDirection) {
                gesture.enabled = false
                gesture.enabled = true
                return
            }
            // At this point, panning is able to move the pane independently from the dynamic animator, so remove all behaviors to prevent conflicting frames
            self.dynamicAnimator?.removeAllBehaviors()
            // Update the pane frame based on the pan gesture
            var paneViewFrameBounded: Bool = false
            self.mainView.frame = self.paneViewFrameForPanWithStartLocation(panStartLocation, currentLocation: currentPanLocation, bounded: &paneViewFrameBounded)
            // Update the pane velocity based on the pan gesture
            let currentPaneVelocity: CGFloat = self.velocityForPanWithStartLocation(panStartLocation, currentLocation: currentPanLocation)
            // If the pane view is bounded or the determined velocity is 0, don't update it
            if !paneViewFrameBounded && (currentPaneVelocity != 0.0) {
                paneVelocity = currentPaneVelocity
            }
            // If the drawer is being swiped into the closed state, set the direciton to none and the state to closed since the user is manually doing so
            if self.currentDrawerDirection != SSDrawerDirection.None &&
                currentPanDirection != SSDrawerDirection.None &&
                CGPointEqualToPoint(self.mainView.frame.origin, self.paneViewOriginForPaneState(SSDrawerMainState.Closed)) {
                self._setMainState(SSDrawerMainState.Closed)
                self.currentDrawerDirection = SSDrawerDirection.None
            }
        case .Ended:
            if self.currentDrawerDirection != SSDrawerDirection.None {
                // If the user released the pane over the velocity threshold
                if fabs(paneVelocity) > SSPaneViewVelocityThreshold {
                    let state: SSDrawerMainState = self.paneStateForPanVelocity(paneVelocity)
                    self.addDynamicsBehaviorsToCreatePaneState(state, pushMagnitude: fabs(paneVelocity) * SSPaneViewVelocityMultiplier, pushAngle: self.gravityAngleForState(state, direction: self.currentDrawerDirection), pushElasticity: self.elasticity)
                }
                // If not released with a velocity over the threhold, update to nearest `paneState`
                else {
                    self.addDynamicsBehaviorsToCreatePaneState(self.nearestPaneState())
                }
            }
        default:
            break
        }
    }

// MARK: - UIGestureRecognizerDelegate
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === self.panePanGestureRecognizer {
            if self.paneDragRequiresScreenEdgePan {
                var paneState: SSDrawerMainState = .Closed
                if self.paneViewIsPositionedInValidState(&paneState) && (paneState == .Closed) {
                    let panStartEdges: UIRectEdge = self.panGestureRecognizer(self.panePanGestureRecognizer!, didStartAtEdgesOfView: self.mainView)

                    // Mask to only edges that are possible (there's a drawer view controller set in that direction)
                    let possibleDirectionsForPanStartEdges: SSDrawerDirection = SSDrawerDirection(rawValue: panStartEdges.rawValue & self.possibleDrawerDirection.rawValue)
                    let gestureStartedAtPossibleEdge: Bool = possibleDirectionsForPanStartEdges.rawValue != UIRectEdge.None.rawValue

                    // If the gesture didn't start at a possible edge, return no
                    if !gestureStartedAtPossibleEdge {
                        return false
                    }
                }
            }

            guard let beginable = self.delegate?.drawerViewController(self, shouldBeginPanePan: self.panePanGestureRecognizer!) else {
                return true
            }

            if !beginable {
                return false
            }
        }

        return true
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if gestureRecognizer === self.panePanGestureRecognizer {
            var shouldReceiveTouch: Bool = true

            // Enumerate the view's superviews, checking for a touch-forwarding class
            touch.view?.superviewHierarchyAction({ [unowned self] (view) in
                // Only enumerate while still receiving the touch
                if !shouldReceiveTouch {
                    return
                }
                // If the touch was in a touch forwarding view, don't handle the gesture
                self.touchForwardingClasses.enumerateObjectsUsingBlock({ (touchForwardingClass, stop) in
                    if view.isKindOfClass(touchForwardingClass as! AnyClass) {
                        shouldReceiveTouch = false
                        stop.memory = true
                    }
                })
            })

            return shouldReceiveTouch
        } else if gestureRecognizer === self.paneTapGestureRecognizer {
            var paneState: SSDrawerMainState = .Closed
            if self.paneViewIsPositionedInValidState(&paneState) {
                return paneState != .Closed
            }
        }

        return true
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer === self.panePanGestureRecognizer) && self.screenEdgePanCancelsConflictingGestures {
            let edges: UIRectEdge = self.panGestureRecognizer(self.panePanGestureRecognizer!, didStartAtEdgesOfView: self.mainView)

            // Mask out edges that aren't possible
            let validEdges: Bool = (edges.rawValue & self.possibleDrawerDirection.rawValue) != 0

            // If there is a valid edge and pane drag is revealed for that edge's direction
            if validEdges && self.isPaneDragRevealEnabledForDirection(SSDrawerDirection(rawValue: UInt(validEdges))) {
                return true
            }
        }

        return false
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailByGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        // If the other gesture recognizer's view is a `UITableViewCell` instance's internal `UIScrollView`, require failure
        if let view = otherGestureRecognizer.view {
            if view.nextResponder() is UITableViewCell && view is UIScrollView {
                return true
            }
        }
        
        return false
    }

// MARK: - NSKeyValueObserving
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

        if (keyPath == "frame") && (object === self.mainView) {
            if let _ = object?.valueForKey(keyPath!) {
                self.paneViewDidUpdateFrame()
            }
        }
    }
}

typealias ViewActionBlock = (view: UIView) -> Void

extension UIView {
    func superviewHierarchyAction(viewAction: ViewActionBlock) -> Void {
        viewAction(view: self)
        self.superview?.superviewHierarchyAction(viewAction)
    }
}
