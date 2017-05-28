//
//  WKWebViewTestController.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/31.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "WKWebViewTestController.h"
#import "ReflectJavascriptBridge.h"
#import <WebKit/WebKit.h>
#import "NativeBridgeObject.h"

@protocol NavigatorProtocol <ReflectBridgeExport>

- (void)setOffset:(NSInteger)offset;

@end

@interface WKWebViewTestController () <NavigatorProtocol>

@property (nonatomic) WKWebView *webView;
@property (nonatomic) ReflectJavascriptBridge *bridge;

@end

@implementation WKWebViewTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:_webView];
    _webView.backgroundColor = [UIColor clearColor];
    
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

#pragma mark - Export method

- (void)setOffset:(NSInteger)offset {
    if (offset > 256) {
        offset = 256;
    }
    NSLog(@"change alpha %ld", offset);
    CGFloat alpha = 1 - ((CGFloat)offset / 256.0f);
    self.navigationController.navigationBar.alpha = alpha;
}

@end
