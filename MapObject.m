//
//  MapObject.m


#import "MapObject.h"
#import "PackedSpriteSheet.h"
#import "Image.h"
#import "Animation.h"
#import "SpriteSheet.h"
#import "Player.h"
#import "GameScene.h"

@implementation MapObject



- (void)dealloc {
    [animation release];
    [super dealloc];
}

- (id) initWithTileLocation:(CGPoint)aTileLocaiton type:(int)aType subType:(int)aSubType {
    self = [super init];
    if (self != nil) {
		
		// Add 0.5 to the tile location so that the object is in the middle of the square
		// as defined in the tile map editor
		tileLocation.x = aTileLocaiton.x;
		tileLocation.y = aTileLocaiton.y;
        pixelLocation = tileMapPositionToPixelPosition(tileLocation);
        type = aType;
		subType = aSubType;
        
        NSLog(@"Initialized Object type: %i subType %i ***init CGPoint, int, int ただしでわありません", type, subType);
        
        PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"atlas.png" controlFile:@"coordinates" imageFilter:GL_NEAREST];
        
        
        // Use the objects subtype to work out which image or sprite sheet is needed from the packed sprite sheet
		switch (subType) {
			case kObjectSubType_Grave:
			{
				image = [[pss imageForKey:@"object_tombstone.png"] retain];
				spriteSheet = [SpriteSheet spriteSheetForImage:image sheetKey:@"object_tombstone.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];
				break;
			}
				
			case kObjectSubType_TopLamp:
			{
				image = [[pss imageForKey:@"object_torch_top.png"] retain];
				spriteSheet = [SpriteSheet spriteSheetForImage:image sheetKey:@"object_torch_top.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];
                
				break;
			}
				
			case kObjectSubType_LeftLamp:
			{
				image = [[pss imageForKey:@"object_torch_left.png"] retain];
				spriteSheet = [SpriteSheet spriteSheetForImage:image sheetKey:@"object_torch_left.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];
				
				break;
			}
                
			case kObjectSubType_BottomLamp:
			{
				image = [[pss imageForKey:@"object_torch.png"] retain];
				spriteSheet = [SpriteSheet spriteSheetForImage:image sheetKey:@"object_torch.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];
				
				break;
			}
                
			case kObjectSubType_RightLamp:
			{
				image = [[pss imageForKey:@"object_torch_right.png"] retain];
				spriteSheet = [SpriteSheet spriteSheetForImage:image sheetKey:@"object_torch_right.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];
				
				break;
			}
				
			case kObjectSubType_Skull:
			{
				image = [[pss imageForKey:@"item_skull.png"] retain];
				break;
			}
				
			case kObjectSubType_Mushroom:
			{
				image = [[pss imageForKey:@"item_mushroom.png"] retain];
				break;
			}
            case kObjectSubType_Tree:
            {
                
                image = [[[Image alloc] initWithImageNamed: @"tree.png" filter: GL_NEAREST] retain];
                break;
            }
                
			default:
				break;
		}
		
		// Using the images defined above, create any necessary animation
		switch (subType) {
			case kObjectSubType_Grave:
			{
				animation = [[Animation alloc] init];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:0.75];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:0.75];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:0.75];
				animation.state = kAnimationState_Running;
				animation.type = kAnimationType_Once;
				break;
			}
				
			case kObjectSubType_LeftLamp:
			case kObjectSubType_RightLamp:
			{
				animation = [[Animation alloc] init];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 1)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 2)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 1)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 2)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 2)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 1)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 2)] delay:0.06];
				animation.type = kAnimationType_PingPong;
				animation.state = kAnimationState_Running;
				break;
                
			}
				
			case kObjectSubType_TopLamp:
			case kObjectSubType_BottomLamp:
			{
				animation = [[Animation alloc] init];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:0.06];
				animation.type = kAnimationType_PingPong;
				animation.state = kAnimationState_Running;
				break;
			}
                
			default:
				break;
		}
    }
    return self;
}
- (id) initWithTileLocation:(CGPoint)aTileLocaiton type:(int)aType subType:(int)aSubType width:(float)aWidth height:(float)aHeight {
    self = [super init];
    if (self != nil) {
		
		// Add 0.5 to the tile location so that the object is in the middle of the square
		// as defined in the tile map editor
		tileLocation.x = aTileLocaiton.x + .5;
		tileLocation.y = aTileLocaiton.y + .5;
        pixelLocation = tileMapPositionToPixelPosition(tileLocation);
        type = aType;
		subType = aSubType;
        width = aWidth;
        height = aHeight;
        NSLog(@"Initialized Object type: %i subType %i width: %f height: %f", type, subType, width, height);

        PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"atlas.png" controlFile:@"coordinates" imageFilter:GL_NEAREST];


        // Use the objects subtype to work out which image or sprite sheet is needed from the packed sprite sheet
		switch (subType) {
			case kObjectSubType_Grave:
			{
				image = [[pss imageForKey:@"object_tombstone.png"] retain];
				spriteSheet = [SpriteSheet spriteSheetForImage:image sheetKey:@"object_tombstone.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];
				break;
			}
				
			case kObjectSubType_TopLamp:
			{
				image = [[pss imageForKey:@"object_torch_top.png"] retain];
				spriteSheet = [SpriteSheet spriteSheetForImage:image sheetKey:@"object_torch_top.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];

				break;
			}
				
			case kObjectSubType_LeftLamp:
			{
				image = [[pss imageForKey:@"object_torch_left.png"] retain];
				spriteSheet = [SpriteSheet spriteSheetForImage:image sheetKey:@"object_torch_left.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];
				
				break;
			}

			case kObjectSubType_BottomLamp:
			{
				image = [[pss imageForKey:@"object_torch.png"] retain];
				spriteSheet = [SpriteSheet spriteSheetForImage:image sheetKey:@"object_torch.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];
				
				break;
			}

			case kObjectSubType_RightLamp:
			{
				image = [[pss imageForKey:@"object_torch_right.png"] retain];
				spriteSheet = [SpriteSheet spriteSheetForImage:image sheetKey:@"object_torch_right.png" spriteSize:CGSizeMake(40, 40) spacing:0 margin:0];
				
				break;
			}
				
			case kObjectSubType_Skull:
			{
				image = [[pss imageForKey:@"item_skull.png"] retain];
				break;
			}
				
			case kObjectSubType_Mushroom:
			{
				image = [[pss imageForKey:@"item_mushroom.png"] retain];
				break;
			}
            case kObjectSubType_Tree:
            {
                
                image = [[[Image alloc] initWithImageNamed: @"tree.png" filter: GL_NEAREST] retain];
                break;
            }

			default:
				break;
		}
		
		// Using the images defined above, create any necessary animation
		switch (subType) {
			case kObjectSubType_Grave:
			{
				animation = [[Animation alloc] init];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:0.75];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:0.75];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:0.75];
				animation.state = kAnimationState_Running;
				animation.type = kAnimationType_Once;
				break;
			}
				
			case kObjectSubType_LeftLamp:
			case kObjectSubType_RightLamp:
			{
				animation = [[Animation alloc] init];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 1)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 2)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 1)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 2)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 2)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 1)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 2)] delay:0.06];
				animation.type = kAnimationType_PingPong;
				animation.state = kAnimationState_Running;
				break;

			}
				
			case kObjectSubType_TopLamp:
			case kObjectSubType_BottomLamp:
			{
				animation = [[Animation alloc] init];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(0, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(1, 0)] delay:0.06];
				[animation addFrameWithImage:[spriteSheet spriteImageAtCoords:CGPointMake(2, 0)] delay:0.06];
				animation.type = kAnimationType_PingPong;
				animation.state = kAnimationState_Running;
				break;
			}

			default:
				break;
		}
    }
    return self;
}

- (void)updateWithDelta:(float)aDelta scene:(AbstractScene *)aScene {
	switch (subType) {
		case kObjectSubType_Mushroom:
			// Randomly set the mushrooms color.  This will cause the mushroom to pulse
			// different colors
			image.color = Color4fMake(RANDOM_0_TO_1(), RANDOM_0_TO_1(), RANDOM_0_TO_1(), 1.0f);
   //         NSLog(@"width: %f height: %f", width, height);
			break;
		default:
			[animation updateWithDelta:aDelta];
			break;
	}
}

- (void)render {
		switch (subType) {
		case kObjectSubType_Grave:
			[animation renderCenteredAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
			break;
		case kObjectSubType_Mushroom:
        case kObjectSubType_Tree:
            [image renderCenteredAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
			break;
		default:
			[animation renderAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
			break;
            
	}
}

- (CGRect)collisionBounds {
    switch(subType){
        case kObjectSubType_Tree:
            return CGRectMake(pixelLocation.x - (width/2.0f), pixelLocation.y - (height), width-6, height );
        case kObjectSubType_Wall:
            return CGRectMake(pixelLocation.x - (width), pixelLocation.y -(height), width, height);
        default:
            return CGRectMake(0,0,0,0);
    
    }
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)aEntity {

	// If the object is a mushroom then we want to check of the player has collided with it.
	// If they have then the players health is reduced as long as they are touching the mushroom
    
	if (subType == kObjectSubType_Mushroom) {
		if ([aEntity isKindOfClass:[Player class]]) {
			if (CGRectIntersectsRect([self collisionBounds], [aEntity collisionBounds])) {
				GameScene *scene = (GameScene*)sharedGameController.currentScene;
				if (scene.player.state == kEntityState_Alive) {
					scene.player.energy -= 0.5f;
					[sharedSoundManager playSoundWithKey:@"hurt" gain:0.25f pitch:1.0f location:pixelLocation shouldLoop:NO];
				}
			}
		}
	}
}

@end
