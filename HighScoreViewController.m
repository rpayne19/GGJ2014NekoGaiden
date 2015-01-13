//
//  HighScoreViewController.m

#import "HighScoreViewController.h"
#import "GameController.h"
#import "Score.h"

@interface HighScoreViewController (Private)

// Moves the high score view into view when a showHighScore notification is received.
- (void)show;

@end


@implementation HighScoreViewController

@synthesize highScoreCell;
@synthesize isVisible;

#pragma mark -
#pragma mark Deallocation

- (void)dealloc {
	// Remove observers that have been set up
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"showHighScore" object:nil];

    [super dealloc];
}

#pragma mark -
#pragma mark Init view

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// Set up a notification observers
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(show) name:@"showHighScore" object:nil];
		
		// Game controller
		sharedGameController = [GameController sharedGameController];
		
		// Set the default visible flag
		isVisible = NO;
		
		// Set up a date formatter so that we can display a nice looking date and time in the high score table
		dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
	// Set the initial alpha of the view
	self.view.alpha = 0;
	scoreTableView.allowsSelection = NO;
	
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

- (void)viewDidAppear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"pauseGame" object:self];
}

#pragma mark -
#pragma mark Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // We only want one section, so we hard code 1.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows this table will contain.  This matches the number of highscore
	// entries that currently exist
	return [sharedGameController.highScores count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"highScoreCell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"HighScoreCell" owner:self options:nil];
		cell = highScoreCell;
    }

	// Alternate the background colors of each row.  This helps the player see the different entries
	// more clearly
	if (indexPath.row % 2) {
		cell.contentView.backgroundColor = [UIColor colorWithRed:0.8 green:0.75 blue:0.6 alpha:0.1];
	} else {
		cell.contentView.backgroundColor = [UIColor colorWithRed:0.8 green:0.75 blue:0.6 alpha:0.2];
	}
	
	// Retrieve the score information from the game controller
	Score *score = [sharedGameController.highScores objectAtIndex:indexPath.row];

	// Update the score label
	UILabel *label;
	label = (UILabel*)[cell viewWithTag:1];
	label.text = [NSString stringWithFormat:@"%d", score.score];
	
	// Update the time label
	label = (UILabel*)[cell viewWithTag:2];
	label.text = score.time;
	
	// Update the date and time label
	label = (UILabel*)[cell viewWithTag:3];
	label.text = [dateFormatter stringFromDate:score.dateTime];
	
	// Update the players name label
	label = (UILabel*)[cell viewWithTag:4];
	label.text = score.name;
	
	// If the player won the game, show a star on the score.  We also have to remember to set
	// set the image to nil of the game was not won as we are sharing the same cell each time.
	// If a winning cell set the image and it was not reset for a loosing cell, then all 
	// cells would have the star.
	UIImageView *iv = (UIImageView*)[cell viewWithTag:5];
	if (score.didWin) {
		iv.image = [UIImage imageNamed:@"star.png"];
	} else {
		iv.image = nil;
	}

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	// This is the pixel height of each row in the table view
	return 70;
}

#pragma mark -
#pragma mark Rotation and hiding

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
   	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (IBAction)hide:(id)sender {
	
	// Only try to hide the high score view if it is currently visible
	if (isVisible) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"hidingScore" object:self];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"startGame" object:self];
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideFinished)];
		self.view.alpha = 0.0f;
		[UIView commitAnimations];	
		isVisible = NO;
		sharedGameController.isHighScoreVisible = NO;
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

@implementation HighScoreViewController (Private)

- (void)show {
		
	[sharedGameController.eaglView addSubview:self.view];
	sharedGameController.isHighScoreVisible = YES;
	
	// Begin the core animation we are going to use
	[UIView beginAnimations:nil context:NULL];
	self.view.alpha = 1.0f;
	[UIView commitAnimations];
	isVisible = YES;
	[scoreTableView reloadData];
}

@end
