
#import <Kiwi/Kiwi.h>
#import <AppMetricaTestUtils/AppMetricaTestUtils.h>
#import "AMACustomAttributeUserProfileUpdateProvider.h"
#import "AMAAttributeUpdateCountValidator.h"
#import "AMAAttributeUpdateNameLengthValidator.h"
#import "AMAAttributeUpdateNamePrefixValidator.h"
#import "AMAAttributeUpdate.h"
#import "AMAAttributeValueUpdate.h"
#import "AMAUserProfileUpdate.h"

SPEC_BEGIN(AMACustomAttributeUserProfileUpdateProviderTests)

describe(@"AMACustomAttributeUserProfileUpdateProvider", ^{

    NSString *const name = @"ATTRIBUTE_NAME";
    AMAAttributeType const type = AMAAttributeTypeCounter;

    NSObject<AMAAttributeValueUpdate> *__block valueUpdate = nil;
    AMAUserProfileUpdate *__block userProfileUpdate = nil;
    AMAAttributeUpdateCountValidator *__block countValidator = nil;
    AMAAttributeUpdateNameLengthValidator *__block nameLengthValidator = nil;
    AMAAttributeUpdateNamePrefixValidator *__block namePrefixValidator = nil;
    AMAAttributeUpdate *__block attributeUpdate = nil;
    AMACustomAttributeUserProfileUpdateProvider *__block provider = nil;

    beforeEach(^{
        valueUpdate = [KWMock nullMockForProtocol:@protocol(AMAAttributeValueUpdate)];
        userProfileUpdate = [AMAUserProfileUpdate stubbedNullMockForInit:@selector(initWithAttributeUpdate:validators:)];
        countValidator = [AMAAttributeUpdateCountValidator stubbedNullMockForDefaultInit];
        nameLengthValidator = [AMAAttributeUpdateNameLengthValidator stubbedNullMockForDefaultInit];
        namePrefixValidator = [AMAAttributeUpdateNamePrefixValidator stubbedNullMockForDefaultInit];
        attributeUpdate = [AMAAttributeUpdate stubbedNullMockForInit:@selector(initWithName:type:custom:valueUpdate:)];
        provider = [[AMACustomAttributeUserProfileUpdateProvider alloc] init];
    });

    it(@"Should create attribute update", ^{
        [[attributeUpdate should] receive:@selector(initWithName:type:custom:valueUpdate:)
                            withArguments:name, theValue(type), theValue(YES), valueUpdate];
        [provider updateWithAttributeName:name type:type valueUpdate:valueUpdate];
    });
    it(@"Should create user profile update", ^{
        NSArray *validators = @[
            countValidator,
            nameLengthValidator,
            namePrefixValidator,
        ];
        [[userProfileUpdate should] receive:@selector(initWithAttributeUpdate:validators:)
                              withArguments:attributeUpdate, validators];
        [provider updateWithAttributeName:name type:type valueUpdate:valueUpdate];
    });
    it(@"Should return update", ^{
        [[[provider updateWithAttributeName:name type:type valueUpdate:valueUpdate] should] equal:userProfileUpdate];
    });

});

SPEC_END
