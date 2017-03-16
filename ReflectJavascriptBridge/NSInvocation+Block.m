//
//  NSInvocation+Block.m
//  ReflectJavascriptBridge
//
//  Created by LZephyr on 2017/3/14.
//  Copyright © 2017年 LZephyr. All rights reserved.
//

#import "NSInvocation+Block.h"
#import "RJBCommons.h"
#import <objc/runtime.h>

#define ARG_GET_SET(type) do { \
                                type val = 0;\
                                val = va_arg(args,type);\
                                [invocation setArgument:&val atIndex:1 + i];\
                             } while (0)

struct Block_literal_1 {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
        unsigned long int reserved;     // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        // void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        // void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        // const char *signature;                         // IFF (1<<30)
        void* rest[1];
    } *descriptor;
    // imported variables
};

enum {
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE =     (1 << 30),
};

static const char *__block_signatrue(id blockObj) {
    struct Block_literal_1 *block = (__bridge void *)blockObj;
    struct Block_descriptor_1 *descriptor = block->descriptor;
    if (block->flags & BLOCK_HAS_SIGNATURE) {
        int offset = 0;
        if(block->flags & BLOCK_HAS_COPY_DISPOSE)
            offset += 2;
        return (char*)(descriptor->rest[offset]);
    } else {
        return nil;
    }
}

@implementation NSInvocation(Block)

+ (instancetype)invocationWithBlock:(id)block {
    NSMethodSignature *sign = [NSMethodSignature signatureWithObjCTypes:__block_signatrue(block)];
    if (sign) {
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sign];
        invocation.target = block;
        return invocation;
    } else {
        RJBLog(@"[RJB]: Unkown block type (no signatrue info)!");
        return nil;
    }
}

+ (instancetype)invocationWithBlockAndArgs:(id)block ,... {
    NSInvocation* invocation = [NSInvocation invocationWithBlock:block];
    if (invocation == nil) {
        return nil;
    }
    
    NSUInteger argsCount = invocation.methodSignature.numberOfArguments - 1;
    va_list args;
    va_start(args, block);
    for (NSInteger i = 0; i < argsCount ; ++i) {
        const char* argType = [invocation.methodSignature getArgumentTypeAtIndex:i + 1];
        if (argType[0] == _C_CONST) {
            argType++;
        }
        
        if (argType[0] == '@') {
            ARG_GET_SET(id);
        } else if (strcmp(argType, @encode(Class)) == 0 ) {
            ARG_GET_SET(Class);
        } else if (strcmp(argType, @encode(IMP)) == 0 ) {
            ARG_GET_SET(IMP);
        } else if (strcmp(argType, @encode(SEL)) == 0) {
            ARG_GET_SET(SEL);
        } else if (strcmp(argType, @encode(double)) == 0) {
            ARG_GET_SET(double);
        } else if (strcmp(argType, @encode(float)) == 0) {
            float val = 0;
            val = (float)va_arg(args,double);
            [invocation setArgument:&val atIndex:1 + i];
        } else if (argType[0] == '^'){                           //pointer ( andconst pointer)
            ARG_GET_SET(void*);
        } else if (strcmp(argType, @encode(char *)) == 0) {      //char* (and const char*)
            ARG_GET_SET(char *);
        } else if (strcmp(argType, @encode(unsigned long)) == 0) {
            ARG_GET_SET(unsigned long);
        } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
            ARG_GET_SET(unsigned long long);
        } else if (strcmp(argType, @encode(long)) == 0) {
            ARG_GET_SET(long);
        } else if (strcmp(argType, @encode(long long)) == 0) {
            ARG_GET_SET(long long);
        } else if (strcmp(argType, @encode(int)) == 0) {
            ARG_GET_SET(int);
        } else if (strcmp(argType, @encode(unsigned int)) == 0) {
            ARG_GET_SET(unsigned int);
        } else if (strcmp(argType, @encode(BOOL)) == 0 || strcmp(argType, @encode(bool)) == 0
                   || strcmp(argType, @encode(char)) == 0 || strcmp(argType, @encode(unsigned char)) == 0
                   || strcmp(argType, @encode(short)) == 0 || strcmp(argType, @encode(unsigned short)) == 0) {
            ARG_GET_SET(int);
        } else {                  //struct union and array
            RJBLog(@"[RJB]: Block argument type not supported!");
        }
    }
    va_end(args);
    
    return invocation;
}

+ (instancetype)invocationWithBlock:(id)block argumentArray:(NSArray *)args {
    NSInvocation *invocation = [NSInvocation invocationWithBlock:block];
    if (invocation == nil) {
        return nil;
    }
    
    NSUInteger argsCount = invocation.methodSignature.numberOfArguments - 1;
    
    for (NSInteger i = 0; i < argsCount; ++i) {
        const char* argType = [invocation.methodSignature getArgumentTypeAtIndex:i + 1];
        if (argType[0] == '@') {
            id arg = nil;
            if (i < args.count) {
                arg = args[i];
            }
            [invocation setArgument:&arg atIndex:i + 1];
        } else {
            RJBLog(@"[RJB]: Block argument only support `id` type");
        }
    }
    
    return invocation;
}

@end
