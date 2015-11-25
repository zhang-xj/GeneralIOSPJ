//
//  BodyCareViewController.m
//  QHC
//
//  Created by qhc2015 on 15/6/15.
//  Copyright (c) 2015年 qhc2015. All rights reserved.
//

#import "QHCBodyCareViewController.h"
#import "QHCBodyCareView.h"

@interface QHCBodyCareViewController ()

@end

@implementation QHCBodyCareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background2.png"]];
    QHCBodyCareView *bodyCareView = [[QHCBodyCareView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    [self.view addSubview:bodyCareView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
