//
//  EnemyAttack.m
//  Neko Gaiden
//
//  Created by Rob on 1/26/14.
//  Copyright (c) 2014 Robert Payne. All rights reserved.
//

#import "EnemyAttack.h"
#import "GameScene.h"
#import "GameController.h"
#import "SoundManager.h"
#import "Image.h"
#import "Player.h"
#import "PackedSpriteSheet.h"
#import "Enemies.h"


@implementation EnemyAttack

@synthesize numOfAttacks;
@synthesize scalar;
- (void)dealloc {
	[image release];
    [super dealloc];
}

#pragma mark -
#pragma mark Initialization

- (id)initWithTileLocation:(CGPoint)aLocation{
    self = [super init];
	if (self != nil) {
        scalar = 1;

   
        // Set the actors location to the vector location which was passed in
        tileLocation.x = aLocation.x;
        tileLocation.y = aLocation.y;
        numOfAttacks = 2;
        
        lifeSpanTimer = 0;
        
        // Set the default direction of the player
        energyDrain = 1;
        soundDelta = 0;
        // Set the entitu state to idle when it is created
        state = kEntityState_Idle;
    }
    return self;
}

#pragma mark -
#pragma mark Update

#define SWORD_LIFE_SPAN .8f

- (void)updateWithDelta:(GLfloat)aDelta entity:(Enemies*)enemy {
    
	// Record the current position of the axe
	lifeSpanTimer += aDelta;
    soundDelta -= aDelta;
    
    if(lifeSpanTimer >= .1f && lifeSpanTimer <= .4f && numOfAttacks == 2) {
        state = kEntityState_Alive;
        if(soundDelta <= 0){
            [sharedSoundManager playSoundWithKey:@"katanaSwing" gain:.5f pitch:.6f location:CGPointMake(pixelLocation.x, pixelLocation.y) shouldLoop:NO];
            soundDelta = .5f;
        }
    } else if(lifeSpanTimer >= .5f && lifeSpanTimer <= .8f && (numOfAttacks == 2 || numOfAttacks == 1)){
        state = kEntityState_Alive;
        if(soundDelta <= 0){
            [sharedSoundManager playSoundWithKey:@"katanaSwing" gain:.4f pitch:.6f location:CGPointMake(pixelLocation.x, pixelLocation.y) shouldLoop:NO];
            soundDelta = .5f;
        }
    }
    else{
        state = kEntityState_Defend; //just to set it to something other than alive
    }
    
    
    switch (state) {
        case kEntityState_Alive:
			// Take a copy of the current location so that we can move the axe back to this
			// location if there is a collision
            
            ;
            // Grab the scene that has been passed in
            energyDrain = 1;
            pixelLocation = enemy.pixelLocation;
			
            // Update the timer and rotate the axe image
            
            
            // If the timer exceeds the defined time then set the entity state
            // to idle
            if(lifeSpanTimer > SWORD_LIFE_SPAN) {
                state = kEntityState_Idle;
                tileLocation = CGPointMake(0, 0);
                lifeSpanTimer = 0;
            }
			
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark Rendering

- (void)render {
    if(state == kEntityState_Alive) {
		[super render];
	}
    
}

#pragma mark -
#pragma mark Collision & Bounding

- (CGRect)collisionBounds {
	if(scene.player.isFacing == kEntityFacing_Down && self.state == kEntityState_Alive){
        return CGRectMake(pixelLocation.x- 8, pixelLocation.y -43, 18, 18);
        
    }
    if(scene.player.isFacing == kEntityFacing_Up && self.state == kEntityState_Alive){
        
        return CGRectMake(pixelLocation.x-8, pixelLocation.y, 18, 18);
    }
    if(scene.player.isFacing == kEntityFacing_Right && self.state == kEntityState_Alive){
        
        return CGRectMake(pixelLocation.x +8, pixelLocation.y -15, 18, 18);
    }
    if(scene.player.isFacing == kEntityFacing_Left && self.state == kEntityState_Alive){
        
        return CGRectMake(pixelLocation.x -22, pixelLocation.y-15, 18, 18); //x+8 , y-15
    }
    return CGRectMake(0,0,0,0);
}

- (CGRect)movementBounds {
	return CGRectMake(0, 0, 0, 0);
}

#pragma mark -
#pragma mark Encoding

- (id)initWithCoder:(NSCoder *)aDecoder {
	[self initWithTileLocation:CGPointMake(0, 0)];
	tileLocation = [aDecoder decodeCGPointForKey:@"position"];
	lifeSpanTimer = [aDecoder decodeFloatForKey:@"lifeSpanTimer"];
	state = [aDecoder decodeIntForKey:@"state"];
    
	// Calculate the pixel position of the weapon
	pixelLocation.x = tileLocation.x * kTile_Width;
	pixelLocation.y = tileLocation.y * kTile_Height;
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeCGPoint:tileLocation forKey:@"position"];
	[aCoder encodeFloat:lifeSpanTimer forKey:@"lifeSpanTimer"];
	[aCoder encodeInt:state forKey:@"state"];
	[aCoder encodeFloat:image.rotation forKey:@"imageRotation"];
}

@end
