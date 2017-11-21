//
//  VDViewController.m
//  VDImageCache
//
//  Created by dvvu on 11/16/2017.
//  Copyright (c) 2017 dvvu. All rights reserved.
//

#import "VDViewController.h"
#import "VDImageCache.h"
@interface VDViewController ()

@end

@implementation VDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[VDImageCache sharedInstance] storeImage:[UIImage imageNamed:@"test.png"] withKey:@"identifier"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
