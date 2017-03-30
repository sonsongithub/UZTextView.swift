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
    let aa = "　　　　, -.―――--.､\n　　 ,ｲ,,i､ﾘ,,リ,,ﾉﾉ,,;;;;;;;;ヽ\n　　.i;}'　　　　　　　\"ﾐ;;;;:}\n　　|} ,,..､_､　 , _,,,..､ 　|;;;:|\n　　|} ,_tｭ,〈 　ﾋ''tｭ_　 i;;;;|\n　　|　 ｰ'　|　｀ - 　 　 ﾄ'{\n　.｢|　　 ｲ_i _ >､ 　 　 }〉}\n　｀{|　_.ﾉ;;/;;/,ゞ;ヽ､ 　.!-'\n　　 |　　 　＝'\" 　 　 |\n　 　 iﾞ ､_　　ﾞ,,,　 ,,　' {\n　　丿＼　￣￣　 _,,-\"ヽ\n''\"~ヽ　　＼､_;;,..-\" ＿　,i`ー-\n　　 ヽ､oヽ/ ＼　 /o/　 |\n\n\n\n http://sonson.jp"
    
    let aa2 = "　　　　　　　　  　 　 　 　 __|__　　　　　-┼-\n　 　　　　　　 七_　 　 　  ,-|ナ、 　 　,.-┼ト、\n　　　あ　　　 (乂 ）　　　 し'ヽ ノ　　　ヽ__ レノ\n　小←──────────────────────→大\n\n　薄\n　↑米米米米米米米 : : : : : : : : : : : : : : :\n　｜髟髟髟髟髟髟髟 :..:..:..:..:..:..:.:..:..:..:..:.:..:\n　｜面面面面面面面 :.:.:.:.:.:.:.:.:.:.::.:.:.:.:.:.:.:.:\n　｜鼎鼎鼎鼎鼎鼎鼎 :.::.::.::.::.::.::.::.::.::.::.::.:::\n　｜蠻蠻蠻蠻蠻蠻蠻 ::::::::::::::::::::::::::::::::::::::\n　｜鬣鬣鬣鬣鬣鬣鬣 ::::::::::::::::::::::::::::::::::::::\n　｜麌麌麌麌麌麌麌 ;:;::;::;::;::;::;::;::;::;::;::;::;::\n　｜黌黌黌黌黌黌黌 :;:;:;:;:;:;:;:;:;:;::;:;:;:;:;:;:;:;:\n　｜鬱鬱鬱鬱鬱鬱鬱 ;;:;;:;;:;;:;;:;;:;;:;;:;;:;;:;;:;;:;;\n　↓䨻䨻䨻䨻䨻䨻䨻 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n　濃"

    override func viewDidLoad() {
        super.viewDidLoad()
        let attr = NSMutableAttributedString(string: aa2)
        let font = UIFont(name: "Mona", size: 20)!
        attr.addAttribute(
            NSFontAttributeName,
            value: font,
            range: NSRange(location: 0, length: attr.string.utf16.count)
        )
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
