//
//  Player.h


#import "AbstractEntity.h"

@class GameController;
@class AbstractObject;


@interface Player : AbstractEntity {
	
	//////////////////// Animation
    Animation *leftAnimation;
    Animation *rightAnimation;
    Animation *downAnimation;
    Animation *upAnimation;
    Animation *currentAnimation;
	Animation *rightAttackAnimation;
    Animation *leftAttackAnimation;
    Animation *upAttackAnimation;
    Animation *downAttackAnimation;
    Animation *sleepAnimation;
    Image *overlay;
    
    
	///////////////// Instance variables
    float playerSpeed;			// Speed at which the player moves
	float angleOfMovement;		// Angle at which the player will move
	float speedOfMovement;		// Speed accelerator added to the players speed.  Provided by the joypad
	float energyTimer;			// Increments over time to reduce players energy steadily
	float deathTimer;			// Increments over time to time how long the player should stay dead
	float blinkTimer;			// Used to make the player sprite blink when appearing
	int lives;					// Number of player lives
	float stayDeadTime;			// How long the player should stay dead before reappearing
	CGPoint beamLocation;		// Location to which the player is being beamed by a portal
    float MOVEMENT_SPEED;
    float retreatAngle;
    float controlDelta;
    float animationDelta;
    float attackDelta;
	
	///////////////// Flags
	BOOL renderSprite;			// Used with the blinkTimer to make the sprite blink when appearing
	BOOL hasParchmentTop, hasParchmentMiddle, hasParchmentBottom; // A flag for each parchment piece collected
    BOOL isLAtk;
    BOOL isRAtk;
    BOOL isUAtk;
    BOOL isDAtk;
    uint isFacing;
}


@property (nonatomic, assign) uint isFacing;
@property (nonatomic, assign) float angleOfMovement;
@property (nonatomic, assign) float speedOfMovement;
@property (nonatomic, assign) int lives;
@property (nonatomic, assign) CGPoint beamLocation;
@property (nonatomic, assign) float attackDelta;



// Creates an instance of the player class with the given tilemap location
- (id)initWithTileLocation:(CGPoint)aLocation;
// Sets the player direction and speed.  This information is provided by the joypad
- (void)setDirectionWithAngle:(float)aAngle speed:(float)aSpeed;

// Checks to see if the object passed in has collided with the player and if so takes
// the necessary action
- (void)checkForCollisionWithObject:(AbstractObject*)aObject;

// Checks to see if the entity passed in has collided with the player and if so takes
// the necessary action
- (void)checkForCollisionWithEntity:(AbstractEntity*)aEntity;


@end
