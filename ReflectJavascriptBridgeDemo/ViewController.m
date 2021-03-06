//
//  ViewController.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/1/22.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "ViewController.h"
#import "ReflectJavascriptBridge.h"
#import "RJBCommand.h"
#import "UIWebViewTestController.h"
#import "WKWebViewTestController.h"

@interface ViewController () <UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) ReflectJavascriptBridge *bridge;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"UIWebView";
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"WKWebView";
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        UIWebViewTestController *vc = [[UIWebViewTestController alloc] initWithNibName:@"UIWebViewTestController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 1) {
        WKWebViewTestController *vc = [[WKWebViewTestController alloc] initWithNibName:@"WKWebViewTestController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
