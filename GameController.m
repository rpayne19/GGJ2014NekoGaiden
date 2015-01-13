//
//  GameController.m


#import "GameController.h"
#import "SLQTSORAppDelegate.h"
#import "SoundManager.h"
#import "GameScene.h"
#import "MenuScene.h"
#import "EAGLView.h"
#import "HighScoreViewController.h"
#import "SettingsViewController.h"
#import "InstructionsViewController.h"
#import "CreditsViewController.h"
#import "Score.h"

#pragma mark -
#pragma mark Private interface

@interface GameController (Private)
// Initializes OpenGL
- (void)initGameController;

// Sort the unsortedHighScores mutable array by score and date
- (void)sortHighScores;

@end

#pragma mark -
#pragma mark Public implementation

@implementation GameController

@synthesize pos;
@synthesize currentScene;
@synthesize resumedGameAvailable;
@synthesize shouldResumeGame;
@synthesize joypadPosition;
@synthesize fireDirection;
@synthesize gameScenes;
@synthesize eaglView;
@synthesize highScores;
@synthesize interfaceOrientation;
@synthesize isHighScoreVisible;
@synthesize isInstructionsVisible;
@synthesize isCreditsVisible;
@synthesize gamePaused;
@synthesize nextScene;

// Make this class a singleton class
SYNTHESIZE_SINGLETON_FOR_CLASS(GameController);

- (void)dealloc {
    
    [gameScenes release];
    [nextScene release];
	[highScores release];
	[settingsViewController release];
	[highScoreViewController release];
	[instructionsViewController release];
	[creditsViewController release];
	[settings release];
    [super dealloc];
}

- (id)init {
    self = [super init];
    if(self != nil) {
		
		// Initialize the game
        [self initGameController];
    }
    return self;
}

#pragma mark -
#pragma mark HighScores

- (void)loadHighScores {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
	NSMutableData *highScoresData;
    NSKeyedUnarchiver *decoder;
    
    // Check to see if the highScores.dat file exists and if so load the contents into the
    // highScores array
    NSString *documentPath = [documentsDirectory stringByAppendingPathComponent:@"highScores.dat"];
    
	highScoresData = [NSData dataWithContentsOfFile:documentPath];
    
	if (highScoresData) {
		decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:highScoresData];
		unsortedHighScores = [[decoder decodeObjectForKey:@"highScores"] retain];
		[decoder release];
	} else {
		unsortedHighScores = [[NSMutableArray alloc] init];
	}
	
	[self sortHighScores];
}

- (void)saveHighScores {
	// Set up the game state path to the data file that the game state will be saved too.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *scoresPath = [documentsDirectory stringByAppendingPathComponent:@"highScores.dat"];
	
	// Set up the encoder and storage for the game state data
	NSMutableData *scores;
	NSKeyedArchiver *encoder;
	scores = [NSMutableData data];
	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:scores];
	
	// Archive the entities
	[encoder encodeObject:unsortedHighScores forKey:@"highScores"];
	
	// Finish encoding and write the contents of gameData to file
	[encoder finishEncoding];
	[scores writeToFile:scoresPath atomically:YES];
	[encoder release];
}

- (void)addToHighScores:(int)aScore gameTime:(NSString*)aGameTime playersName:(NSString*)aPlayerName didWin:(BOOL)aDidWin {
	Score *score = [[Score alloc] initWithScore:aScore gameTime:aGameTime playersName:aPlayerName didWin:aDidWin];
	[unsortedHighScores addObject:score];
	[score release];
	[self saveHighScores];
	[self sortHighScores];
}

#pragma mark -
#pragma mark Save game settings

- (void)deleteGameState {
	
	// Delete the gameState.dat file
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *gameStatePath = [documentsDirectory stringByAppendingPathComponent:@"gameState.dat"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	[fileManager removeItemAtPath:gameStatePath error:NULL];
	
	// Flag that there is then no resume game available
	resumedGameAvailable = NO;
	shouldResumeGame = NO;
}

- (void)loadSettings {
	
	SLQLOG(@"INFO - EAGLView: Loading settings.");
    
	// If the key "userDefaultsSet" is not set then it means that no settings have been
	// defined yet, so set the defaults otherwise load the settings
	if (![settings boolForKey:@"userDefaultsSet"]) {
		[settings setBool:1 forKey:@"userDefaultsSet"];
		[settings setFloat:0.5f forKey:@"musicVolume"];
		[sharedSoundManager setMusicVolume:0.5f];
		[settings setFloat:0.75f forKey:@"fxVolume"];
		[sharedSoundManager setFxVolume:0.75f];
		[settings setInteger:0 forKey:@"joypadPosition"];
		self.joypadPosition = 0;
		[settings setInteger:0 forKey:@"fireDirection"];
		self.fireDirection = 0;
	} else {
		[sharedSoundManager setMusicVolume:[settings floatForKey:@"musicVolume"]];
		[sharedSoundManager setFxVolume:[settings floatForKey:@"fxVolume"]];
		self.joypadPosition = [settings integerForKey:@"joypadPosition"];
		self.fireDirection = [settings integerForKey:@"fireDirection"];
	}
	
	// Now that the settings values have been updated from the settings file, post a notification
	// which causes the sliders on the settings view to be updated with the new values.
	[[NSNotificationCenter defaultCenter] postNotificationName:@"updateSettingsSliders" object:self];
}

- (void)saveSettings {
	// Save the current settings to the apps prefs file
	[settings setFloat:sharedSoundManager.musicVolume forKey:@"musicVolume"];
	[settings setFloat:sharedSoundManager.fxVolume forKey:@"fxVolume"];
	[settings setInteger:self.joypadPosition forKey:@"joypadPosition"];
	[settings setInteger:self.fireDirection forKey:@"fireDirection"];
}

#pragma mark -
#pragma mark Update & Render

- (void)updateCurrentSceneWithDelta:(float)aDelta {
    [currentScene updateSceneWithDelta:aDelta];         //change the speed here <----- hannabarbara
    //    if(nextScene.state == kSceneState_Loading)
    //        [nextScene updateSceneWithDelta:aDelta];
}

-(void)renderCurrentScene {
    [currentScene renderScene];
}

#pragma mark -
#pragma mark Transition

- (void)transitionToSceneWithKey:(NSString*)aKey {
    [self deleteGameState]; //need to do something about this one..
    
    currentScene = [gameScenes objectForKey:aKey];
	// Set the current scene to the one specified in the key
    //    [[gameScenes objectForKey:@"battle"] initNewGameState];
    
    if([aKey compare:@"menu"]){
        [[gameScenes objectForKey:@"game"]dealloc];
        
        [gameScenes setValue:[[GameScene alloc] initWithMap: @"gameMapAlpha1" music: @"Spotted2.mp3" location:CGPointMake(11, 11)] forKey:@"game"];
    }
	// Run the transitionIn method inside the new scene
	[currentScene transitionIn];
}
- (void)transitionToGameScene {
    
    currentScene = [gameScenes objectForKey:@"game"];
    [currentScene transitionIn];
    [[gameScenes objectForKey:@"battle"]dealloc];
    //  battle = [[BattleScene alloc] init];
    //   [gameScenes setValue:battle forKey:@"battle"];
    //   [battle release];
}

- (void)transitionToBattleScene {
    AbstractScene *game;
    currentScene = [gameScenes objectForKey:@"battle"];
    [currentScene transitionIn];
    [[gameScenes objectForKey:@"game"]dealloc];
    game = [[GameScene alloc] init];
    [gameScenes setValue:game forKey:@"game"];
    [game release];
}

- (void)setupNextScene:(NSString*)aMap music:(NSString*)aSong location:(CGPoint) aPosition{
    NSLog(@"GameController: Setting up next scene");
    
    
    [nextScene initWithMap: aMap music: aSong location:aPosition];
    [gameScenes setValue:nextScene forKey:@"nextScene"];
}

- (void)switchToNextScene{
    NSLog(@"GameController: switching to next scene");
    
    [self deleteGameState];
    currentScene = [gameScenes objectForKey:@"nextScene"];
    [currentScene transitionIn];
    //   [[gameScenes objectForKey:@"game"]release];
    nextScene = [GameScene alloc];
    [gameScenes setValue:currentScene forKey:@"game"];
    
}
#pragma mark -
#pragma mark Orientation adjustment

- (CGPoint)adjustTouchOrientationForTouch:(CGPoint)aTouch {
	
	CGPoint touchLocation;
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		touchLocation.x = aTouch.y;
		touchLocation.y = aTouch.x;
	}
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		touchLocation.x = 480 - aTouch.y;
		touchLocation.y = 320 - aTouch.x;
	}
	
	return touchLocation;
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation GameController (Private)

- (void)initGameController {
    
    SLQLOG(@"INFO - GameController: Starting game initialization.");
	
	// Set up the sound manager
	sharedSoundManager = [SoundManager sharedSoundManager];
	
	// Set up the notifications we are going to listen our for
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startGame) name:@"startGame" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseGame) name:@"pauseGame" object:nil];
    
	// Set the random number seed.  If we don't set this then each time the game is run we will get
	// the same numbers generated from the random macros in global.h
	srandomdev();
	
	// Init the prefs file which is storing the games settings
	settings = [[NSUserDefaults  standardUserDefaults] retain];
	
	// Set the orientation of the device
	interfaceOrientation = UIInterfaceOrientationLandscapeRight;
	

	// Settup the menu scenes
    gameScenes = [[NSMutableDictionary alloc] init];
    
    // Menu scene
	AbstractScene *scene = [[MenuScene alloc] init];
    [gameScenes setValue:scene forKey:@"menu"];
	
	// Game scene
    nextScene = [GameScene alloc];
	scene = [[GameScene alloc] initWithMap: @"gameMapAlpha1" music: @"Spotted.mp3" location:CGPointMake(11, 11)];
	[gameScenes setValue:scene forKey:@"game"];

	currentScene = [gameScenes objectForKey:@"menu"];       //hannabarbera
    
	// Setup and load the highscores
	highScores = [[NSArray alloc] init];
	[self loadHighScores];
	
	
	// By default a saved game doesn't exist
	resumedGameAvailable = NO;
	
	// By default the game is not paused
	gamePaused = NO;

	
	// By default we are not going to start from a resumed game.  This is set to YES if the
	// resume game option is selected from the main menu
	shouldResumeGame = NO;
    
    // Set the initial scenes state
    [currentScene transitionIn];
    
    SLQLOG(@"INFO - GameController: Finished game initialization.");
}



- (void)sortHighScores {
	// Sort the high score data using the score and then the date and time.  For this we need to create two
	// sort descriptors using the score and dateTime properties of the score object
	NSSortDescriptor *scoreSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO] autorelease];
	NSSortDescriptor *dateSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"dateTime" ascending:NO] autorelease];
    
	// We then place the sort descriptors we want to use into an array of sortDescriptors
	NSArray *sortDescriptors = [NSArray arrayWithObjects:scoreSortDescriptor, dateSortDescriptor, nil];
	
	// We have a retain on highScores, so we release that before loading the sorted data into the highScores array
	[highScores release];
	
	// Load the highScores array with the sorted data from the unsortedHighScores array
	highScores = [[unsortedHighScores sortedArrayUsingDescriptors:sortDescriptors] retain];
}

- (void)startGame {
	gamePaused = NO;
}

- (void)pauseGame {
	gamePaused = YES;	
}


@end
