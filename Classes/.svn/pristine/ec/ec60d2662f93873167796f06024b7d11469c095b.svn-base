//
//  HighScoreViewController.h
//  SLQTSOR
//
//  Created by Mike Daley on 08/12/2009.
//  Copyright 2009 Michael Daley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameController;

// The high score view controller is used to display the highscores that have been saved.
// The view layout and objects are defined in the HigiScoreView.xib file
// 
@interface HighScoreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

	//////////////////// Singleton references
	GameController *sharedGameController;	// Reference to the shared game controller
	
	//////////////////// Table view
	IBOutlet UITableView *scoreTableView;	// High score table view
	UITableViewCell *highScoreCell;			// TableViewCell used within the table view to display high score information
	NSDateFormatter *dateFormatter;			// Date formatter used to define the format of dates in the table view cells
	
	//////////////////// Flags
	BOOL isVisible;							// Set to YES when the view is visible
}

@property (nonatomic, retain) IBOutlet UITableViewCell *highScoreCell;
@property (nonatomic, assign) BOOL isVisible;

// Called when the done button is pressed
- (IBAction)hide:(id)aSender;

@end
