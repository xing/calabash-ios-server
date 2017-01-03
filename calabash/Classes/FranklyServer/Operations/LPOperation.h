//
//  Operation.h
//  Created by Karl Krukow on 14/08/11.
//  Copyright 2011 LessPainful. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Operations should return this token if performing the operation should
 * result in an HTTP error response.
 *
 * This is necessary because, for some operations, nil is valid response.
 * Even if nil were not a valid response, existing clients expect nil to
 * indicate an error response.
 *
 * The alternative is to use a nil check on the NSError argument of
 * performWithTarget:error:.  This is problematic for two reasons:
 *
 * 1. By convention nil checks on errors are frowned upon because in the past
 *    Cocoa APIs were allowed to scribble on NSError references.
 * 2. Some existing operations can generate errors, but should not result in
 *    an HTTP error response.
 */
extern NSString const *kLPServerOperationErrorToken;

@interface LPOperation : NSObject

@property(nonatomic, assign, readonly) SEL selector;
@property(nonatomic, copy, readonly) NSArray *arguments;
@property(nonatomic, assign) BOOL done;

+ (id) operationFromDictionary:(NSDictionary *) dictionary;
+ (NSArray *) performQuery:(id) query;
- (id) initWithOperation:(NSDictionary *) operation;
- (id) performWithTarget:(id) target error:(NSError **) error;

- (void)getError:(NSError *__autoreleasing*)error
    formatString:(NSString *)format, ...;


@end
