//
//  SSScrollView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 5..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

enum SSScrollViewDirection: Int {
    case Unknown = 0
    case Left
    case Right
}

protocol SSScrollViewDelegate: class {
    func closeScrollView(needToReload: Bool)
    func openSignIn(completion: ((finish:Bool) -> Void)?)
    func doSsom(ssomType: SSType, postId: String, partnerImageUrl: String?, ssomLatitude: Double, ssomLongitude: Double)
}

class SSCustomScrollView: UIScrollView {
    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        if view is UIButton {
            return true
        }

        return super.touchesShouldCancelInContentView(view)
    }
}

class SSScrollView: UIView, SSDetailViewDelegate, UIScrollViewDelegate {
    @IBOutlet private var viewBackground: UIView!
    @IBOutlet private var scrollView: SSCustomScrollView!
    @IBOutlet private var contentView: UIView!
    @IBOutlet var constContentViewWidth: NSLayoutConstraint!
    @IBOutlet var constContentViewWidthMin: NSLayoutConstraint!
    @IBOutlet var constContentViewToScrollViewWidthRatio: NSLayoutConstraint!
    @IBOutlet var constContentViewToScrollViewWidthRatioMin: NSLayoutConstraint!

    weak var delegate: SSScrollViewDelegate?
    private var datas: [SSViewModel]?
    var ssomType: SSType?

    private var previousView: SSDetailView?
    private var currentView: SSDetailView?
    private var nextView: SSDetailView?

    private var currentIndex: Int = 0
    private var startScrollContentOffset: CGPoint = CGPointZero
    private var scrolledContentOffset: CGPoint = CGPointZero
    private var scrollDirection: SSScrollViewDirection = .Unknown
    private var isScrolled: Bool = false
    private var isScrollBounced: Bool = false

    private var constPreviousViewToContentView: [NSLayoutConstraint] = []
    private var constCurrentViewToContentView: [NSLayoutConstraint] = []
    private var constNextViewToContentView: [NSLayoutConstraint] = []

    override func layoutSubviews() {
        super.layoutSubviews()

        var startingOffsetX: CGFloat = 0.0
        if self.currentIndex > 0 {
            startingOffsetX = self.bounds.size.width
        }

        if (self.currentIndex + 1) == self.datas!.count {
            startingOffsetX = self.bounds.size.width * 2
        }

        if self.datas!.count == 1 {
            startingOffsetX = 0
        }
        self.scrollView.setContentOffset(CGPointMake(startingOffsetX, 0), animated: false)
    }

    func configureWithDatas(datas: [SSViewModel], currentViewModel: SSViewModel?) {
        self.scrollView.delegate = self
        
        self.datas = datas

        if let viewModel = currentViewModel {
            if let index = datas.indexOf({ $0 === viewModel }) {
                self.currentIndex = index
            }
        }

        if datas.count > 0 {

            self.currentView = UIView.loadFromNibNamed("SSDetailView", className: SSDetailView.self) as? SSDetailView
            self.currentView?.configureWithViewModel(datas[self.currentIndex])
            self.currentView?.delegate = self
            self.contentView.addSubview(self.currentView!)
            self.currentView?.translatesAutoresizingMaskIntoConstraints = false

            var needScroll: Bool = false
            if self.currentIndex > 0 {
                self.setPreviousView(datas[self.currentIndex - 1])

                needScroll = true
            }

            if datas.count > (self.currentIndex + 1) {
                self.setNextView(datas[self.currentIndex + 1])

                needScroll = true
            }

            self.resetConstraints(needScroll)
        }
    }

    func setPreviousView(viewModel: SSViewModel) -> Void {
        if self.previousView != nil {
            self.previousView!.removeFromSuperview()
        }

        self.previousView = (UIView.loadFromNibNamed("SSDetailView", className: SSDetailView.self) as? SSDetailView)!
        self.previousView!.configureWithViewModel(viewModel)
        self.previousView!.delegate = self
        self.contentView.addSubview(self.previousView!)
        self.previousView!.translatesAutoresizingMaskIntoConstraints = false

        self.previousView!.changeTheme(self.ssomType!)
    }

    func setNextView(viewModel: SSViewModel) -> Void {
        if self.nextView != nil {
            self.nextView!.removeFromSuperview()
        }

        self.nextView = (UIView.loadFromNibNamed("SSDetailView", className: SSDetailView.self) as? SSDetailView)!
        self.nextView!.configureWithViewModel(viewModel)
        self.nextView!.delegate = self
        self.contentView.addSubview(self.nextView!)
        self.nextView!.translatesAutoresizingMaskIntoConstraints = false

        self.nextView!.changeTheme(self.ssomType!)
    }

    func resetConstraints(needScroll: Bool) -> Void {
        if self.currentIndex >= 0 && self.currentIndex < self.datas!.count {
            self.contentView.removeConstraints(self.constPreviousViewToContentView)
            self.contentView.removeConstraints(self.constCurrentViewToContentView)
            self.contentView.removeConstraints(self.constNextViewToContentView)

            self.constPreviousViewToContentView = []
            self.constCurrentViewToContentView = []
            self.constNextViewToContentView = []
        }

        if self.currentIndex > 0 {

            // determine if it needs to make nextView
            if self.datas!.count > (self.currentIndex + 1) {
                self.constPreviousViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("|-31-[previousView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["previousView": self.previousView!]))
                self.constPreviousViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-12-[previousView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previousView": self.previousView!]))

                self.contentView.addConstraints(self.constPreviousViewToContentView)

                self.constCurrentViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("[previousView]-62-[currentView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["currentView": currentView!, "previousView": self.previousView!]))
                self.constCurrentViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[currentView]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["currentView": currentView!]))

                self.contentView.addConstraints(self.constCurrentViewToContentView)

                self.constNextViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("[currentView]-62-[nextView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["currentView": self.currentView!, "nextView": self.nextView!]))
                self.constNextViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-12-[nextView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["nextView": self.nextView!]))

                self.contentView.addConstraints(self.constNextViewToContentView)
            } else if self.datas!.count == (self.currentIndex + 1) {
                self.constPreviousViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-12-[previousView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previousView": self.previousView!]))

                self.contentView.addConstraints(self.constPreviousViewToContentView)

                self.constCurrentViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("[previousView(width)]-62-[currentView(width)]-31-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["currentView": currentView!, "previousView": self.previousView!]))
                self.constCurrentViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[currentView]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["currentView": currentView!]))

                self.contentView.addConstraints(self.constCurrentViewToContentView)
            }
        } else if self.currentIndex == 0 {

            if needScroll {

                // determine if it needs to make nextView
                if self.datas!.count > (self.currentIndex + 1) {
                    self.constCurrentViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("|-31-[currentView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["currentView": currentView!]))
                    self.constCurrentViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[currentView]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["currentView": currentView!]))

                    self.contentView.addConstraints(self.constCurrentViewToContentView)

                    self.constNextViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("[currentView]-62-[nextView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["currentView": self.currentView!, "nextView": self.nextView!]))
                    self.constNextViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-12-[nextView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["nextView": self.nextView!]))

                    self.contentView.addConstraints(self.constNextViewToContentView)
                } else if self.datas!.count == (self.currentIndex + 1) {
                    self.constCurrentViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("[currentView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["currentView": currentView!]))
                    self.constCurrentViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[currentView]-12-|", options: NSLayoutFormatOptions.AlignAllCenterX, metrics: nil, views: ["currentView": currentView!]))
                    
                    self.contentView.addConstraints(self.constCurrentViewToContentView)
                }

            } else {
                self.scrollView.scrollEnabled = needScroll

                self.constCurrentViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("|-31-[currentView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["currentView": currentView!]))
                self.constCurrentViewToContentView.appendContentsOf(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[currentView]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["currentView": currentView!]))

                self.contentView.addConstraints(self.constCurrentViewToContentView)
            }
        }
    }

    func changeTheme(ssomType: SSType) -> Void {
        if self.ssomType == nil {
            self.ssomType = ssomType
        }

        self.previousView?.changeTheme(ssomType)

        self.currentView?.changeTheme(ssomType)

        self.nextView?.changeTheme(ssomType)
    }

// MARK:- SSDetailViewDelegate

    func closeDetailView(needToReload: Bool) {
        guard let _ = self.delegate?.closeScrollView(needToReload) else {
            return
        }
    }

    func openSignIn(completion: ((finish:Bool) -> Void)?) {
        guard let _ = self.delegate?.openSignIn(completion) else {
            return
        }
    }

    func doSsom(ssomType: SSType, postId: String, partnerImageUrl: String?, ssomLatitude: Double, ssomLongitude: Double) {
        guard let _ = self.delegate?.doSsom(ssomType, postId: postId, partnerImageUrl: partnerImageUrl, ssomLatitude: ssomLatitude, ssomLongitude: ssomLongitude) else {
            return
        }
    }

// MARK:- UIScrollViewDelegate

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x < 0 {
            self.isScrollBounced = true
//            self.isScrolled = false
        } else if scrollView.contentOffset.x > (scrollView.contentSize.width - scrollView.bounds.size.width) {
            self.isScrollBounced = true
//            self.isScrolled = false
        } else if scrollView.contentOffset.x == 0 {
            if self.scrolledContentOffset.x < scrollView.contentOffset.x {
                self.isScrollBounced = true
//                self.isScrolled = false
            } else {
                self.isScrollBounced = false
//                self.isScrolled = true
            }
        } else if scrollView.contentOffset.x == (scrollView.contentSize.width - scrollView.bounds.size.width) {
            if self.scrolledContentOffset.x > scrollView.contentOffset.x {
                self.isScrollBounced = true
//                self.isScrolled = false
            } else {
                self.isScrollBounced = false
//                self.isScrolled = true
            }
        } else {
            self.isScrollBounced = false
//            self.isScrolled = true
        }

        if self.scrolledContentOffset.x < scrollView.contentOffset.x {
            print("left! ==> \(self.scrolledContentOffset), \(scrollView.contentOffset), isScrollBounced ==> \(self.isScrollBounced), isScrolled ==> \(self.isScrolled)")

            self.scrollDirection = .Left
        } else if self.scrolledContentOffset.x > scrollView.contentOffset.x {
            print("right! ==> \(self.scrolledContentOffset), \(scrollView.contentOffset), isScrollBounced ==> \(self.isScrollBounced), isScrolled ==> \(self.isScrolled)")

            self.scrollDirection = .Right
        } else {
            self.scrollDirection = .Unknown
        }

        self.scrolledContentOffset = scrollView.contentOffset
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        print("willBeginDragging! \(scrollView.contentOffset)")

        self.startScrollContentOffset = scrollView.contentOffset
    }

    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("willEndDragging! \(scrollView.contentOffset), \(targetContentOffset.memory), velocity ==> \(velocity)")

        self.isScrolled = !(self.startScrollContentOffset == targetContentOffset.memory)
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("endDragging! \(scrollView.contentOffset), decelerate ==> \(decelerate)")

        self.startScrollContentOffset = CGPointZero
    }

    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        print("willBeginDecelerationg!")
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        print("didEndDecelerating!, \(scrollView.contentOffset)")
        if self.isScrollBounced {
            return
        }

        if !self.isScrolled {
            return
        }

        var offsetX: CGFloat = 0.0

        if self.scrollDirection == .Left {

            if self.previousView != nil {
                self.previousView!.removeFromSuperview()
            }

            self.currentIndex += 1

            self.previousView = self.currentView
            self.currentView = self.nextView

            if self.datas!.count > self.currentIndex + 1 {

                self.setNextView(self.datas![self.currentIndex + 1])

                self.contentView.addSubview(self.currentView!)

                offsetX = self.bounds.size.width
            } else if self.datas!.count == (self.currentIndex + 1) {

                self.nextView!.removeFromSuperview()
                self.nextView = nil

                self.contentView.addSubview(self.currentView!)

                offsetX = self.bounds.size.width * 2
            }
        }

        if self.scrollDirection == .Right {

            if self.nextView != nil {
                self.nextView!.removeFromSuperview()
            }

            self.currentIndex -= 1

            self.nextView = self.currentView
            self.currentView = self.previousView

            if self.currentIndex > 0 {

                self.setPreviousView(self.datas![self.currentIndex - 1])

                self.contentView.addSubview(self.currentView!)

                offsetX = self.bounds.size.width
            } else if self.currentIndex == 0 {

                self.previousView!.removeFromSuperview()
                self.previousView = nil

                self.contentView.addSubview(self.currentView!)

                offsetX = 0
            } else {
                offsetX = 0
            }
        }

        self.resetConstraints(true)

        scrollView.contentOffset = CGPointMake(offsetX, 0)
    }
}
