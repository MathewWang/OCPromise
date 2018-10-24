//
//  WWPromise.h
//  ORMiddleWare
//
//  Created by mathewwang on 2018/10/23.
//  Copyright © 2018年 oriente. All rights reserved.
//

//  Demo 事例

//  WWPromise.promise(^(ResolveFunc resolve, RejectFunc reject){
//      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//          resolve(@"aaa");
//      });
//  }).then(^(NSString *result){
//      NSLog(@"###promise the result is 111: %@", result);
//
//      return WWPromise.promise(^(ResolveFunc resolve, RejectFunc reject){
//          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//              resolve([result stringByAppendingString:@"bbb"]);
//          });
//      });
//  }, nil).then(^(NSString *result){
//      NSLog(@"###promise the result is 222: %@", result);
//
//      return [WWPromise empty];
//  }, nil);



#import <Foundation/Foundation.h>

typedef id(^ResolveFunc)(id);
typedef void(^RejectFunc)(id);

@interface WWPromise : NSObject

+ (WWPromise*(^)(void(^)(ResolveFunc, RejectFunc)))promise;

- (WWPromise*(^)(ResolveFunc, RejectFunc))then;

+ (id)empty;

@end
