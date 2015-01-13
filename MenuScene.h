//
//  MenuScene.h


#import "AbstractScene.h"

@class ImageRenderManager;
@class SoundManager;
@class TextureManager;
@class GameController;
@class Image;
@class BitmapFont;
@class PackedSpriteSheet;
@class Player;

// This class defines the menu scene that is displayed to the player when they first start 
// the game.  It shows a main menu with an animated background.  It is able to display the
// historical highscores of the player along with instructions, credits and the ability to
// not only start a new game but also resume a saved game.
//
@interface MenuScene : AbstractScene {

	/////////////////// Singleton Managers
	ImageRenderManager *sharedImageRenderManager;
	GameController *sharedGameController;
	SoundManager *sharedSoundManager;
	TextureManager *sharedTextureManager;
	
	/////////////////// Sprite sheets and images
	PackedSpriteSheet *pss;				// Master spritesheet that contains all menu images
	Image *background;					// Background image for the menu
	Image *fadeImage;					// Full screen black image used to fade in and out
	NSArray *clouds;					// Cloud images
	Image *menu, *menuButton;			// Menu and menu button images
	Image *castle;						// Castle image
	Image *logo;						// 71Squared logo which can also be tapped for credits
	Image *settings;					// Image used for the settings button
	Image *buttonHighlight;				// used to highlight touched buttons
	
	/////////////////// iVars used to control the cloud movement
	CGPoint *cloudPositions;
	float cloudSpeed;
	
	/////////////////// Sound iVar
	GLfloat musicVolume;				// Music volume used to fade music in and out
	
	/////////////////// Button iVars
	uint startWidth, resumeWidth;
	uint xStart, xResume;
	CGRect startButtonBounds;
	CGRect resumeButtonBounds;
	CGRect scoreButtonBounds;
	CGRect instructionButtonBounds;
	CGRect logoButtonBounds;
	CGRect settingsButtonBounds;
	CGPoint highlightPosition;

	/////////////////// Flags
	BOOL isMusicFading;					// YES if the music is already fading during a transition
	BOOL buttonPressed;					// YES if the player has pressed a button
}

@end
