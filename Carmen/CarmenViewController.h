//
//  CarmenViewController.h
//  Carmen
//
//  Created by Vincent Masiello on 5/26/11.
//  Copyright 2011 Apollic Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreLocationController.h"

@interface CarmenViewController : UIViewController <CoreLocationControllerDelegate> {
    CoreLocationController *CLController;
    IBOutlet UILabel *locLabel;
}

@property (nonatomic, retain) CoreLocationController *CLController;
@property (nonatomic, retain) IBOutlet UILabel *locLabel;

@end
