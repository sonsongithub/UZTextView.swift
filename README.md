# UZTextView.swift

Clickable and selectable text view for iOS, in **Swift**!!!!!

## What's UZTextView?

UZTextView class implements implements the behavior for a scrollable, multiline, selectable, clickable text region. The class supports the display of text using custom style and link information.
Create subclass of the class and use UZTextView internal category methods if you want to expand the UZTextView class. For example, you have to override some methods of the class in order to add your custom UIMenuItem objects.
You can use the Class on the UITableView cell and set custom style text using NSAttributedString class objects(like the following image).

## Contribution

### Easy to use

For exmple, you can render html string by following codes,

```
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
```

### Supported attributes of NSAttributedString

 * NSLinkAttributeName
 * NSFontAttributeName
 * NSStrikethroughStyleAttributeName
 * NSUnderlineStyleAttributeName
 * NSBackgroundColorAttributeName


### Size estimation

It's important to estimate the size of rendered string in case of UITableView. 

```
let size = UZTextView.size(of: attributedString, restrictedWithin: self.view.frame.size.width - 16)
height = size.height + 18
```

### Japanese ASCII Art

UZTextView enables to render Japanese ASCII art by `scale` property and "[Mona](http://www.geocities.jp/ipa_mona/)" font.

```
let attr = NSMutableAttributedString(string: asciiart)
let font = UIFont(name: "Mona", size: 20)!
attr.addAttribute(
    NSFontAttributeName,
    value: font,
    range: NSRange(location: 0, length: attr.string.utf16.count)
)
textView.attributedString = attr

let size = UZTextView.size(of: attr, restrictedWithin: textView.frame.size.width)
let ratio = textView.frame.size.width / size.width
textView.scale = ratio
```

![aa](https://cloud.githubusercontent.com/assets/33768/24529153/05b03bbc-15e5-11e7-938f-3572795dc1d5.png) ![](https://cloud.githubusercontent.com/assets/33768/24529684/10125ea2-15e8-11e7-9e44-fb0abcd9e30b.png)

## License

 * UZTextView.swift is available under MIT License.
 * UZTextView.swift is based on [UZTextView](https://github.com/sonsongithub/UZTextView).
 * UZTextView.swift uses [SECoreTextView](https://github.com/kishikawakatsumi/SECoreTextView) source code. [SECoreTextView](https://github.com/kishikawakatsumi/SECoreTextView) is available under the MIT license.
 * Sample project contains "[Mona.font](http://www.geocities.jp/ipa_mona/)".