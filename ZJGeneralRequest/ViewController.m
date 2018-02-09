//
//  ViewController.m
//  ZJGeneralRequest
//
//  Created by 吴孜健 on 2018/2/8.
//  Copyright © 2018年 吴孜健. All rights reserved.
//

#import "ViewController.h"
#import "ZJGeneralRequest.h"
#import "ZJModel.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    ZJGeneralRequest *req = [ZJGeneralRequest requestWithParams:nil FormDataApi:@"https://www.baidu.com"];
    [req requestReturnClass:@"NSString" Success:^(id res) {
        NSLog(@"res :%@",res);
    } Failed:^(id errCode, id errMsg) {
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
