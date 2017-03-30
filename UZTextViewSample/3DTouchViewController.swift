//
//  3DTouchViewController.swift
//  UZTextView
//
//  Created by sonson on 2017/03/29.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit
import UZTextView

class _DTouchViewController: UIViewController, UIViewControllerPreviewingDelegate {
    @IBOutlet var textView: UZTextView!

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
            textView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            textView.scale = 1
            textView.attributedString = attr
        } catch {
            print(error)
        }
        
        self.registerForPreviewing(with: self, sourceView: self.view)
        
        let bar = UIBarButtonItem(title: "Toggle", style: .plain, target: self, action: #selector(_DTouchViewController.toggle(sender:)))
        self.navigationItem.rightBarButtonItem = bar
    }
    
    func toggle(sender: Any) {
        if textView.scale > 1 {
            textView.scale = 1
        } else {
            textView.scale = 1.2
        }
    }

    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        let locationInTextView = self.view.convert(location, to: textView)
        
        if let attributes = textView.attributes(at: locationInTextView) {
            if let url = attributes[NSLinkAttributeName] as? URL, let rect = attributes[UZTextViewLinkRect] as? CGRect {
                print(url)
                previewingContext.sourceRect = self.view.convert(rect, from: textView)
                let controller = WebViewController(nibName: nil, bundle: nil)
                controller.url = url
                return controller
            }
        }
        
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        let nav = UINavigationController(rootViewController: viewControllerToCommit)
        self.present(nav, animated: true, completion: nil)
    }
}
