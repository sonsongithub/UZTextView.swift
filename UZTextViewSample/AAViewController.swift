//
//  AAViewController.swift
//  UZTextView
//
//  Created by sonson on 2017/03/29.
//  Copyright © 2017年 sonson. All rights reserved.
//

import UIKit
import UZTextView

class AAViewController: UIViewController {
    @IBOutlet var textView: UZTextView!
    let aa = "　　　　, -.―――--.､\n　　 ,ｲ,,i､ﾘ,,リ,,ﾉﾉ,,;;;;;;;;ヽ\n　　.i;}'　　　　　　　\"ﾐ;;;;:}\n　　|} ,,..､_､　 , _,,,..､ 　|;;;:|\n　　|} ,_tｭ,〈 　ﾋ''tｭ_　 i;;;;|\n　　|　 ｰ'　|　｀ - 　 　 ﾄ'{\n　.｢|　　 ｲ_i _ >､ 　 　 }〉}\n　｀{|　_.ﾉ;;/;;/,ゞ;ヽ､ 　.!-'\n　　 |　　 　＝'\" 　 　 |\n　 　 iﾞ ､_　　ﾞ,,,　 ,,　' {\n　　丿＼　￣￣　 _,,-\"ヽ\n''\"~ヽ　　＼､_;;,..-\" ＿　,i`ー-\n　　 ヽ､oヽ/ ＼　 /o/　 |"

    override func viewDidLoad() {
        super.viewDidLoad()
        let attr = NSMutableAttributedString(string: aa)
        let font = UIFont(name: "Mona", size: 20)!
        attr.addAttribute(NSFontAttributeName, value: font, range: NSRange(location: 0, length: attr.string.utf16.count))
        textView.attributedString = attr
        
        let size = UZTextView.size(of: attr, restrictedWithin: textView.frame.size.width)
        let ratio = textView.frame.size.width / size.width
        print(ratio)
        textView.scale = ratio
    }
}
