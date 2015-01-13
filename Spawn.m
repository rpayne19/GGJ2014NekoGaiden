//
//  Spawn.m
//
//  Created by Robert Payne on 5/18/13.
//  Copyright (c) 2013 Robert Payne. All rights reserved.
//

#import "Spawn.h"
#import "GameController.h"
#import "GameScene.h"
#import "AbstractObject.h"
#import "TiledMap.h"
#import "Layer.h"
#import "Enemies.h"

@implementation Spawn

@synthesize alive;
@synthesize spawnState;
@synthesize arrayIndex;
@synthesize enemyIndex;

- (void)dealloc {
	[super dealloc];
}

- (id)initWithTileLocation:(CGPoint)aPoint type:(int)aType arrayIndex:(int)aArrayIndex{
    self = [super init];
    if(self != nil) {
        		
		// By default doors are not locked
		alive = NO;
		enemyIndex = aType;
		type = aType;
		arrayIndex = aArrayIndex;
		spawnState = kEntityState_Dead;
		
		
		// All door objects on the tile map are rendered at their center.  We therefore need to add 0.5 to
		// the tile location for this door so it can also be rendered at its center.
		tileLocation.x = aPoint.x;
		tileLocation.y = aPoint.y;
    
		// If the door has been marked as locked then set its initial state to closed and also mark
		// the tile it occupies as blocked
		GameScene *gameScene = (GameScene*)sharedGameController.currentScene;
		if (alive) {
			
			[gameScene setBlocked:tileLocation.x y:tileLocation.y blocked:YES];
		} else {
			// set the spawn timer
			spawnTimer = 15;
			timer = 15;
		}

    }
    return self;
}

- (void)updateWithDelta:(float)aDelta scene:(GameScene*)aScene {
    
    
#pragma mark Respawn
 	if (spawnState == kEntityState_Dead) {
        
		// Update the timer with |aDelta|
		timer += aDelta;
		
		// If the timer is now greater than the time defined for this door change the doors state
		if(timer > spawnTimer) {
			[aScene spawnEnemyAtTile:tileLocation Enemy:enemyIndex Index:arrayIndex ];
			
            timer = 0;
            

        }
        
    }
	 
}



#pragma mark -
#pragma mark Getters/Setters

- (void)setSpawnState:(int)aState {
	spawnState = aState;
    
}

#pragma mark -
#pragma mark Encoding

- (id)initWithCoder:(NSCoder *)aDecoder {
	[self initWithTileLocation:[aDecoder decodeCGPointForKey:@"tileLocation"] type:[aDecoder decodeIntForKey:@"type"]
					arrayIndex:[aDecoder decodeIntForKey:@"arrayIndex"]];
	timer = [aDecoder decodeFloatForKey:@"timer"];
	self.spawnState = [aDecoder decodeIntForKey:@"spawnState"];
	arrayIndex = [aDecoder decodeIntForKey:@"arrayIndex"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
	// Subtract half a tile from the doors location so that the addition of half a tile
	// when we create a door that has been saved, we don't double up
	[aCoder encodeCGPoint:tileLocation forKey:@"tileLocation"];
	[aCoder encodeFloat:timer forKey:@"timer"];
	[aCoder encodeInt:spawnState forKey:@"spawnState"];
	[aCoder encodeInt:type forKey:@"type"];
	[aCoder encodeInt:arrayIndex forKey:@"arrayIndex"];
}

@end
