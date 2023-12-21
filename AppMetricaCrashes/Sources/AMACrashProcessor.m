
#import "AMACrashLogging.h"
#import "AMACrashProcessor.h"
#import "AMACrashEventType.h"
#import "AMACrashReportCrash.h"
#import "AMACrashReportError.h"
#import "AMADecodedCrash.h"
#import "AMADecodedCrashSerializer+CustomEventParameters.h"
#import "AMADecodedCrashSerializer.h"
#import "AMAErrorModel.h"
#import "AMAExceptionFormatter.h"
#import "AMAInfo.h"
#import "AMASignal.h"
#import "AMACrashReporter.h"

@interface AMACrashProcessor ()

@property (nonatomic, strong, readonly) AMADecodedCrashSerializer *serializer;
@property (nonatomic, strong, readonly) AMAExceptionFormatter *formatter;
@property (nonatomic, strong, readonly) AMACrashReporter *crashReporter;

@property (nonatomic, copy, readwrite) NSDictionary *currentErrorEnvironment;

@end

@implementation AMACrashProcessor

- (instancetype)initWithIgnoredSignals:(NSArray *)ignoredSignals
                            serializer:(AMADecodedCrashSerializer *)serializer
                         crashReporter:(AMACrashReporter *)crashReporter
{
    return [self initWithIgnoredSignals:ignoredSignals
                             serializer:serializer
                          crashReporter:[[AMACrashReporter alloc] init]
                              formatter:[[AMAExceptionFormatter alloc] init]];
}

- (instancetype)initWithIgnoredSignals:(NSArray *)ignoredSignals
                            serializer:(AMADecodedCrashSerializer *)serializer
                         crashReporter:(AMACrashReporter *)crashReporter
                             formatter:(AMAExceptionFormatter *)formatter
{
    self = [super init];

    if (self != nil) {
        _serializer = serializer;
        _formatter = formatter;
        _ignoredCrashSignals = [ignoredSignals copy];
        _crashReporter = crashReporter;
        _currentErrorEnvironment = nil;
    }

    return self;
}

#pragma mark - Public -

- (void)processCrash:(AMADecodedCrash *)decodedCrash withError:(NSError *)error
{
    if (error != nil) {
        [self.crashReporter reportInternalError:error];
        return;
    }

    if ([self shouldIgnoreCrash:decodedCrash]) { return; }
    
    NSError *localError = nil;
    AMACustomEventParameters *parameters = [self.serializer eventParametersFromDecodedData:decodedCrash
                                                                              forEventType:AMACrashEventTypeCrash
                                                                                     error:&localError];
    
    if (parameters == nil) {
        [self.crashReporter reportInternalCorruptedCrash:localError];
    }
    
    [self.crashReporter reportCrashWithParameters:parameters];
}

- (void)processANR:(AMADecodedCrash *)decodedCrash withError:(NSError *)error
{
    if (error != nil) {
        [self.crashReporter reportInternalError:error];
        return;
    }
    
    NSError *localError = nil;
    AMACustomEventParameters *parameters = [self.serializer eventParametersFromDecodedData:decodedCrash
                                                                              forEventType:AMACrashEventTypeANR
                                                                                     error:&localError];
    
    if (parameters == nil) {
        [self.crashReporter reportInternalCorruptedCrash:localError];
    }
    
    [self.crashReporter reportANRWithParameters:parameters];
}

- (void)processError:(AMAErrorModel *)errorModel onFailure:(void (^)(NSError *))onFailure
{
    NSError *potentialError = nil;
    NSData *formattedData = [self.formatter formattedError:errorModel error:&potentialError];
    
    if (formattedData == nil) {
        [self.crashReporter reportInternalCorruptedError:potentialError];
        onFailure(potentialError);
        return;
    }
    
    AMACustomEventParameters *params = [[AMACustomEventParameters alloc] initWithEventType:AMACrashEventTypeError];
    params.valueType = AMAEventValueTypeBinary;
    params.data = formattedData;
    params.GZipped = YES;
    params.bytesTruncated = errorModel.bytesTruncated;
    if (self.currentErrorEnvironment.count > 0) {
        params.errorEnvironment = self.currentErrorEnvironment;
    }
    
    [self.crashReporter reportErrorWithParameters:params onFailure:onFailure];
}

- (void)updateErrorEnvironment:(NSDictionary *)errorEnvironment
{
    self.currentErrorEnvironment = [errorEnvironment copy];
}

#pragma mark - Private -

- (BOOL)shouldIgnoreCrash:(AMADecodedCrash *)decodedCrash
{
    return [self.ignoredCrashSignals containsObject:@(decodedCrash.crash.error.signal.signal)];
}

@end
