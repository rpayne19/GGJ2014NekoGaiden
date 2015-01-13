//
//  AbstractState.h


#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@class TextureManager;
@class SoundManager;

// This is an abstract class which contains the basis for any game scene which is going
// to be used.  A game scene is a self contained class which is responsible for updating 
// the logic and rendering the screen for the current scene.  It is simply a way to 
// encapsulate a specific scenes code in a single class.
//
// The Director class controls which scene is the current scene and it is this scene which
// is updated and rendered during the game loop.
//
@interface AbstractScene : NSObject {

	CGRect screenBounds;
	uint state;
	GLfloat alpha;
	NSString *nextSceneKey;
    float fadeSpeed;
	NSString *name;
    int numberOfMonsters;
    float battleFinished;
    NSMutableArray *mapObjects;
    BOOL isTextBoxTime;

}

#pragma mark -
#pragma mark Properties

@property (nonatomic) int numberOfMonsters;
@property (nonatomic, assign) uint state;
@property (nonatomic, assign) GLfloat alpha;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSMutableArray *mapObjects;
@property (nonatomic) BOOL isTextBoxTime;
#pragma mark -
#pragma mark Selectors

// Selector to update the scenes logic using |aDelta| which is passe in from the game loop
- (void)updateSceneWithDelta:(float)aDelta;

// Selector that enables a touchesBegan events location to be passed into a scene.
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;
- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView;

// Selector which enables accelerometer data to be passed into the scene.
//- (void)updateWithAccelerometer:(UIAcceleration*)aAcceleration;

// Selector that transitions from this scene to the scene with the key specified.  This allows the current
// scene to perform a transition action before the current scene within the game controller is changed.
- (void)transitionToSceneWithKey:(NSString*)aKey;

// Selector that sets off a transition into the scene
- (void)transitionIn;

// Selector which renders the scene
- (void)renderScene;

// Saves the current state of the game to be resumed later
- (void)saveGameState;

@end
