//
//  ViewController.swift
//  UZTextViewSample
//
//  Created by sonson on 2017/03/24.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit
import UZTextView

class ViewController: UIViewController {
    @IBOutlet var textView: UZTextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
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
            textView.attributedString = attr
            
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

