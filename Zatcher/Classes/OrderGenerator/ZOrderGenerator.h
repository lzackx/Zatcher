//
//  ZOrderGenerator.h
//  Zatcher
//
//  Created by lzackx on 2021/2/19.
//


/*
 other c flags:
 -fsanitize-coverage=func,trace-pc-guard
 
 other swift flags:
 -sanitize=undefined
 -sanitize-coverage=func
 */


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZOrderGenerator : NSObject

+ (void)generateAfterTimeInterval:(NSTimeInterval)timeInterval;

@end

NS_ASSUME_NONNULL_END

