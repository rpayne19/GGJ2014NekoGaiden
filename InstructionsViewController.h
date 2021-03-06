//
//  InstructionsViewController.h


#import <UIKit/UIKit.h>

@class GameController;

@interface InstructionsViewController : UIViewController {

	//////////////////// Singleton references
	GameController *sharedGameController;	// Reference to the shared game controller
	
	//////////////////// Scroll view
	IBOutlet UIScrollView *scrollView;		// Scroll view used to display the intructions image

	//////////////////// Flags
	BOOL isVisible;							// Set to YES when this view is visible
	
}

@property (nonatomic, assign) BOOL isVisible;

- (IBAction)hide:(id)sender;

@end
