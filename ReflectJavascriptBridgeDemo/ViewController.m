//
//  ViewController.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "ViewController.h"
#import "ReflectJavascriptBridge.h"
#import "BridgeClass.h"
#import "RJBCommand.h"

@interface ViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) ReflectJavascriptBridge *bridge;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _bridge = [ReflectJavascriptBridge bridge:_webView delegate:self];
    
    BridgeClass *obj = [[BridgeClass alloc] init];
    _bridge[@"obj"] = obj;
    
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

- (IBAction)refreshWebView:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://localhost:3000/main.html"];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

@end
