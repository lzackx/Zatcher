//
//  ZViewController.m
//  Zatcher
//
//  Created by lzackx on 02/07/2021.
//  Copyright (c) 2021 lzackx. All rights reserved.
//

#import "ZViewController.h"
#import <Zatcher/Zatcher.h>

@interface ZViewController ()

@end

@implementation ZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	NSLog(@"touched");
}

@end
