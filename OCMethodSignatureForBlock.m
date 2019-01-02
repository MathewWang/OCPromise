//
//  OCMethodSignatureForBlock.m
//  FutureKit
//
//  Created by mathewwang on 2019/1/2.
//  Copyright © 2019 mathew. All rights reserved.
//

#import <Foundation/NSMethodSignature.h>

struct OCBlockLiteral {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct block_descriptor {
        unsigned long int reserved;    // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};

typedef NS_OPTIONS(NSUInteger, OCBlockDescriptionFlags) {
    OCBlockDescriptionFlagsHasCopyDispose = (1 << 25),
    OCBlockDescriptionFlagsHasCtor = (1 << 26), // helpers have C++ code
    OCBlockDescriptionFlagsIsGlobal = (1 << 28),
    OCBlockDescriptionFlagsHasStret = (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    OCBlockDescriptionFlagsHasSignature = (1 << 30)
};

static NSMethodSignature *NSMethodSignatureForBlock(id block) {
    if (!block)
        return nil;
    
    struct OCBlockLiteral *blockRef = (__bridge struct OCBlockLiteral *)block;
    OCBlockDescriptionFlags flags = (OCBlockDescriptionFlags)blockRef->flags;
    
    if (flags & OCBlockDescriptionFlagsHasSignature) {
        void *signatureLocation = blockRef->descriptor;
        signatureLocation += sizeof(unsigned long int);
        signatureLocation += sizeof(unsigned long int);
        
        if (flags & OCBlockDescriptionFlagsHasCopyDispose) {
            signatureLocation += sizeof(void(*)(void *dst, void *src));
            signatureLocation += sizeof(void (*)(void *src));
        }
        
        const char *signature = (*(const char **)signatureLocation);
        return [NSMethodSignature signatureWithObjCTypes:signature];
    }
    return 0;
}
