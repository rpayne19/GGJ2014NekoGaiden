//
//  Player.m
//  Tutorial1


#import "GameController.h"
#import "SoundManager.h"
#import "Player.h"
#import "GameScene.h"
#import "Image.h"
#import "SpriteSheet.h"
#import "Animation.h"
#import "Primitives.h"
#import "BitmapFont.h"
#import "PackedSpriteSheet.h"
#import "AbstractObject.h"
#import "MapObject.h"
#import "EnergyObject.h"
#import "EnemyAttack.h"


#pragma mark -
#pragma mark Private implementation

@interface Player (Private)
// Updates the players location with the given delta
- (void)updateLocationWithDelta:(float)aDelta;

// Checks to see if the supplied object is part of the parchment
- (void)checkForParchment:(AbstractObject*)aObject pickup:(BOOL)aPickup;
@end

#pragma mark -
#pragma mark Public implementation

@implementation Player

@synthesize angleOfMovement;
@synthesize speedOfMovement;
@synthesize lives;
@synthesize beamLocation;
@synthesize attackDelta;
@synthesize isFacing;




- (void)dealloc {
    [leftAnimation release];
    [rightAnimation release];
    [downAnimation release];
    [upAnimation release];
    [leftAttackAnimation release];
    [rightAttackAnimation release];
    [upAttackAnimation release];
    [downAttackAnimation release];
    [sleepAnimation release];
    [super dealloc];
}

#pragma mark -
#pragma mark Init

- (id)initWithTileLocation:(CGPoint)aLocation {
    self = [super init];
	if (self != nil) {
		
		// The players position is held in terms of tiles on the map
        tileLocation.x = aLocation.x;
        tileLocation.y = aLocation.y;
		
		// Set up the initial pixel position based on the players tile position
		pixelLocation = tileMapPositionToPixelPosition(tileLocation);
		
       		PackedSpriteSheet *test = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pkgsprites.png" controlFile:@"pkgsprites" imageFilter:GL_NEAREST];
    
        // Set up the animations for our player for different directions
        leftAnimation = [[Animation alloc] init];
        rightAnimation = [[Animation alloc] init];
        downAnimation = [[Animation alloc] init];
		upAnimation = [[Animation alloc] init];
        leftAttackAnimation = [[Animation alloc] init];
        rightAttackAnimation = [[Animation alloc] init];
        upAttackAnimation = [[Animation alloc] init];
        downAttackAnimation = [[Animation alloc] init];
        sleepAnimation = [[Animation alloc]init];

        float animationDelay = 0.2f;
        
        NSString *name = [[NSString alloc]initWithString:@"s"];

        
        // Left animation
		[leftAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"rl1.png"]] delay:animationDelay];
		[leftAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"rl2.png"]] delay:animationDelay];
		[leftAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"rl3.png"]] delay:animationDelay];
		[leftAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"rl1.png"]] delay:animationDelay];
		[leftAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"il.png"]] delay:animationDelay];
		leftAnimation.type = kAnimationType_Repeating;
		leftAnimation.state = kAnimationState_Running;
		leftAnimation.bounceFrame = 4;

        // Right animation  //start with mid run > run 1 > mid run > run 3 > standing
		[rightAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"rr1.png"]] delay:animationDelay];
		[rightAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"rr2.png"]] delay:animationDelay];
		[rightAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"rr3.png"]] delay:animationDelay];
		[rightAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"rr1.png"]] delay:animationDelay];
		[rightAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"ir.png"]] delay:animationDelay];
		rightAnimation.type = kAnimationType_Repeating;
		rightAnimation.state = kAnimationState_Running;
		rightAnimation.bounceFrame = 4;
      
        // Down animation
		[downAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"rd1.png"]] delay:animationDelay];
		[downAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"rd2.png"]] delay:animationDelay];
		[downAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"rd3.png"]] delay:animationDelay];
		[downAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"rd1.png"]] delay:animationDelay];
		[downAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"id.png"]] delay:animationDelay];
		downAnimation.type = kAnimationType_Repeating;
		downAnimation.state = kAnimationState_Running;
		downAnimation.bounceFrame = 4;
        
        // Up animation
		[upAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"ru1.png"]] delay:animationDelay];
		[upAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"ru2.png"]] delay:animationDelay];
		[upAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"ru3.png"]] delay:animationDelay];
		[upAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"ru1.png"]] delay:animationDelay];
		[upAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"iu.png"]] delay:animationDelay];
		upAnimation.type = kAnimationType_Repeating;
		upAnimation.state = kAnimationState_Running;
		upAnimation.bounceFrame = 4;           //not 9 9 0 2

        // Right attack animation
        [rightAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"ar1.png"]] delay:animationDelay];
		[rightAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"ar2.png"]] delay:animationDelay];
		[rightAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"ar1.png"]] delay:animationDelay];
		[rightAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"ar2.png"]] delay:animationDelay];
		rightAttackAnimation.type = kAnimationType_Once;
		rightAttackAnimation.state = kAnimationState_Running;
		rightAttackAnimation.bounceFrame = 4;
        
        // Left attack animation
        [leftAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"al1.png"]] delay:animationDelay];
		[leftAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"al2.png"]] delay:animationDelay];
		[leftAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"al1.png"]] delay:animationDelay];
		[leftAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"al2.png"]] delay:animationDelay];
		leftAttackAnimation.type = kAnimationType_Once;
		leftAttackAnimation.state = kAnimationState_Running;
		leftAttackAnimation.bounceFrame = 4;
     
        [upAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"au1.png"]] delay:animationDelay];
		[upAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"iu.png"]] delay:animationDelay];
		[upAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"au1.png"]] delay:animationDelay];
		[upAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"iu.png"]] delay:animationDelay];
		upAttackAnimation.type = kAnimationType_Once;
		upAttackAnimation.state = kAnimationState_Running;
		upAttackAnimation.bounceFrame = 4;
        
        // Down attack animation
        [downAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"ad1.png"]] delay:animationDelay];
		[downAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"ad2.png"]] delay:animationDelay];
		[downAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"ad1.png"]] delay:animationDelay];
		[downAttackAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"ad2.png"]] delay:animationDelay];
		downAttackAnimation.type = kAnimationType_Once;
		downAttackAnimation.state = kAnimationState_Running;
		downAttackAnimation.bounceFrame = 4;
        
        //Need to add sleeping animation
        [sleepAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"s1.png"]] delay:animationDelay];
		[sleepAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"s2.png"]] delay:animationDelay];
		[sleepAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"s3.png"]] delay:animationDelay];
		[sleepAnimation addFrameWithImage:[test imageForKey:[name stringByAppendingString:@"s4.png"]] delay:animationDelay];
		sleepAnimation.type = kAnimationType_PingPong;
		sleepAnimation.state = kAnimationState_Running;
		
        // End of Animation definitions//
        

        // Set the default animation to be facing the right with the selected frame
        // showing the player standing
        currentAnimation = downAnimation;
        [currentAnimation setCurrentFrame:4];
        // Set the players state to alive
        state = kEntityState_Alive;
        // Speed at which the player moves
        playerSpeed = 0.6f;
        maxEnergy = 10;
		// Default player values
        energy = maxEnergy;
 
        target = nil;

        
        
 
        
        self.isEnemy = NO;
        self.isDying = YES;
        // Number of seconds the player stays dead before reappearing
		stayDeadTime = 4;
		deathTimer = 0;
		appearingTimer = 0;
     
        energyDrain = 1;
        attackTimer = 0;
        controlDelta = 0;
        animationDelta = 0;
        timeAlive = 0;
        attackDelta = 0;
        regenDelta = 0;
    }
    return self;
    
}

#pragma mark -
#pragma mark Update

- (void)updateWithDelta:(GLfloat)aDelta scene:(GameScene*)aScene {

    

    if(attackDelta > 0)
        attackDelta -= aDelta;
    timeAlive += aDelta;
    

    // Check the state of the player and update them accordingly
    switch (state) {
        

        case kEntityState_Attack:
            if(attackDelta <= 0) {
                state = kEntityState_Alive;
            }
            speedOfMovement *= .0;

            [self updateLocationWithDelta:aDelta];
            break;
                
        case kEntityState_Defend:
        case kEntityState_Evade:
        
            appearingTimer += aDelta;
            
            if(appearingTimer >= .2) {
                renderSprite = YES;
            }
            if(state == kEntityState_Evade) {
                
                state = kEntityState_Alive;
                break;
            }
            break;

        case kEntityState_Appearing:
		case kEntityState_Alive:
        case kEntityState_Hit:
			

 
            
			// If the player is appearing then update the timers
			if (state == kEntityState_Appearing || state == kEntityState_Hit) {
				appearingTimer += aDelta;

				// If the player has been appearing for more than 2 seconds then set their
				// state to alive
				if (appearingTimer >= .1) {
					state = previousState;
					appearingTimer = 0;
				}

				//  The player sprite will only be rendered if the renderSprite flag is YES. This
				// allows us to make the player blink when appearing
				blinkTimer += aDelta;
				if (blinkTimer >= 0.01) {
					renderSprite = (renderSprite == YES) ? NO : YES;
					blinkTimer = 0;
				}
                state = kEntityState_Alive;
			}

            // Update the players position
        
            [self updateLocationWithDelta:aDelta];
			
			// If the players energy reaches 0 then set their state to
			// dead
			if (energy <= 0) {
				state = kEntityState_Dead;
				
				// Set the energy to 0 else a small amount of energy could be left
				// showing even though the player is dead
				energy = 0;
				
				// Reduce the number of lives the player has.  If the player is then below the minimum number of lives
				// they are dead, for good, so we set the game scene state to game over.
				lives -= 1;
				if (lives < 1) {
					[sharedGameController transitionToSceneWithKey:@"menu"];
				}
				
				// The player has died so play a suitable scream
				//[sharedSoundManager playSoundWithKey:@"scream" location:pixelLocation];
			}
            break;
	
		case kEntityState_Dead:
            timeAlive = 0;
			// The player should stay dead for the time defined in stayDeadTime.  After this time has passed
			// the players state is set back to alive and their energy is reset
			deathTimer += aDelta;
			if (deathTimer >= stayDeadTime) {
				deathTimer = 0;
				state = kEntityState_Appearing;
				energy = maxEnergy;
			}
			break;
        default:
            break;
    }

}

- (void)setState:(uint)aState {
	state = aState;
}

#pragma mark -
#pragma mark Render

- (void)render {

	switch (state) {
		case kEntityState_Alive:
        case kEntityState_Attack:
            [super render];
            [currentAnimation renderAtPointWithFilter:CGPointMake((int)pixelLocation.x, (int)pixelLocation.y) filter:Color4fMake(1, 1, 1, 1)];
            break;

        case kEntityState_Defend:
        case kEntityState_Idle:
        case kEntityState_Lattack:
            [super render];
			[currentAnimation renderCenteredAtPoint:CGPointMake((int)pixelLocation.x, (int)pixelLocation.y)];
			break;
        		
		case kEntityState_Appearing:
			[super render];
			if (renderSprite)
				[currentAnimation renderCenteredAtPoint:CGPointMake((int)pixelLocation.x, (int)pixelLocation.y)];
            break;
        case kEntityState_Evade:
        case kEntityState_Hit:

           [super render];
            
            if (renderSprite)
                [currentAnimation renderCenteredAtPoint:CGPointMake((int)pixelLocation.x, (int) pixelLocation.y)];
			break;
		default:
			break;
	}

}

#pragma mark -
#pragma mark Bounds & Collision

- (CGRect)movementBounds { 
	// Calculate the pixel position and return a CGRect that defines the bounds
	pixelLocation = tileMapPositionToPixelPosition(tileLocation);
	return CGRectMake(pixelLocation.x-8, pixelLocation.y-28, 14, 10); //(x-8, y-28, 14, 10)
    
}

- (CGRect)collisionBounds {
	// Calculate the pixel position and return a CGRect that defines the bounds
	pixelLocation = tileMapPositionToPixelPosition(tileLocation);
	return CGRectMake(pixelLocation.x - 10, pixelLocation.y - 20, 20, 35);
}

- (void)checkForCollisionWithEntity:(AbstractEntity*)aEntity {
	
	if (CGRectIntersectsRect([self collisionBounds], [aEntity collisionBounds])) {
		if ([aEntity isKindOfClass:[EnemyAttack class]]) {
            energy -= 1;
		}
	}
} 

- (void)checkForCollisionWithObject:(AbstractObject*)aObject {
		
	if (CGRectIntersectsRect([self collisionBounds], [aObject collisionBounds])) {
		if ([aObject isKindOfClass:[EnergyObject class]]) {
					energy += aObject.energy;
					if (energy > maxEnergy) {
						energy = maxEnergy;
					}
		}
	}
}


#pragma mark -
#pragma mark Inventory

- (void)placeInInventoryObject:(AbstractObject*)aObject {
    ;
}

- (void)dropInventoryFromSlot:(int)aInventorySlot {

	AbstractObject *invObject = nil;
	

	// Change the properties of invObject so that the object is placed
	// back into the map
	if (invObject) {
		invObject.pixelLocation = pixelLocation;
		invObject.tileLocation = tileLocation;
		invObject.state = kObjectState_Active;
	}

}

#pragma mark -
#pragma mark Encoding

- (id)initWithCoder:(NSCoder *)aDecoder {
	// Initialize the player
	[self initWithTileLocation:CGPointMake(0, 0)];
	
	// Load in the important variables from the decoder
	self.tileLocation = [aDecoder decodeCGPointForKey:@"position"];
	self.angleOfMovement = [aDecoder decodeFloatForKey:@"directionAngle"];
	self.energy = [aDecoder decodeFloatForKey:@"energy"];
	self.lives = [aDecoder decodeFloatForKey:@"lives"];
	
	// Set up the initial pixel position based on the players tile position
	pixelLocation = tileMapPositionToPixelPosition(tileLocation);
	
	// Make sure that the inventory items are rotated correctly.

	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	// Encode the important variables to save the players state
	[aCoder encodeCGPoint:tileLocation forKey:@"position"];
	[aCoder encodeFloat:angleOfMovement forKey:@"directionAngle"];
	[aCoder encodeFloat:energy forKey:@"energy"];
	[aCoder encodeFloat:lives forKey:@"lives"];
}

#pragma mark -
#pragma mark Setters

- (void)setDirectionWithAngle:(float)aAngle speed:(float)aSpeed {
	self.angleOfMovement = aAngle;
	self.speedOfMovement = aSpeed;
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation Player (Private)

- (void)updateLocationWithDelta:(float)aDelta {
  
    controlDelta += aDelta;
    if(controlDelta > (1.0/30.0)) {
	
    // Holds the bounding box verticies in tile map coordinates
	BoundingBoxTileQuad bbtq;
	CGPoint oldPosition = tileLocation;
        
    if (speedOfMovement != 0) {
		// Move the player in the x-axis based on the angle of the joypad
		tileLocation.x -= (aDelta * (playerSpeed * speedOfMovement)) * cosf(angleOfMovement);
		// Check to see if any of the players bounds are in a blocked tile.  If they are
		// then set the x location back to its original location
		CGRect bRect = [self movementBounds];
		bbtq = getTileCoordsForBoundingRect(bRect, CGSizeMake(kTile_Width, kTile_Height));
		if ([scene isBlocked:bbtq.x1 y:bbtq.y1] ||
			[scene isBlocked:bbtq.x2 y:bbtq.y2] ||
			[scene isBlocked:bbtq.x3 y:bbtq.y3] ||
			[scene isBlocked:bbtq.x4 y:bbtq.y4] ||
            [scene isPlayerOnTopOfEnemy]

             ){
			
             tileLocation.x = oldPosition.x;
		}
		
		// Move the player in the y-axis based on the angle of the joypad
		tileLocation.y -= (aDelta * (playerSpeed * speedOfMovement)) * sinf(angleOfMovement);
		
		// Check to see if any of the players bounds are in a blocked tile.  If they are
		// then set the x location back to its original location
		bRect = [self movementBounds];
		bbtq = getTileCoordsForBoundingRect(bRect, CGSizeMake(kTile_Width, kTile_Height));
		if ([scene isBlocked:bbtq.x1 y:bbtq.y1] ||
			[scene isBlocked:bbtq.x2 y:bbtq.y2] ||
			[scene isBlocked:bbtq.x3 y:bbtq.y3] ||
			[scene isBlocked:bbtq.x4 y:bbtq.y4] ||
            [scene isPlayerOnTopOfEnemy]) {
    
            tileLocation.y = oldPosition.y;
		}
		
		// Based on the players current direction angle in radians, decide
		// which is the best animation to be using
        if(state== kEntityState_Alive){
		if (angleOfMovement > 0.785 && angleOfMovement < 2.355) {
			currentAnimation = downAnimation;
            isFacing = kEntityFacing_Down;
		} else if (angleOfMovement < -0.785 && angleOfMovement > -2.355) {
			currentAnimation = upAnimation;
            isFacing = kEntityFacing_Up;
		} else if (angleOfMovement < -2.355 || angleOfMovement > 2.355) {
			currentAnimation = rightAnimation;
            isFacing = kEntityFacing_Right;
		} else  {
			currentAnimation = leftAnimation;
            isFacing = kEntityFacing_Left;
		}

		[currentAnimation setState:kAnimationState_Running];
        [currentAnimation updateWithDelta:controlDelta];
		
		// Set the OpenAL listener position within the sound manager to the location of the player
		[sharedSoundManager setListenerPosition:CGPointMake(pixelLocation.x, pixelLocation.y)];
        }
    }else if(state == kEntityState_Alive){
        if (currentAnimation== downAttackAnimation) {
			currentAnimation = downAnimation;
            isFacing = kEntityFacing_Down;
            
		} else if (currentAnimation == upAttackAnimation) {
			currentAnimation = upAnimation;
            isFacing = kEntityFacing_Up;
        } else if (currentAnimation == rightAttackAnimation) {
			currentAnimation = rightAnimation;
            isFacing = kEntityFacing_Right;
		} else  if(currentAnimation == leftAttackAnimation){
			currentAnimation = leftAnimation;
            isFacing = kEntityFacing_Left;
		}
    
        [currentAnimation setState:kAnimationState_Stopped];
        
        [currentAnimation setCurrentFrame:4];

    }else if(state == kEntityState_Attack){
        if (currentAnimation == downAnimation) {
            
			currentAnimation = downAttackAnimation;
            isFacing = kEntityFacing_Down;
            [currentAnimation setCurrentFrame:0];
		} else if (currentAnimation == upAnimation) {
			currentAnimation = upAttackAnimation;
            isFacing = kEntityFacing_Up;
            [currentAnimation setCurrentFrame:0];
		} else if (currentAnimation == rightAnimation) {
			currentAnimation = rightAttackAnimation;
            isFacing = kEntityFacing_Right;
            [currentAnimation setCurrentFrame:0];
		} else  if(currentAnimation == leftAnimation){
			currentAnimation = leftAttackAnimation;
            isFacing = kEntityFacing_Left;
            [currentAnimation setCurrentFrame:0];
		}
            [currentAnimation setState: kAnimationState_Running];
            [currentAnimation setCurrentFrame:0];
            [currentAnimation updateWithDelta:controlDelta];

    
        }

        controlDelta = 0;
    }
}

- (void)checkForParchment:(AbstractObject*)aObject pickup:(BOOL)aPickup {

	// Check to see if the object just picked up was part of the parchment needed to escape from the
	// castle.  If pickup was YES then and the object was a parchment piece, then we set the approprite
	// parchment variable to YES.  If we were putting it down, then we set the appropriate variable to NO
	if (aPickup) {
		if (aObject.subType == kObjectSubType_ParchmentTop) {
			hasParchmentTop = YES;
		} else if (aObject.subType == kObjectSubType_ParchmentMiddle) {
			hasParchmentMiddle = YES;
		} else if (aObject.subType == kObjectSubType_ParchmentBottom) {
			hasParchmentBottom = YES;
		}
	} else {
		if (aObject.subType == kObjectSubType_ParchmentTop) {
			hasParchmentTop = NO;
		} else if (aObject.subType == kObjectSubType_ParchmentMiddle) {
			hasParchmentMiddle = NO;
		} else if (aObject.subType == kObjectSubType_ParchmentBottom) {
			hasParchmentBottom = NO;
		}
	}
	

}

@end

