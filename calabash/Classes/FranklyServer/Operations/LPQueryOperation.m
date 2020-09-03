//
//  QueryOperation.m
//  Created by Karl Krukow on 10/09/11.
//  Copyright (c) 2011 LessPainful. All rights reserved.
//

#import "LPQueryOperation.h"
#import "LPCocoaLumberjack.h"


@implementation LPQueryOperation

- (id) performWithTarget:(id) target error:(NSError **) error {
  LPLogInfo(@"DEBUG: %@:%@ %@ %@", self, NSStringFromSelector(_cmd), target, error);
  return [super performWithTarget:target error:error];
}

@end
