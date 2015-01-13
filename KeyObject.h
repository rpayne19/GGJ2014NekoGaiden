//
//  KeyBlue.h


#import "Global.h"
#import "AbstractObject.h"

@class Image;

@interface KeyObject : AbstractObject {

	// Image to be displayed for this object
	Image *image;
	
}

// Designated initializer
- (id) initWithTileLocation:(CGPoint)aTileLocaiton type:(int)aType subType:(int)aSubType;

@end
