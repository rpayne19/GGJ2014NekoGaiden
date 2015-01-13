//
//  SettingsViewController.h


#import <UIKit/UIKit.h>

@class SoundManager;
@class GameController;

// The settings view controller is used to display the settings to the player.  It fades
// over the EAGLView and displays a slider for the music and fx volume allowing
// the player to select the settings they would like to use.  This class observes the
// "showSettings" notification which is how it knows when to fade the settings view
// into place.  The view layout and objects are defined in the SettingsView.xib file
// This view is added as a subview to EAGLView when it appears and then removed when it
// is done.  Only the first subview of EAGLView will respond to rotation events and
// we need this view as well as the high score view to rotate.  To overcome this we
// add and remove views to EAGLView as necessary.
//
@interface SettingsViewController : UIViewController {

	//////////////////// Singleton references
	SoundManager *sharedSoundManager;					// Reference to the SoundManager singleton
	GameController *sharedGameController;				// Reference to the GameController singleton
	
	//////////////////// IBOutlets for the view
	IBOutlet UISlider *musicVolume;						// Controls the music volume
	IBOutlet UISlider *fxVolume;						// Controls the fx volume
	IBOutlet UISegmentedControl *joypadPosition;		// Specifies the location of the joypad
	IBOutlet UISegmentedControl *fireDirction;			// Direction the axe is thrown when the player fires
														// Player = direction the player is facing
														// Touch = direction of the touch from the player
	IBOutlet UIButton *menuButton;						// Button that returns the player to the main menu

	//////////////////// Flags
	BOOL isVisible;										// is the settings view currently visible
}

// Used to hide the settings view
- (IBAction)hide:(id)aSender;

// Button that takes the player back to the menu if they are playing the game
- (IBAction)moveToMenu:(id)sender;

// Sets the music volume within the sound manager class when the music volume
// slider on the settings view is changed
- (IBAction)musicValueChanged:(UISlider*)sender;

// Sets the fx volume within the sound manager class when the fx volume
// slider on the settings view is changed
- (IBAction)fxValueChanged:(UISlider*)sender;

// Sets the left handed flag within the game controller class when the switch is changed
- (IBAction)joypadSideChanged:(UISegmentedControl*)sender;

// Sets the fire direction flag within the game controller when the direction is changed
- (IBAction)fireDirctionChanged:(UISegmentedControl*)sender;

@end
