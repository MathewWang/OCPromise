# OCPromise

```
    create Promise(function(resolve, reject){
        resolve(@1);
    }).then(^(id value){
        NSLog(@"number is : %@", value);
        return 123;
    }, nil).then(^(id value){
        NSLog(@"number is : %@", value);
        return create Promise(function(resolve, reject){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                reject(@3);
            });
        });
    }, nil).then(^(id value){
        NSLog(@"number is : %@", value);
    }, ^(id error){
        NSLog(@"number is : %@", error);
        return create Promise(function(resolve, reject){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                resolve(@4);
            });
        });
    }).then(^(id value){
        NSLog(@"number is : %@", value);
    }, ^(id error){
        NSLog(@"number is : %@", error);
    });
  
```
