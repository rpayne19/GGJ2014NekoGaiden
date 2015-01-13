//
//  AbstractObject.m


#import "AbstractObject.h"
#import "AbstractScene.h"
#import "AbstractEntity.h"
#import "SoundManager.h"
#import "Primitives.h"

@implementation AbstractObject

@synthesize tileLocation;
@synthesize pixelLocation;
@synthesize state;
@synthesize type;
@synthesize subType;
@synthesize energy;
@synthesize isCollectable;
@synthesize width;
@synthesize height;

- (void)dealloc {
	[super dealloc];
}

- (id)init {
	self = [super init];
	if (self != nil) {
		sharedSoundManager = [SoundManager sharedSoundManager];
		sharedGameController = [GameController sharedGameController];
	}
    NSLog(@"Init object using generic init... T/S/W/H %i, %i, %f, %f", type, subType, width, height);
	return self;
}		

- (id) initWithTileLocation:(CGPoint)aTileLocaiton type:(int)aType subType:(int)aSubType {
	self = [self init];
    NSLog(@"Initialized Object type: %i subType %i without width/height params", type, subType);
	return self;
}

- (id) initWithTileLocation:(CGPoint)aTileLocation type:(int)aType subType:(int)aSubType width:(float)aWidth height:(float)aHeight {
    
        self = [self init];
    NSLog(@"Initialized Object type: %i subType %i width: %f height: %f", type, subType, width, height);
        return self;

}

- (void)updateWithDelta:(float)aDelta scene:(AbstractScene*)aScene { }

- (void)render { 
// Debug code that allows us to draw bounding boxes for the entity
#ifdef SCB
		glColor4f(.8f, .8f, 0, 1);
		drawRect([self collisionBounds]);
#endif
	
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)aEntity { }


- (CGRect)collisionBounds { 
	return CGRectZero;
}

#pragma mark -
#pragma mark Encoding

- (id)initWithCoder:(NSCoder *)aDecoder {
	[self initWithTileLocation:[aDecoder decodeCGPointForKey:@"tileLocation"]
						  type:[aDecoder decodeIntForKey:@"state"] 
					   subType:[aDecoder decodeIntForKey:@"subType"]];
	pixelLocation = [aDecoder decodeCGPointForKey:@"pixelLocation"];
	state = [aDecoder decodeIntForKey:@"entityState"];
	energy = [aDecoder decodeIntForKey:@"energy"];
	isCollectable = [aDecoder decodeIntForKey:@"isCollectable"];
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {

	[aCoder encodeCGPoint:tileLocation forKey:@"tileLocation"];
	[aCoder encodeCGPoint:pixelLocation forKey:@"pixelLocation"];
	[aCoder encodeInt:state forKey:@"entityState"];
	[aCoder encodeInt:type forKey:@"type"];
	[aCoder encodeInt:subType forKey:@"subType"];
	[aCoder encodeInt:energy forKey:@"energy"];
	[aCoder encodeInt:isCollectable forKey:@"isCollectbale"];

}
@end
