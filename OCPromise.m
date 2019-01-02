//
//  OCPromise.m
//  FutureKit
//
//  Created by mathewwang on 2019/1/2.
//  Copyright © 2019 mathew. All rights reserved.
//

#import "OCPromise.h"
#import "OCMethodSignatureForBlock.m"

#define asyncExe(executor)     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), executor);

typedef NS_ENUM(NSInteger, OCPromiseState){
    OCPromiseStatePending = 0,  //initial state
    OCPromiseStateResolved,     //execute success state
    OCPromiseStateRejected,     //execute failed state
};

@interface OCPromise()

@property (nonatomic, assign) OCPromiseState state;
@property (nonatomic, strong) id value;
@property (nonatomic, strong) id reason;
@property (nonatomic, strong) NSMutableArray<void(^)(void)> *onResolvedCallbacks;
@property (nonatomic, strong) NSMutableArray<void(^)(void)> *onRejectedCallbacks;

@end

@implementation OCPromise

+ (OCPromise *(^)(void(^)(CallBackFunc, CallBackFunc)))Promise{
    return ^(void(^executor)(CallBackFunc, CallBackFunc)){
        OCPromise *promise = [OCPromise new];
        promise.state = OCPromiseStatePending;
        
        CallBackFunc resolve = ^(id value){
            if (promise.state == OCPromiseStatePending) {
                promise.value = value;
                promise.state = OCPromiseStateResolved;
    
                for (void(^func)(void) in promise.onResolvedCallbacks) {
                    func();
                }
            }
        };
        
        CallBackFunc reject = ^(id error){
            if (promise.state == OCPromiseStatePending) {
                promise.state = OCPromiseStateRejected;
                promise.reason = error;
                
                for (void(^func)(void) in promise.onRejectedCallbacks) {
                    func();
                }
            }
        };
        
        executor(resolve, reject);
        return promise;
    };
}

- (OCPromise *(^)(id , id))then{
    return ^(id onFullfill, id onReject){
        if (!onFullfill) { onFullfill = ^(id value){ return value; }; }
        if (!onReject) { onReject = ^(id error){ return error; };  }
        
        OCPromise *nextPromise = [OCPromise new];
        if (self.state == OCPromiseStateResolved) {
            nextPromise = create Promise(function(resolve, reject){
                asyncExe(^{
                    id retX = [OCPromise dynamicBlockCall:onFullfill value:self.value];
                    [self resolvePromise:nextPromise retX:retX resolve:resolve reject:reject];
                });
            });
        }
        
        if (self.state == OCPromiseStateRejected) {
            nextPromise = create Promise(function(resolve, reject){
                id retX = [OCPromise dynamicBlockCall:onReject value:self.reason];
                [self resolvePromise:nextPromise retX:retX resolve:resolve reject:reject];
            });
        }
        
        if (self.state == OCPromiseStatePending) {
            nextPromise = create Promise(function(resolve, reject){
                __weak typeof(self) weakSelf = self;
                [self.onResolvedCallbacks addObject:^{
                    __strong typeof(self) strongSelf = weakSelf;
                    asyncExe(^{
                        id retX = [OCPromise dynamicBlockCall:onFullfill value:strongSelf.value];
                        [strongSelf resolvePromise:nextPromise retX:retX resolve:resolve reject:reject];
                    });
                }];
                
                [self.onRejectedCallbacks addObject:^{
                    __strong typeof(self) strongSelf = weakSelf;
                    asyncExe(^{
                        id retX = [OCPromise dynamicBlockCall:onReject value:strongSelf.reason];
                        [strongSelf resolvePromise:nextPromise retX:retX resolve:resolve reject:reject];
                    });
                }];
                
            });
        }
        
        return nextPromise;
    };
}

#pragma mark resolve the promise ret
- (void)resolvePromise:(OCPromise *) promise
                  retX:(id) retX
               resolve:(CallBackFunc) resolve
                reject:(CallBackFunc) reject{
    if (promise == retX) {
        reject([NSError errorWithDomain:@"Code syntax error" code:9999 userInfo:@{NSLocalizedDescriptionKey:@"promise resolver can't  return self"}]);
        return;
    }
    __block BOOL called = NO;
    if ([retX isKindOfClass:[OCPromise class]]
        || [retX isMemberOfClass:[OCPromise class]]) {
        
        ((OCPromise*)retX).then(^(id retY){
            if (called) {
                return;
            }
            called = YES;
            [self resolvePromise:promise retX:retY resolve:resolve reject:reject];
        }, ^(id error){
            if (called) {
                return;
            }
            called = YES;
            reject(error);
        });
    }else{
        resolve(retX);
    }
}

+ (id)dynamicBlockCall:(id) block value:(id) value{
    NSMethodSignature *sig = NSMethodSignatureForBlock(block);
    const char rtype = sig.methodReturnType[0];
    
#define call_block(type) ({^type{ \
return ((type(^)(id))block)(value); \
}();})
    
    switch (rtype) {
        case 'v':
            call_block(void);
            return nil;
        case '@':
            return call_block(id) ?: nil;
        case '*': {
            char *str = call_block(char *);
            return str ? @(str) : nil;
        }
        case 'c': return @(call_block(char));
        case 'i': return @(call_block(int));
        case 's': return @(call_block(short));
        case 'l': return @(call_block(long));
        case 'q': return @(call_block(long long));
        case 'C': return @(call_block(unsigned char));
        case 'I': return @(call_block(unsigned int));
        case 'S': return @(call_block(unsigned short));
        case 'L': return @(call_block(unsigned long));
        case 'Q': return @(call_block(unsigned long long));
        case 'f': return @(call_block(float));
        case 'd': return @(call_block(double));
        case 'B': return @(call_block(_Bool));
        case '^':
            if (strcmp(sig.methodReturnType, "^v") == 0) {
                call_block(void);
                return nil;
            }
            // else fall through!
        default:
            @throw [NSException exceptionWithName:@"PromiseKit" reason:@"PromiseKit: Unsupported method signature." userInfo:nil];
    }
    
}

#pragma mark Getter & Setter
- (NSMutableArray *)onResolvedCallbacks{
    if (!_onResolvedCallbacks) {
        _onResolvedCallbacks = @[].mutableCopy;
    }
    return _onResolvedCallbacks;
}

- (NSMutableArray *)onRejectedCallbacks{
    if (!_onRejectedCallbacks) {
        _onRejectedCallbacks = @[].mutableCopy;
    }
    return _onRejectedCallbacks;
}

- (void)dealloc{
    NSLog(@"OCPromise dealloced");
}

@end
