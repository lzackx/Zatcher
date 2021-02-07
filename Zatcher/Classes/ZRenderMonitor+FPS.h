//
//  ZRenderMonitor+FPS.h
//  Zatcher
//
//  Created by lzackx on 2021/2/7.
//

#import <Zatcher/Zatcher.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZRenderMonitor (FPS)

@property (nonatomic, readwrite, strong) dispatch_semaphore_t observerSemaphore;
@property (nonatomic, readwrite, assign) int lagCounter;
@property (nonatomic, readwrite, assign) CFRunLoopActivity rlActivity;

- (void)startWatchingWithTimeoutThread:(NSInteger)timeoutThread
							lagCallout:(void (^ _Nullable )(NSString *callstack))lagCallout;

@end

NS_ASSUME_NONNULL_END
