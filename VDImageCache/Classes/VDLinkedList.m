//
//  VDLinkedList.m
//  VDImageCache
//
//  Created by Vu.Doan on 11/13/17.
//  Copyright © 2017 Vu.Doan. All rights reserved.
//

#import "VDLinkedList.h"

// 100% Support for both ARC and non-ARC projects
#if __has_feature(objc_arc)
#define SAFE_ARC_PROP_RETAIN strong
#define SAFE_ARC_RETAIN(x) (x)
#define SAFE_ARC_RELEASE(x)
#define SAFE_ARC_AUTORELEASE(x) (x)
#define SAFE_ARC_BLOCK_COPY(x) (x)
#define SAFE_ARC_BLOCK_RELEASE(x)
#define SAFE_ARC_SUPER_DEALLOC()
#define SAFE_ARC_AUTORELEASE_POOL_START() @autoreleasepool {
#define SAFE_ARC_AUTORELEASE_POOL_END() }
#else
#define SAFE_ARC_PROP_RETAIN retain
#define SAFE_ARC_RETAIN(x) ([(x) retain])
#define SAFE_ARC_RELEASE(x) ([(x) release])
#define SAFE_ARC_AUTORELEASE(x) ([(x) autorelease])
#define SAFE_ARC_BLOCK_COPY(x) (Block_copy(x))
#define SAFE_ARC_BLOCK_RELEASE(x) (Block_release(x))
#define SAFE_ARC_SUPER_DEALLOC() ([super dealloc])
#define SAFE_ARC_AUTORELEASE_POOL_START() NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#define SAFE_ARC_AUTORELEASE_POOL_END() [pool release];
#endif

@implementation VDLinkedList

@synthesize first, last;

- (id)init {
    
    if ((self = [super init]) == nil) return nil;
    
    first = last = nil;
    size = 0;
    
    return self;
}

+ (id)listWithObject:(id)anObject {
    
    VDLinkedList* n = [[VDLinkedList alloc] initWithObject:anObject];
    return SAFE_ARC_AUTORELEASE(n);
}

- (id)initWithObject:(id)anObject {
    
    if ((self = [super init]) == nil) return nil;
    
    LNode* n = LNodeMake(anObject, nil, nil);
    
    first = last = n;
    size = 1;
    
    return self;
}

- (void)pushBack:(id)anObject {
    
    if (anObject == nil) return;
    
    LNode* n = LNodeMake(anObject, nil, last);
    
    if (size == 0) {
        
        first = last = n;
    } else {
        
        last->next = n;
        last = n;
    }
    
    size++;
}

- (id)lastObject {
    
    return last ? last->obj : nil;
}

- (id)firstObject {
    
    return first ? first->obj : nil;
}

- (id)secondLastObject {
    
    if (last && last->prev) {
        
        return last->prev->obj;
    }
    
    return nil;
}

- (LNode *)firstNode {
    
    return first;
}

- (LNode *)lastNode {
    
    return last;
}

- (id)top {
    
    return [self lastObject];
}

- (void)pushFront:(id)anObject {
    
    if (anObject == nil) return;
    
    LNode *n = LNodeMake(anObject, first, nil);
    
    if (size == 0) {
        
        first = last = n;
    } else {
        
        first->prev = n;
        first = n;
    }
    
    size++;
}

- (void)prependObject:(id)anObject {
    
    [self pushFront:anObject];
}

- (void)appendObject:(id)anObject {
    
    [self pushBack:anObject];
}

- (void)insertObject:(id)anObject beforeNode:(LNode *)node {
    
    [self insertObject:anObject betweenNode:node->prev andNode:node];
}

- (void)insertObject:(id)anObject afterNode:(LNode *)node {
    
    [self insertObject:anObject betweenNode:node andNode:node->next];
}

- (void)insertObject:(id)anObject betweenNode:(LNode *)previousNode andNode:(LNode *)nextNode {
    
    if (anObject == nil) return;
    
    LNode* n = LNodeMake(anObject, nextNode, previousNode);
    
    if (previousNode) {
        
        previousNode->next = n;
    } else {
        
        first = n;
    }
    
    if (nextNode) {
        
        nextNode->prev = n;
    } else {
        
        last = n;
    }
    
    size++;
}

- (void)addObject:(id)anObject {
    
    [self pushBack:anObject];
}

- (void)pushNodeBack:(LNode *)n {
    
    if (size == 0) {
        
        first = last = LNodeMake(n->obj, nil, nil);
    } else {
        
        last->next = LNodeMake(n->obj, nil, last);
        last = last->next;
    }
    
    size++;
}

- (void)pushNodeFront:(LNode *)n {
    
    if (size == 0) {
        
        first = last = LNodeMake(n->obj, nil, nil);
    } else {
        
        first->prev = LNodeMake(n->obj, first, nil);
        first = first->prev;
    }
    
    size++;
}

// With support for negative indexing!
- (id)objectAtIndex:(const int)inidx {
    
    int idx = inidx;
    
    // they've given us a negative index
    // we just need to convert it positive
    if (inidx < 0) idx = size + inidx;
    
    if (idx >= size || idx < 0) return nil;
    
    LNode* n = nil;
    
    if (idx > (size / 2)) {
        
        // loop from the back
        int curridx = size - 1;
        for (n = last; idx < curridx; --curridx) n = n->prev;
        return n->obj;
    } else {
        // loop from the front
        int curridx = 0;
        for (n = first; curridx < idx; ++curridx) n = n->next;
        return n->obj;
    }
    
    return nil;
}

- (id)popBack {
    
    if (size == 0) return nil;
    
    id ret = SAFE_ARC_RETAIN(last->obj);
    [self removeNode:last];
    return SAFE_ARC_AUTORELEASE(ret);
    
}

- (id)popFront {
    
    if (size == 0) return nil;
    
    id ret = SAFE_ARC_RETAIN(first->obj);
    [self removeNode:first];
    return SAFE_ARC_AUTORELEASE(ret);
    
}

- (void)removeNode:(LNode *)aNode {
    
    if (size == 0) return;
    
    if (size == 1) {
        
        // delete first and only
        first = last = nil;
    } else if (aNode->prev == nil) {
        
        // delete first of many
        first = first->next;
        first->prev = nil;
    } else if (aNode->next == nil) {
        
        // delete last
        last = last->prev;
        last->next = nil;
    } else {
        
        // delete in the middle
        LNode *tmp = aNode->prev;
        tmp->next = aNode->next;
        tmp = aNode->next;
        tmp->prev = aNode->prev;
    }
    
    SAFE_ARC_RELEASE(aNode->obj);
    aNode->obj = nil;
    free(aNode);
    size--;
}

- (BOOL)removeObjectEqualTo:(id)anObject {
    
    LNode* n = nil;
    
    for (n = first; n; n = n->next) {
        
        if (n->obj == anObject) {
            
            [self removeNode:n];
            return YES;
        }
    }
    
    return NO;
}

- (void)removeAllObjects {
    
    LNode* n = first;
    
    while (n) {
        
        LNode* next = n->next;
        
        SAFE_ARC_RELEASE(n->obj);
        n->obj = nil;
        free(n);
        n = next;
    }
    
    first = last = nil;
    size = 0;
}

- (void)dumpList {
    
    LNode* n = nil;
    for (n = first; n; n=n->next) {
        
        NSLog(@"%p", n);
    }
}

- (void)insertObject:(id)anObject orderedPositionByKey:(NSString *)key ascending:(BOOL)ascending {
    
    assert(0); // currently not implemented
}

- (int)count  { return size; }
- (int)size   { return size; }
- (int)length { return size; }

- (BOOL)containsObject:(id)anObject {
    
    LNode* n = nil;
    
    for (n = first; n; n=n->next) {
        if (n->obj == anObject) return YES;
    }
    
    return NO;
}

- (NSArray *)allObjects {
    
    NSMutableArray* ret = SAFE_ARC_AUTORELEASE([[NSMutableArray alloc] initWithCapacity:size]);
    LNode* n = nil;
    
    for (n = first; n; n=n->next) {
        
        [ret addObject:n->obj];
    }
    
    return [NSArray arrayWithArray:ret];
}

- (NSArray *)allObjectsReverse {
    
    NSMutableArray *ret = SAFE_ARC_AUTORELEASE([[NSMutableArray alloc] initWithCapacity:size]);
    LNode* n = nil;
    
    for (n = last; n; n=n->prev) {
        
        [ret addObject:n->obj];
    }
    
    return [NSArray arrayWithArray:ret];
}

- (void)dealloc {
    
    [self removeAllObjects];
    SAFE_ARC_SUPER_DEALLOC();
}

- (NSString *)description {
    
    return [NSString stringWithFormat:@"VDLinkedList with %d objects", size];
}

@end

LNode * LNodeMake(id obj, LNode* next, LNode* prev) {
    
    LNode* n = malloc(sizeof(LNode));
    n->next = next;
    n->prev = prev;
    n->obj = SAFE_ARC_RETAIN(obj);
    return n;
};
