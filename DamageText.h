//
//  DamageText.h
//
//  Created by Rob on 8/12/13.
//  Copyright (c) 2013 Robert Payne. All rights reserved.
//

#import "AbstractEntity.h"

@class GameScene;
@class GameController;
@class BitmapFont;
@class Image;

@interface DamageText : AbstractEntity {
    
    NSString *text;


    
    BitmapFont *numberFont;
    double timer;
    double animationTimer;
    CGPoint location;
    
    NSInteger textIndex;
    
    
}
@property(nonatomic, assign) NSString *text;

- (id)initWithText:(NSString*)aText aLocation:(CGPoint)aLocation;
- (BOOL)isAlive;
@end
