//
//  KeyBlue.m


#import "KeyObject.h"
#import "PackedSpriteSheet.h"
#import "Image.h"

@implementation KeyObject


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

		// Based on the type of key, set the image for the key
		switch (subType) {
			case kObjectSubType_BlueKey:
				image = [[[pss imageForKey:@"item_keyB.png"] imageDuplicate] retain];
				break;

			case kObjectSubType_RedKey:
				image = [[[pss imageForKey:@"item_keyR.png"] imageDuplicate] retain];
				break;
			
			case kObjectSubType_GreenKey:
				image = [[[pss imageForKey:@"item_keyG.png"] imageDuplicate] retain];
				break;
				
			case kObjectSubType_YellowKey:
				image = [[[pss imageForKey:@"item_key.png"] imageDuplicate] retain];
				break;

			default:
				break;
		}

		// Set the point around which the image will rotate
		image.rotationPoint = CGPointMake(10, 10);
	}
	return self;
}

- (void)updateWithDelta:(float)aDelta scene:(AbstractScene *)aScene {

	switch (state) {
		case kObjectState_Active:
			image.rotation += -180 * aDelta;
			break;

		case kObjectState_Inventory:
			image.rotation = -47;
			break;

		default:
			break;
	}
}

- (void)render {
	if (state == kObjectState_Active || state == kObjectState_Inventory) {
		[image renderCenteredAtPoint:pixelLocation];
	}
	[super render];
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)aEntity {

	if ([aEntity isKindOfClass:[Player class]] && state == kObjectState_Active) {
		if (CGRectIntersectsRect([self collisionBounds], [aEntity collisionBounds])) {
			isCollectable = YES;
		} else {
			isCollectable = NO;
		}
	}
}

- (CGRect)collisionBounds { 
	return CGRectMake(pixelLocation.x - 10, pixelLocation.y - 10, 20, 20);
}

@end
