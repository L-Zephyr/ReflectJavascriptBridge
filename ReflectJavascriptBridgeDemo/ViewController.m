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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
