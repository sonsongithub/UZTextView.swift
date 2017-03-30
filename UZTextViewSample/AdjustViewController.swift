//
//  AdjustViewController.swift
//  UZTextView
//
//  Created by sonson on 2017/03/29.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit
import UZTextView

class AdjustViewController: UIViewController {
    @IBOutlet var textView: UZTextView!
    
    @IBOutlet var sliderFontSize: UISlider!
    @IBOutlet var sliderInset: UISlider!
    
    var attributedString = NSMutableAttributedString(string: "")
    
    @IBAction func changeSliderFontSize(_ sender: Any?) {
        guard let slider = sender as? UISlider else { return }
        attributedString.removeAttribute(NSFontAttributeName, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(NSFontAttributeName,
                                      value: UIFont.systemFont(ofSize: CGFloat(slider.value)),
                                      range: NSRange(location: 0, length: attributedString.length))
        textView.attributedString = attributedString
    }
    
    @IBAction func changeSliderInset(_ sender: Any?) {
        guard let slider = sender as? UISlider else { return }
        
        if slider == sliderFontSize {
            attributedString.removeAttribute(NSFontAttributeName, range: NSRange(location: 0, length: attributedString.length))
            attributedString.addAttribute(NSFontAttributeName,
                                          value: UIFont.systemFont(ofSize: CGFloat(slider.value)),
                                          range: NSRange(location: 0, length: attributedString.length))
            textView.attributedString = attributedString
        } else if slider == sliderInset {
            let d = CGFloat(slider.value)
            textView.contentInset = UIEdgeInsets(top: d, left: d, bottom: d, right: d)
        }
    }

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
            textView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            textView.attributedString = attr
        } catch {
            print(error)
        }
        
        let bar = UIBarButtonItem(title: "Debug", style: .plain, target: self, action: #selector(AdjustViewController.toggle(sender:)))
        self.navigationItem.rightBarButtonItem = bar
    }
    
    func toggle(sender: Any) {
        textView.isDebugMode = !textView.isDebugMode
    }
}
