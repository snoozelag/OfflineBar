# OfflineBar
 
[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
             )](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
             )](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
            )](http://mit-license.org)
[![Twitter](https://img.shields.io/badge/twitter-@snoozelag-blue.svg?style=flat)](http://twitter.com/snoozelag)

**In facebook or slack of ios app, offline display bar similar to the one that is displayed.**

![OfflineBar](https://github.com/snoozelag/OfflineBar/blob/master/README_resources/OfflineBarDemo20170511.gif)

## Requirements ##
* Swift 3.0
* iOS 8.0+
* Xcode 8

## Installation ##
#### Cocoapods ####
- Add into your Podfile.

```:Podfile
pod "OfflineBar"
```

Then `$ pod install`
- Add `import OfflineBar` to the top of your files where you wish to use it.  
  
## Usage ##
  
Here is the code for this example project. .  
```swift
import UIKit
import OfflineBar

class ViewController: UIViewController {

    private var offlineBar: OfflineBar!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.offlineBar = OfflineBar(addedTo: self, style: .reload) // like Slack style
//           or
//        self.offlineBar = OfflineBar(addedTo: self, style: .close) // like Facebook style
    }
}
```

##### See also:  
- [:link: iOS Example Project](https://github.com/snoozelag/OfflineBar/tree/master/Example/OfflineBarExample)

## Author
  
Teruto Yamasaki, y.teruto@gmail.com
  
## License ##
  
The MIT License (MIT)
See the LICENSE file for more info.  
