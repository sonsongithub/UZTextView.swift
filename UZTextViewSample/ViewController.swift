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
        if let attribute = attribute as? [String: Any], let link = attribute[NSLinkAttributeName] as? URL {
            UIApplication.shared.open(link, options: [:], completionHandler: nil)
        }
    }
    
    func textView(_ textView: UZTextView, didLongTapLinkAttribute attribute: Any) {
        print(#function)
        if let attribute = attribute as? [String: Any], let link = attribute[NSLinkAttributeName] as? URL {
            let sheet = UIAlertController(title: "Link", message: link.absoluteString, preferredStyle: .actionSheet)
            do {
                let action = UIAlertAction(title: "Copy", style: .default) { (action) in
                    print("copy")
                }
                sheet.addAction(action)
            }
            do {
                let action = UIAlertAction(title: "Open is Safari", style: .default) { (action) in
                    UIApplication.shared.open(link, options: [:], completionHandler: nil)
                }
                sheet.addAction(action)
            }
            do {
                let action = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                }
                sheet.addAction(action)
            }
            self.present(sheet, animated: true, completion: nil)
        }
    }
    
    func selectingStringBegun(_ textView: UZTextView) {
    }
    
    func selectingStringEnded(_ textView: UZTextView) {
//        print(#function)
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

