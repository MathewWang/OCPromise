//
//  WWPromise.m
//  ORMiddleWare
//
//  Created by mathewwang on 2018/10/23.
//  Copyright © 2018年 oriente. All rights reserved.
//

#import "WWPromise.h"

@interface WWPromise()

@property (nonatomic, copy) ResolveFunc resolveFunc;
@property (nonatomic, copy) RejectFunc rejectFunc;
@property (nonatomic, strong) WWPromise *next;

@end

@implementation WWPromise

+ (WWPromise *(^)(void (^)(ResolveFunc, RejectFunc)))promise{
    return ^(void(^func)(ResolveFunc, RejectFunc)){
        return [[WWPromise alloc] initWithFunc:func];
    };
}


- (instancetype)initWithFunc:(void(^)(ResolveFunc, RejectFunc)) func{
    if (self = [super init]) {
        id(^tmpResolve)(id) = ^(id result){
            if (self.resolveFunc) {
                id preReturnValue = self.resolveFunc(result);
                if ([preReturnValue isKindOfClass:[WWPromise class]]) {
                    [(WWPromise *)preReturnValue setResolveFunc:self.next.resolveFunc];
                    [(WWPromise*)preReturnValue setRejectFunc:self.next.rejectFunc];
                    self.next = preReturnValue;
                    self.next.then(self.next.resolveFunc, self.next.rejectFunc);
                }else{
                    if (self.next) {
                        func(self.next.resolveFunc, self.next.rejectFunc);
                    }
                }
                return preReturnValue;
            }
            return (id)nil;
        };
        void(^tmpError)(id) = ^(id error){
            if (self.rejectFunc) {
                self.rejectFunc(error);
            }
        };
        func(tmpResolve, tmpError);
    }
    return self;
}

- (WWPromise *(^)(ResolveFunc, RejectFunc))then{
    return ^(ResolveFunc resolve, RejectFunc reject){
        self.resolveFunc = resolve;
        self.rejectFunc = reject;
        self.next = [WWPromise new];
        return self.next;
    };
}

+ (id)empty{
    return nil;
}

@end
