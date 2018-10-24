//
//  WWPromise.h
//  ORMiddleWare
//
//  Created by mathewwang on 2018/10/23.
//  Copyright © 2018年 oriente. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^ResolveFunc)(id);
typedef void(^RejectFunc)(id);

@interface WWPromise : NSObject

+ (WWPromise*(^)(void(^)(ResolveFunc, RejectFunc)))promise;

- (WWPromise*(^)(ResolveFunc, RejectFunc))then;

+ (id)empty;

@end
