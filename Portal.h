//
//  Portal.h


#import "AbstractEntity.h"


@interface Portal : AbstractEntity {
	CGPoint beamLocation;						// Location to which the player is beamed on entering the portal
	uint locationName;							// An enum for the name of the floor this portal
												// transports you too
}

@property (nonatomic, assign) uint locationName;

// Creates an instance of the player class with the given tilemap location.  It also takes
// a tile map location as the beam location which specifies the tile map locaiton the
// player will be beamed too.
- (id)initWithTileLocation:(CGPoint)aLocation beamLocation:(CGPoint)aBeamLocation;

@end
