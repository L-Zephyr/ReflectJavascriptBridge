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
    
    _bridge = [ReflectJavascriptBridge bridge:_webView delegate:self];
    
    BridgeClass *obj = [[BridgeClass alloc] init];
    _bridge[@"nativeObject"] = obj;
    
//    NSURL *url = [NSURL URLWithString:@"http://localhost:3000/main.html"];
//    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    NSData *htmlData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"main" ofType:@"html"]];
    NSString *html = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
    [_webView loadHTMLString:html baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
