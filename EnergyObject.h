//
//  EnergyCake.h


#import "Global.h"
#import "AbstractObject.h"

@class Image;

@interface EnergyObject : AbstractObject {

	Image *image;		// Image to be displayed for this object
	BOOL scaleUp;    	// Identifies if the image is scaling up or down

}

// Designated initializer
- (id) initWithTileLocation:(CGPoint)aTileLocaiton type:(int)aType subType:(int)aSubType;

@end
