
#import <CoreLocation/CoreLocation.h>
#import "AMALocationManager+TestUtilities.h"
#import <Kiwi/Kiwi.h>

@implementation AMALocationManager (TestUtilities)

+ (void)stubCurrentLocation:(CLLocation *)location
{
    AMALocationManager *locationManager = [[AMALocationManager alloc] init];
    [AMALocationManager stub:@selector(sharedManager) andReturn:locationManager];
    [locationManager stub:@selector(currentLocation) andReturn:location];
}

@end
