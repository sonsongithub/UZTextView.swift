//
//  MainTableViewController.swift
//  UZTextView
//
//  Created by sonson on 2017/03/31.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit
import UZTextView
import SafariServices

struct Content {
    public let attributedString: NSAttributedString
    public let height: CGFloat
    public let scale: CGFloat
    public let inset: UIEdgeInsets
}

class MainTableViewController: UITableViewController, UZTextViewDelegate, UIViewControllerPreviewingDelegate {
    var contents: [Content] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UZTextView.checkMemoryLeak = true
        
        do {
            let data = try Data(contentsOf: Bundle.main.url(forResource: "source", withExtension: "json")!)
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                self.contents = try json.flatMap({
                    guard let body = $0["body"] as? String else { return nil }
                    guard let aa = $0["aa"] as? Bool else { return nil }
                    guard let margin = $0["margin"] as? CGFloat else { return nil}
                    
                    guard let data = body.data(using: .utf8) else { return nil }
                    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                        NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                        NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue
                    ]
                    let inset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
                    let attributedString = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
                    if aa {
                        let size = UZTextView.size(of: attributedString, restrictedWithin: self.view.frame.size.width - 16, inset: inset)
                        let ratio = (self.view.frame.size.width - 16) / size.width
                        return Content(attributedString: attributedString, height: size.height * ratio + 16, scale: ratio, inset: inset)
                    } else {
                        let size = UZTextView.size(of: attributedString, restrictedWithin: self.view.frame.size.width - 16, inset: inset)
                        let height = size.height + 16
                        return Content(attributedString: attributedString, height: height, scale: 1, inset: inset)
                    }
                })
            }
            tableView.reloadData()
        } catch {
            print(error)
        }
        
        self.registerForPreviewing(with: self, sourceView: self.view)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                           viewControllerForLocation location: CGPoint) -> UIViewController? {
        let cells: [SampleCell] = self.tableView.visibleCells
            .flatMap({ $0 as? SampleCell })
            .filter({
                previewingContext.sourceView.convert($0.textView.frame, from: $0.textView).contains(location)
            })
        let linkAndRectArray: [(URL, CGRect)] = cells.flatMap({
            let locationInTextView = self.view.convert(location, to: $0.textView)
            guard let attributes = $0.textView.attributes(at: locationInTextView) else { return nil }
            
            switch attributes {
            case .rect(let attribute, let rect):
                if let url = attribute[.link] as? URL {
                    return (url, rect)
                }
                return nil
            default:
                return nil
            }
        })
        
        guard let linkAndRect = linkAndRectArray.first else { return nil }
        previewingContext.sourceRect = linkAndRect.1
        let controller = SFSafariViewController(url: linkAndRect.0)
        return controller
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        let nav = UINavigationController(rootViewController: viewControllerToCommit)
        self.present(nav, animated: true, completion: nil)
    }
    
    func textView(_ textView: UZTextView, didClickLinkInfo info: UZTextViewAttributeInfo) {
        if let url = info.attribute[.link] as? URL {
            let controller = SFSafariViewController(url: url)
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func textView(_ textView: UZTextView, didLongTapLinkInfo info: UZTextViewAttributeInfo) {
        if let url = info.attribute[.link] as? URL {
            let sheet = UIAlertController(title: "Link", message: url.absoluteString, preferredStyle: .actionSheet)
            sheet.addAction(
                UIAlertAction(title: "Copy", style: .default) { (_) in print("copy") }
            )
            sheet.addAction(
                UIAlertAction(title: "Open", style: .default) { (_) in
                    let controller = SFSafariViewController(url: url)
                    self.present(controller, animated: true, completion: nil)
                }
            )
            sheet.addAction(
                UIAlertAction(title: "Open in Safari", style: .default) { (_) in
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            )
            sheet.addAction(
                UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
            )
            self.present(sheet, animated: true, completion: nil)
        }
    }
    
    func selectingStringBegun(_ textView: UZTextView) {
        self.tableView.isScrollEnabled = false
    }
    
    func selectingStringEnded(_ textView: UZTextView) {
        self.tableView.isScrollEnabled = true
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return contents[indexPath.row].height
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        if let cell = cell as? SampleCell {
            cell.textView.attributedString = contents[indexPath.row].attributedString
            cell.textView.scale = contents[indexPath.row].scale
            cell.textView.contentInset = contents[indexPath.row].inset
            cell.textView.delegate = self
        }

        return cell
    }
}
