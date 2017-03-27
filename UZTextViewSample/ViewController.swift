//
//  ViewController.swift
//  UZTextViewSample
//
//  Created by sonson on 2017/03/24.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit
import UZTextView

class ViewController: UIViewController, UZTextViewDelegate {
    @IBOutlet var textView1: UZTextView!
    @IBOutlet var textView2: UZTextView!
    @IBOutlet var textView3: UZTextView!
    @IBOutlet var textView4: UZTextView!

    func textView(_ textView: UZTextView, didClickLinkAttribute attribute: Any) {
        print(#function)
        print(attribute)
    }
    
    func textView(_ textView: UZTextView, didLongTapLinkAttribute attribute: Any) {
        print(#function)
        print(attribute)
    }
    
    func selectingStringBegun(_ textView: UZTextView) {
        print(#function)
    }
    
    func selectingStringEnded(_ textView: UZTextView) {
        print(#function)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        textView1.scale = 0.3
        
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
            textView1.attributedString = attr
            textView2.attributedString = attr
            textView1.delegate = self
            textView2.delegate = self
            
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

