//
//  Textbox.m
//
//  Created by Rob on 8/12/13.
//  Copyright (c) 2013 Robert Payne. All rights reserved.
//

#import "Textbox.h"
#import "GameScene.h"
#import "BitmapFont.h"
#import "SoundManager.h"
#import "Image.h"

@implementation Textbox

@synthesize text;
//@synthesize state;
@synthesize text2;
@synthesize text3;

- (void)dealloc {
	[image release];
    [super dealloc];
}

#pragma mark -
#pragma mark Initialization
- (id)init{
    self = [super init];
    image = [[[Image alloc] initWithImageNamed: @"bluetextbox.png" filter: GL_NEAREST] retain];
    text = [[NSString alloc]init];
    timer = 0;
    textIndex = 1;
    state = kEntityState_Alive;
    smallFont = [[BitmapFont alloc] initWithFontImageNamed:@"zafontv2.png" controlFile:@"zafont" scale:Scale2fMake(1.2f, 1.2f) filter:GL_LINEAR];
    image.scale = Scale2fMake(.1f, .1f);
    textboxSize = .1;
    lifeTimer = 0;
    return self;
    
}
- (id)initWithText:(NSString*)aText {
    self = [super init];
    text = aText;
    
    timer = 0;
    textIndex = 1;
    state = kEntityState_Alive;
    smallFont = [[BitmapFont alloc] initWithFontImageNamed:@"zafontv2.png" controlFile:@"zafont" scale:Scale2fMake(1.2f, 1.2f) filter:GL_LINEAR];
    textboxSize = .1;
    image = [[[Image alloc] initWithImageNamed: @"bluetextbox.png" filter: GL_NEAREST] retain];
    numberOfLines = 1;
    currentLine = 1;

    return self;
}
- (id)initWIthText:(NSString*)aText text2:(NSString*)aText2{
    self = [super init];
    text = aText;
    text2 = aText2;
    timer = 0;
    textIndex = 1;
    state = kEntityState_Alive;
    smallFont = [[BitmapFont alloc] initWithFontImageNamed:@"zafontv2.png" controlFile:@"zafont" scale:Scale2fMake(1.2f, 1.2f) filter:GL_LINEAR];
    textboxSize = .1;
    image = [[[Image alloc] initWithImageNamed: @"bluetextbox.png" filter: GL_NEAREST] retain];
    numberOfLines = 2;
    currentLine = 1;
    return self;
}
- (id)initWithText:(NSString*)aText text2:(NSString*)aText2 text3:(NSString*)aText3{
    self = [super init];
    text = aText;
    text2 = aText2;
    text3 = aText3;
    timer = 0;
    textIndex = 1;
    state = kEntityState_Alive;
    smallFont = [[BitmapFont alloc] initWithFontImageNamed:@"zafontv2.png" controlFile:@"zafont" scale:Scale2fMake(1.2f, 1.2f) filter:GL_LINEAR];
    textboxSize = .1;
    image = [[[Image alloc] initWithImageNamed: @"bluetextbox.png" filter: GL_NEAREST] retain];
    numberOfLines = 3;
    currentLine = 1;
    return self;
}
- (id)initWithTileLocation:(CGPoint)aLocation {
    self = [super init];
    timer = 0;
    textIndex = 1;
    state = kEntityState_Alive;
    image = [[[Image alloc] initWithImageNamed: @"bluetextbox.png" filter: GL_NEAREST] retain];
    smallFont = [[BitmapFont alloc] initWithFontImageNamed:@"zafontv2.png" controlFile:@"zafont" scale:Scale2fMake(1.2f, 1.2f) filter:GL_LINEAR];
    textboxSize = .1;
    image.scale = Scale2fMake(.01f, .01f);
    return self;
}

#pragma mark -
#pragma mark Update


- (void)updateWithDelta:(GLfloat)aDelta scene:(AbstractScene*)aScene {
    if(textboxSize < 1) {
        textboxSize += aDelta * 6;
    
        image.scale = Scale2fMake(textboxSize, textboxSize);
	}
    else if(textboxSize > 1){
        image.scale = Scale2fMake(1, 1);
    }
    timer += aDelta;
    lifeTimer += aDelta;
    NSLog(@"%f  ", timer);
    NSLog(@"%i", textIndex);
    NSLog(@"%i", [text length]);
    switch (state) {
        case kEntityState_Alive:
			
            if(timer > .02f && [text length] > textIndex){
                if(([text length] > textIndex && currentLine == 1) ||
                   ([text2 length] > textIndex && currentLine == 2) ||
                   ([text3 length] > textIndex && currentLine == 3))
                if(textIndex < 42) {
                    textIndex ++;
        //            [sharedSoundManager playSoundWithKey:@"voice1" location:CGPointMake(240, 160)];
                   [sharedSoundManager playSoundWithKey:@"voice2" gain:.08f pitch:2.2f location:CGPointMake(240, 160) shouldLoop:NO];
                }
                if((textIndex == 42 || textIndex == [text length]) && currentLine == 1 && numberOfLines > 1) {
                    currentLine = 2;
                    textIndex = 0;
                }else if((textIndex == 42  || textIndex == [text2 length]) && currentLine == 2 && numberOfLines > 2) {
                    currentLine = 3;
                    textIndex = 0;
                }
                timer = 0;
            }
                
      
            if(lifeTimer >= 3.5){ //was 3.5
                state = kEntityState_Dead;
                scene.isTextBoxTime = NO;
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
        [image renderCenteredAtPoint:CGPointMake(240,279)];
        if(textboxSize >= 1) {
            [super render];
            
            if(currentLine > 1) {
                //output text1 if on another text line
                [smallFont renderStringJustifiedInFrame:CGRectMake(12, 278, 76, 35) justification:BitmapFontJustification_MiddleLeft text:text];
                if(currentLine > 2) {
                    //output text2 if on text3
                    [smallFont renderStringJustifiedInFrame:CGRectMake(12,260,76,35) justification:BitmapFontJustification_MiddleLeft text: text2];
                    //output the current location of text3
                    [smallFont renderStringJustifiedInFrame:CGRectMake(12, 242, 76, 35) justification:BitmapFontJustification_MiddleLeft text:[text3 substringToIndex:textIndex]];

                }else   //output current location on text2
                    [smallFont renderStringJustifiedInFrame:CGRectMake(12, 260, 76, 35) justification:BitmapFontJustification_MiddleLeft text:[text2 substringToIndex:textIndex]];
 
            
        }
        else    //output the current location on text1
            [smallFont renderStringJustifiedInFrame:CGRectMake(12, 278, 76, 35) justification:BitmapFontJustification_MiddleLeft text:[NSString stringWithFormat:[text substringToIndex:textIndex]]];
        }
    }
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


