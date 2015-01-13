//
//  CreditsViewController.m
//  SLQTSOR
//
//  Created by Mike Daley on 02/01/2010.
//  Copyright 2010 Michael Daley. All rights reserved.
//

#import "CreditsViewController.h"
#import "GameController.h"

#pragma mark -
#pragma mark Private interface

@interface CreditsViewController (Private)

// Causes the view controller to be added to the EAGLView view and faded into view
- (void)show;

@end

#pragma mark -
#pragma mark Public implementation

@implementation CreditsViewController

@synthesize isVisible;

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"showCredits" object:nil];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Set up a notification observers
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:@"showCredits" object:nil];
		
		sharedGameController = [GameController sharedGameController];
    }
    return self;
}

- (void)viewDidLoad {
	// Set the size of scrollView content which is going to be moved.  This should match the size of the
	// image inside the scrollview.
	scrollView.contentSize = CGSizeMake(298, 950);
}

- (void)viewDidAppear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"pauseGame" object:self];
}

- (void)viewWillAppear:(BOOL)animated {
	// Set the initial alpha of the view
	self.view.alpha = 0;
	
	// If the orientation is in landscape then transform the view
	if (sharedGameController.interfaceOrientation == UIInterfaceOrientationLandscapeRight){
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
		self.view.transform = CGAffineTransformIdentity;
		self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
		self.view.center = CGPointMake(160, 240);
	}
	if (sharedGameController.interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
		[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
		self.view.transform = CGAffineTransformIdentity;
		self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
		self.view.center = CGPointMake(160, 240);
	}
}

#pragma mark -
#pragma mark Rotation and hiding

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)hide:(id)sender {
	
	// Only try to hide the high score view if it is currently visible
	if (isVisible) {
		// Send a notification to hide the high score view if its visible
		[[NSNotificationCenter defaultCenter] postNotificationName:@"startGame" object:self];
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideFinished)];
		self.view.alpha = 0.0f;
		[UIView commitAnimations];	
		isVisible = NO;
		sharedGameController.isCreditsVisible = NO;
	}
}

-(void)hideFinished {
	// Remove this view from its superview i.e. EAGLView.  This allows the next view that is added
	// to be the topmost view and therefore react to orientation events
	[self.view removeFromSuperview];
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation CreditsViewController (Private)

- (void)show {
	
	[sharedGameController.eaglView addSubview:self.view];
	sharedGameController.isCreditsVisible = YES;
	
	// Begin the core animation we are going to use
	[UIView beginAnimations:nil context:NULL];
	self.view.alpha = 1.0f;
	[UIView commitAnimations];
	isVisible = YES;
}

@end
