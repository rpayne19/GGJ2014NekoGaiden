//
//  AbstractState.m


#import "AbstractScene.h"

@implementation AbstractScene

@synthesize numberOfMonsters;
@synthesize state;
@synthesize alpha;
@synthesize name;
@synthesize mapObjects;
@synthesize isTextBoxTime;

- (void)updateSceneWithDelta:(GLfloat)aDelta {}
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
- (void)touchesCancelled:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {}
//- (void)updateWithAccelerometer:(UIAcceleration*)aAcceleration {}
- (void)transitionToSceneWithKey:(NSString*)aKey {}
- (void)transitionIn {}
- (void)renderScene {}
- (void)saveGameState {}

@end