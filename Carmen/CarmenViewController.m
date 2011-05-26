//
//  CarmenViewController.m
//  Carmen
//
//  Created by Vincent Masiello on 5/26/11.
//  Copyright 2011 Apollic Software, LLC. All rights reserved.
//

#import "CarmenViewController.h"

@implementation CarmenViewController
@synthesize CLController;
@synthesize locLabel;

- (void)dealloc {
    [CLController release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CLController = [[CoreLocationController alloc] init];
    CLController.delegate = self;
    [CLController.locMgr startUpdatingLocation];
    
}

- (void)locationUpdate:(CLLocation *)location {
    locLabel.text = [location description];
}

- (void)locationError:(NSError *)error {
    locLabel.text = [error description];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
