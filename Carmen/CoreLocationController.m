//
//  CoreLocationController.m
//  Carmen
//
//  Created by Vincent Masiello on 5/26/11.
//  Copyright 2011 Apollic Software, LLC. All rights reserved.
//

#import "CoreLocationController.h"


@implementation CoreLocationController
@synthesize locMgr;
@synthesize delegate;

- (id)init {
    self = [super init];
    if(self != nil) {
        self.locMgr = [[[CLLocationManager alloc] init] autorelease]; //Create new instance of locMgr
        self.locMgr.delegate = self; //set delegate as self
    }
    return self;
}

- (void)locationManager:(CLLocation *)manager didUpdateLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if([self.delegate conformsToProtocol:@protocol(CoreLocationControllerDelegate)]) { // Check if the class assigning itself as the delegate conforms to our protocol.  If not, the message will go nowhere.  Not good.
        
        [self.delegate locationUpdate:newLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	if([self.delegate conformsToProtocol:@protocol(CoreLocationControllerDelegate)]) {  // Check if the class assigning itself as the delegate conforms to our protocol.  If not, the message will go nowhere.  Not good.
		[self.delegate locationError:error];
	}
}

- (void)dealloc {
	[self.locMgr release];
	[super dealloc];
}
@end
