//  Created by Karl Krukow on 11/08/11.
//  Copyright 2011 LessPainful. All rights reserved.

#import <Foundation/Foundation.h>

@class LPInfoPlist;

extern NSString const* LPFServerPortEnvironmentKey;
extern unsigned short const LPCalabashServerDefaultPort;

@class LPHTTPServer;

@interface CalabashServer : NSObject {
  LPHTTPServer *_httpServer;
}

+ (void) start;
+ (unsigned short)serverPortByDetectingFromEnvOrInfoPlist:(LPInfoPlist *)plist;

@end
