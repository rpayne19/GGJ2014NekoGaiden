//
//  GeneralGrave.h


#import "Global.h"
#import "AbstractObject.h"

@class Image;
@class Animation;

@interface MapObject : AbstractObject {

	// Image to be displayed for this object
	Image *image;
	// Animation
	SpriteSheet *spriteSheet;
	Animation *animation;
	
}

// Designated initializer
- (id) initWithTileLocation:(CGPoint)aTileLocaiton type:(int)aType subType:(int)aSubType width:(float)aWidth height:(float)aHeight;
- (id) initWithTileLocation:(CGPoint)aTileLocaiton type:(int)aType subType:(int)aSubType width:(float)aWidth height:(float)aHeight;
@end
