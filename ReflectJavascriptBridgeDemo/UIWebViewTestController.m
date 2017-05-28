//
//  UIWebViewTestController.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/25.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "UIWebViewTestController.h"
#import "ReflectJavascriptBridge.h"
#import "NativeBridgeObject.h"

@protocol NavigationBarBridgeDelegate <ReflectBridgeExport>

- (void)setNavBarOffset:(CGFloat)offset;

@end

@interface UIWebViewTestController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonnull) ReflectJavascriptBridge *bridge;

@end

@implementation UIWebViewTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _webView.delegate = self;
    _webView.backgroundColor = [UIColor clearColor];
    
    // 1. Create bridge to webView
    _bridge = [ReflectJavascriptBridge bridge:_webView delegate:self];
    
    // 2. bridge native instance to js, just like JavaScriptCore
    NativeBridgeObject *obj = [[NativeBridgeObject alloc] init];
    _bridge[@"native"] = obj;
    
    // 3. bridge block to js
    _bridge[@"block"] = ^(NSString *str1, NSString *str2) {
        NSLog(@"JavaScript调用Native的Block, str1=%@, str2=%@", str1, str2);
        return [str1 stringByAppendingString:str2];
    };
    
    NSData *htmlData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"]];
    NSString *html = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    [_webView loadHTMLString:html baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
