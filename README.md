# WWPromise

```
// Resolve Example
  ORPromise.promise(^(ResolveFunc resolve, RejectFunc reject){
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          resolve(@"aaa");
      });
  }).then(^(NSString *result){
      NSLog(@"###promise the result is 111: %@", result);

      return ORPromise.promise(^(ResolveFunc resolve, RejectFunc reject){
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              resolve([result stringByAppendingString:@"bbb"]);
          });
      });
  }, nil).then(^(NSString *result){
      NSLog(@"###promise the result is 222: %@", result);

      return [ORPromise empty];
  }, nil);
  
// Reject Example
   ORPromise.promise(^(ResolveFunc resolve, RejectFunc reject){
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          reject(@"aaa");
      });
  }).then(nil, ^(NSString *result){
      NSLog(@"###promise the result is 111: %@", result);

      return [ORPromise empty];
  });
  
```
