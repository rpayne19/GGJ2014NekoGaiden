//
//  EnergyCake.m


#import "EnergyObject.h"
#import "PackedSpriteSheet.h"
#import "Image.h"
#import "AbstractEntity.h"
#import "SoundManager.h"
#import "Player.h"

@implementation EnergyObject

- (void)dealloc {
	[image release];
	[super dealloc];
}

- (id) initWithTileLocation:(CGPoint)aTileLocaiton type:(int)aType subType:(int)aSubType {
	self = [super init];
	if (self != nil) {
		type = aType;
		subType = aSubType;

		// Add 0.5 to the tile location so that the object is in the middle of the square
		// as defined in the tile map editor
		tileLocation.x = aTileLocaiton.x + 0.5f;
		tileLocation.y = aTileLocaiton.y + 0.5f;
		pixelLocation = tileMapPositionToPixelPosition(tileLocation);
		
		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"atlas.png" controlFile:@"coordinates" imageFilter:GL_LINEAR];

		switch (subType) {
			case kObjectSubType_Cake:
				image = [[Image alloc] initWithImageNamed:@"wetfood.png" filter:GL_NEAREST];
				energy = 14;
				break;
				

			default:
				break;
		}
	}
	return self;
}

- (void)updateWithDelta:(float)aDelta scene:(AbstractScene *)aScene {
	
    ;
}

- (void)render {
	// Only render the object if its state is active
	if (state == kObjectState_Active) {
		[image renderCenteredAtPoint:pixelLocation];
	}
	[super render];
}

- (void)checkForCollisionWithEntity:(AbstractEntity*)aEntity {

	// Only bother to check for collisions if the entity passed in is the player
	if ([aEntity isKindOfClass:[Player class]]) {

		if (CGRectIntersectsRect([self collisionBounds], [aEntity collisionBounds])) {
			// If we have collided with the player then set the state of the object to inactive
			// and plat the eatfood sound
			state = kObjectState_Inactive;
			
			// Play the sound to signify that the player has gained energy
            [sharedSoundManager playSoundWithKey:@"powerup" location:pixelLocation];

		}
	}
}

- (CGRect)collisionBounds { 
	return CGRectMake(pixelLocation.x - 10, pixelLocation.y - 10, 20, 20);
}

@end
