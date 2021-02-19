//
//  ZRenderMonitor.m
//  Zatcher
//
//  Created by lzackx on 2021/2/7.
//

#import "ZRenderMonitor.h"


@interface ZRenderMonitor ()



@end


@implementation ZRenderMonitor

#pragma mark - Life Cycle

+ (instancetype)shared {
	static ZRenderMonitor *instance = nil;
	static dispatch_once_t once;
	dispatch_once(&once, ^{
		instance = [[ZRenderMonitor alloc] init];
	});
	return instance;
}

@end
