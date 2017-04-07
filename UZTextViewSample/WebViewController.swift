//
//  WebViewController.swift
//  UZTextView
//
//  Created by sonson on 2017/03/29.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    let webView = WKWebView(frame: CGRect.zero)
    
    override var previewActionItems: [UIPreviewActionItem] {
        let action1 = {
            return UIPreviewAction(title: "Copy", style: .default) { _, _ in
                print("copy")
            }
        }()
        let action2 = {
            return UIPreviewAction(title: "Open", style: .default) { _, _ in
                let controller = WebViewController(nibName: nil, bundle: nil)
                let nav = UINavigationController(rootViewController: controller)
                controller.url = self.url
                self.present(nav, animated: true, completion: nil)
            }
        }()
        let action3 = {
            return UIPreviewAction(title: "Open in Safari", style: .default) { _, _ in
                if let url = self.url {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }()
        let action4 = {
            return UIPreviewAction(title: "Cancel", style: .destructive) { _, _ in
            }
        }()
        
        return [action1, action2, action3, action4]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        let views = ["webView": webView]
        
        view.addConstraints (
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[webView]-0-|", options: [], metrics: nil, views: views)
        )
        view.addConstraints (
            NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[webView]-0-|", options: [], metrics: nil, views: views)
        )
        
        let bar = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(WebViewController.close(sender:)))
        self.navigationItem.rightBarButtonItem = bar
    }
    
    func close(sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var url: URL? = nil {
        didSet {
            if let aUrl = url {
                let request = URLRequest(url: aUrl)
                webView.load(request)
            }
        }
    }
}
