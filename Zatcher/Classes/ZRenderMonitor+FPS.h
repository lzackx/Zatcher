//
//  ZRenderMonitor+FPS.h
//  Zatcher
//
//  Created by lzackx on 2021/2/7.
//

#import <Zatcher/Zatcher.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZRenderMonitor (FPS)

#pragma mark - RunLoop Observer
@property (nonatomic, readwrite, strong) dispatch_semaphore_t observerSemaphore;
@property (nonatomic, readwrite, assign) int lagCounter;
@property (nonatomic, readwrite, assign) CFRunLoopActivity rlActivity;

- (void)startWatchingWithTimeoutThread:(NSInteger)timeoutThread
							lagCallout:(void (^ _Nullable )(NSString *callstack))lagCallout;


#pragma mark - CADisplayLink
@property (nonatomic, readwrite, strong) CADisplayLink *displayLink;
@property (nonatomic, readwrite, assign) NSTimeInterval lastTimestamp;

- (void)startWatchingFPS;

@end

NS_ASSUME_NONNULL_END
