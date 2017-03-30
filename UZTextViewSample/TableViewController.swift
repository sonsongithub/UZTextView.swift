//
//  TableViewController.swift
//  UZTextView
//
//  Created by sonson on 2017/03/29.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit
import UZTextView

class TableViewController: UITableViewController, UZTextViewDelegate {
    var attributedString = NSMutableAttributedString(string: "")
    var height = CGFloat(0)

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            let data = try Data(contentsOf: Bundle.main.url(forResource: "data", withExtension: "html")!)
            let options: [String: Any] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue
            ]
            let attr = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
            attr.addAttribute(NSFontAttributeName,
                              value: UIFont.systemFont(ofSize: 20),
                              range: NSRange(location: 0, length: attr.length))
            attributedString = attr
            
            let size = UZTextView.size(of: attributedString, restrictedWithin: self.view.frame.size.width - 16)
            height = size.height + 18
            
            tableView.reloadData()
        } catch {
            print(error)
        }
        
    }
    
    func textView(_ textView: UZTextView, didClickLinkAttribute attribute: Any) {
    }
    
    func textView(_ textView: UZTextView, didLongTapLinkAttribute attribute: Any) {
    }
    
    func selectingStringBegun(_ textView: UZTextView) {
        self.tableView.isScrollEnabled = false
    }
    
    func selectingStringEnded(_ textView: UZTextView) {
        self.tableView.isScrollEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return height
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if let cell = cell as? SampleCell {
            cell.textView.attributedString = attributedString
            cell.textView.delegate = self
        }

        return cell
    }

}
