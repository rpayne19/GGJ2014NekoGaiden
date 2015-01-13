//
//  Door.h


#import "AbstractEntity.h"
#import "Player.h"

@class SpriteSheet;

@interface Door : AbstractEntity {

	Image *openDoor;	// Open door image
	Image *closedDoor;	// Closed door image
    float timer;		// Records the amount of time between changes to the doors state
    float doorTimer;	// Milliseconds that should pass before door state changes
    int doorState;		// Doors current state
	int type;			// Type of door
	BOOL locked;		// Is the door locked or not
	int color;			// Color of the door
	int arrayIndex;		// Index of the door in the doors array
}

@property (nonatomic, assign) BOOL locked;
@property (nonatomic, assign) int color;
@property (nonatomic, assign) int doorState;
@property (nonatomic, assign) int arrayIndex;

// Initialize a door entity with the given location
- (id)initWithTileLocation:(CGPoint)aPoint type:(int)aType arrayIndex:(int)aArrayIndex;

@end
