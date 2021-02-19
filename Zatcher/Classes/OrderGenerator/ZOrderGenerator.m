//
//  ZOrderGenerator.m
//  Zatcher
//
//  Created by lzackx on 2021/2/19.
//

#import "ZOrderGenerator.h"

#include <stdint.h>
#include <stdio.h>
#include <sanitizer/coverage_interface.h>
#import <dlfcn.h>
#import <libkern/OSAtomic.h>

@implementation ZOrderGenerator

#pragma mark - Instrumentation
static OSQueueHead orderSymbols = OS_ATOMIC_QUEUE_INIT;

typedef struct {
	void *pc;
	void *next;
}OrderSymbolNode;

void __sanitizer_cov_trace_pc_guard_init(uint32_t *start, uint32_t *stop) {
	
	static uint32_t N;
	if (start == stop || *start) return;
	printf("__sanitizer_cov_trace_pc_guard_init: %p %p\n", start, stop);
	for (uint32_t *x = start; x < stop; x++)
	*x = ++N;
}

void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
	
// comment this for +[NSObject load] methods
//    if(!*guard) return;
	
	void *PC = __builtin_return_address(0); // parameter: level of pc
	Dl_info info;
	dladdr(PC, &info);
	OrderSymbolNode *node = malloc(sizeof(OrderSymbolNode));
	*node = (OrderSymbolNode){PC, NULL};
	OSAtomicEnqueue(&orderSymbols, node, offsetof(OrderSymbolNode, next));
}

+ (void)generateOrderFile {
	
	NSMutableArray<NSString *> * symbolNames = [NSMutableArray array];
	while (YES) {
		OrderSymbolNode *node =  OSAtomicDequeue(&orderSymbols, offsetof(OrderSymbolNode, next));
		if(node ==NULL) break;
		Dl_info info = {0};
		dladdr(node->pc, &info);
		free(node);
		NSString *name = @(info.dli_sname);
		BOOL isObjc = [name hasPrefix: @"+["] || [name hasPrefix: @"-["];
		NSString *symbolName = isObjc ? name : [NSString stringWithFormat:@"_%@",name];
		[symbolNames addObject:symbolName];
	}
	NSEnumerator *enumerator = [symbolNames reverseObjectEnumerator];
	NSMutableArray *funcs = [NSMutableArray arrayWithCapacity:symbolNames.count];
	NSString *name;
	while (name = [enumerator nextObject]) {
		if (![funcs containsObject:name]) {
			[funcs addObject:name];
		}
	}
	[funcs removeObject:[NSString stringWithFormat:@"%s", __FUNCTION__]];
	NSString *orderSymbolString = [funcs componentsJoinedByString:@"\n"];
	NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"project.order"];
	NSData *fielContents = [orderSymbolString dataUsingEncoding:NSUTF8StringEncoding];
	[[NSFileManager defaultManager] createFileAtPath:filePath contents:fielContents attributes:nil];
	
	NSLog(@"%@",funcs);
	NSLog(@"%@",filePath);
	NSLog(@"%@",fielContents);
}

+ (void)generateAfterTimeInterval:(NSTimeInterval)timeInterval {
	if (@available(iOS 10.0, *)) {
		[NSTimer scheduledTimerWithTimeInterval:timeInterval repeats:NO block:^(NSTimer * _Nonnull timer) {
			[ZOrderGenerator generateOrderFile];
		}];
	} else {
		NSAssert([UIDevice currentDevice].systemVersion.doubleValue >= 10.0, @"System version too low ");
	}
}

@end
