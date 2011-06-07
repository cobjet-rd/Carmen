//
//  CarmenViewController.m
//  Carmen
//
//  Created by Vincent Masiello on 5/26/11.
//  Copyright 2011 Apollic Software, LLC. All rights reserved.
//

#import "CarmenViewController.h"

#define kAlphaNumeric @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ123456789"
#error DELETE_ME
#define kDefaultURL @"REPLACEME" //default url used for empty url bar
#define kDefaultSignificantURL @"REPLACEMETOO" //default url used for empty significant url bar

@implementation CarmenViewController
@synthesize locationManager;
@synthesize then;
@synthesize fullView;
@synthesize sigView;

@synthesize pollingRadius;
@synthesize pollingInterval;
@synthesize toggle;
@synthesize onButton;
@synthesize offButton;
@synthesize callbackField;
@synthesize sigCallbackField;
@synthesize lblSecret;
@synthesize lblSuccess;
@synthesize postTypeSegments;

- (void)dealloc {
    [locationManager release];
    [then release];
    [sigView release];
    [fullView release];
    [toggle release];
    [pollingInterval release];
    [pollingRadius release];
    [onButton release];
    [offButton release];
    [callbackField release];
    [sigCallbackField release];
    [lblSecret release];
    [lblSuccess release];
    [postTypeSegments release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    self.fullView = nil;
    self.sigView = nil;
    self.toggle = nil;
    self.pollingRadius = nil;
    self.pollingInterval = nil;
    self.offButton = nil;
    self.onButton = nil;
    self.callbackField = nil;
    self.lblSecret = nil;
    self.lblSuccess = nil;
    self.postTypeSegments = nil;
    self.sigCallbackField = nil;
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
    significantUpdate = NO;
    firstPass = YES;
    
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
    
    //get saved url or output default
    NSString *urlStr = [settings objectForKey:@"url"];
    if (!urlStr) {
        urlStr = kDefaultURL;
    }
    self.callbackField.text = urlStr;
    
    urlStr = [settings objectForKey:@"significantURL"];
    if (!urlStr) {
        urlStr = kDefaultSignificantURL;
    }
    
    self.sigCallbackField.text = urlStr;
    
    //set up initial time
    self.then = [NSDate date];
    
    [super viewDidLoad];
}

- (IBAction)toggleService:(UIButton *)sender {
    isRunning = !isRunning;
    if (isRunning) { 
        //show stop button
        self.offButton.hidden = NO;
        self.onButton.hidden = YES;
        self.pollingRadius.enabled = NO;
        self.pollingInterval.enabled = NO;
        self.callbackField.enabled = NO;
        self.postTypeSegments.enabled = NO;
        
        // Create the manager object 
        self.locationManager = [[[CLLocationManager alloc] init] autorelease];
        locationManager.delegate = self;
        
        //user settings from sliders
        locationManager.desiredAccuracy = pow(10, [self.pollingRadius value]);
        locationManager.distanceFilter = 45.0f;
        
        [locationManager startUpdatingLocation];
    } else {
        //show go button
        self.onButton.hidden = NO;
        self.offButton.hidden = YES;
        self.pollingRadius.enabled = YES;
        self.pollingInterval.enabled = YES;
        self.callbackField.enabled = YES;
        self.postTypeSegments.enabled = YES;
        
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
    
    //setup post url
    
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:[NSString stringWithFormat:@"%@",callbackField.text] forKey:@"url"];
    [settings setObject:[NSString stringWithFormat:@"%@",sigCallbackField.text] forKey:@"significantURL"];
    
    NSString *urlStr;
    if (significantUpdate) {
        urlStr = [NSString stringWithFormat:@"%@",sigCallbackField.text];
    } else {
        urlStr = [NSString stringWithFormat:@"%@",callbackField.text];
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //make timestamp
    NSDate *now = [NSDate date];
    
    double pollInterval = 3600*[self.pollingInterval value];
    if ([now timeIntervalSinceDate:then] >= pollInterval || firstPass) {
        firstPass = !firstPass;
        //save last update
        self.then = now;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *currentTime = [formatter stringFromDate:now];
        [formatter release];
        
        //TODO: code an actual success message...
        self.lblSuccess.text = currentTime;
        
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
        if (significantUpdate) {
            [manager stopUpdatingLocation];
            [manager startMonitoringSignificantLocationChanges];
        }
    }
    
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

- (void)stopMonitoringSignificantLocationChanges:(NSString *)state {
    //TODO: update status indicator (to be added)
    [locationManager stopMonitoringSignificantLocationChanges];
    locationManager.delegate = nil;
}

#pragma mark - Background methods
- (void)switchToBackgroundMode:(BOOL)background {
    if (background) {
        if (!isRunning) {
            if (significantUpdate) {
                [self.locationManager stopMonitoringSignificantLocationChanges];
            } else {
                [self.locationManager stopUpdatingLocation];
            }
            self.locationManager.delegate = nil;
        }
    } else {
        if (!isRunning) {
            self.locationManager.delegate = self;
            if (significantUpdate) {
                [self.locationManager startMonitoringSignificantLocationChanges];
            } else {
                [self.locationManager startUpdatingLocation];
            }
            
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

#pragma mark - segmented control methods
- (IBAction)segmentChanged:(id)sender {
    significantUpdate = !significantUpdate;
    if (significantUpdate) {
        self.sigView.hidden = NO;
        self.fullView.hidden = YES;
        self.callbackField.hidden = YES;
        self.sigCallbackField.hidden = NO;
    } else {
        self.sigView.hidden = YES;
        self.fullView.hidden = NO;
        self.callbackField.hidden = NO;
        self.sigCallbackField.hidden = YES;
    }
}

#pragma mark -
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
