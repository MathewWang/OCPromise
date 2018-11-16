//
//  WWPromise.m
//  ORMiddleWare
//
//  Created by mathewwang on 2018/10/23.
//  Copyright © 2018年 mathewwang. All rights reserved.
//

#import "WWPromise.h"

typedef NS_ENUM(NSInteger, ORPromiseState){
    ORPromiseStateProcessing = 0,
    ORPromiseStateResolved,
    ORPromiseStateRejected
};

@interface WWPromise()

@property (nonatomic, copy) ResolveFunc resolveFunc;
@property (nonatomic, copy) RejectFunc rejectFunc;
@property (nonatomic, strong) WWPromise *next;
@property (nonatomic, copy) void(^executionFunc)(ResolveFunc, RejectFunc);
@property (nonatomic, assign) ORPromiseState state;
@property (nonatomic, strong) id result;
@property (nonatomic, strong) NSError *error;

@end

@implementation WWPromise

+ (WWPromise *(^)(void (^)(ResolveFunc, RejectFunc)))promise{
    return ^(void(^func)(ResolveFunc, RejectFunc)){
        return [[WWPromise alloc] initWithFunc:func];
    };
}


- (instancetype)initWithFunc:(void(^)(ResolveFunc, RejectFunc)) func{
    if (self = [super init]) {
        self.executionFunc = func;
        id(^tmpResolve)(id) = ^(id result){
            self.result = result;
            self.state = ORPromiseStateResolved;
            if (self.resolveFunc) {
                id preReturnValue = self.resolveFunc(result);
                //根据resolve的结果进行决议
                [self p_ajust:preReturnValue];
                return preReturnValue;
            }
            return [ORPromise empty];
        };
        void(^tmpError)(id) = ^(id error){
            self.error = error;
            self.state = ORPromiseStateRejected;
            if (self.rejectFunc) {
                self.rejectFunc(error);
            }
        };

        self.state = ORPromiseStateProcessing;
        self.executionFunc(tmpResolve, tmpError);
    }
    return self;
}

- (void)p_ajust:(id) preRes{
    if ([preRes isKindOfClass:[ORPromise class]]) {
        [(ORPromise *)preRes setResolveFunc:self.next.resolveFunc];
        [(ORPromise*)preRes setRejectFunc:self.next.rejectFunc];
        self.next = preRes;
        self.next.then(self.next.resolveFunc, self.next.rejectFunc);
    }else{
        if (self.next) {
            if (self.state == ORPromiseStateResolved) {
                self.next.state = ORPromiseStateResolved;
                self.next.result = self.result;
                if (self.next.resolveFunc) {
                    [self.next p_ajust:self.next.resolveFunc(self.result)];
                }
            }else if (self.state == ORPromiseStateRejected){
                self.next.state = ORPromiseStateRejected;
                self.next.error = self.error;
                self.next.rejectFunc(self.error);
            }
        }
    }
}

- (ORPromise *(^)(ResolveFunc, RejectFunc))then{
    return ^(ResolveFunc resolve, RejectFunc reject){
        self.resolveFunc = resolve;
        self.rejectFunc = reject;
        
        if (self.state == ORPromiseStateResolved) {
            id preReturnValue = self.resolveFunc(self.result);
            if ([preReturnValue isKindOfClass:[ORPromise class]]) {
                self.next = preReturnValue;
            }else{
                return self;
            }
        }
        
        if (self.state == ORPromiseStateRejected){
            self.rejectFunc(self.error);
        }
        if (!self.next) {
            self.next = [ORPromise new];
        }
        return self.next;
    };
}

- (void)dealloc{
    NSLog(@"###promise dealloc");
}

@end
