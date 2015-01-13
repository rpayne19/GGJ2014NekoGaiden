//
//  Enemies.m
//
//  Created by Robert Payne on 5/16/13.
//  Copyright (c) 2013 Robert Payne. All rights reserved.
//

#import "Enemies.h"
#import "GameScene.h"
#import "GameController.h"
#import "SoundManager.h"
#import "SpriteSheet.h"
#import "Animation.h"
#import "Player.h"
#import "BitmapFont.h"
#import "PackedSpriteSheet.h"
#import "Spawn.h"
#import "PlayerAttack.h"
#import "EnemyAttack.h"

@implementation Enemies


@synthesize isReadyToThrow;
@synthesize index;

#define MOVEMENT_SPEED 1.0f

- (void)dealloc {
    [leftAnimation release];
    [rightAnimation release];
    [upAnimation release];
    [downAnimation release];
    [currentAnimation release];
    [super dealloc];
}

#pragma mark -
#pragma mark Initialization

- (id)initWithTileLocation:(CGPoint)aLocation type:(int)aType spawnPointIndex:(int)anIndex {
    self = [super init];
	if (self != nil) {
        PackedSpriteSheet *pss = [PackedSpriteSheet packedSpriteSheetForImageNamed:@"pkgsprites.png" controlFile:@"pkgsprites" imageFilter:GL_NEAREST];
        
        leftAnimation = [[Animation alloc] init];
        rightAnimation = [[Animation alloc] init];
        downAnimation = [[Animation alloc] init];
		upAnimation = [[Animation alloc] init];
        leftAttackAnimation = [[Animation alloc] init];
        rightAttackAnimation = [[Animation alloc] init];
        downAttackAnimation = [[Animation alloc] init];
		upAttackAnimation = [[Animation alloc] init];
        sleepAnimation = [[Animation alloc]init];
        NSString *name = [NSString alloc];
        index = aType
        ;
        
        if(index >1 && index < 8){
            name = @"f";
        } else if(index == 8){
            name = @"m";
        } else if(index == 9){
            name = @"l";
        } else if(index == 10){
            name = @"t";
        } else if(index == 11){
            name = @"d";
        } else if(index == 12){
            name = @"c";
        }
        if(index == 3){
            name = @"d";
        }
        
        currentAnimation = [[Animation alloc] init];
		float animationDelay = 0.1f;
        // Left animation
		[leftAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"rl1.png"]] delay:animationDelay];
		[leftAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"rl2.png"]] delay:animationDelay];
		[leftAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"rl3.png"]] delay:animationDelay];
		[leftAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"rl1.png"]] delay:animationDelay];
		[leftAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"il.png"]] delay:animationDelay];
		leftAnimation.type = kAnimationType_Repeating;
		leftAnimation.state = kAnimationState_Running;
		leftAnimation.bounceFrame = 4;
        
        // Right animation  //start with mid run > run 1 > mid run > run 3 > standing
		[rightAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"rr1.png"]] delay:animationDelay];
		[rightAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"rr2.png"]] delay:animationDelay];
		[rightAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"rr3.png"]] delay:animationDelay];
		[rightAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"rr1.png"]] delay:animationDelay];
		[rightAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"ir.png"]] delay:animationDelay];
		rightAnimation.type = kAnimationType_Repeating;
		rightAnimation.state = kAnimationState_Running;
		rightAnimation.bounceFrame = 4;
        
        // Down animation
		[downAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"rd1.png"]] delay:animationDelay];
		[downAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"rd2.png"]] delay:animationDelay];
		[downAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"rd3.png"]] delay:animationDelay];
		[downAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"rd1.png"]] delay:animationDelay];
		[downAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"id.png"]] delay:animationDelay];
		downAnimation.type = kAnimationType_Repeating;
		downAnimation.state = kAnimationState_Running;
		downAnimation.bounceFrame = 4;
        
        // Up animation
		[upAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"ru1.png"]] delay:animationDelay];
		[upAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"ru2.png"]] delay:animationDelay];
		[upAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"ru3.png"]] delay:animationDelay];
		[upAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"ru1.png"]] delay:animationDelay];
		[upAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"iu.png"]] delay:animationDelay];
		upAnimation.type = kAnimationType_Repeating;
		upAnimation.state = kAnimationState_Running;
		upAnimation.bounceFrame = 4;           //not 9 9 0 2
        
        // Right attack animation
        [rightAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"ar1.png"]] delay:animationDelay];
		[rightAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"ar2.png"]] delay:animationDelay];
		[rightAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"ar1.png"]] delay:animationDelay];
		[rightAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"ar2.png"]] delay:animationDelay];
		rightAttackAnimation.type = kAnimationType_Once;
		rightAttackAnimation.state = kAnimationState_Running;
		rightAttackAnimation.bounceFrame = 4;
        
        // Left attack animation
        [leftAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"al1.png"]] delay:animationDelay];
		[leftAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"al2.png"]] delay:animationDelay];
		[leftAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"al1.png"]] delay:animationDelay];
		[leftAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"al2.png"]] delay:animationDelay];
		leftAttackAnimation.type = kAnimationType_Once;
		leftAttackAnimation.state = kAnimationState_Running;
		leftAttackAnimation.bounceFrame = 4;
        
        [upAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"au1.png"]] delay:animationDelay];
		[upAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"iu.png"]] delay:animationDelay];
		[upAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"au1.png"]] delay:animationDelay];
		[upAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"iu.png"]] delay:animationDelay];
		upAttackAnimation.type = kAnimationType_Once;
		upAttackAnimation.state = kAnimationState_Running;
		upAttackAnimation.bounceFrame = 4;
        
        // Down attack animation
        [downAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"ad1.png"]] delay:animationDelay];
		[downAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"ad2.png"]] delay:animationDelay];
		[downAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"ad1.png"]] delay:animationDelay];
		[downAttackAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"ad2.png"]] delay:animationDelay];
		downAttackAnimation.type = kAnimationType_Once;
		downAttackAnimation.state = kAnimationState_Running;
		downAttackAnimation.bounceFrame = 4;
        
        //Need to add sleeping animation
        [sleepAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"s1.png"]] delay:animationDelay];
		[sleepAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"s2.png"]] delay:animationDelay];
		[sleepAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"s3.png"]] delay:animationDelay];
		[sleepAnimation addFrameWithImage:[pss imageForKey:[name stringByAppendingString:@"s4.png"]] delay:animationDelay];
		sleepAnimation.type = kAnimationType_PingPong;
		sleepAnimation.state = kAnimationState_Running;
        

        // Set the actors location to the CGPoint location which was passed in
        tileLocation = aLocation;
        pixelLocation = tileMapPositionToPixelPosition(aLocation);
        spawnPointIndex = anIndex;
        angle = (int)(360 * RANDOM_0_TO_1()) % 360;
        speed =  0* (float)(RANDOM_0_TO_1() * MOVEMENT_SPEED);
        currentAnimation = downAnimation;
        [currentAnimation setState:kAnimationState_Stopped];
        [currentAnimation setCurrentFrame:4];
        maxEnergy = 2;
        energy = maxEnergy;
		state = kEntityState_Alive;
		energyDrain = 1;
        isEnemy = YES;
        patrolDuration = 1;
        patrolDelta = 2;
        isStandingStill = YES;
        attackReadyDelta = 0;
    }
    return self;

}


#pragma mark -
#pragma mark Updating

- (void)updateWithDelta:(GLfloat)aDelta scene:(AbstractScene*)aScene {
   // if(entityAIState != kEntityAIState_Chasing)
   //     entityAIState = kEntityAIState_Roaming;
    
    if(attackReadyDelta > 0)
        attackReadyDelta -= aDelta;
    scene = (GameScene*)aScene;
	int changeDirSpeed;
    spellDamageDelta -= aDelta;

	switch (state) {
        case kEntityState_Attack:
            if(attackReadyDelta < 0){
                state = kEntityState_Alive;
                isStandingStill =YES;
                entityAIState = kEntityAIState_Roaming;
                if (currentAnimation == downAttackAnimation) {
                    currentAnimation = downAnimation;
                } else if (currentAnimation == upAttackAnimation) {
                    currentAnimation = upAnimation;
                } else if (currentAnimation == rightAttackAnimation) {
                    
                    currentAnimation = rightAnimation;
                } else  if(currentAnimation == leftAttackAnimation){
                    currentAnimation = leftAnimation;
                }
                [currentAnimation setState:kAnimationState_Stopped];

                [currentAnimation updateWithDelta:aDelta];

            }
            speed = 0;
            if (currentAnimation == downAnimation) {
                currentAnimation = downAttackAnimation;
                [currentAnimation setCurrentFrame:0];
                [currentAnimation setState: kAnimationState_Running];
            } else if (currentAnimation == upAnimation) {
               currentAnimation = upAttackAnimation;
                [currentAnimation setCurrentFrame:0];
                [currentAnimation setState: kAnimationState_Running];
            } else if (currentAnimation == rightAnimation) {
                
                currentAnimation = rightAttackAnimation;
                [currentAnimation setCurrentFrame:0];
                [currentAnimation setState: kAnimationState_Running];
            } else  if(currentAnimation == leftAnimation){
                currentAnimation = leftAttackAnimation;
                [currentAnimation setCurrentFrame:0];
                [currentAnimation setState: kAnimationState_Running];
            }
            [currentAnimation setState: kAnimationState_Running];
            [currentAnimation updateWithDelta:aDelta];
            
    
            break;
		case kEntityState_Appearing:
			// If the particle count for the appearing emitter is 0 then it has not been started and
			// we can start it now
            energy = maxEnergy;
            appearingTimer+=.05;
            Spawn *temp = [[scene getSpawnPoints] objectAtIndex:spawnPointIndex];
            temp.spawnState = kEntityState_Alive;
			
			
			
				// Check to see if we have exceeded the appearing timer.  If so then set it to inactive,
				// mark the ninja as alive and reset the appearing timer to 0
				if (appearingTimer >= 0.01f) {
					state = kEntityState_Alive;
					appearingTimer = 0;
				}
			
			break;
			
		case kEntityState_Alive:
			timeAlive += aDelta;
			// If there are any particles alive from appearing update them
			CGPoint oldPosition = tileLocation;
            distanceFromPlayer = (fabs(scene.player.tileLocation.x - tileLocation.x) + fabs(scene.player.tileLocation.y - tileLocation.y));
			// If the player is within 5 tiles of the Green Ninja then set its AI state to chasing
			if (distanceFromPlayer <=3) {
            
				entityAIState = kEntityAIState_Chasing;

            
                
            } else if (entityAIState != kEntityAIState_Retreating){

                entityAIState = kEntityAIState_Roaming;
                
			}
            
			if (entityAIState == kEntityAIState_Chasing) {
                speed = 4.5 * MOVEMENT_SPEED;
                float dy = 0;
                float dx = 0;
                if(scene.player.energy > 0) {
                    dx = tileLocation.x - scene.player.tileLocation.x;
                    dy = tileLocation.y - scene.player.tileLocation.y;
                    target = scene.player;
                }
				angle = atan2(dy, dx) - DEGREES_TO_RADIANS(180);
				tileLocation.x += (speed * aDelta) * cos(angle);
				tileLocation.y += (speed * aDelta) * sin(angle);
                if(distanceFromPlayer <= 1){
                    [scene attackPlayerFromEntity:self];
                    attackReadyDelta = 0.8;
                    state = kEntityState_Attack;
                    scene.player.state = kEntityState_Hit;
                    scene.player.energy -=1;
                    [sharedSoundManager playSoundWithKey:@"hit" location:pixelLocation];

                    
                }

			}
			if(entityAIState == kEntityAIState_Retreating){
                speed = .5 * MOVEMENT_SPEED;
                float dx = tileLocation.x - scene.player.tileLocation.x;
                float dy = tileLocation.y - scene.player.tileLocation.y;
                tileLocation.x += (speed * aDelta) * cos(angle);
                tileLocation.y += (speed * aDelta) * sin(angle);
                if(distanceFromPlayer <= 3) {
                    entityAIState = kEntityAIState_Chasing;
                } else if(distanceFromPlayer >9) {
                    entityAIState = kEntityAIState_Roaming;
                }
            }
			if (entityAIState == kEntityAIState_Roaming) {
                if(index == 2){
                    if(isStandingStill && patrolDelta > 0){
                        patrolDelta -= aDelta/3;
                    } else if(isStandingStill){
                        isStandingStill = NO;
                    
                    if(index ==2){
                        if(angle == 180){
                            speed = 4 * MOVEMENT_SPEED;
                            angle = 0;
                        }else if(angle == 0){
                            angle = 180;
                            speed = 4 * MOVEMENT_SPEED;

                            }
                    }
                        
                    if(patrolDelta < 1){
                        patrolDelta +=aDelta;
                        speed = 3 * MOVEMENT_SPEED;

                    } else{
                        speed = 0;
                        isStandingStill = YES;
                    }
                }
                    
                    
                } else if(index == 3){
                    if(isStandingStill && patrolDelta > 0){
                        patrolDelta -= aDelta/3;
                    } else if(isStandingStill){
                        isStandingStill = NO;
                        
                        if(index !=1){
                            if(angle == 90){
                                speed = 4 * MOVEMENT_SPEED;
                                angle = 270;
                            }else if(angle == 270){
                                angle = 90;
                                speed = 4 * MOVEMENT_SPEED;

                            }
                        }
                        
                        if(patrolDelta < 1){
                            patrolDelta +=aDelta;
                            speed = 3 * MOVEMENT_SPEED;
                            
                        } else{
                            speed = 0;
                            isStandingStill = YES;

                        }
                    }
                }
				// Based on the new direction and speed move the ninja.  This also takes into account
				// the fixed time that has been passed in.  We also take a copy of the current
				// position in case we need to back out this move if the way is blocked
				tileLocation.x += (speed * aDelta) * cos(DEGREES_TO_RADIANS(angle));
				tileLocation.y += (speed * aDelta) * sin(DEGREES_TO_RADIANS(angle));
			}
            
			// We have just moved the ninja, so we need to make sure that none of the vertices for its
			// bounding box are in a blocked tile.  First get the bounds for the ninja
			CGRect bRect = [self movementBounds];
			
			// ...and then convert them into tile map coordinates
			BoundingBoxTileQuad bbtq = getTileCoordsForBoundingRect(bRect, CGSizeMake(kTile_Width, kTile_Height));
			
			// ...and then check to see of any of the vertices are in a blocked tile.  If they are then we
			// reverse the ninja by reversing
			if([scene isBlocked:bbtq.x1 y:bbtq.y1] ||
			   [scene isBlocked:bbtq.x2 y:bbtq.y2] ||
			   [scene isBlocked:bbtq.x3 y:bbtq.y3] ||
			   [scene isBlocked:bbtq.x4 y:bbtq.y4] ||
               [scene isPlayerOnTopOfEnemy]) {
				
				// The way is blocked so restore the old position and change the ninjas angle
				// to something in the oposite direction
				tileLocation = oldPosition;
				angle = (int)(angle + 180) * RANDOM_0_TO_1();
			}
			
			// Now that the ninjas logic has been updated we can render the current animation
			// frame
            // Based on the players current direction angle in radians, decide
            // which is the best animation to be using
            
            if (angle > 225 && angle < 315) {
                currentAnimation = downAnimation;
            } else if (angle > 45 && angle < 135) {
                currentAnimation = upAnimation;
            } else if (angle < 45 || angle > 315) {
                currentAnimation = rightAnimation;
            } else  {
                currentAnimation = leftAnimation;
            }
            
            if(speed != 0) {
                [currentAnimation setState:kAnimationState_Running];
                [currentAnimation updateWithDelta:aDelta];
            }else{
                [currentAnimation setState:kAnimationState_Stopped];
                [currentAnimation setCurrentFrame:4];
            }

	 
    

			
			
			break;
			
		case kEntityState_Dying:
            [currentAnimation setState: kAnimationState_Stopped];
            [currentAnimation setCurrentFrame:4];
            state = kEntityState_Dead;
            temp = [[scene getSpawnPoints] objectAtIndex:spawnPointIndex];
            temp.spawnState = kEntityState_Dead;
			
			break;
			
		default:

			break;
	}
	NSLog(@"State: %d", state);
}

#pragma mark -
#pragma mark Rendering

- (void)render {

	switch (state) {

		case kEntityState_Alive:
			[super render];
            NSLog(@"Rendering current animation frame: %d at pos(%f, %f)" , currentAnimation.currentFrame, pixelLocation.x, pixelLocation.y);
			[currentAnimation renderCenteredAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
			break;
		case kEntityState_Dying:
            [currentAnimation renderCenteredAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];
			break;
        case kEntityState_Attack:
            [super render];
            [currentAnimation renderCenteredAtPoint:CGPointMake(pixelLocation.x, pixelLocation.y)];

		default:
			break;
	}
}

#pragma mark -
#pragma mark Bounds & collision

- (CGRect)movementBounds {
	// Calculate the pixel position and return a CGRect that defines the bounds
	if(state == kEntityState_Alive|| state == kEntityState_Attack){
        pixelLocation = tileMapPositionToPixelPosition(tileLocation);
        return CGRectMake(pixelLocation.x - 8, pixelLocation.y - 28, 14, 10);
    }
    return CGRectMake(0,0,0,0);
}

- (CGRect)collisionBounds {
	// Calculate the pixel position and return a CGRect that defines the bounds
	if(state == kEntityState_Alive|| state == kEntityState_Attack){
        pixelLocation = tileMapPositionToPixelPosition(tileLocation);
        return CGRectMake(pixelLocation.x - 10, pixelLocation.y - 20, 20, 35);
    }
    return CGRectMake(0,0,0,0);
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)aEntity {
	if(([aEntity isKindOfClass:[PlayerAttack class]])
       && aEntity.state == kEntityState_Alive && timeAlive > 1) {
		if (CGRectIntersectsRect([self collisionBounds], [aEntity collisionBounds])) {
	//		[sharedSoundManager playSoundWithKey:@"pop" location:CGPointMake(tileLocation.x*kTile_Width, tileLocation.y*kTile_Height)];

            
            if([aEntity isKindOfClass:[PlayerAttack class]]){
                int damage = aEntity.energyDrain;
                energy -= damage;
                [scene reduceNoOfAttacks];
                [sharedSoundManager playSoundWithKey:@"hit" location:CGPointMake(tileLocation.x*kTile_Width, tileLocation.y*kTile_Height)];
            }


            if(energy <= 0) {
                scene.player.target = nil;
                
                experienceValue = 6;
                state = kEntityState_Dying;

                scene.score += 150;
            }
		}
	}
}



@end






















