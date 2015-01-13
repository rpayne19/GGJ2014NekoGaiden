//
//  GameController.h


#import <UIKit/UIKit.h>
#import "SynthesizeSingleton.h"
#import "EAGLView.h"
#import "Global.h"

@class AbstractScene;
@class GameScene;
@class EAGLView;
@class SoundManager;
@class HighScoreViewController;
@class SettingsViewController;
@class InstructionsViewController;
@class CreditsViewController;

// Class responsbile for passing touch and game events to the correct game
// scene.  A game scene is an object which is responsible for a specific
// scene within the game i.e. Main menu, main game, high scores etc.
// The state manager hold the currently active scene and the game controller
// will then pass the necessary messages to that scene.
//
@interface GameController : NSObject {
    
    
	///////////////////// Singletons
	SoundManager *sharedSoundManager;				// Reference to the shared sound manager
    
	///////////////////// Views and orientation
	EAGLView *eaglView;						        // Reference to the EAGLView
	UIInterfaceOrientation interfaceOrientation;	// Devices interface orientation
	
    ///////////////////// Game controller iVars
	CGRect screenBounds;					// Bounds of the screen
    NSDictionary *gameScenes;				// Dictionary of the different game scenes
	NSArray *highScores;					// Sorted high scores array
	NSMutableArray *unsortedHighScores;		// Unsorted high scores array
    AbstractScene *currentScene;			// Current game scene being updated and rendered
    GameScene *nextScene;
    AbstractScene *previousScene;
    CGPoint pos;
    ///////////////////// Game controller flags
	BOOL resumedGameAvailable;				// Can a game be resumed
	BOOL shouldResumeGame;					// Should the game being loaded be resumed
	int joypadPosition;						// Joypad position
	int fireDirection;						// Direction used when player is firing
    // 0 = direction player is facing
    // 1 = touch location in relation to player
	BOOL isHighScoreVisible;				// Is the high score view visible
	BOOL isInstructionsVisible;				// Is the instructions view visible
	BOOL isCreditsVisible;					// Is the credits view visible
	BOOL gamePaused;						// Is the game paused
    
	///////////////////// Settings
	NSUserDefaults *settings;
	
	///////////////////// Views
	HighScoreViewController *highScoreViewController;		// Displays the high score table
	SettingsViewController *settingsViewController;			// Displays the settings
	InstructionsViewController *instructionsViewController;	// Displays the instructions
	CreditsViewController *creditsViewController;			// Displays the credits
    
}
@property (nonatomic) CGPoint pos;
@property (nonatomic, retain) AbstractScene *previousScene;
@property (nonatomic, retain) GameScene *nextScene;
@property (nonatomic, retain) EAGLView *eaglView;
@property (nonatomic, retain) AbstractScene *currentScene;
@property (nonatomic, assign) int joypadPosition;
@property (nonatomic, assign) int fireDirection;
@property (nonatomic, retain) NSDictionary *gameScenes;
@property (nonatomic, retain) NSArray *highScores;
@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, assign) BOOL resumedGameAvailable;
@property (nonatomic, assign) BOOL shouldResumeGame;
@property (nonatomic, assign) BOOL isHighScoreVisible;
@property (nonatomic, assign) BOOL isInstructionsVisible;
@property (nonatomic, assign) BOOL isCreditsVisible;
@property (nonatomic, assign) BOOL gamePaused;

// Class method to return an instance of GameController.  This is needed as this
// class is a singleton class
+ (GameController *)sharedGameController;

// Updates the logic within the current scene
- (void)updateCurrentSceneWithDelta:(float)aDelta;

// Renders the current scene
- (void)renderCurrentScene;

// Causes the game controller to select a new scene as the current scene
- (void)transitionToSceneWithKey:(NSString*)aKey;

- (void)switchToNextScene;
// Causes the game controller to change over play to the game scene
- (void)transitionToBattleScene;

// Causes the game controller to change back to the map screen

- (void)transitionToGameScene;

// Load the high scores
- (void)loadHighScores;

// Add a new score to the high scores list
- (void)addToHighScores:(int)aScore gameTime:(NSString*)aGameTime playersName:(NSString*)aPlayersName didWin:(BOOL)aDidWin;

// Save the current high scores table
- (void)saveHighScores;

// Deletes the game state file
- (void)deleteGameState;

// Loads the game settings such as volume and joypad location
- (void)loadSettings;

// Saves the current settings
- (void)saveSettings;

- (void)setupNextScene:(NSString*)aMap music:(NSString*)aSong location:(CGPoint) aPositition;

// Returns an adjusted touch point based on the orientation of the device
- (CGPoint)adjustTouchOrientationForTouch:(CGPoint)aTouch;

@end
