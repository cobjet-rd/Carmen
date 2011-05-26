//
//  CoreLocationController.h
//  Carmen
//
//  Created by Vincent Masiello on 5/26/11.
//  Copyright 2011 Apollic Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol CoreLocationControllerDelegate
@required
- (void)locationUpdate:(CLLocation *)location; //location updates are sent here
- (void)locationError:(NSError *)error; //errors are sent here
@end

@interface CoreLocationController : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locMgr;
    id delegate;
}

@property (nonatomic, retain) CLLocationManager *locMgr;
@property (nonatomic, retain) id delegate;

@end
