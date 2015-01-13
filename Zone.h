//
//  Zone.h


#import "AbstractEntity.h"


@interface Zone : AbstractEntity {
	CGPoint beamLocation;						// Location to which the player is beamed on entering the portal
	uint locationName;							// An enum for the name of the floor this portal
    // transports you too
    NSString *tilemap;
    NSString *song;
    
}

@property (nonatomic, assign) uint locationName;
@property (nonatomic, retain) NSString *tilemap;
@property (nonatomic, retain) NSString *song;
@property (nonatomic, assign) CGPoint beamLocation;

// Creates an instance of the player class with the given tilemap location.  It also takes
// a tile map location as the beam location which specifies the tile map locaiton the
// player will be beamed too.
- (id)initWithTileLocation:(CGPoint)aLocation beamLocation:(CGPoint)aBeamLocation tileMap:(NSString*)aTileMap music:(NSString*)aSong;

@end
