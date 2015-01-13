//
//  MenuScene.m


#import "MenuScene.h"
#import "Primitives.h"
#import "Global.h"
#import "ImageRenderManager.h"
#import "GameController.h"
#import "Image.h"
#import "BitmapFont.h"
#import "SoundManager.h"
#import "TextureManager.h"
#import "PackedSpriteSheet.h"
#import "SpriteSheet.h"
#import "Player.h"

@implementation MenuScene

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"hidingScore" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"hidingInstructions" object:nil];
	[background release];
	[fadeImage release];

	if (clouds)
		free(clouds);
	if (cloudPositions)
		free(cloudPositions);
		
	[super dealloc];
}

// Set up the strings for the menu items
# define startString @"New Game"
# define resumeString @"Resume Game"
# define scoreString @"Score"
# define creditString @"Credits"

- (id)init {
	
	if(self = [super init]) {

		// Set the name of this scene
		self.name = @"menu";
		
		sharedImageRenderManager = [ImageRenderManager sharedImageRenderManager];
		sharedGameController = [GameController sharedGameController];
		sharedSoundManager = [SoundManager sharedSoundManager];
		sharedTextureManager = [TextureManager sharedTextureManager];
		
		// Register for the instructions view being hidden so that we can undo the button highlight
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHighlight) name:@"hidingInstructions" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHighlight) name:@"hidingScore" object:nil];


		// Create images for the menu from packed spritesheet and also the fade image
		menu = [[[Image alloc] initWithImageNamed: @"titleScreenAndHisBlobtouchtobegin.png" filter:GL_NEAREST] retain];


		
		// The allBack image is a single black pixel. This texture is stretched to fill the full
		// screen my scaling the image
		fadeImage = [[Image alloc] initWithImageNamed:@"allBlack.png" filter:GL_NEAREST];
		fadeImage.color = Color4fMake(1.0, 1.0, 1.0, 1.0);
		fadeImage.scale = Scale2fMake(480, 320);

		// Define cloud speed and position
		cloudSpeed = 3;
		

		
		// Init the fadespeed and alpha for this scene
		fadeSpeed = 1.0f;
		alpha = 1.0f;
		
		// Define the bounds for the buttons being used on the menu
		startButtonBounds = CGRectMake(0, 0, 360, 560);

		
		// Set the default music volume for the menu.  Start at 0 as we are going to fade the sound up
		musicVolume = 1.0f;
		
		// Set the initial state for the menu
		state = kSceneState_Idle;
		
		// No buttons pressed yet
		buttonPressed = NO;
	}
	return self;
}

- (void)updateSceneWithDelta:(float)aDelta {
	switch (state) {
		case kSceneState_Running:
			
			// Loop through clouds travelling to the right.  We want the speed of each cloud to 
			// be different as it looks better than having them all travel at the same speed.  To
			// Achieve this we have a very simple calculation that uses the index of the cloud in 
			// the array to work out the speed.
            ;

			break;
		case kSceneState_TransitionIn:
			
			// If external music is playing, then don't start the in game music
			if (!isMusicFading && !sharedSoundManager.isExternalAudioPlaying) {
				isMusicFading = YES;
				sharedSoundManager.currentMusicVolume = 0;
				[sharedSoundManager startPlaylistNamed:@"menu"];
				[sharedSoundManager fadeMusicVolumeFrom:0 toVolume:sharedSoundManager.musicVolume duration:0.8f stop:NO];
			}
			
			// Update the alpha value of the fadeImage
			alpha -= fadeSpeed * aDelta;
			fadeImage.color = Color4fMake(1.0, 1.0, 1.0, alpha);

			if(alpha < 0.0f) {
				alpha = 0.0f;
				isMusicFading = NO;
				state = kSceneState_Running;
			}
			break;
		case kSceneState_TransitionOut:
			
			// If not already fading, fade the currently playing track from the current volume to 0
			if (!isMusicFading && sharedSoundManager.isMusicPlaying) {
				isMusicFading = YES;
				[sharedSoundManager fadeMusicVolumeFrom:sharedSoundManager.musicVolume toVolume:0 duration:0.8f stop:YES];
			}
			
			// Adjust the alpha value of the fadeImage.  This will cause the image to move from transparent to opaque
			alpha += fadeSpeed * aDelta;
			fadeImage.color = Color4fMake(1.0, 1.0, 1.0, alpha);
			
			// Check to see if the image is now fully opache.  If so then the fade is finished
			if(alpha > 1.0f) {
				alpha = 1.0f;
				
				// The render routine will not be called for this scene past this point, so we have added
				// a render of the fadeImage here so that the menu scene is completely removed.  Without this
				// it was sometimes possible to see the main menu faintly.
				[fadeImage renderAtPoint:CGPointMake(0, 0)];
				[sharedImageRenderManager renderImages];
				
				// This scene is now idle
				state = kSceneState_Idle;
				
				// We stop the music for this scene and also remove the music we have been using.  This frees
				// up memory for the game scene.
				[sharedSoundManager removeMusicWithKey:@"themeIntro"];

				[sharedSoundManager removePlaylistNamed:@"menu"];
				sharedSoundManager.usePlaylist = NO;
				sharedSoundManager.loopLastPlaylistTrack = NO;
				
				// Stop the idletimer from kicking in while playing the game.  This stops the screen from fading
				// during game play
				[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
				
				// Reset the music fading flag
				isMusicFading = NO;
				
				// Ask the game controller to transition to the scene called game.
				[sharedGameController transitionToSceneWithKey:@"game"];
			}
			break;

		default:
			break;
	}
}

- (void)transitionIn {
	// Load GUI sounds
	[sharedSoundManager setListenerPosition:CGPointMake(0, 0)];
	[sharedSoundManager loadMusicWithKey:@"themeIntro" musicFile:@"Spotted.mp3"];
	[sharedSoundManager removePlaylistNamed:@"menu"];
	[sharedSoundManager addToPlaylistNamed:@"menu" track:@"themeIntro"];
	sharedSoundManager.usePlaylist = YES;
	sharedSoundManager.loopLastPlaylistTrack = YES;

    // Switch the idle timer back on as its not a problem if the phone locks while you are
	// at the menu.  This is recommended by apple and helps to save power
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	
	state = kSceneState_TransitionIn;
	
	buttonPressed = NO;
}

- (void)renderScene {

	// Render the background
	[background renderAtPoint:CGPointMake(0, 0)];
	
	// Render the menu and add the options text
	[menu renderAtPoint:CGPointMake(0, 0)];
	
	// Check with the game controller to see if a saved game is available
	if ([sharedGameController resumedGameAvailable])
		[menuButton renderAtPoint:CGPointMake(71, 60)];
	
	if (buttonPressed)
		[buttonHighlight renderAtPoint:highlightPosition];
	
	// If we are transitioning in, out or idle then render the fadeImage
	if (state == kSceneState_TransitionIn || state == kSceneState_TransitionOut || state == kSceneState_Idle) {
		[fadeImage renderAtPoint:CGPointMake(0, 0)];
	}
	
	// Having rendered our images we ask the render manager to actually put then on screen.
	[sharedImageRenderManager renderImages];

// If debug is on then display the bounds of the buttons
#ifdef SCB
	drawRect(startButtonBounds);
	drawRect(scoreButtonBounds);
	drawRect(instructionButtonBounds);
	drawRect(resumeButtonBounds);
	drawRect(logoButtonBounds);
	drawRect(settingsButtonBounds);
#endif
	
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
	UITouch *touch = [[event touchesForView:aView] anyObject];
	
	// Get the point where the player has touched the screen
	CGPoint originalTouchLocation = [touch locationInView:aView];
	
	// As we have the game in landscape mode we need to switch the touches 
	// x and y coordinates
	CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation];
	
	// We only want to check the touches on the screen when the scene is running.
	if (state == kSceneState_Running) {
		// Check to see if the user touched the start button
		if (CGRectContainsPoint(startButtonBounds, touchLocation)) {
			state = kSceneState_TransitionOut;
			sharedGameController.shouldResumeGame = NO;
			alpha = 0;
			highlightPosition = CGPointMake(85, 239);
			buttonPressed = YES;
			return;
		}

	}
}

- (void)updateHighlight {
	buttonPressed = NO;
}

@end
