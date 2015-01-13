//
//  Enemies.h
//
//  Created by Robert Payne on 5/16/13.
//  Copyright (c) 2013 Robert Payne. All rights reserved.
//


#import "AbstractEntity.h"

@class EnemyAttack;


@interface Enemies : AbstractEntity {
    Animation *leftAnimation;
    Animation *rightAnimation;
    Animation *downAnimation;
    Animation *upAnimation;
    Animation *rightAttackAnimation;
    Animation *leftAttackAnimation;
    Animation *upAttackAnimation;
    Animation *downAttackAnimation;
    Animation *sleepAnimation;
    Animation *currentAnimation;
    EnemyAttack *myAttack;
    
    BOOL isStandingStill;
    int experienceValue;
    int index;                      //represents the type of enemy
    double spellDamageDelta;
    double patrolDuration;
    double patrolDelta;
    double attackReadyDelta;
    

}

@property(nonatomic, assign) BOOL isReadyToThrow;
@property(nonatomic, retain) AbstractEntity *target;
@property(nonatomic, assign) int index;

- (id)initWithTileLocation:(CGPoint)aLocation type:(int)aType spawnPointIndex:(int)anIndex ;

@end
