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
    obj.name = @"wind";
    obj.age = 18;
    obj.success = YES;
    _bridge[@"obj"] = obj;
//    _bridge[@"navBar"] = self; // 这里有循环引用
    
//    NSDictionary *info = @{@"className": @"BridgeClass",
//                           @"identifier": @"1",
//                           @"method": @"classFunction",
//                           @"args": @[]};
//    RJBCommand *command = [RJBCommand commandWithDic:info];
//    [command exec:obj];
    
    NSURL *url = [NSURL URLWithString:@"http://localhost:3000/main.html"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(id)sender {
//    [_bridge callMethod:@"func" withArgs:nil];
    NSURL *url = [NSURL URLWithString:@"http://localhost:3000/main.html"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

@end
