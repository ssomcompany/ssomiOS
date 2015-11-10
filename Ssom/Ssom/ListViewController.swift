//
//  ListViewController.swift
//  Ssom
//
//  Created by DongSoo Lee on 2015. 11. 6..
//  Copyright © 2015년 SsomCompany. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var chatListTableView: UITableView!
    @IBOutlet var bottomInfoView: UIView!
    let testArr:[String] = ["a", "b", "c"]

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

// MARK:- UITableViewDelegate & UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: ListTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell") as! ListTableViewCell

        cell.label.text = testArr[indexPath.row]

        return cell;
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return Util.convertScreenSize(false, size: 280, fromWidth: 1080, fromHeight: 1920);
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testArr.count;
    }

}