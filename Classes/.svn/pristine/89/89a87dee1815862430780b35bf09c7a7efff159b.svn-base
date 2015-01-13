//
//  InstructionsViewController.m
//  SLQTSOR
//
//  Created by Mike Daley on 01/01/2010.
//  Copyright 2010 Michael Daley. All rights reserved.
//

#import "InstructionsViewController.h"
#import "GameController.h"

@interface InstructionsViewController (Private)

- (void)show;

@end


@implementation InstructionsViewController

@synthesize isVisible;

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"showInstructions" object:nil];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Set up a notification observers
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:@"showInstructions" object:nil];
		
		sharedGameController = [GameController sharedGameController];
    }
    return self;
}

- (void)viewDidLoad {
	// Set the size of scrollView content which is going to be moved
	scrollView.contentSize = CGSizeMake(220, 1051);
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

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
   	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)hide:(id)sender {
	
	// Only try to hide the high score view if it is currently visible
	if (isVisible) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hidingInstructions" object:self];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"startGame" object:self];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideFinished)];
		self.view.alpha = 0.0f;
		[UIView commitAnimations];	
		isVisible = NO;
		sharedGameController.isInstructionsVisible = NO;
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

@implementation InstructionsViewController (Private)

- (void)show {
	
	[sharedGameController.eaglView addSubview:self.view];
	sharedGameController.isInstructionsVisible = YES;
	
	// Begin the core animation we are going to use
	[UIView beginAnimations:nil context:NULL];
	self.view.alpha = 1.0f;
	[UIView commitAnimations];
	isVisible = YES;
}

@end
