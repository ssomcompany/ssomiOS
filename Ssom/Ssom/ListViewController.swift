//
//  ListViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 6..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit
import SDWebImage

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SSListTableViewCellDelegate, SSPhotoViewDelegate {
    @IBOutlet var chatListTableView: UITableView!
    @IBOutlet var bottomInfoView: UIView!

    var dataArray:[[String: AnyObject]]
    var profileImageView: SSPhotoView?

    init() {
        self.dataArray = []

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        self.dataArray = []

        super.init(coder: aDecoder)
    }

    convenience init(dataArray:[[String: AnyObject]]) {
        self.init()

        self.dataArray = dataArray
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        chatListTableView.delegate = self
        chatListTableView.dataSource = self

        chatListTableView.registerNib(UINib.init(nibName: "ListTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "cell");
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.loadingData()
    }

// MARK: private
    func loadingData() {
//        weak var wSelf = self
//        SSNetworkAPIClient.getPosts { (responseObject) -> Void in
//            wSelf!.dataArray = responseObject as! [[String: AnyObject]]
//            print("result is : \(wSelf!.dataArray)")
//
//            wSelf?.chatListTableView.reloadData()
//        }

        print("result is : \(self.dataArray)")

        self.chatListTableView.reloadData()
    }

// MARK:- SSListTableViewCellDelegate
    func tapProfileImage(sender: AnyObject, imageUrl: String) {
        self.profileImageView = UIView.loadFromNibNamed("SSPhotoView") as? SSPhotoView
        self.profileImageView!.loadingImage(self.view.bounds, imageUrl: imageUrl)
        self.profileImageView!.delegate = self

        self.navigationController?.navigationBarHidden = true;
        self.view.addSubview(self.profileImageView!)
    }

// MARK:- SSPhotoViewDelegate
    func tapClose() {
        self.navigationController?.navigationBarHidden = false;

        self.profileImageView!.removeFromSuperview()
    }

// MARK:- UITableViewDelegate & UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ListTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as! ListTableViewCell

        let rowDict:[String: AnyObject] = dataArray[indexPath.row]
        if let content = rowDict["content"] as? String {
            print("content is \(content.stringByRemovingPercentEncoding)")

            cell.descriptionLabel.text = content.stringByRemovingPercentEncoding
        }

        if let imageUrl = rowDict["imageUrl"] as? String {
            print("imageUrl is \(imageUrl)")

            cell.profileImageView!.sd_setImageWithURL(NSURL(string: imageUrl))
            cell.profilImageUrl = imageUrl
        }

        var memberInfoString:String = "";
        if let minAge = rowDict["minAge"] as? Int {
            memberInfoString = memberInfoString.stringByAppendingFormat("\(minAge)살")
        }
        if let maxAge = rowDict["maxAge"] as? Int {
            memberInfoString = memberInfoString.stringByAppendingFormat("~\(maxAge)살")
        }
        if let userCount = rowDict["userCount"] as? Int {
            memberInfoString = memberInfoString.stringByAppendingFormat(" \(userCount)명 있어요.")
        }
        cell.memberInfoLabel.text = memberInfoString

        if let distance = rowDict["distance"] as? Int {
            cell.distanceLabel.text = Util.getDistanceString(distance)
        }

        cell.delegate = self

        return cell;
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Util.convertScreenSize(false, size: 280, fromWidth: 1080, fromHeight: 1920);
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count;
    }

}