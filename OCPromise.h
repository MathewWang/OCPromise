//
//  OCPromise.h
//  FutureKit
//
//  Created by mathewwang on 2019/1/2.
//  Copyright © 2019 mathew. All rights reserved.
//

#import <Foundation/Foundation.h>

#define function(resolve, reject) ^(CallBackFunc resolve, CallBackFunc reject)
#define create OCPromise.

typedef void(^CallBackFunc)(id __nullable);

@interface OCPromise : NSObject

+ (OCPromise*(^)(void(^)(CallBackFunc resolve, CallBackFunc reject)))Promise;
- (OCPromise*(^)(id , id))then;

@end
