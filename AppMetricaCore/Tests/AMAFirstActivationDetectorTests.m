
#import <Kiwi/Kiwi.h>
#import "AMAFirstActivationDetector.h"
#import "AMACore.h"
#import "AMAMigrationTo500Utils.h"
#import "AMADatabaseFactory.h"
#import "AMAMetricaInMemoryConfiguration.h"

SPEC_BEGIN(AMAFirstActivationDetectorTests)

describe(@"AMAFirstActivationDetector", ^{
    NSString *apiKey = @"api_key";
    NSString *migrationPath = @"migration_persistent_db_path";
    NSString *persistentPath = @"persistent_db_path";
    
    NSString *(^dbFilePath)(NSString *) = ^NSString *(NSString *basePath) {
        return [basePath stringByAppendingPathComponent:@"data.sqlite"];
    };
    
    context(@"isFirstLibraryReporterActivation", ^{
        NSString *const persistentPathForApiKey = [persistentPath stringByAppendingPathComponent:kAMAMetricaLibraryApiKey];
        NSString *const migrationPathForApiKey = [migrationPath stringByAppendingPathComponent:kAMAMetricaLibraryApiKey];
        
        it(@"Should return YES when the library reporter is unavailable", ^{
            [AMAMigrationTo500Utils stub:@selector(migrationPath) andReturn:migrationPath];
            [AMAFileUtility stub:@selector(persistentPathForApiKey:)
                       andReturn:persistentPathForApiKey
                   withArguments:kAMAMetricaLibraryApiKey];
            [AMAFileUtility stub:@selector(fileExistsAtPath:)
                       andReturn:theValue(NO)
                   withArguments:dbFilePath(migrationPathForApiKey)];
            [AMAFileUtility stub:@selector(fileExistsAtPath:)
                       andReturn:theValue(NO)
                   withArguments:dbFilePath(persistentPathForApiKey)];
            
            BOOL result = [AMAFirstActivationDetector isFirstLibraryReporterActivation];
            [[theValue(result) should] beYes];
        });
        
        it(@"Should return NO when the library reporter is available", ^{
            [AMAMigrationTo500Utils stub:@selector(migrationPath) andReturn:migrationPath];
            [AMAFileUtility stub:@selector(persistentPathForApiKey:)
                       andReturn:persistentPathForApiKey
                   withArguments:kAMAMetricaLibraryApiKey];
            [AMAFileUtility stub:@selector(fileExistsAtPath:)
                       andReturn:theValue(YES)
                   withArguments:dbFilePath(migrationPathForApiKey)];
            [AMAFileUtility stub:@selector(fileExistsAtPath:)
                       andReturn:theValue(YES)
                   withArguments:dbFilePath(persistentPathForApiKey)];

            BOOL result = [AMAFirstActivationDetector isFirstLibraryReporterActivation];
            [[theValue(result) should] beNo];
        });
    });
    
    context(@"isFirstMainReporterActivation", ^{
        NSString *const persistentPathForApiKey = [persistentPath stringByAppendingPathComponent:kAMAMainReporterDBPath];
        NSString *const migrationPathForApiKey = [migrationPath stringByAppendingPathComponent:kAMAMainReporterDBPath];
        
        it(@"Should return YES when the main reporter is unavailable", ^{
            [AMAMigrationTo500Utils stub:@selector(migrationPath) andReturn:migrationPath];
            [AMAFileUtility stub:@selector(persistentPathForApiKey:)
                       andReturn:persistentPathForApiKey
                   withArguments:kAMAMainReporterDBPath];
            [AMAFileUtility stub:@selector(fileExistsAtPath:)
                       andReturn:theValue(NO)
                   withArguments:dbFilePath(migrationPathForApiKey)];
            [AMAFileUtility stub:@selector(fileExistsAtPath:)
                       andReturn:theValue(NO)
                   withArguments:dbFilePath(persistentPathForApiKey)];
            
            BOOL result = [AMAFirstActivationDetector isFirstMainReporterActivation];
            [[theValue(result) should] beYes];
        });
        
        it(@"Should return NO when the main reporter is available", ^{
            [AMAMigrationTo500Utils stub:@selector(migrationPath) andReturn:migrationPath];
            [AMAFileUtility stub:@selector(persistentPathForApiKey:)
                       andReturn:persistentPathForApiKey
                   withArguments:kAMAMainReporterDBPath];
            [AMAFileUtility stub:@selector(fileExistsAtPath:)
                       andReturn:theValue(YES)
                   withArguments:dbFilePath(migrationPathForApiKey)];
            [AMAFileUtility stub:@selector(fileExistsAtPath:)
                       andReturn:theValue(YES)
                   withArguments:dbFilePath(persistentPathForApiKey)];

            BOOL result = [AMAFirstActivationDetector isFirstMainReporterActivation];
            [[theValue(result) should] beNo];
        });
    });
});

SPEC_END
