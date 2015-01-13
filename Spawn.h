//
//  Spawn.h
//
//  Created by Robert Payne on 5/18/13.
//  Copyright (c) 2013 Robert Payne. All rights reserved.
//


#import "AbstractEntity.h"
#import "Player.h"


@interface Spawn : AbstractEntity {
    
    float timer;		// Records the amount of time between changes to the doors state
    float spawnTimer;	// Milliseconds that should pass before door state changes
    int spawnState;		// Doors current state
	uint type;			// Type of door
	BOOL alive;		// Is the door locked or not
	int color;			// Color of the door
	int arrayIndex;		// Index of the door in the doors array
    int enemyIndex;
}

@property (nonatomic, assign) BOOL alive;
@property (nonatomic, assign) int spawnState;
@property (nonatomic, assign) int arrayIndex;
@property (nonatomic, assign) int enemyIndex;

// Initialize a door entity with the given location
- (id)initWithTileLocation:(CGPoint)aPoint type:(int)aType arrayIndex:(int)aArrayIndex ;

@end
