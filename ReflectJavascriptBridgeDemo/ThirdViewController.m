//
//  ThirdViewController.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/31.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "ThirdViewController.h"
#import "ReflectJavascriptBridge.h"
#import <WebKit/WebKit.h>

@protocol NavigatorProtocol <ReflectBridgeExport>

- (void)setOffset:(NSInteger)offset;

@end

@interface ThirdViewController () <UIWebViewDelegate, NavigatorProtocol>

@property (nonatomic) WKWebView *webView;
@property (nonatomic) ReflectJavascriptBridge *bridge;

@end

@implementation ThirdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height)];
    [self.view addSubview:_webView];
    _webView.backgroundColor = [UIColor clearColor];
    
    _bridge = [ReflectJavascriptBridge bridge:_webView delegate:self];
    _bridge[@"navigator"] = self;
    
    NSData *htmlData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"demo2" ofType:@"html"]];
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
