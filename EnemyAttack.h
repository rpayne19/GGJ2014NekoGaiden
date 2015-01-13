//
//  EnemyAttack.h
//  Neko Gaiden
//
//  Created by Rob on 1/26/14.
//  Copyright (c) 2014 Robert Payne. All rights reserved.
//

#import "AbstractEntity.h"

@class GameScene;
@class GameController;
@class Enemies;

@interface EnemyAttack : AbstractEntity {
    Enemies *enemy;
    float scalar;
    float numOfAttacks;
    float lifeSpanTimer;	// Accumulates the time the axe is alive.  Used as a timer
    float soundDelta;
}

@property (nonatomic, assign) float numOfAttacks;
@property (nonatomic, assign) float scalar;


@end
