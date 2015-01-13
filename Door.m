//
//  Door.m


#import "Door.h"
#import "Image.h"
#import "SpriteSheet.h"
#import "GameController.h"
#import "SoundManager.h"
#import "GameScene.h"
#import "PackedSpriteSheet.h"
#import "AbstractObject.h"
#import "TiledMap.h"
#import "Layer.h"

@implementation Door

@synthesize locked;
@synthesize color;
@synthesize doorState;
@synthesize arrayIndex;

- (void)dealloc {
	[super dealloc];
}

- (id)initWithTileLocation:(CGPoint)aPoint type:(int)aType arrayIndex:(int)aArrayIndex {
    self = [super init];
    if(self != nil) {
        
        // Create a packed sprite sheet that contains the door images.
		PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"spritesheet_doors.png" controlFile:@"doorCoords" imageFilter:GL_LINEAR];
		
		// By default doors are not locked
		locked = NO;
		
		type = aType;
		arrayIndex = aArrayIndex;
		
		// The file names for doors have been created using a key i.e.
		// direction:color:type:state
		// direction: v = vertical, h = horizontal
		// color: g = green, b = blue, r = red, p = plain
		// state: o = open, c = closed
		// type: c = cave, w = wood, sw = stone to wood, ws = wood to stone
		//
		// vgcc = vertical:green:cave:closed
		switch (type) {
			case kDoorV_CaveGreen:
				openDoor = [pss imageForKey:@"vco.png"];
				closedDoor = [pss imageForKey:@"vgcc.png"];
				locked = YES;
				color = kObjectSubType_GreenKey;
				break;
			case kDoorV_CavePlain:
				openDoor = [pss imageForKey:@"vco.png"];
				closedDoor = [pss imageForKey:@"vpcc.png"];
				break;
			case kDoorV_WoodRed:
				openDoor = [pss imageForKey:@"vwo.png"];
				closedDoor = [pss imageForKey:@"vrwc.png"];
				locked = YES;
				color = kObjectSubType_RedKey;
				break;
			case kDoorV_WoodGreen:
				openDoor = [pss imageForKey:@"vwo.png"];
				closedDoor = [pss imageForKey:@"vgwc.png"];
				color = kObjectSubType_GreenKey;
				locked = YES;
				break;
			case kDoorV_WoodPlain:
				openDoor = [pss imageForKey:@"vwo.png"];
				closedDoor = [pss imageForKey:@"vpwc.png"];
				break;
			case kDoorV_WoodBlue:
				openDoor = [pss imageForKey:@"vco.png"];
				closedDoor = [pss imageForKey:@"vbwc.png"];
				color = kObjectSubType_BlueKey;
				locked = YES;
				break;
			case kDoorV_StoneRed:
				openDoor = [pss imageForKey:@"vso.png"];
				closedDoor = [pss imageForKey:@"vrsc.png"];
				color = kObjectSubType_RedKey;
				locked = YES;
				break;
			case kDoorV_CaveBlue:
				openDoor = [pss imageForKey:@"vco.png"];
				closedDoor = [pss imageForKey:@"vbcc.png"];
				locked = YES;
				color = kObjectSubType_BlueKey;
				break;
			case kDoorV_StoneGreen:
				openDoor = [pss imageForKey:@"vso.png"];
				closedDoor = [pss imageForKey:@"vgsc.png"];
				color = kObjectSubType_GreenKey;
				locked = YES;
				break;
			case kDoorV_StonePlain:
				openDoor = [pss imageForKey:@"vso.png"];
				closedDoor = [pss imageForKey:@"vpsc.png"];
				break;
			case kDoorV_StoneBlue:
				openDoor = [pss imageForKey:@"vso.png"];
				closedDoor = [pss imageForKey:@"vbsc.png"];
				locked = YES;
				color = kObjectSubType_BlueKey;
				break;
			case kDoorV_CaveRed:
				openDoor = [pss imageForKey:@"vco.png"];
				closedDoor = [pss imageForKey:@"vrcc.png"];
				locked = YES;
				color = kObjectSubType_RedKey;
				break;
			case kDoorV_WoodStone:
				openDoor = [pss imageForKey:@"vpwso.png"];
				closedDoor = [pss imageForKey:@"vpwsc.png"];
				break;
			case kDoorV_StoneWood:
				openDoor = [pss imageForKey:@"vpswo.png"];
				closedDoor = [pss imageForKey:@"vpswc.png"];
				break;

				
			case kDoorH_CaveGreen:
				openDoor = [pss imageForKey:@"hco.png"];
				closedDoor = [pss imageForKey:@"hgcc.png"];
				color = kObjectSubType_GreenKey;
				locked = YES;
				break;
			case KDoorH_CavePlain:
				openDoor = [pss imageForKey:@"hco.png"];
				closedDoor = [pss imageForKey:@"hpcc.png"];
				break;
			case KDoorH_WoodRed:
				openDoor = [pss imageForKey:@"hwo.png"];
				closedDoor = [pss imageForKey:@"hrwc.png"];
				locked = YES;
				color = kObjectSubType_RedKey;
				break;
			case kDoorH_WoodGreen:
				openDoor = [pss imageForKey:@"hwo.png"];
				closedDoor = [pss imageForKey:@"hgwc.png"];
				color = kObjectSubType_GreenKey;
				locked = YES;
				break;
			case kDoorH_WoodPlain:
				openDoor = [pss imageForKey:@"hwo.png"];
				closedDoor = [pss imageForKey:@"hpwc.png"];
				break;
			case kDoorH_WoodBlue:
				openDoor = [pss imageForKey:@"hwo.png"];
				closedDoor = [pss imageForKey:@"hbwc.png"];
				locked = YES;
				color = kObjectSubType_BlueKey;
				break;
			case kDoorH_StoneGreen:
				openDoor = [pss imageForKey:@"hso.png"];
				closedDoor = [pss imageForKey:@"hgsc.png"];
				color = kObjectSubType_GreenKey;
				locked = YES;
				break;
			case kDoorH_StonePlain:
				openDoor = [pss imageForKey:@"hso.png"];
				closedDoor = [pss imageForKey:@"hpsc.png"];
				break;
			case kDoorH_StoneBlue:
				openDoor = [pss imageForKey:@"hso.png"];
				closedDoor = [pss imageForKey:@"hbsc.png"];
				color = kObjectSubType_BlueKey;
				locked = YES;
				break;
			case kDoorH_CaveRed:
				openDoor = [pss imageForKey:@"hco.png"];
				closedDoor = [pss imageForKey:@"hrcc.png"];
				locked = YES;
				color = kObjectSubType_RedKey;
				break;
			case kDoorH_CaveBlue:
				openDoor = [pss imageForKey:@"hco.png"];
				closedDoor = [pss imageForKey:@"hbcc.png"];
				locked = YES;
				color = kObjectSubType_BlueKey;
				break;
			case kDoorH_StoneRed:
				openDoor = [pss imageForKey:@"hso.png"];
				closedDoor = [pss imageForKey:@"hrsc.png"];
				locked = YES;
				color = kObjectSubType_RedKey;
				break;
			case kDoorH_WoodStone:
				openDoor = [pss imageForKey:@"hpwso.png"];
				closedDoor = [pss imageForKey:@"hpwsc.png"];
				break;
			case kDoorH_StoneWood:
				openDoor = [pss imageForKey:@"hpswo.png"];
				closedDoor = [pss imageForKey:@"hpswc.png"];
				break;				
			default:
				break;
		}
		
		// All door objects on the tile map are rendered at their center.  We therefore need to add 0.5 to
		// the tile location for this door so it can also be rendered at its center.
		tileLocation.x = aPoint.x;
		tileLocation.y = aPoint.y;
		
		// Calculate the doors pixel location
		pixelLocation = tileMapPositionToPixelPosition(tileLocation);

		// If the door has been marked as locked then set its initial state to closed and also mark
		// the tile it occupies as blocked
		GameScene *gameScene = (GameScene*)sharedGameController.currentScene;
		if (locked) {
			doorState = kDoorState_Closed;
			[gameScene setBlocked:tileLocation.x y:tileLocation.y blocked:YES];
		} else {
			// Pick a random door timer in seconds between 0 and 5
			doorTimer = 4 * RANDOM_0_TO_1() + 1;
			timer = 0;
		}
		
		// Update the games tilemap collision layer for this doors tile with the index number of this
		// door in the doors array
		Layer *collisionLayer = [gameScene.sceneTileMap.layers objectAtIndex:2];
		[collisionLayer setValueAtTile:CGPointMake(tileLocation.x, tileLocation.y) value:arrayIndex];
    }
    return self;
}

- (void)updateWithDelta:(float)aDelta scene:(GameScene*)aScene {
    

#pragma mark Random door
    // If the door is not a locked door then we are going to randomly open it
	if (!locked) {

		// Update the timer with |aDelta|
		timer += aDelta;
		
		// If the timer is now greater than the time defined for this door change the doors state
		if(timer > doorTimer) {

			// Reset the door timer
			timer = 0;

			// Switch the state of the door, but only if the player or the axe are not in the door
			if(![[aScene player] isEntityInTileAtCoords:CGPointMake(tileLocation.x, tileLocation.y)] && 
			   ![aScene isEntityInTileAtCoords:CGPointMake(tileLocation.x, tileLocation.y)]) {
				
				// Based on the doors current state, set its new state i.e. if the door is open close it
				doorState = (doorState == kDoorState_Open) ? kDoorState_Closed : kDoorState_Open;
			
				// To keep things interesting, change door timer to another random
				// value between 0 and 5...
				doorTimer = 4 * RANDOM_0_TO_1() + 1;
			
				// Update the blocked status of the doors tile
				[aScene setBlocked:tileLocation.x y:tileLocation.y blocked:doorState];

			}
		}
	} else {
#pragma mark Locked door
		// Check to see if the player has hit the bounds of the locked door
		if (CGRectIntersectsRect([self collisionBounds], [aScene.player movementBounds]) && doorState == kDoorState_Closed) {
			
            ;
	//			[sharedSoundManager playSoundWithKey:@"doorOpen" location:CGPointMake(tileLocation.x * kTile_Width, tileLocation.y * kTile_Height)];
			
		}
	}
}

- (void)render {
	[super render];
    // Only render the door if its state is closed
	if(doorState == kDoorState_Closed) {
		[closedDoor renderAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
	} else {
		[openDoor renderAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
	}
}

- (CGRect)collisionBounds {
	return CGRectMake(pixelLocation.x - 10, pixelLocation.y - 10, 60, 60);
}

#pragma mark -
#pragma mark Getters/Setters

- (void)setDoorState:(int)aState {
	doorState = aState;
	GameScene *gameScene = (GameScene*)sharedGameController.currentScene;
	[gameScene setBlocked:tileLocation.x y:tileLocation.y blocked:aState];
}

#pragma mark -
#pragma mark Encoding

- (id)initWithCoder:(NSCoder *)aDecoder {
	[self initWithTileLocation:[aDecoder decodeCGPointForKey:@"tileLocation"] type:[aDecoder decodeIntForKey:@"type"]
					arrayIndex:[aDecoder decodeIntForKey:@"arrayIndex"]];
	timer = [aDecoder decodeFloatForKey:@"timer"];
	self.doorState = [aDecoder decodeIntForKey:@"doorState"];
	color = [aDecoder decodeIntForKey:@"color"];
	arrayIndex = [aDecoder decodeIntForKey:@"arrayIndex"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

	// Subtract half a tile from the doors location so that the addition of half a tile
	// when we create a door that has been saved, we don't double up
	[aCoder encodeCGPoint:tileLocation forKey:@"tileLocation"];
	[aCoder encodeFloat:timer forKey:@"timer"];
	[aCoder encodeInt:doorState forKey:@"doorState"];
	[aCoder encodeInt:type forKey:@"type"];
	[aCoder encodeInt:color forKey:@"color"];
	[aCoder encodeInt:arrayIndex forKey:@"arrayIndex"];
}

@end
