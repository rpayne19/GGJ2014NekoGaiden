//
//  Textbox.h
//
//  Created by Rob on 8/12/13.
//  Copyright (c) 2013 Robert Payne. All rights reserved.
//

#import "AbstractEntity.h"

@class GameScene;
@class GameController;
@class BitmapFont;
@class Image;

@interface Textbox : AbstractEntity {
    
    NSString *text;
    NSString *text2;
    NSString *text3;
    int numberOfLines;
    int currentLine;
    
    BitmapFont *smallFont;
    double lifeTimer;
    double timer;
    double textboxSize;
    
    NSInteger textIndex;
    
    
}
@property(nonatomic, assign) NSString *text;
@property(nonatomic, assign) NSString *text2;
@property(nonatomic, assign) NSString *text3;
//@property(nonatomic, assign) uint state;

- (id)initWithText:(NSString*)aText;
- (id)initWithText:(NSString*)aText text2:(NSString*)aText2;
- (id)initWithText:(NSString*)aText text2:(NSString*)aText2 text3:(NSString*)aText3;

@end
