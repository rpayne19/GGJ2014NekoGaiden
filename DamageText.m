//
//  DamageText.m
//
//  Created by Rob on 8/13/13.
//  Copyright (c) 2013 Robert Payne. All rights reserved.
//

#import "DamageText.h"
#import "GameScene.h"
#import "BitmapFont.h"
#import "Image.h"

@implementation DamageText

@synthesize text;


- (void)dealloc {
	[image release];
    [super dealloc];
}

#pragma mark -
#pragma mark Initialization

- (id)initWithText:(NSString*)aText aLocation:(CGPoint)aLocation{
    self = [super init];
    text = aText;
    location = aLocation;
    timer = 0;
    isEnemy = NO;
    animationTimer = 0;
    textIndex = 1;
    
    state = kEntityState_Alive;
    numberFont = [[BitmapFont alloc] initWithFontImageNamed:@"smallDigits.png" controlFile:@"smallDigit" scale:Scale2fMake(1.0f, 1.0f) filter:GL_LINEAR];
    
    return self;
}

- (void)initHealingWithText:(NSString *)aText aLocation:(CGPoint)aLocation{
    self = [super init];
    text = aText;
    location = aLocation;
    timer = 0;
    isEnemy = NO;
    animationTimer = 0;
    textIndex = 1;
    
    state = kEntityState_Alive;
    numberFont = [[BitmapFont alloc] initWithFontImageNamed:@"smallDigits.png" controlFile:@"smallDigitHealing" scale:Scale2fMake(1.0f, 1.0f) filter:GL_LINEAR];
}



#pragma mark -
#pragma mark Update


- (void)updateWithDelta:(GLfloat)aDelta scene:(AbstractScene*)aScene {

    timer += aDelta;

    switch (state) {
        case kEntityState_Alive:

            if(timer > .05f){
                if([text length] > textIndex) {
                    textIndex ++;

                }else{
                    animationTimer += aDelta;
                    
                    if(animationTimer > .3f) {
                        state = kEntityState_Dead;
                    }
                    
                }
                timer = 0;
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
        [numberFont renderStringJustifiedInFrame:CGRectMake(location.x - 15, location.y + (animationTimer * 100) - 35, 25, 35) justification:BitmapFontJustification_MiddleRight text:[text substringToIndex:textIndex]];
        
    }
}

-(BOOL)isAlive{
    if(state == kEntityState_Alive)
        return YES;
    else
        return NO;
}



#pragma mark -
#pragma mark Encoding

- (id)initWithCoder:(NSCoder *)aDecoder {
	state = [aDecoder decodeIntForKey:@"state"];
    
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeInt:state forKey:@"state"];
}

@end


