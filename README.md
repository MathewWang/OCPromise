# WWPromise

```
// Resolve Example
  WWPromise.promise(^(ResolveFunc resolve, RejectFunc reject){
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          resolve(@"aaa");
      });
  }).then(^(NSString *result){
      NSLog(@"###promise the result is 111: %@", result);

      return WWPromise.promise(^(ResolveFunc resolve, RejectFunc reject){
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
              resolve([result stringByAppendingString:@"bbb"]);
          });
      });
  }, nil).then(^(NSString *result){
      NSLog(@"###promise the result is 222: %@", result);

      return [ORPromise empty];
  }, nil);
  
// Reject Example
   WWPromise.promise(^(ResolveFunc resolve, RejectFunc reject){
      dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          reject(@"aaa");
      });
  }).then(nil, ^(NSString *result){
      NSLog(@"###promise the result is 111: %@", result);

      return [ORPromise empty];
  });
  
  
// mixture example
    WWPromise.promise(^(ResolveFunc resolve, RejectFunc reject){
        resolve(@"test");
    })
    .then(^(id result){
        NSLog(@"%@ -- 1", result);
        return [ORPromise empty];
    }, nil)
    .then(^(id result){
        NSLog(@"%@ -- 2", result);
        return [ORPromise empty];
    }, nil)
    .then(^(id result){
        NSLog(@"%@ -- 3", result);
        return     ORPromise.promise(^(ResolveFunc resolve, RejectFunc reject){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                resolve(@"hello ");
            });
        });
    }, nil)
    .then(^(id result){
        NSLog(@"%@ -- 4", result);
        return [ORPromise empty];
    }, nil);
  
```
