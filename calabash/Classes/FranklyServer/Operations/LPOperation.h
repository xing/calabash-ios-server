//
//  Operation.h
//  Created by Karl Krukow on 14/08/11.
//  Copyright 2011 LessPainful. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPOperation : NSObject

@property(nonatomic, assign, readonly) SEL selector;
@property(nonatomic, copy, readonly) NSArray *arguments;
@property(nonatomic, assign) BOOL done;

+ (id) operationFromDictionary:(NSDictionary *) dictionary;
+ (NSArray *) performQuery:(id) query;
- (id) initWithOperation:(NSDictionary *) operation;
- (id) performWithTarget:(id) target error:(NSError **) error;

- (void)getError:(NSError *__autoreleasing*)error
 withDescription:(NSString *)description;

@end
