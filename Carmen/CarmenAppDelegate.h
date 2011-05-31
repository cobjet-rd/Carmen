//
//  CarmenAppDelegate.h
//  Carmen
//
//  Created by Vincent Masiello on 5/26/11.
//  Copyright 2011 Apollic Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CarmenViewController;

@interface CarmenAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet CarmenViewController *viewController;

@end
