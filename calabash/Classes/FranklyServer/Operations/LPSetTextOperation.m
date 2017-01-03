#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

//  Created by Karl Krukow on 11/09/11.
//  Copyright (c) 2011 LessPainful. All rights reserved.

#import "LPSetTextOperation.h"
#import "LPJSONUtils.h"
#import "LPWebViewProtocol.h"
#import "LPCocoaLumberjack.h"

@interface LPSetTextOperation ()

- (NSString *) stringValueForArgument:(id) argument;

@end

@implementation LPSetTextOperation

- (NSString *) stringValueForArgument:(id) argument {
  if ([argument isKindOfClass:[NSString class]]) {
    return [(NSString *)argument copy];
  } else if ([argument respondsToSelector:@selector(stringValue)]) {
    return [argument stringValue];
  } else {
    return [argument description];
  }
}

- (id) performWithTarget:(id) target error:(NSError * __autoreleasing *) error {
  NSArray *arguments = self.arguments;
  if (!arguments || [arguments count] == 0) {
    [self getError:error
      formatString:@"Missing the 'text' argument @ index 0 of arguments; "
     "nothing to do - returning nil"];
    return nil;
  }

  if ([target isKindOfClass:[NSDictionary class]]) {
    NSMutableDictionary *mutableDictionary;
    mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:target];
    [mutableDictionary removeObjectForKey:@"html"];

    id webViewValue = [mutableDictionary valueForKey:@"webView"];
    if (!webViewValue) {
      [self getError:error
        formatString:@"Missing value for 'webView' key in target; nothing to "
       "do - returning nil"];
      return nil;
    }

    if (![webViewValue conformsToProtocol:@protocol(LPWebViewProtocol)]) {
      [self getError:error
        formatString:@"Expected 'webView' => UIView<LPWebViewProtocol>, found %@; "
       "nothing to do - returning nil", webViewValue];
      return nil;
    }

    NSString *json = [LPJSONUtils serializeDictionary:mutableDictionary];
    if (!json) {
      [self getError:error
        formatString:@"Could not '%@' to JSON; nothing to do - returning nil",
       mutableDictionary];
      return nil;
    }

    UIView<LPWebViewProtocol> *webView = (UIView<LPWebViewProtocol> *)webViewValue;
    NSString *text = [self stringValueForArgument:arguments[0]];
    NSString *javascript = [NSString stringWithFormat:LP_SET_TEXT_JS,
                            json, text];
    return [webView calabashStringByEvaluatingJavaScript:javascript];
  }

  if ([target respondsToSelector:@selector(setText:)]) {
    NSString *text = [self stringValueForArgument:arguments[0]];
    [target performSelector:@selector(setText:) withObject:text];
    return target;
  }

  return nil;
}

@end
