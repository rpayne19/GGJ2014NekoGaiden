//
//  PlayerAttack.h
//
//  Created by Rob on 8/17/13.
//  Copyright (c) 2013 Robert Payne. All rights reserved.
//


#import "AbstractEntity.h"

@class GameScene;
@class GameController;

@interface PlayerAttack : AbstractEntity {
    
    float scalar;
    float numOfAttacks;		
    float lifeSpanTimer;	// Accumulates the time the axe is alive.  Used as a timer
    float soundDelta;
}

@property (nonatomic, assign) float numOfAttacks;
@property (nonatomic, assign) float scalar;

@end
