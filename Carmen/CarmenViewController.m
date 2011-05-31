//
//  CarmenViewController.m
//  Carmen
//
//  Created by Vincent Masiello on 5/26/11.
//  Copyright 2011 Apollic Software, LLC. All rights reserved.
//

#import "CarmenViewController.h"

#define kAlphaNumeric @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ123456789"
#error delete this error when you've replaced the default url
#define kDefaultURL @"replace_me"

@implementation CarmenViewController
@synthesize locationManager;
@synthesize pollingRadius;
@synthesize pollingTimeout;
@synthesize toggle;
@synthesize onButton;
@synthesize offButton;
@synthesize callbackField;
@synthesize lblSecret;

- (void)dealloc {
    [locationManager release];
    [toggle release];
    [pollingTimeout release];
    [pollingRadius release];
    [onButton release];
    [offButton release];
    [callbackField release];
    [lblSecret release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    self.toggle = nil;
    self.pollingRadius = nil;
    self.pollingTimeout = nil;
    self.offButton = nil;
    self.onButton = nil;
    self.callbackField = nil;
    self.lblSecret = nil;
    [super viewDidUnload];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    callbackField.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    isRunning = NO;
    
    //generate secret if none exists and output
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSString *secret = [settings objectForKey:@"secret"];
    if (!secret) {
        NSString *letters = kAlphaNumeric;
        NSMutableString *randStr = [NSMutableString stringWithCapacity:10];
        for (int i=0; i<10; i++) {
            [randStr appendFormat: @"%c", [letters characterAtIndex: rand()%[letters length]]];
        }
        [settings setObject:randStr forKey: @"secret"];
        secret = (NSString *)randStr;
    }
    self.lblSecret.text = secret;
    
    [super viewDidLoad];
}

- (IBAction)toggleService:(UIButton *)sender {
    isRunning = !isRunning;
    if (isRunning) { 
        //show stop button
        self.offButton.hidden = NO;
        self.onButton.hidden = YES;
        self.pollingRadius.enabled = NO;
        self.pollingTimeout.enabled = NO;
        self.callbackField.enabled = NO;
        
        // Create the manager object 
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        locationManager.delegate = self;
        
        //user settings from sliders
        locationManager.desiredAccuracy = pow(10, [self.pollingRadius value]);
        locationManager.distanceFilter = [self.pollingTimeout value];
        
        [locationManager startUpdatingLocation];
    } else {
        //show go button
        self.onButton.hidden = NO;
        self.offButton.hidden = YES;
        self.pollingRadius.enabled = YES;
        self.pollingTimeout.enabled = YES;
        self.callbackField.enabled = YES;
        
        //stop location services
        [self.locationManager stopUpdatingLocation];
    }
}

- (IBAction)sliderChanged:(id)sender {
    
}

#pragma mark - Location Manager Interactions

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    //check validity of location
    if (newLocation.horizontalAccuracy < 0) return;
    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;
    
    //callback default if field is empty
    NSString *urlStr = [NSString stringWithFormat:@"%@",callbackField.text];
    if ([urlStr isEqualToString:@""]) {
        urlStr = kDefaultURL;
    }
    NSURL *url = [NSURL URLWithString:@"urlStr"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //make timestamp
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *currentTime = [formatter stringFromDate:today];
    [formatter release];
    
    //url secret
    NSString *secret = lblSecret.text;
    
    //prepare parameter string
    NSString *params = [[NSString alloc] initWithFormat:@"lat=%f&long=%f&time=%@&secret=%@", 
                        newLocation.coordinate.latitude, 
                        newLocation.coordinate.longitude,
                        currentTime,
                        secret];
    
    //make the request
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    NSLog(@"Oh snap! an error has occured.");
}

- (void)stopUpdatingLocation:(NSString *)state {
    //TODO: update status indicator (to be added)
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
}

#pragma mark - Background methods
- (void)switchToBackgroundMode:(BOOL)background {
    if (background) {
        if (!isRunning) {
            [self.locationManager stopUpdatingLocation];
            self.locationManager.delegate = nil;
        }
    } else {
        if (!isRunning) {
            self.locationManager.delegate = self;
            [self.locationManager startUpdatingLocation];
        }
    }
}

#pragma mark - Keyboard Methods
-(void)textFieldDidBeginEditing:(UITextField *)sender {
    if ([sender isEqual:callbackField]) {
        //move the main view, so that the keyboard does not hide it.
        if  (self.view.frame.origin.y >= 0) {
            [self slideViewMovedUp:YES];
        }
    }
}

-(void)slideViewMovedUp:(BOOL)movedUp {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = self.view.frame;
    if (movedUp) {
        rect = CGRectMake(0, -160, 320, 480);
    } else {
        rect = CGRectMake(0, 0, 320, 480);
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


- (void)keyboardWillShow:(NSNotification *)notif {
    //move view up
    //[self slideViewMovedUp:YES];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    //move view back down
    [self slideViewMovedUp:NO];
}

- (IBAction)hideKeyboard:(id)sender {
    [(UITextView *)sender resignFirstResponder];
}

#pragma mark -
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
