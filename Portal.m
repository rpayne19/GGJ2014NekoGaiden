//
//  Portal.m


#import "GameController.h"
#import "Portal.h"
#import "GameScene.h"
#import "Player.h"

@implementation Portal

@synthesize locationName;

- (void)dealloc {
	[super dealloc];
}

#pragma mark -
#pragma mark Initialization

- (id)initWithTileLocation:(CGPoint)aLocation beamLocation:(CGPoint)aBeamLocation {
    self = [super init];
	if (self != nil) {
		beamLocation = aBeamLocation;
		tileLocation.x = aLocation.x + 0.5f;
		tileLocation.y = aLocation.y + 0.5f;
		state = kEntityState_Idle;

		// Calculate the pixel coordinates for the portal
		pixelLocation = tileMapPositionToPixelPosition(tileLocation);
		
		// Create a new particle emitter
		//portalParticleEmitter = [[ParticleEmitter alloc] initParticleEmitterWithFile:@"teleport.pex"];
		//portalParticleEmitter.sourcePosition = Vector2fMake(pixelLocation.x, pixelLocation.y);
    }
    return self;
}

#pragma mark -
#pragma mark Updating

#define kMaxPlayerDistance 6.0f

- (void)updateWithDelta:(GLfloat)aDelta scene:(AbstractScene*)aScene {
	
	switch (state) {
		case kEntityState_Alive:
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark Rendering

- (void)render {
		switch (state) {
			case kEntityState_Alive:
				[super render];
				break;
			default:
				break;
		}
}

#pragma mark -
#pragma mark Bounds & Collision

- (CGRect)collisionBounds { 
	// Calculate their location in pixels
	CGRect rect = CGRectMake(pixelLocation.x - 72, pixelLocation.y, 96, 6);
	return rect;
}

- (void)checkForCollisionWithEntity:(AbstractEntity *)aEntity {
	if (CGRectIntersectsRect([self collisionBounds], [aEntity collisionBounds])) {
		if([aEntity isKindOfClass:[Player class]]) {
			[sharedSoundManager playSoundWithKey:@"swoosh" location:CGPointMake(pixelLocation.x, pixelLocation.y)];
            scene.state = kSceneState_TransportingOut;
			scene.locationName = locationName;
			Player *player = (Player*)aEntity;
			player.beamLocation = beamLocation;
            

        }
	}
}

@end
