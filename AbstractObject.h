//
//  AbstractObject.h


#import "Global.h"
#import "Player.h"

@class AbstractScene;
@class AbstractEntity;
@class SoundManager;

// Abstract class that represents game objects.  This are normally objects that are updated and
// rendered within the game loop.  Objects can be loaded manually within the game logic such as
// the GeneralGrave class when the player dies, and also loaded from object metadata found inside
// the file map file.
//
@interface AbstractObject : NSObject <NSCoding> {

	////////////////// Singleton Managers
	SoundManager *sharedSoundManager;		// Reference to the shared sound manager
	GameController *sharedGameController;	// Reference to the shared game controller

	////////////////// Instance variables
	CGPoint tileLocation;		// Tile position of the object in the map
	CGPoint pixelLocation;		// Pixel position of the object in the map
	int state;					// Object state
	int type;					// Object type
	int subType;				// Object subtype
	int energy;					// Energy that is passed to the player is this object is an energy object
    float width;
    float height;

	////////////////// Flags
	BOOL isCollectable;			// Identifies if the object can be collected by the player i.e. the player is
								// colliding with the object
}

@property (nonatomic, assign) CGPoint tileLocation;
@property (nonatomic, assign) CGPoint pixelLocation;
@property (nonatomic, assign) int state;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) int subType;
@property (nonatomic, assign) int energy;
@property (nonatomic, assign) BOOL isCollectable;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;

// Designated initializer that creates a new instance of this class at the specified location
// and with the specified type and subtype.
- (id)initWithTileLocation:(CGPoint)aTileLocaiton type:(int)aType subType:(int)aSubType;
- (id)initWithTileLocation:(CGPoint)aTileLocation type:(int)aType subType:(int)aSubType width:(float)aWidth height:(float)aHeight;

// Updates the object providing the time delta since the last update and also a
// reference to the parent scene
- (void)updateWithDelta:(float)aDelta scene:(AbstractScene*)aScene;

// Renders the object
- (void)render;

// Checks to see if the object has collided with the |aEntity|
- (void)checkForCollisionWithEntity:(AbstractEntity*)aEntity;

// Get the collision bounds for the object
- (CGRect)collisionBounds;

#pragma mark -
#pragma mark NSCoding support

- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
