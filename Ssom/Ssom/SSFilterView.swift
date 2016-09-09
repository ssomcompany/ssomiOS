//
//  SSFilterView.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 12. 2..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

@objc protocol SSFilterViewDelegate: NSObjectProtocol {
    func closeFilterView() -> Void;
    func applyFilter(filterViewModel: SSFilterViewModel) -> Void;
}

class SSFilterView: UIView {
    @IBOutlet var filterMainView: UIView!

    @IBOutlet var filter20beginAgeButton: UIButton!
    @IBOutlet var filter20middleAgeButton: UIButton!
    @IBOutlet var filter20lateAgeButton: UIButton!
    @IBOutlet var filter30overAgeButton: UIButton!

    @IBOutlet var peopleLabel: UILabel!

    @IBOutlet var filter1PersonButton: UIButton!
    @IBOutlet var filter2PeopleButton: UIButton!
    @IBOutlet var filter3PeopleButton: UIButton!
    @IBOutlet var filter4PeopleButton: UIButton!

    @IBOutlet var btnClose: UIButton!

    weak var delegate: SSFilterViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)

        self.filterMainView.layer.cornerRadius = self.btnClose.frame.height/2
    }

    func handleTap(gesture: UITapGestureRecognizer) {
        if let _ = self.filterMainView.hitTest(gesture.locationInView(self.filterMainView), withEvent: nil) {

        } else {
            self.tapCloseButton(nil)
        }
    }

    @IBAction func tapCloseButton(sender: AnyObject?) {
        if self.delegate?.respondsToSelector(#selector(SSFilterViewDelegate.closeFilterView)) != nil {
            self.delegate?.closeFilterView()
        }
    }

    @IBAction func tapFilter20beginAgeButton(sender: AnyObject) {
        self.filter20beginAgeButton.selected = true;
        self.filter20middleAgeButton.selected = false;
        self.filter20lateAgeButton.selected = false;
        self.filter30overAgeButton.selected = false;

        self.filter20beginAgeButton.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.filter20middleAgeButton.backgroundColor = UIColor.whiteColor()
        self.filter20lateAgeButton.backgroundColor = UIColor.whiteColor()
        self.filter30overAgeButton.backgroundColor = UIColor.whiteColor()

    }

    @IBAction func tap20middleAgeButton(sender: AnyObject) {
        self.filter20beginAgeButton.selected = false;
        self.filter20middleAgeButton.selected = true;
        self.filter20lateAgeButton.selected = false;
        self.filter30overAgeButton.selected = false;

        self.filter20beginAgeButton.backgroundColor = UIColor.whiteColor()
        self.filter20middleAgeButton.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.filter20lateAgeButton.backgroundColor = UIColor.whiteColor()
        self.filter30overAgeButton.backgroundColor = UIColor.whiteColor()
    }

    @IBAction func tapFilter20lateAgeButton(sender: AnyObject) {
        self.filter20beginAgeButton.selected = false;
        self.filter20middleAgeButton.selected = false;
        self.filter20lateAgeButton.selected = true;
        self.filter30overAgeButton.selected = false;

        self.filter20beginAgeButton.backgroundColor = UIColor.whiteColor()
        self.filter20middleAgeButton.backgroundColor = UIColor.whiteColor()
        self.filter20lateAgeButton.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.filter30overAgeButton.backgroundColor = UIColor.whiteColor()
    }

    @IBAction func tapFilter30overAgeButton(sender: AnyObject) {
        self.filter20beginAgeButton.selected = false;
        self.filter20middleAgeButton.selected = false;
        self.filter20lateAgeButton.selected = false;
        self.filter30overAgeButton.selected = true;

        self.filter20beginAgeButton.backgroundColor = UIColor.whiteColor()
        self.filter20middleAgeButton.backgroundColor = UIColor.whiteColor()
        self.filter20lateAgeButton.backgroundColor = UIColor.whiteColor()
        self.filter30overAgeButton.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
    }

    @IBAction func tap1PersonButton(sender: AnyObject) {
        self.filter1PersonButton.selected = true;
        self.filter2PeopleButton.selected = false;
        self.filter3PeopleButton.selected = false;
        self.filter4PeopleButton.selected = false;

        self.filter1PersonButton.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.filter2PeopleButton.backgroundColor = UIColor.whiteColor()
        self.filter3PeopleButton.backgroundColor = UIColor.whiteColor()
        self.filter4PeopleButton.backgroundColor = UIColor.whiteColor()
    }

    @IBAction func tap2PeopleButton(sender: AnyObject) {
        self.filter1PersonButton.selected = false;
        self.filter2PeopleButton.selected = true;
        self.filter3PeopleButton.selected = false;
        self.filter4PeopleButton.selected = false;

        self.filter1PersonButton.backgroundColor = UIColor.whiteColor()
        self.filter2PeopleButton.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.filter3PeopleButton.backgroundColor = UIColor.whiteColor()
        self.filter4PeopleButton.backgroundColor = UIColor.whiteColor()
    }

    @IBAction func tap3PeopleButton(sender: AnyObject) {
        self.filter1PersonButton.selected = false;
        self.filter2PeopleButton.selected = false;
        self.filter3PeopleButton.selected = true;
        self.filter4PeopleButton.selected = false;

        self.filter1PersonButton.backgroundColor = UIColor.whiteColor()
        self.filter2PeopleButton.backgroundColor = UIColor.whiteColor()
        self.filter3PeopleButton.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
        self.filter4PeopleButton.backgroundColor = UIColor.whiteColor()
    }

    @IBAction func tapOver4PeopleButton(sender: AnyObject) {
        self.filter1PersonButton.selected = false;
        self.filter2PeopleButton.selected = false;
        self.filter3PeopleButton.selected = false;
        self.filter4PeopleButton.selected = true;

        self.filter1PersonButton.backgroundColor = UIColor.whiteColor()
        self.filter2PeopleButton.backgroundColor = UIColor.whiteColor()
        self.filter3PeopleButton.backgroundColor = UIColor.whiteColor()
        self.filter4PeopleButton.backgroundColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 1)
    }
    @IBAction func tapFilterInitialize(sender: AnyObject) {
        let filterValue: SSFilterViewModel = SSFilterViewModel(ageType: .AgeAll, peopleCount: .All)

        guard let _ = self.delegate?.applyFilter(filterValue) else {
            NSLog("%@", "This SSFilterView isn't implemented applyFilter function")

            return
        }
    }

    @IBAction func tapApplyButton(sender: AnyObject) {
        let filterValue: SSFilterViewModel = SSFilterViewModel(ageType: .AgeEarly20, peopleCount: .OnePerson)
        if self.filter20beginAgeButton.selected {
            filterValue.ageType = .AgeEarly20
        } else if self.filter20middleAgeButton.selected {
            filterValue.ageType = .AgeMiddle20
        } else if self.filter20lateAgeButton.selected {
            filterValue.ageType = .AgeLate20
        } else if self.filter30overAgeButton.selected {
            filterValue.ageType = .Age30
        }

        // how many people
        if self.filter1PersonButton.selected {
            filterValue.peopleCountType = .OnePerson
        } else if self.filter2PeopleButton.selected {
            filterValue.peopleCountType = .TwoPeople
        } else if self.filter3PeopleButton.selected {
            filterValue.peopleCountType = .ThreePeople
        } else if self.filter4PeopleButton.selected {
            filterValue.peopleCountType = .OverFourPeople
        }

        guard let _ = self.delegate?.applyFilter(filterValue) else {
            NSLog("%@", "This SSFilterView isn't implemented applyFilter function")

            return
        }
    }
}
