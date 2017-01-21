//
//  ViewController.swift
//  Reflect
//
//  Created by LZephyr on 2017/1/4.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

import UIKit

@objc protocol BridgeProtocol: ReflectExport {
    var name: String { set get }
    func function(withName name: String, _ age: Int)
}

class JSObject: NSObject, BridgeProtocol {
    var name: String = "wind"
    var age: String = ""
    func function(withName name: String, _ age: Int) {
        print("\(name)")
    }
    
    init(_ name: String) {
        super.init()
        self.name = name
    }
}

class ViewController: UIViewController {
    
    var bridge: ReflectJavascriptBridge? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let webView = UIWebView()
        webView.frame = CGRect(x: 0, y: 20, width: self.view.frame.size.width, height: self.view.frame.size.height - 20)
        bridge = ReflectJavascriptBridge.bridge(webView, delegate: self)
        
        let obj = JSObject("wind")
        
        bridge?["obj"] = obj
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController: UIWebViewDelegate {
    
}
