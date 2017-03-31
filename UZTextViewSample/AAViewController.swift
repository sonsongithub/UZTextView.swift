//
//  AAViewController.swift
//  UZTextView
//
//  Created by sonson on 2017/03/29.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit
import UZTextView

class AAViewController: UIViewController, UIViewControllerPreviewingDelegate {
    @IBOutlet var textView: UZTextView!
    let aa = "<font face=\"Mona\">　　　　, -.―――--.､<br/>　　 ,ｲ,,i､ﾘ,,リ,,ﾉﾉ,,;;;;;;;;ヽ<br/>　　.i;}'　　　　　　　\"ﾐ;;;;:}<br/>　　|} ,,..､_､　 , _,,,..､ 　|;;;:|<br/>　　|} ,_tｭ,〈 　ﾋ''tｭ_　 i;;;;|<br/>　　|　 ｰ'　|　｀ - 　 　 ﾄ'{<br/>　.｢|　　 ｲ_i _ >､ 　 　 }〉}<br/>　｀{|　_.ﾉ;;/;;/,ゞ;ヽ､ 　.!-'<br/>　　 |　　 　＝'\" 　 　 |<br/>　 　 iﾞ ､_　　ﾞ,,,　 ,,　' {<br/>　　丿＼　￣￣　 _,,-\"ヽ<br/>''\"~ヽ　　＼､_;;,..-\" ＿　,i`ー-<br/>　　 ヽ､oヽ/ ＼　 /o/　 |<br/><br/><br/><br/><a href=\"http://sonson.jp\">http://sonson.jp</a></font>"
    
    let aa2 = "<font face=\"Mona\">　　　　　　　　  　 　 　 　 __|__　　　　　-┼-<br/>　 　　　　　　 七_　 　 　  ,-|ナ、 　 　,.-┼ト、<br/>　　　あ　　　 (乂 ）　　　 し'ヽ ノ　　　ヽ__ レノ<br/>　小←──────────────────────→大<br/><br/>　薄<br/>　↑米米米米米米米 : : : : : : : : : : : : : : :<br/>　｜髟髟髟髟髟髟髟 :..:..:..:..:..:..:.:..:..:..:..:.:..:<br/>　｜面面面面面面面 :.:.:.:.:.:.:.:.:.:.::.:.:.:.:.:.:.:.:<br/>　｜鼎鼎鼎鼎鼎鼎鼎 :.::.::.::.::.::.::.::.::.::.::.::.:::<br/>　｜蠻蠻蠻蠻蠻蠻蠻 ::::::::::::::::::::::::::::::::::::::<br/>　｜鬣鬣鬣鬣鬣鬣鬣 ::::::::::::::::::::::::::::::::::::::<br/>　｜麌麌麌麌麌麌麌 ;:;::;::;::;::;::;::;::;::;::;::;::;::<br/>　｜黌黌黌黌黌黌黌 :;:;:;:;:;:;:;:;:;:;::;:;:;:;:;:;:;:;:<br/>　｜鬱鬱鬱鬱鬱鬱鬱 ;;:;;:;;:;;:;;:;;:;;:;;:;;:;;:;;:;;:;;<br/>　↓䨻䨻䨻䨻䨻䨻䨻 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;<br/>　濃</font>"
    override func viewDidLoad() {

        super.viewDidLoad()
//        let attr = NSMutableAttributedString(string: aa2)
        do {
            guard let data = aa2.data(using: .utf8) else { return }
            let options: [String: Any] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue
            ]
            let attr = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
            textView.attributedString = attr
            
            //        attr.addAttributes(
            //            [NSLinkAttributeName:URL(string: "http://sonson.jp")!],
            //            range: NSRange(location: attr.string.utf16.count - 16, length: 16)
            //        )
            
            let size = UZTextView.size(of: attr, restrictedWithin: textView.frame.size.width)
            let ratio = textView.frame.size.width / size.width
            print(ratio)
            textView.scale = ratio
            textView.tintColor = .red
            
            self.registerForPreviewing(with: self, sourceView: self.view)
        } catch {
            print("\(error)")
        }
//        let attr = NSMutableAttributedString(
        
//        let font = UIFont(name: "mona", size: 20)!
//        attr.addAttribute(
//            NSFontAttributeName,
//            value: font,
//            range: NSRange(location: 0, length: attr.string.utf16.count)
//        )
        
        
        
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
