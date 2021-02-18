//
//  ZRenderMonitor+FPS.m
//  Zatcher
//
//  Created by lzackx on 2021/2/7.
//

#import "ZRenderMonitor+FPS.h"
#import <CoreFoundation/CFRunLoop.h>
#import <objc/runtime.h>
#import <CrashReporter/CrashReporter.h>

@implementation ZRenderMonitor (FPS)

#pragma mark - RunLoop Observer
- (dispatch_semaphore_t)observerSemaphore {
	return objc_getAssociatedObject(self, @selector(observerSemaphore));
}

- (void)setObserverSemaphore:(dispatch_semaphore_t)observerSemaphore {
	objc_setAssociatedObject(self,
							 @selector(observerSemaphore),
							 observerSemaphore,
							 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (int)lagCounter {
	NSNumber *lc = objc_getAssociatedObject(self, @selector(lagCounter));
	return lc.intValue;
}

- (void)setLagCounter:(int)lagCounter {
	NSNumber *lc = [NSNumber numberWithInt:lagCounter];
	objc_setAssociatedObject(self,
							 @selector(lagCounter),
							 lc,
							 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CFRunLoopActivity)rlActivity {
	NSNumber *a = objc_getAssociatedObject(self, @selector(rlActivity));
	return (CFRunLoopActivity)(a.intValue);
}

- (void)setRlActivity:(CFRunLoopActivity)rlActivity {
	NSNumber *a = [NSNumber numberWithInt:(int)rlActivity];
	objc_setAssociatedObject(self,
							 @selector(rlActivity),
							 a,
							 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)startWatchingWithTimeoutThread:(NSInteger)timeoutThread
							lagCallout:(void (^)(NSString *callstack))lagCallout {
	
	self.observerSemaphore = dispatch_semaphore_create(0);
	self.lagCounter = 0;
	
	// add observer
	CFRunLoopObserverContext context = {0, (__bridge void *)self, NULL, NULL};
	CFRunLoopObserverRef fpsObserver = CFRunLoopObserverCreate(CFAllocatorGetDefault(),
																kCFRunLoopAllActivities,
																true,
																0,
																&observerCallout,
																&context);
	CFRunLoopAddObserver(CFRunLoopGetMain(), fpsObserver, kCFRunLoopCommonModes);

	// sub thread
	dispatch_queue_t queue = dispatch_queue_create("com.zatcher.monitor.render",
												   DISPATCH_QUEUE_SERIAL);
	dispatch_async(queue, ^{
		while (1) {
			intptr_t result = dispatch_semaphore_wait(self.observerSemaphore,
													  dispatch_time(DISPATCH_TIME_NOW, timeoutThread * NSEC_PER_MSEC));
			if (result != 0) {
				if (self.rlActivity == kCFRunLoopBeforeSources ||
					self.rlActivity == kCFRunLoopAfterWaiting) {
					self.lagCounter++;
					if (self.lagCounter > 3) {
						self.lagCounter = 0;
						if (lagCallout) {
							NSData *lagData = [[[PLCrashReporter alloc]
												initWithConfiguration:[[PLCrashReporterConfig alloc] initWithSignalHandlerType:PLCrashReporterSignalHandlerTypeBSD
																										 symbolicationStrategy:PLCrashReporterSymbolicationStrategyAll]]
											   generateLiveReport];
							PLCrashReport *lagReport = [[PLCrashReport alloc] initWithData:lagData
																					 error:NULL];
							NSString *callStack = [PLCrashReportTextFormatter stringValueForCrashReport:lagReport
																							   withTextFormat:PLCrashReportTextFormatiOS];
							lagCallout(callStack);
						}
					}
				}
			}
		}
	});
}

static void observerCallout(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info) {
	[ZRenderMonitor shared].rlActivity = activity;
	switch (activity) {
		case kCFRunLoopEntry:
			[ZRenderMonitor shared].rlActivity = kCFRunLoopEntry;
//#ifdef DEBUG
//			NSLog(@"observerCallout: kCFRunLoopEntry");
//#endif
			break;
		case kCFRunLoopBeforeTimers:
			[ZRenderMonitor shared].rlActivity = kCFRunLoopBeforeTimers;
//#ifdef DEBUG
//			NSLog(@"observerCallout: kCFRunLoopBeforeTimers");
//#endif
			break;
		case kCFRunLoopBeforeSources:
			[ZRenderMonitor shared].rlActivity = kCFRunLoopBeforeSources;
//#ifdef DEBUG
//			NSLog(@"observerCallout: kCFRunLoopBeforeSources");
//#endif
			break;
		case kCFRunLoopBeforeWaiting:
			[ZRenderMonitor shared].rlActivity = kCFRunLoopBeforeWaiting;
//#ifdef DEBUG
//			NSLog(@"observerCallout: kCFRunLoopBeforeWaiting");
//#endif
			break;
		case kCFRunLoopAfterWaiting:
			[ZRenderMonitor shared].rlActivity = kCFRunLoopAfterWaiting;
//#ifdef DEBUG
//			NSLog(@"observerCallout: kCFRunLoopAfterWaiting");
//#endif
			break;
		case kCFRunLoopExit:
			[ZRenderMonitor shared].rlActivity = kCFRunLoopExit;
//#ifdef DEBUG
//			NSLog(@"observerCallout: kCFRunLoopExit");
//#endif
			break;
		default:
			break;
	}
	dispatch_semaphore_signal([ZRenderMonitor shared].observerSemaphore);
}

#pragma mark - CADisplayLink
- (CADisplayLink *)displayLink {
	return objc_getAssociatedObject(self, @selector(displayLink));
}

- (void)setDisplayLink:(dispatch_semaphore_t)displayLink {
	objc_setAssociatedObject(self,
							 @selector(displayLink),
							 displayLink,
							 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)lastTimestamp {
	NSNumber *lc = objc_getAssociatedObject(self, @selector(lastTimestamp));
	if (lc) {
		return (NSTimeInterval)(lc.doubleValue);
	} else {
		return 0;
	}
}

- (void)setLastTimestamp:(NSTimeInterval)lastTimestamp {
	NSNumber *lts = [NSNumber numberWithDouble:lastTimestamp];
	objc_setAssociatedObject(self,
							 @selector(lastTimestamp),
							 lts,
							 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)startWatchingFPS {
	self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(showFPS:)];
	[self.displayLink  addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

static NSInteger _vSyncCount = 0;
- (void)showFPS:(CADisplayLink *)sender {
	if (self.lastTimestamp == 0) {
		self.lastTimestamp = sender.timestamp;
		return;
	}
	_vSyncCount++;
	double fps = 0;
	NSTimeInterval interval = sender.timestamp - self.lastTimestamp;
	if (interval >= 1) {
		fps = _vSyncCount / interval; // frame per second
		_vSyncCount = 0;
		self.lastTimestamp = sender.timestamp;
	} else {
		return;
	}
	NSLog(@"FPS: %f", fps);
}

@end
