//
//  SecondViewController.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/25.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "SecondViewController.h"
#import "ReflectJavascriptBridge.h"
#import "BridgeClass.h"
#import <WebKit/WebKit.h>

@protocol NavigationBarBridgeDelegate <ReflectBridgeExport>

- (void)setNavBarOffset:(CGFloat)offset;

@end

@interface SecondViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonnull) ReflectJavascriptBridge *bridge;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _webView.delegate = self;
    _webView.backgroundColor = [UIColor clearColor];
    
    // 1. Create bridge to webView
    _bridge = [ReflectJavascriptBridge bridge:_webView delegate:self];
    
    // 2. bridge native instance to js, just like JavaScriptCore
    BridgeClass *obj = [[BridgeClass alloc] init];
    _bridge[@"nativeObject"] = obj;
    
    // 3. bridge block to js
    _bridge[@"block"] = ^(NSString *string) {
        NSLog(@"call native block with param: %@", string);
        return @"block return string";
    };
    
    NSData *htmlData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"demo1" ofType:@"html"]];
    NSString *html = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    [_webView loadHTMLString:html baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
