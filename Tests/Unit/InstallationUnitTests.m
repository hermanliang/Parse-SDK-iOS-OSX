/**
 * Copyright (c) 2015-present, Parse, LLC.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */
#import <OCMock/OCMock.h>

#import "PFInstallation.h"
#import "PFUnitTestCase.h"
#import "Parse.h"
#import "Parse_Private.h"
#import "PFCommandRunning.h"
#import "ParseManagerPrivate.h"
#import "PFObjectState.h"
#import "PFObjectPrivate.h"

@interface InstallationUnitTests : PFUnitTestCase

@end

@implementation InstallationUnitTests

- (void)testInstallationObjectIdCannotBeChanged {
    PFInstallation *installation = [PFInstallation currentInstallation];
    PFAssertThrowsInvalidArgumentException(installation.objectId = nil);
    PFAssertThrowsInvalidArgumentException(installation[@"objectId"] = @"abc");
}

- (void)testReSaveInstallation {
    
    // enable LDS
    [[Parse _currentManager]loadOfflineStoreWithOptions:0];
    
    // create and save installation
    PFInstallation *installation = [PFInstallation currentInstallation];
    PFObjectState *state = [PFObjectState stateWithParseClassName:[PFInstallation parseClassName] objectId:@"abc" isComplete:YES];
    installation._state = state;
    [installation save];
    
    // mocking installation was deleted on the server
    id commandRunner = PFStrictProtocolMock(@protocol(PFCommandRunning));
    [Parse _currentManager].commandRunner = commandRunner;
    
    BFTask *mockedTask = [BFTask taskWithError:[NSError errorWithDomain:@"" code:kPFErrorObjectNotFound userInfo:nil]];
    
    OCMStub([commandRunner runCommandAsync:[OCMArg any] withOptions:PFCommandRunningOptionRetryIfFailed]).andReturn(mockedTask);
    
    installation.deviceToken = @"11433856eed2f1285fb3aa11136718c1198ed5647875096952c66bf8cb976306";
    [installation save];
    OCMVerifyAll(commandRunner);
}

- (void)testInstallationImmutableFieldsCannotBeChanged {
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation.deviceToken = @"11433856eed2f1285fb3aa11136718c1198ed5647875096952c66bf8cb976306";

    PFAssertThrowsInvalidArgumentException(installation[@"deviceType"] = @"android");
    PFAssertThrowsInvalidArgumentException(installation[@"installationId"] = @"a");
    PFAssertThrowsInvalidArgumentException(installation[@"localeIdentifier"] = @"a");
}

- (void)testInstallationImmutableFieldsCannotBeDeleted {
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation.deviceToken = @"11433856eed2f1285fb3aa11136718c1198ed5647875096952c66bf8cb976306";

    PFAssertThrowsInvalidArgumentException([installation removeObjectForKey:@"deviceType"]);
    PFAssertThrowsInvalidArgumentException([installation removeObjectForKey:@"installationId"]);
    PFAssertThrowsInvalidArgumentException([installation removeObjectForKey:@"localeIdentifier"]);
}

@end
