//
//  SSScrollView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2016. 7. 5..
//  Copyright © 2016년 SsomCompany. All rights reserved.
//

import UIKit

enum SSScrollViewDirection: Int {
    case unknown = 0
    case left
    case right
}

protocol SSScrollViewDelegate: class {
    func closeScrollView(_ needToReload: Bool)
    func openSignIn(_ completion: ((_ finish:Bool) -> Void)?)
    func doSsom(_ ssomType: SSType, model: SSViewModel)
}

class SSScrollView: UIView, SSDetailViewDelegate, UIScrollViewDelegate {
    @IBOutlet fileprivate var viewBackground: UIView!
    @IBOutlet fileprivate var scrollView: SSCustomScrollView!
    @IBOutlet fileprivate var contentView: UIView!
    @IBOutlet var constContentViewWidth: NSLayoutConstraint!
    @IBOutlet var constContentViewWidthMin: NSLayoutConstraint!
    @IBOutlet var constContentViewToScrollViewWidthRatio: NSLayoutConstraint!
    @IBOutlet var constContentViewToScrollViewWidthRatioMin: NSLayoutConstraint!

    weak var delegate: SSScrollViewDelegate?
    fileprivate var datas: [SSViewModel]?
    var ssomTypes: [SSType] = [.SSOM, .SSOSEYO]

    fileprivate var previousView: SSDetailView?
    fileprivate var currentView: SSDetailView?
    fileprivate var nextView: SSDetailView?

    fileprivate var currentIndex: Int = 0
    fileprivate var startScrollContentOffset: CGPoint = CGPoint.zero
    fileprivate var scrolledContentOffset: CGPoint = CGPoint.zero
    fileprivate var scrollDirection: SSScrollViewDirection = .unknown
    fileprivate var isScrolled: Bool = false
    fileprivate var isScrollBounced: Bool = false

    fileprivate var constPreviousViewToContentView: [NSLayoutConstraint] = []
    fileprivate var constCurrentViewToContentView: [NSLayoutConstraint] = []
    fileprivate var constNextViewToContentView: [NSLayoutConstraint] = []

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

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
        self.scrollView.setContentOffset(CGPoint(x: startingOffsetX, y: 0), animated: false)
    }

    func configureWithDatas(_ datas: [SSViewModel], currentViewModel: SSViewModel?) {
        self.scrollView.delegate = self
        
        self.datas = datas

        if let viewModel = currentViewModel {
            if let index = datas.index(where: { $0 === viewModel }) {
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

    func setPreviousView(_ viewModel: SSViewModel) -> Void {
        if self.previousView != nil {
            self.previousView!.removeFromSuperview()
        }

        self.previousView = (UIView.loadFromNibNamed("SSDetailView", className: SSDetailView.self) as? SSDetailView)!
        self.previousView!.configureWithViewModel(viewModel)
        self.previousView!.delegate = self
        self.contentView.addSubview(self.previousView!)
        self.previousView!.translatesAutoresizingMaskIntoConstraints = false

        self.previousView!.changeTheme()
    }

    func setNextView(_ viewModel: SSViewModel) -> Void {
        if self.nextView != nil {
            self.nextView!.removeFromSuperview()
        }

        self.nextView = (UIView.loadFromNibNamed("SSDetailView", className: SSDetailView.self) as? SSDetailView)!
        self.nextView!.configureWithViewModel(viewModel)
        self.nextView!.delegate = self
        self.contentView.addSubview(self.nextView!)
        self.nextView!.translatesAutoresizingMaskIntoConstraints = false

        self.nextView!.changeTheme()
    }

    func resetConstraints(_ needScroll: Bool) -> Void {
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
                self.constPreviousViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-31-[previousView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["previousView": self.previousView!]))
                self.constPreviousViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[previousView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previousView": self.previousView!]))

                self.contentView.addConstraints(self.constPreviousViewToContentView)

                self.constCurrentViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "[previousView]-62-[currentView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["currentView": currentView!, "previousView": self.previousView!]))
                self.constCurrentViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[currentView]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["currentView": currentView!]))

                self.contentView.addConstraints(self.constCurrentViewToContentView)

                self.constNextViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "[currentView]-62-[nextView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["currentView": self.currentView!, "nextView": self.nextView!]))
                self.constNextViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[nextView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["nextView": self.nextView!]))

                self.contentView.addConstraints(self.constNextViewToContentView)
            } else if self.datas!.count == (self.currentIndex + 1) {
                self.constPreviousViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[previousView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["previousView": self.previousView!]))

                self.contentView.addConstraints(self.constPreviousViewToContentView)

                self.constCurrentViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "[previousView(width)]-62-[currentView(width)]-31-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["currentView": currentView!, "previousView": self.previousView!]))
                self.constCurrentViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[currentView]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["currentView": currentView!]))

                self.contentView.addConstraints(self.constCurrentViewToContentView)
            }
        } else if self.currentIndex == 0 {

            if needScroll {

                // determine if it needs to make nextView
                if self.datas!.count > (self.currentIndex + 1) {
                    self.constCurrentViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-31-[currentView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["currentView": currentView!]))
                    self.constCurrentViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[currentView]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["currentView": currentView!]))

                    self.contentView.addConstraints(self.constCurrentViewToContentView)

                    self.constNextViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "[currentView]-62-[nextView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["currentView": self.currentView!, "nextView": self.nextView!]))
                    self.constNextViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[nextView]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["nextView": self.nextView!]))

                    self.contentView.addConstraints(self.constNextViewToContentView)
                } else if self.datas!.count == (self.currentIndex + 1) {
                    self.constCurrentViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "[currentView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["currentView": currentView!]))
                    self.constCurrentViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[currentView]-12-|", options: NSLayoutFormatOptions.alignAllCenterX, metrics: nil, views: ["currentView": currentView!]))
                    
                    self.contentView.addConstraints(self.constCurrentViewToContentView)
                }

            } else {
                self.scrollView.isScrollEnabled = needScroll

                self.constCurrentViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "|-31-[currentView(width)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: ["width": (self.bounds.size.width - 31 - 31)], views: ["currentView": currentView!]))
                self.constCurrentViewToContentView.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[currentView]-12-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["currentView": currentView!]))

                self.contentView.addConstraints(self.constCurrentViewToContentView)
            }
        }
    }

    func changeTheme(_ ssomTypes: [SSType]) -> Void {
        self.ssomTypes = ssomTypes

        self.previousView?.changeTheme()

        self.currentView?.changeTheme()

        self.nextView?.changeTheme()
    }

// MARK:- SSDetailViewDelegate

    func closeDetailView(_ needToReload: Bool) {
        guard let _ = self.delegate?.closeScrollView(needToReload) else {
            return
        }
    }

    func openSignIn(_ completion: ((_ finish:Bool) -> Void)?) {
        guard let _ = self.delegate?.openSignIn(completion) else {
            return
        }
    }

    func doSsom(_ ssomType: SSType, model: SSViewModel) {
        guard let _ = self.delegate?.doSsom(ssomType, model: model) else {
            return
        }
    }

// MARK:- UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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

            self.scrollDirection = .left
        } else if self.scrolledContentOffset.x > scrollView.contentOffset.x {
            print("right! ==> \(self.scrolledContentOffset), \(scrollView.contentOffset), isScrollBounced ==> \(self.isScrollBounced), isScrolled ==> \(self.isScrolled)")

            self.scrollDirection = .right
        } else {
            self.scrollDirection = .unknown
        }

        self.scrolledContentOffset = scrollView.contentOffset
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("willBeginDragging! \(scrollView.contentOffset)")

        self.startScrollContentOffset = scrollView.contentOffset
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        print("willEndDragging! \(scrollView.contentOffset), \(targetContentOffset.pointee), velocity ==> \(velocity)")

        self.isScrolled = !(self.startScrollContentOffset == targetContentOffset.pointee)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print("endDragging! \(scrollView.contentOffset), decelerate ==> \(decelerate)")

        self.startScrollContentOffset = CGPoint.zero
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print("willBeginDecelerationg!")
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("didEndDecelerating!, \(scrollView.contentOffset)")
        if self.isScrollBounced {
            return
        }

        if !self.isScrolled {
            return
        }

        var offsetX: CGFloat = 0.0

        if self.scrollDirection == .left {

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

        if self.scrollDirection == .right {

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

        scrollView.contentOffset = CGPoint(x: offsetX, y: 0)
    }
}
