#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import <XCTest/XCTest.h>
#import "CalabashServer.h"
#import "LPInfoPlist.h"

@interface CalabashServer ()

+ (unsigned short)serverPortFromEnvironment;
+ (unsigned short)serverPortByDetectingFromEnvOrInfoPlist:(LPInfoPlist *)plist;

@end

@interface CalabashServerTest : XCTestCase

@end

@implementation CalabashServerTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testServerPortFromEnvironmentKeyDefined {
  NSDictionary *env = @{LPFServerPortEnvironmentKey : @"12345"};
  id mock = OCMPartialMock([NSProcessInfo processInfo]);
  OCMExpect([mock environment]).andReturn(env);

  expect([CalabashServer serverPortFromEnvironment]).to.equal(12345);

  OCMVerifyAll(mock);
}

- (void)testServerPortFromEnvironmentKeyNotDefined {
  id mock = OCMPartialMock([NSProcessInfo processInfo]);
  OCMExpect([mock environment]).andReturn(@{});

  expect([CalabashServer serverPortFromEnvironment]).to.equal(0);

  OCMVerifyAll(mock);
}

- (void)testServerPortFromEnvironmentValueMaxNSUInteger {
  NSString *notFound = [NSString stringWithFormat:@"%@", @(NSNotFound)];
  NSDictionary *env = @{LPFServerPortEnvironmentKey : notFound};
  id mock = OCMPartialMock([NSProcessInfo processInfo]);
  OCMExpect([mock environment]).andReturn(env);

  expect([CalabashServer serverPortFromEnvironment]).to.equal(USHRT_MAX);

  OCMVerifyAll(mock);
}

- (void)testServerPortFromEnvironmentValueNegative {
  NSString *notFound = [NSString stringWithFormat:@"%@", @(-1)];
  NSDictionary *env = @{LPFServerPortEnvironmentKey : notFound};
  id mock = OCMPartialMock([NSProcessInfo processInfo]);
  OCMExpect([mock environment]).andReturn(env);

  expect([CalabashServer serverPortFromEnvironment]).to.equal(USHRT_MAX);

  OCMVerifyAll(mock);
}

- (void)testServerPortFromEnvironmentValueNotANumber {
  NSDictionary *env = @{LPFServerPortEnvironmentKey : @"abc"};
  id mock = OCMPartialMock([NSProcessInfo processInfo]);
  OCMExpect([mock environment]).andReturn(env);

  expect([CalabashServer serverPortFromEnvironment]).to.equal(USHRT_MAX);

  OCMVerifyAll(mock);
}

- (void)testServerPortFromEnvOrInfoPlist_from_environment {
  id CalabashServerMock = OCMClassMock([CalabashServer class]);
  OCMExpect([CalabashServerMock serverPortFromEnvironment]).andReturn(322);

  expect([CalabashServer serverPortByDetectingFromEnvOrInfoPlist:nil]).to.equal(322);

  OCMVerifyAll(CalabashServerMock);
}

- (void)testServerPortFromEnvOrInfoPlist_from_plist {
  id CalabashServerMock = OCMClassMock([CalabashServer class]);
  OCMExpect([CalabashServerMock serverPortFromEnvironment]).andReturn(0);

  LPInfoPlist *infoPlist = [LPInfoPlist new];
  id mock = OCMPartialMock(infoPlist);
  OCMExpect([mock serverPort]).andReturn(322);

  expect([CalabashServer serverPortByDetectingFromEnvOrInfoPlist:mock]).to.equal(322);

  OCMVerifyAll(CalabashServerMock);
  OCMVerifyAll(mock);
}

- (void)testServerPortFromEnvOrInfoPlist_return_default_plist {
  id CalabashServerMock = OCMClassMock([CalabashServer class]);
  OCMExpect([CalabashServerMock serverPortFromEnvironment]).andReturn(0);

  LPInfoPlist *infoPlist = [LPInfoPlist new];
  id mock = OCMPartialMock(infoPlist);
  OCMExpect([mock serverPort]).andReturn(0);

  unsigned short actual;
  actual =[CalabashServer serverPortByDetectingFromEnvOrInfoPlist:mock];
  expect(actual).to.equal(LPCalabashServerDefaultPort);

  OCMVerifyAll(CalabashServerMock);
  OCMVerifyAll(mock);
}

@end
