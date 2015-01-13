//
//  GameScene.m
//


#import <QuartzCore/QuartzCore.h>
#import "Global.h"
#import "GameController.h"
#import "ImageRenderManager.h"
#import "GameScene.h"
#import "TextureManager.h"
#import "SoundManager.h"
#import "AbstractEntity.h"
#import "Image.h"
#import "SpriteSheet.h"
#import "Animation.h"
#import "TiledMap.h"
#import "BitmapFont.h"
#import "Player.h"
#import "Door.h"
#import "Spawn.h"
#import "Enemies.h"
#import "Portal.h"
#import "Primitives.h"
#import "PackedSpriteSheet.h"
#import "Layer.h"
#import "EnergyObject.h"
#import "KeyObject.h"
#import "MapObject.h"
#import "Textbox.h"
#import "Primitives.h"
#import "DamageText.h"
#import "PlayerAttack.h"
#import "EnemyAttack.h"
#import "Zone.h"

#pragma mark -
#pragma mark Private interface

@interface GameScene (Private)
// Initialize the sound needed for this scene
- (void)initSound;

// Initialize/reset the game
- (void)initScene;

// Sets up the game from the previously saved game.  If any of the data files are
// missing then the resume will not take place and the initial game state will be
// used instead
- (void)loadGameState;

// Initializes the games state
- (void)initNewGameState;

// Checks the game controller for the joypadPosition value. This is used to decide where the 
// joypad should be rendered i.e. for left or right handed players.
- (void)checkJoypadSettings;

// Initialize the game content e.g. tile map, collision array
- (void)initGameContent;

// Initializes portals defined in the tile map
- (void)initPortals;

// Initializes items defined in the tile map
- (void)initItems;

// Initiaize the doors used in the map
- (void)initCollisionMapAndDoors;

// Initializes the tile map
- (void)initTileMap;

- (void)initNewTileMap:(NSString*) aTilemap song:(NSString*)aSong;

// Initializes the localDoor array before the update loop starts.  This means that doors will be
// rendered correctly when the scene fades in
- (void)initLocalDoors;

// Calculate the players tile map location.  This inforamtion is used when rendering the tile map
// layers in the render method
- (void)calculatePlayersTileMapLocation;

// Make pixel blocks
//- (void)pixelBlockedAtTileX:(int)x TileY:(int)y Shape:(uint) shape;

// Deallocates resources this scene has created
- (void)deallocResources;

@end

#pragma mark -
#pragma mark Public implementation

@implementation GameScene

@synthesize sceneTileMap;
@synthesize player;
@synthesize gameEntities;
@synthesize gameObjects;
@synthesize doors;
@synthesize spawnPoints;
@synthesize gameStartTime;
@synthesize timeSinceGameStarted;
@synthesize score;
@synthesize gameTimeToDisplay;
@synthesize locationName;
@synthesize isAnnika;
@synthesize isSkidd;
@synthesize damageText;
@synthesize playerAttack;
@synthesize nextMap;
@synthesize nextMusic;

- (void)dealloc {
    
    // Remove observers that have been set up
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"hidingSettings" object:nil];

	// Dealloc resources this scene has created
	[self deallocResources];
	
    [super dealloc];
}

- (id)init {
    
    if(self = [super init]) {
        
		// Name of this scene
        self.name = @"game";
		nextMap = nil;
		nextMusic = nil;
        // Grab an instance of our singleton classes
        sharedImageRenderManager = [ImageRenderManager sharedImageRenderManager];
        sharedTextureManager = [TextureManager sharedTextureManager];
        sharedSoundManager = [SoundManager sharedSoundManager];
        sharedGameController = [GameController sharedGameController];
        
        // Grab the bounds of the screen
        screenBounds = [[UIScreen mainScreen] bounds];

        // Set the scenes fade speed which is used when fading the scene in and out and also set
        // the default alpha value for the scene
        fadeSpeed = 1.0f;
        alpha = 0.0f;
		musicVolume = 0.0f;
		isTextBoxTime = NO;
		isMenuScreenTime = NO;

		
		// Add observations on notifications we are interested in.  When the settings view is hidden we
		// want to check to see if the joypad settings have changed.  For this reason we look for this
		// notification
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkJoypadSettings) name:@"hidingSettings" object:nil];
    }
	
    
    return self;
}

- (id)initWithMap:(NSString*)aMap music:(NSString*)aSong location:(CGPoint)aPosition {
    
    if(self = [super init]) {
        
		// Name of this scene
        self.name = @"game";
		nextMap = aMap;
		nextMusic = aSong;
		newPosition = aPosition;
        // Grab an instance of our singleton classes
        sharedImageRenderManager = [ImageRenderManager sharedImageRenderManager];
        sharedTextureManager = [TextureManager sharedTextureManager];
        sharedSoundManager = [SoundManager sharedSoundManager];
        sharedGameController = [GameController sharedGameController];

        // Grab the bounds of the screen
        screenBounds = [[UIScreen mainScreen] bounds];
		
        // Set the scenes fade speed which is used when fading the scene in and out and also set
        // the default alpha value for the scene
        fadeSpeed = 1.0f;
        alpha = 0.0f;
		musicVolume = 0.0f;
		isTextBoxTime = NO;
		isMenuScreenTime = NO;
		//textbox
		textbox = [[Textbox alloc] init];				// Add observations on notifications we are interested in.  When the settings view is hidden we
		textbox.state = kEntityState_Dead;
		// want to check to see if the joypad settings have changed.  For this reason we look for this
		// notification
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkJoypadSettings) name:@"hidingSettings" object:nil];
    }
	
    
    return self;
}

#pragma mark -
#pragma mark Update scene logic

- (void)updateSceneWithDelta:(GLfloat)aDelta {
    
	// Clear the screen before rendering
	glClear(GL_COLOR_BUFFER_BIT);

	switch (state) {
            
        #pragma mark kSceneState_Running
        case kSceneState_Running:
            // Update the game timer if the player is alive
            if (player.state == kEntityState_Alive || player.state == kEntityState_Appearing)
                timeSinceGameStarted += aDelta;

			// Calculate the minutes and seconds that have passed since the game started
            gameSeconds = (int)timeSinceGameStarted % 60;
            gameMinutes = (int)timeSinceGameStarted / 60;
			
            // Release the gameTime string before we create it and retain it.  We retain it to make sure 
            // that it is available even if this code is not run i.e. the game is paused.  The release
            // makes sure we release it and don't leak memory.
            NSString *timeSeconds = [NSString stringWithFormat:@"%02d", gameSeconds];
            NSString *timeMinutes = [NSString stringWithFormat:@"%03d", gameMinutes];
            self.gameTimeToDisplay = [NSString stringWithFormat:@"%@.%@", timeMinutes, timeSeconds] ;
            
            // Update player
            [player updateWithDelta:aDelta scene:self];

            // Now we have updated the player we need to update their position relative to the tile map
            [self calculatePlayersTileMapLocation];
			
			[playerAttack updateWithDelta:aDelta scene:self];

			// Calculate the tile bounds around the player. We clamp the possbile values to between
			// 0 and the width/height of the tile map.  We remove 1 from the width and height
			// as the tile map is zero indexed in the game.  These values can then be used when
			// checking if objects, portals or doors should be updated
			int minScreenTile_x = CLAMP(player.tileLocation.x - 12, 0, kMax_Map_Width-1);
			int maxScreenTile_x = CLAMP(player.tileLocation.x + 12, 0, kMax_Map_Width-1);
			int minScreenTile_y = CLAMP(player.tileLocation.y - 8, 0, kMax_Map_Height-1);
			int maxScreenTile_y = CLAMP(player.tileLocation.y + 8, 0, kMax_Map_Height-1);
			
			// Update the game objects that are inside the bounds calculated above
			isPlayerOverObject = NO;
			
            for(AbstractObject *gameObject in gameObjects) {
              
                if (gameObject.tileLocation.x >= minScreenTile_x && gameObject.tileLocation.x <= maxScreenTile_x &&
                    gameObject.tileLocation.y >= minScreenTile_y && gameObject.tileLocation.y <= maxScreenTile_y) {

                    // Update the object
                    [gameObject updateWithDelta:aDelta scene:self];

                    if (gameObject.state == kObjectState_Active) {
						[player checkForCollisionWithObject:gameObject];
						[gameObject checkForCollisionWithEntity:player];
						if (gameObject.isCollectable) {
							isPlayerOverObject = YES;
						}

						
					
                    }
                }
            }


			if(playerAttack.state == kEntityState_Alive) {
				[playerAttack updateWithDelta:aDelta scene:self];
			
			}
			for(AbstractEntity *attack in enemyProjectiles) {
				[attack updateWithDelta:aDelta scene:self];
				
				if(attack.state == kEntityState_Alive) {
					[player checkForCollisionWithEntity:attack];
				}
			}
			for(AbstractEntity *entity in damageText)
				[entity updateWithDelta:aDelta scene:self];
			
			float distanceFromPlayer;
            for(AbstractEntity *entity in gameEntities) {
				distanceFromPlayer = (fabs(player.tileLocation.x - entity.tileLocation.x) + fabs(player.tileLocation.y - entity.tileLocation.y));
				if(distanceFromPlayer < 24)

				[entity updateWithDelta:aDelta scene:self];
	
				switch (entity.state) {
				
					case kEntityState_Alive:
						// Get the player to see if it has hit the entity and also ask the entity to see if it has
						// hit the player.  Each entity has its own way of resolving a collision so both checks are
						// necessary.
						[player checkForCollisionWithEntity:entity];
						[entity checkForCollisionWithEntity:player];
						if([entity isKindOfClass:[Enemies class]]&& entity.entityAIState == kEntityAIState_Chasing  && ((fabs(player.tileLocation.x - entity.tileLocation.x) + fabs(player.tileLocation.y - entity.tileLocation.y)) < 4 || (fabs(entity.target.tileLocation.x - entity.tileLocation.x) + fabs(entity.tileLocation.y - entity.tileLocation.y)))) {

							;
						}
						// Check to see if the axe has collided with the current entity


						break;
						
					// If the entity is dead then we can revive it somewhere new near the player

					default:
						break;
				}
				if(playerAttack.state == kEntityState_Alive) {
					[entity checkForCollisionWithEntity:playerAttack];
				}
				
			}
				
			// Update portals that are within the visible screen
            for(AbstractEntity *portal in portals) {
				if (portal.tileLocation.x >= minScreenTile_x && portal.tileLocation.x <= maxScreenTile_x &&
                    portal.tileLocation.y >= minScreenTile_y && portal.tileLocation.y <= maxScreenTile_y) {
					[portal updateWithDelta:aDelta scene:self];
					[portal checkForCollisionWithEntity:player];
				}
			}
			for(Zone *zone in zones) {
				if (zone.tileLocation.x >= minScreenTile_x && zone.tileLocation.x <= maxScreenTile_x &&
                    zone.tileLocation.y >= minScreenTile_y && zone.tileLocation.y <= maxScreenTile_y) {
					[zone updateWithDelta:aDelta scene:self];
					if(sharedGameController.nextScene.nextMap != zone.tilemap){
						[sharedGameController setupNextScene:zone.tilemap music:zone.song location:zone.beamLocation];
					}
						[zone checkForCollisionWithEntity:player];
				}
			}
			
            // Populate the localDoors array with any doors that are found around the player.  This allows
            // us to reduce the number of doors we are rendering and updating in any single frame.  We only
			// perform this check if the player has moved from one tile to another on the tile map to save cycles
            if ((int)player.tileLocation.x != (int)playersLastLocation.x || (int)player.tileLocation.y != (int)playersLastLocation.y) {
                
				// Clear the localDoors array as we are about to populate it again based on the 
                // players new position
                [localDoors removeAllObjects];
                
                // Find doors that are close to the player and add them to the localDoors loop.  Layer 3 in the 
				// tile map holds the door information. Updating all doors in the map is a real performance hog
				// so only updating those near the player is necessary
                Layer *layer = [[sceneTileMap layers] objectAtIndex:2];
                for (int yy=minScreenTile_y; yy < maxScreenTile_y; yy++) {
                    for (int xx=minScreenTile_x; xx < maxScreenTile_x; xx++) {
						
                        // If the value property for this tile is not -1 then this must be a door and
                        // we should add it to the localDoors array
                        if ([layer valueAtTile:CGPointMake(xx, yy)] > -1) {
                            int index = [layer valueAtTile:CGPointMake(xx, yy)];
                            [localDoors addObject:[NSNumber numberWithInt:index]];
                        }
                    }
                }
            }
			
			// Update all doors in the localDoors array populated above
            for (int index=0; index < [localDoors count]; index++) {
                Door *door = [doors objectAtIndex:[[localDoors objectAtIndex:index] intValue]];
                [door updateWithDelta:aDelta scene:self];
            }
			for(int i = 0; i < [spawnPoints count]; i++) {
				Spawn *spawn = [spawnPoints objectAtIndex:i];
			
		//	NSLog(@"Index of spawnPoints: (correct) %i, index actually stored in spawn: %i", i, spawn.arrayIndex);
				[spawn updateWithDelta:aDelta scene:self];
				
			//	NSLog(@"Call made to update Spawn point index: %i", i);
			}
				

			
			// Check to see if the player has collided with the exit rectangle.  If so then the game is over and they
			// can go home for a nice cup of tea!!
			if (CGRectIntersectsRect([player movementBounds], exitBounds)) {
				//[sharedSoundManager playSoundWithKey:@"encounter" location: CGPointMake(240,150)];
				//[sharedGameController transitionToSceneWithKey:@"battle"];
			}
			
			// Record the players current position previous position so we can check if the player has
			// moved between updates
            playersLastLocation = player.tileLocation;
			[textbox updateWithDelta:aDelta scene:self];
            
            break;

        #pragma mark kSceneState_TransportingOut
        case kSceneState_TransportingOut:
            alpha += fadeSpeed * aDelta;
            fadeImage.color = Color4fMake(1, 1, 1, alpha);
            if(alpha >= 1.0f) {
                alpha = 1.0f;
                state = kSceneState_TransportingIn;

				// Now we have faded out the scene, set the players new position i.e. the beam location
				// and make the scene transition in
				player.tileLocation = player.beamLocation;
				player.pixelLocation = tileMapPositionToPixelPosition(player.tileLocation);
				
				// Init the doors local to the players new position
				[self initLocalDoors];
            }
            break;

			
        #pragma mark kSceneState_TransportingIn
        case kSceneState_TransportingIn:
            alpha -= fadeSpeed * aDelta;
            fadeImage.color = Color4fMake(1, 1, 1, alpha);

			// Once the scene has faded in, start the scene running and
			// also reset the joypad settings.  This removes any issues with
			// the state of the joypad before the transportation takes place
            if(alpha <= 0.0f) {
                alpha = 0.0f;
                state = kSceneState_Running;
				isJoypadTouchMoving = NO;
				joypadTouchHash = 0;
				player.angleOfMovement = 0;
				player.speedOfMovement = 0;
            }
            break;
		#pragma mark kSceneState_ZoningOut
		case kSceneState_ZoningOut:
			alpha += fadeSpeed * aDelta;
			fadeImage.color = Color4fMake(1,1,1, alpha);
			if(alpha >= 1.0f){
				alpha = 1.0f;
				player.tileLocation = player.beamLocation;
				player.pixelLocation = tileMapPositionToPixelPosition(player.tileLocation);
				isZoning = YES;
				isGameInitialized = NO;
				[sharedGameController switchToNextScene];
				[self calculatePlayersTileMapLocation];
				[self initLocalDoors];
				
				
			}
			break;
		#pragma mark kSceneState_ZoningIn
		case kSceneState_ZoningIn:
			alpha -= fadeSpeed * aDelta;
            fadeImage.color = Color4fMake(1, 1, 1, alpha);
			
			// Once the scene has faded in, start the scene running and
			// also reset the joypad settings.  This removes any issues with
			// the state of the joypad before the transportation takes place
            if(alpha <= 0.0f) {
                alpha = 0.0f;
                state = kSceneState_Running;
				isJoypadTouchMoving = NO;
				joypadTouchHash = 0;
				player.angleOfMovement = 0;
				player.speedOfMovement = 0;
            }
            break;
		
		#pragma mark kSceneState_Loading
		case kSceneState_Loading:
			// If there is a game to resume and the game has not been initialized
            // then use the saved game state to init the game else use the default
            // game state
            if (!isGameInitialized) {
				isGameInitialized = YES;

				// Set the alpha to be used when fading
				alpha = 1.0f;
				
                if(sharedGameController.shouldResumeGame) {
                    [self loadGameState];
                } else {
					[self initNewGameState];
                }
				
				// Setup the joypad based on the current settings
				[self checkJoypadSettings];
            } else if(isZoning){		//not even doing this right now
				NSLog(@"Made it to kSceneState_Loading - isZoning clause");
				isZoning = NO;
				state = kSceneState_TransitionIn;
				alpha = 1.0f;
			}
            
            // Update the alpha for this scene using the scenes fadeSpeed.  We are not actually
			// fading all the elements on the screen.  Instead we are changing the alpha value
			// of a fully black image that is drawn over the entire scene and faded out.  This
			// gives us a nice consistent fade across all objects, including those rendered ontop
			// of other graphics such as objects on the tilemap
            alpha -= fadeSpeed * aDelta;
            fadeImage.color = Color4fMake(1, 1, 1, alpha);
			
            // Once the scene has faded in start playing the background music and set the
			// scene to running
			if(alpha < 0.0f) {
				alpha = 0.0f;
				fadeImage.color = Color4fMake(1, 1, 1, alpha);
				isLoadingScreenVisible = NO;
                state = kSceneState_Running;
				
				// Now the game is running we check to see if it was a resumed game.  If not then we play the spooky
				// voice otherwise we just play the music
				if(sharedGameController.shouldResumeGame) {
					if (!sharedSoundManager.isMusicPlaying && !sharedSoundManager.isExternalAudioPlaying) {
						sharedSoundManager.currentMusicVolume = 0;	// Make sure the music volume is down before playing the music
						[sharedSoundManager playMusicWithKey:@"ingame" timesToRepeat:-1];
						[sharedSoundManager fadeMusicVolumeFrom:0 toVolume:sharedSoundManager.musicVolume duration:0.8f stop:NO];
					}
				} else {
					if (!sharedSoundManager.isMusicPlaying && !sharedSoundManager.isExternalAudioPlaying) {
						sharedSoundManager.loopLastPlaylistTrack = YES;
						sharedSoundManager.currentMusicVolume = sharedSoundManager.musicVolume;
						[sharedSoundManager playMusicWithKey:@"ingame" timesToRepeat:-1];
					}
				}
            }
			break;
			
        #pragma mark kSceneState_TransitionIn
        case kSceneState_TransitionIn:
			if (!isSceneInitialized) {
				isSceneInitialized = YES;
				[self initScene];
				[self initSound];
			}
			
			if (isLoadingScreenVisible) {
				state = kSceneState_Loading;
			}
            break;
			
		#pragma mark kSceneState_TransitionOut
        case kSceneState_TransitionOut:

			if (!isMusicFading) {
				isMusicFading = YES;
				[sharedSoundManager fadeMusicVolumeFrom:sharedSoundManager.musicVolume toVolume:0 duration:0.8f stop:YES];
				alpha = 0;
			}
			
			alpha += fadeSpeed * aDelta;
			fadeImage.color = Color4fMake(1, 1, 1, alpha);
			
            if(alpha > 1.0f) {
                alpha = 1.0f;
                state = kSceneState_Idle;
				
				// Deallocate the resources this scene has created
				[self deallocResources];
				
				// Reset game flags
				isGameInitialized = NO;
				isZoning = NO;
				timeSinceGameStarted = 0;
				score = 0;
				isJoypadTouchMoving = NO;
				isSceneInitialized = NO;
				isLoadingScreenVisible = NO;
				isMusicFading = NO;
				
				// Transition to the menu scene
				[sharedGameController transitionToSceneWithKey:@"menu"];
            }
            break;

		#pragma mark ksceneState_GameOver
		case kSceneState_GameOver:
			if (!isLoseMusicPlaying && !sharedSoundManager.isExternalAudioPlaying) {
				isLoseMusicPlaying = YES;
	//			sharedSoundManager.usePlaylist = YES;
	//			sharedSoundManager.loopLastPlaylistTrack = YES;
	//			[sharedSoundManager startPlaylistNamed:@"lose"];

				// Delete the old gamestate file
				[sharedGameController deleteGameState];

			}
			break;

		#pragma mark kSceneState_GameCompleted
		case kSceneState_GameCompleted:
			if (!isWinMusicPlaying && !sharedSoundManager.isExternalAudioPlaying) {
				isWinMusicPlaying = YES;
	//			sharedSoundManager.usePlaylist = YES;
	//			sharedSoundManager.loopLastPlaylistTrack = YES;
	//			[sharedSoundManager startPlaylistNamed:@"win"];
				
				// Delete the old gamestate file
		//		[sharedGameController deleteGameState];

			}
			break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark Tile map functions

- (BOOL)isBlocked:(float)x y:(float)y {
	// If we are asked for blocking information that is beyond the map border then by default
	// return yes.  When the player is moving near the edge of the map coordinates may be passed
	// that are beyond these bounds
	if (x < 0 || y < 0 || x > kMax_Map_Width || y > kMax_Map_Height) {
		return YES;
	}
	// Return the blocked status of the specified tile
    return blocked[(int)x][(int)y];
}


- (void)setBlocked:(float)aX y:(float)aY blocked:(BOOL)aState {
    blocked[(int)aX][(int)aY] = aState;
}
- (void)reduceNoOfAttacks{
	playerAttack.numOfAttacks -= 1;
}


- (BOOL)isPlayerOnTopOfEnemy {
	BOOL result = NO;
	for(AbstractEntity *entity in gameEntities) {
		if([entity isEnemy])
			if(CGRectIntersectsRect([player movementBounds], [entity movementBounds])){
				result = YES;
				break;
			}


		}
	return result;
}



- (BOOL)isPlayerOnTopOfMapObject {
	BOOL result = NO;
	for(AbstractObject *object in gameObjects){
		if(CGRectIntersectsRect([player movementBounds], [object collisionBounds])) {
//			NSLog(@"Object type: %i", [object subType]);
			result = YES;
			break;
		}
	}
	return result;
}

- (void) spawnEnemyAtTile:(CGPoint)aLocation Enemy:(uint)aType Index:(int) anIndex{

	Spawn *spawn = [spawnPoints objectAtIndex: anIndex];
	if(spawn.spawnState == kEntityState_Alive) {
		NSLog(@"Invalid spawn call for index %i", anIndex);
		
	}
	BOOL found = NO;
	
	 if(1 < aType && 13 > aType) {
		for(Enemies *enemy in gameEntities)
			if(enemy.spawnPointIndex == anIndex){
				enemy.state = kEntityState_Appearing;
				spawn.spawnState = kEntityState_Alive;
				found = YES;
				break;
				
			}
		 if(!found){
			 
			 NSLog(@"Adding enemy to the entities array");
			 Enemies *enemy = [[Enemies alloc] initWithTileLocation:aLocation type:aType spawnPointIndex:anIndex];
		
			 enemy.state = kEntityState_Appearing;
			 [gameEntities addObject:enemy];
			 spawn.spawnState = kEntityState_Alive;
		 }
	}
}

- (void)attackPlayerFromEntity:(Enemies*)anEnemy{
	EnemyAttack* newAttack;
	newAttack = [[EnemyAttack alloc] initWithTileLocation:anEnemy.tileLocation];
	[enemyProjectiles addObject:newAttack];
}



- (BOOL)isEntityInTileAtCoords:(CGPoint)aPoint {
    // By default nothing is at the point provided
    BOOL result = NO;

    // Check to see if any of the entities are in the tile provided
    for(AbstractEntity *entity in gameEntities) {
        if([entity isEntityInTileAtCoords:aPoint]) {
            result = YES;
            break;
        }
    }
    
    // Also check to see if the sword is in the tile provided
	if([playerAttack isEntityInTileAtCoords:aPoint])
		result = YES;
    
    return result;
}

#pragma mark -
#pragma mark Touch events

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
    
    for (UITouch *touch in touches) {
        // Get the point where the player has touched the screen
        CGPoint originalTouchLocation = [touch locationInView:nil];
        [sharedSoundManager playSoundWithKey:@"katana"];
        // As we have the game in landscape mode we need to switch the touches 
        // x and y coordinates
        CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation];
        
		switch (state) {
			case kSceneState_Running:
				if (CGRectContainsPoint(joypadBounds, touchLocation) && !isJoypadTouchMoving && !isMenuScreenTime && textbox.state == kEntityState_Dead) {
					isJoypadTouchMoving = YES;
					joypadTouchHash = [touch hash];
					break;
				}
				
				// Check to see if the jump button was pressed

				// Check to see if the settings button has been pressed
				if (CGRectContainsPoint(settingsBounds, touchLocation)) {
					;
					//menu button
				}

				// Next check to see if the pause/play button has been pressed
				if (CGRectContainsPoint(pauseButtonBounds, touchLocation)) {
					NSLog(@"Attack button");

					if(!isMenuScreenTime){
						if(playerAttack.state != kEntityState_Alive && player.attackDelta <= 0 && player.state == kEntityState_Alive){
							
							[playerAttack initWithTileLocation:CGPointMake(0,0)];
							playerAttack.numOfAttacks = 2;
							player.state = kEntityState_Attack;
							player.attackDelta = .8f;
							playerAttack.state = kEntityState_Alive;
							playerAttack.pixelLocation = player.pixelLocation;

					}
					}
					break;
								   
				}
				//Check for casting button press
				if(CGRectContainsPoint(castingButtonBounds, touchLocation)){
					NSLog(@"Magic button");
					;
				}
				
				break;
				
			case kSceneState_GameCompleted:
			case kSceneState_GameOver:
			{
				// The game is over and we want to get the players name for the score board.  We are going to a UIAlertview
				// to do this for us.  The message which is defined as "anything" cannot be blank else the buttons on the 
				// alertview will overlap the textfield.
				UIAlertView *playersNameAlertView = [[UIAlertView alloc] initWithTitle:@"Enter Your Name" message:@"anything" 
																			  delegate:self cancelButtonTitle:@"Dismiss" 
																	 otherButtonTitles:@"OK", nil];

				// Before iOS 4, it was necessary to move the alert view up manually, so that the keyboard did not cover the
				// alert. With iOS 4, this has been changed and the alert view is moved automatically. The following check
				// is done to only move the alert box if the game is running on an earlier version of iOS.
				NSString *reqSysVer = @"4.0";
				NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
				if ([currSysVer compare:reqSysVer options:NSNumericSearch] == NSOrderedAscending)
				{
					CGAffineTransform transform = CGAffineTransformMakeTranslation(0, 80);
					playersNameAlertView.transform = transform;
				}
				
				// Now we have moved the view we need to create a UITextfield to add to the view
				UITextField *playersNameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12, 35, 260, 20)];

				// We set the background to white and the tag to 99.  This allows us to reference the text field in the alert
				// view later on to get the text that is typed in.  We also set it to becomeFirstResponder so that the keyboard
				// automatically shows
				playersNameTextField.backgroundColor = [UIColor whiteColor];
				playersNameTextField.tag = 99;
				[playersNameTextField becomeFirstResponder];
				
				// Add the textfield to the alert view
				[playersNameAlertView addSubview:playersNameTextField];

				// Show the alert view and then release it and the textfield.  As they are shown a retain is held.  If
				// we do not release then we will leak memory when the view is dismissed.
				[playersNameAlertView show];
				[playersNameAlertView release];
				[playersNameTextField release];
				break;
			}
				
			case kSceneState_Paused:
				// Check to see if the pause/play button has been pressed
				if (CGRectContainsPoint(settingsBounds, touchLocation) && isMenuScreenTime) {
					[sharedSoundManager resumeMusic];
					isMenuScreenTime = NO;
					settingsBounds = CGRectMake(280, 27, 50, 50);
					isJoypadTouchMoving = NO;
                    joypadTouchHash = 0;
                    player.angleOfMovement = 0;
					player.speedOfMovement = 0;
					state = kSceneState_Running;
				}
				break;
			
			default:
				break;
		}
    }
}


- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {

    // Loop through all the touches
	for (UITouch *touch in touches) {
        
		// If the scene is running then check to see if we have a running joypad touch
        if (state == kSceneState_Running) {
            if ([touch hash] == joypadTouchHash && isJoypadTouchMoving) {
                
				// Get the point where the player has touched the screen
                CGPoint originalTouchLocation = [touch locationInView:nil];
                
                // As we have the game in landscape mode we need to switch the touches 
                // x and y coordinates
				CGPoint touchLocation = [sharedGameController adjustTouchOrientationForTouch:originalTouchLocation];
					                
                // Calculate the angle of the touch from the center of the joypad
                float dx = (float)joypadCenter.x - (float)touchLocation.x;
                float dy = (float)joypadCenter.y - (float)touchLocation.y;

				// Calculate the distance from the center of the joypad to the players touch using the manhatten
				// distance algorithm
				float distance = fabs(touchLocation.x - joypadCenter.x) + fabs(touchLocation.y - joypadCenter.y);
				
                // Set the players joypadAngle causing the player to move in that direction
				joyPadAngle = atan2(dy, dx);
                [player setDirectionWithAngle:joyPadAngle speed:CLAMP(distance/4, 0, 8)];


				
            }
        }
    }
}


- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
    
    switch (state) {
        case kSceneState_Running:
            // Loop through the touches checking to see if the joypad touch has finished
            for (UITouch *touch in touches) {
                // If the hash for the joypad has reported that its ended, then set the
                // state as necessary
                if ([touch hash] == joypadTouchHash) {
                    isJoypadTouchMoving = NO;
                    joypadTouchHash = 0;
                    player.angleOfMovement = 0;
					player.speedOfMovement = 0;
                    return;
                }
            }
            break;

        default:
            break;
    }
}

#pragma mark -
#pragma mark Alert View Delegates

- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

	// First off grab a refernce to the textfield on the alert view.  This is done by hunting
	// for tag 99
	UITextField *nameField = (UITextField *)[alertView viewWithTag:99];

	// If the OK button is pressed then set the playersname
	if (buttonIndex == 1) {
		playersName = nameField.text;
		if ([playersName length] == 0)
			playersName = @"No Name Given";

		// Save the games info to the high scores table only if a players name has been entered
		if (playersName) {
			BOOL won = NO;
			if (state == kSceneState_GameCompleted)
				won = YES;
			[sharedGameController addToHighScores:score gameTime:gameTimeToDisplay playersName:playersName didWin:won];
		}
	}
	
	// We must remember to resign the textfield before this method finishes.  If we don't then an error
	// is reported e.g. "wait_fences: failed to receive reply:"
	[nameField resignFirstResponder];

	// Finally set the state to transition out of the scene
	state = kSceneState_TransitionOut;
}

#pragma mark -
#pragma mark Transition

- (void)transitionToSceneWithKey:(NSString*)theKey {
    state = kSceneState_TransitionOut;
}

- (void)transitionIn {
    state = kSceneState_TransitionIn;
	[self initSound];
	player.speedOfMovement = 0;
}

#pragma mark -
#pragma mark Render scene

- (void)renderScene {

	// If we are transitioning into the scene and we have initialized the scene then display the loading
	// screen.  This will be displayed until the rest of the game content has been loaded.
	if (state == kSceneState_TransitionIn && isSceneInitialized) {
		
		[sharedImageRenderManager renderImages];
		isLoadingScreenVisible = YES;
	}
	
	// Only render if the game has been initialized
	if (isGameInitialized) {
		switch (state) {
				
			case kSceneState_Loading:
			case kSceneState_TransitionOut:
			case kSceneState_TransportingOut:
			case kSceneState_TransportingIn:
			case kSceneState_Paused:
			case kSceneState_Running:
			{
				// Clear the screen before rendering
				glClear(GL_COLOR_BUFFER_BIT);
				// Save the current Matrix
				glPushMatrix();
			    
				// Translate the world coordinates so that the player is rendered in the middle of the screen
				//Vertical and Horizontal Scrolling needs to be modified here?
				glTranslatef(240- player.pixelLocation.x, 160 - player.pixelLocation.y, 0);
				
				// Render the Map tilemap layer
				[sceneTileMap renderLayer:0
									  mapx:playerTileX - leftOffsetInTiles - 1
									  mapy:playerTileY - bottomOffsetInTiles - 1 
									 width:screenTilesWide + 2 
									height:screenTilesHeight + 2 
							   useBlending:NO];
				
				// Render the Objects tilemap layer
				[sceneTileMap renderLayer:1 
									  mapx:playerTileX - leftOffsetInTiles - 1 
									  mapy:playerTileY - bottomOffsetInTiles - 1 
									 width:screenTilesWide + 2 
									height:screenTilesHeight + 2 
							   useBlending:NO];
								
				[sharedImageRenderManager renderImages];

				[playerAttack render];
				
			
				for(int i = player.pixelLocation.y + 320; i >= player.pixelLocation.y - 320; i --){

				// Render the game objects
				for(AbstractObject *gameObject in gameObjects) {
					if (gameObject.state == kObjectState_Active && gameObject.pixelLocation.y == i) {
						[gameObject render];
					}
				}
				
				// Render the player
				if(player.pixelLocation.y ==i)
					[player render];

				
				// Render entities
					for(Enemies *entity in gameEntities) {

						if(entity.pixelLocation.y == i) {
							[entity render];

					
						}
					}
					
				}
		
				[sceneTileMap renderLayer:3
									  mapx:playerTileX - leftOffsetInTiles - 1
									  mapy:playerTileY - bottomOffsetInTiles - 1
									 width:screenTilesWide + 2
									height:screenTilesHeight + 2
							   useBlending:NO];
				
				for(AbstractEntity *entity in damageText){
					[entity render];
				}
				 // Render what we have so far so that everything else rendered is drawn over it
				[sharedImageRenderManager renderImages];
				
				// Render the doors onto the map.  The localDoors array holds all doors
				// that have been found to be close to the player during the scenes update

				
				// Pop the old matrix off the stack ready for the next frame.  We need to make sure that the modelview
				// is using the origin 0, 0 again so that the images for the HUD below are rendered in view.
				glPopMatrix();
				
				// Render the torch mask over the scene.  This is done behind the hud and controls
				//[torchMask renderCenteredAtPoint:CGPointMake(240, 160)];
				
				// If we are transporting the player then the fade panel should be drawn under 
				// the HUD
	
				if (state == kSceneState_TransportingIn || state == kSceneState_TransportingOut) {
					[fadeImage renderAtPoint:CGPointMake(0, 0)];
					
					// To make sure that this gets rendered UNDER the following images we need to get the
					// render manager to render what is currently in the queue.
					[sharedImageRenderManager renderImages];
				}
		// Render the hud background

				// Render the joypad

				//                             |||
				//put the number of lives here VVV
				//New UI
				[smallFont renderStringJustifiedInFrame:CGRectMake(50, 286, 21, 8) justification:BitmapFontJustification_MiddleRight text:[NSString stringWithFormat:@"LIFE"]];
				for(float i = 1; i <= player.energy * 6; i+=6)
					[lifebar renderAtPoint:CGPointMake(i + 70, 286)];
				
				[joypad renderCenteredAtPoint:joypadCenter];

				if (state == kSceneState_Running) {
					[pause renderCenteredAtPoint:CGPointMake(386, 50)];
				}

				if (state == kSceneState_Paused) {
					fadeImage.color = Color4fMake(1, 1, 1, 0.55f);
					[fadeImage renderCenteredAtPoint:CGPointMake(240, 160)];

					fadeImage.color = Color4fMake(1, 1, 1, 1);
				}
				
				// We only draw the black overlay when we are fading into or out of this scene
				if (state == kSceneState_Loading || state == kSceneState_TransitionOut) {
					[fadeImage renderAtPoint:CGPointMake(0, 0)];
				}
				if(isTextBoxTime)
					[textbox render];	//render the text box
									
				// Render all queued images at this point
				[sharedImageRenderManager renderImages];

// Debug info
#ifdef SCB

				drawRect(joypadBounds);
				drawRect(settingsBounds);
				drawRect(pauseButtonBounds);
				drawRect(castingButtonBounds);
				
				
#endif
				break;
			}
				
			case kSceneState_GameCompleted:
			{
				// Render the game complete background
				[joypad renderCenteredAtPoint:CGPointMake(240, 160)];
				
				// Render the game stats
				CGRect textRectangle = CGRectMake(55, 42, 216, 160);
				NSString *finalScore = [NSString stringWithFormat:@"%06d", score];
				NSString *scoreStat = [NSString stringWithFormat:@"Final Score: %@", finalScore];
				NSString *timeStat = [NSString stringWithFormat:@"Final Time: %@", gameTimeToDisplay];
				[smallFont renderStringJustifiedInFrame:textRectangle justification:BitmapFontJustification_TopLeft text:scoreStat];
				[smallFont renderStringJustifiedInFrame:textRectangle justification:BitmapFontJustification_MiddleLeft text:timeStat];
				[sharedImageRenderManager renderImages];
				break;
			}

			case kSceneState_GameOver:
			{
				// Render the game over background
				[joypad renderCenteredAtPoint:CGPointMake(240, 160)];
				
				// Render the game stats
				CGRect textRectangle = CGRectMake(55, 42, 216, 150);
				NSString *finalScore = [NSString stringWithFormat:@"%06d", score];
				NSString *scoreStat = [NSString stringWithFormat:@"Final Score: %@", finalScore];
				NSString *timeStat = [NSString stringWithFormat:@"Final Time: %@", gameTimeToDisplay];
				[smallFont renderStringJustifiedInFrame:textRectangle justification:BitmapFontJustification_TopLeft text:scoreStat];
				[smallFont renderStringJustifiedInFrame:textRectangle justification:BitmapFontJustification_MiddleLeft text:timeStat];
				[sharedImageRenderManager renderImages];
				break;
			}
				
			default:
				break;
		}
		
	}
}

#pragma mark -
#pragma mark Save game state

- (void)saveGameState {
	
	SLQLOG(@"INFO - GameScene: Saving game state.");
		
	// Set up the game state path to the data file that the game state will be saved too. 
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *gameStatePath = [documentsDirectory stringByAppendingPathComponent:@"gameState.dat"];
	
	// Set up the encoder and storage for the game state data
	NSMutableData *gameData;
	NSKeyedArchiver *encoder;
	gameData = [NSMutableData data];
	encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:gameData];
	
	// Archive the entities
	[encoder encodeObject:gameEntities forKey:@"gameEntities"];
	
	// Archive the player
	[encoder encodeObject:player forKey:@"player"];
		
	// Archive the games doors
	[encoder encodeObject:doors forKey:@"doors"];
	
	// Archive the game objects
	[encoder encodeObject:gameObjects forKey:@"gameObjects"];
	
	// Archive the games timer settings
	NSNumber *savedGameStartTime = [NSNumber numberWithFloat:gameStartTime];
	NSNumber *savedTimeSinceGameStarted = [NSNumber numberWithFloat:timeSinceGameStarted];
	NSNumber *savedScore = [NSNumber numberWithFloat:score];
	[encoder encodeObject:savedGameStartTime forKey:@"gameStartTime"];
	[encoder encodeObject:savedTimeSinceGameStarted forKey:@"timeSinceGameStarted"];
	[encoder encodeObject:savedScore forKey:@"score"];
	[encoder encodeInt:locationName forKey:@"locationName"];
	
	// Finish encoding and write the contents of gameData to file
	[encoder finishEncoding];
	[gameData writeToFile:gameStatePath atomically:YES];
	[encoder release];
	
	// Tell the game controller that a resumed game is available
	sharedGameController.resumedGameAvailable = YES;
}

@end

#pragma mark -
#pragma mark Private implementation

@implementation GameScene (Private)

#pragma mark -
#pragma mark Initialize new game state

- (void)initNewGameState {

	[self initGameContent];
	
	// Set up the players initial locaiton
	player = [[Player alloc] initWithTileLocation:CGPointMake(13.0f, 506.0f)];
	
	// Set the initial location name
	locationName = kLocationName_GroundFloor;
    
	// Now we have loaded the player we need to set up their position in the tilemap
	[self calculatePlayersTileMapLocation];
        

	playerAttack = [[PlayerAttack alloc] initWithTileLocation:CGPointMake(0,0)];
	
	// Initialize the game items.  This is only done when initializing a new game as
	// this information is loaded when a resumed game is started.
	[self initItems];

	// Init the localDoors array
	[self initLocalDoors];
}

                                    
- (void)loadGameState {
	
	[self initGameContent];

    // Set up the file manager and documents path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSMutableData *gameData;
    NSKeyedUnarchiver *decoder;
    
    // Check to see if the ghosts.dat file exists and if so load the contents into the
    // entities array
    NSString *documentPath = [documentsDirectory stringByAppendingPathComponent:@"gameState.dat"];
    gameData = [NSData dataWithContentsOfFile:documentPath];

    decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:gameData];

    SLQLOG(@"INFO - GameScene: Loading saved player data.");
    player = [[decoder decodeObjectForKey:@"player"] retain];
	[self calculatePlayersTileMapLocation];


	SLQLOG(@"INFO - GameScene: Loading saved entity data.");
	if (gameEntities)
		[gameEntities release];
    gameEntities = [[decoder decodeObjectForKey:@"gameEntities"] retain];

	SLQLOG(@"INFO - GameScene: Loading saved game object data.");
	if (gameObjects)
		[gameObjects release];
	gameObjects = [[decoder decodeObjectForKey:@"gameObjects"] retain];

	SLQLOG(@"INFO - GameScene: Loading saved door data.");
	if (doors)
		[doors release];
    doors = [[decoder decodeObjectForKey:@"doors"] retain];
    
	SLQLOG(@"INFO - GameScene: Loading saved game duration.");
    timeSinceGameStarted = [[decoder decodeObjectForKey:@"timeSinceGameStarted"] floatValue];
	
	SLQLOG(@"INFO - GameScene: Loading saved game score.");
	score = [[decoder decodeObjectForKey:@"score"] floatValue];
	
	SLQLOG(@"INFO - GameScene: Loading location name.");
	locationName = [decoder decodeIntForKey:@"locationName"];
    
    SLQLOG(@"INFO - GameScene: Loading game time data.");

	// We have finishd decoding the objects and retained them so we can now release the
	// decoder object
	[decoder release];

	// Init the localDoors array
	[self initLocalDoors];
}

- (void)initScene {

	// Game objects
	doors = [[NSMutableArray alloc] init];
	spawnPoints = [[NSMutableArray alloc] initWithCapacity:128];
	gameEntities = [[NSMutableArray alloc] initWithCapacity:128];
	portals = [[NSMutableArray alloc] init];
	zones = [[NSMutableArray alloc] init];
	gameObjects = [[NSMutableArray alloc] init];
	localDoors = [[NSMutableArray alloc] init];
	enemyProjectiles = [[NSMutableArray alloc] initWithCapacity:8];
	damageText = [[NSMutableArray alloc] init];

    // Initialize the fonts needed for the game
    smallFont = [[BitmapFont alloc] initWithFontImageNamed:@"font.png" controlFile:@"zafont" scale:Scale2fMake(1.2f, 1.2f) filter:GL_LINEAR];
	digitFont = [[BitmapFont alloc] initWithFontImageNamed:@"smallDigits.png" controlFile:@"smallDigit" scale:Scale2fMake(1.0f, 1.0f) filter:GL_LINEAR];
    

	exitBounds = CGRectMake(6, 100, 80, 40);
	menuScreen = [[Image alloc] initWithImageNamed:@"menuScreenWithPortraits.png" filter:GL_NEAREST];

	jumpButtonBounds = CGRectMake(230, 0, 75, 75);

	// Pause button
	pause = [[Image alloc] initWithImageNamed:@"button.png" filter:GL_NEAREST];
	pause.color = Color4fMake(1, 1, 1, 0.35f);
	pause.scale = Scale2fMake(.5f,.5f);
    pauseButtonBounds = CGRectMake(365, 27, 50, 50);
	castingButtonBounds = CGRectMake(370, 80, 50, 50);
	// Settings button
	settings = [[Image alloc] initWithImageNamed:@"button.png" filter:GL_NEAREST];
	settings.color = Color4fMake(1, 1, 1, 0.35f);
	settings.scale = Scale2fMake(.5f, .5f);
	settingsBounds = CGRectMake(290, 27, 50, 50);
  
    // Overlay used to fade the game scene
    fadeImage = [[Image alloc] initWithImageNamed:@"allBlack.png" filter:GL_NEAREST];
	fadeImage.scale = Scale2fMake(480, 320);
	
	
    // Joypad setup
	joypadCenter = CGPointMake(70, 70);
	joypadRectangleSize = CGSizeMake(40, 40);
	
    lifebar = [[[Image alloc]initWithImageNamed:@"lifetick.png" filter:GL_NEAREST] retain];
    joypad = [[Image alloc] initWithImageNamed: @"gamepad.png" filter: GL_NEAREST];
	joypad.color = Color4fMake(1.0f, 1.0f, 1.0f, 0.25f);
  
	// Set up the game score and timers
	score = 0;
	timeSinceGameStarted = 0;
    gameStartTime = CACurrentMediaTime();
	gameTimeToDisplay = @"000.00";
	
	// Set up flags
	isWinMusicPlaying = NO;
	isLoseMusicPlaying = NO;
		
	playersLastLocation = CGPointMake(0,0);
}

- (void)initGameContent {	//hannabarbera
	// Initialize the scenes tile map
	[self initTileMap];
    [self initCollisionMapAndDoors];
    [self initPortals];	
}




- (void)initSound {
    
    // Set the listener to the middle of the screen by default.  This will be changed as the player moves around the map
    [sharedSoundManager setListenerPosition:CGPointMake(240, 160)];
    // Initialize the sound effects
	[sharedSoundManager loadSoundWithKey:@"encounter" soundFile:@"encount.caf"];
    [sharedSoundManager loadSoundWithKey:@"casting" soundFile:@"Casting.caf"];
    [sharedSoundManager loadSoundWithKey:@"castingDown" soundFile:@"wm2.caf"];		//powup13 .8 .4 sound cool
																						//
    [sharedSoundManager loadSoundWithKey:@"throw" soundFile:@"throw.caf"];
    [sharedSoundManager loadSoundWithKey:@"cure" soundFile:@"LAZER.caf"];	//doesn't work :(
	[sharedSoundManager loadSoundWithKey:@"swoosh" soundFile:@"Swoosh.caf"];
	[sharedSoundManager loadSoundWithKey:@"voice1" soundFile:@"Man voice.caf"];
	[sharedSoundManager loadSoundWithKey:@"voice2" soundFile:@"Man voice B.caf"];
	[sharedSoundManager loadSoundWithKey:@"voice3" soundFile:@"Man voice C.caf"];
	[sharedSoundManager loadSoundWithKey:@"voice4" soundFile:@"Robot voice.caf"];
	[sharedSoundManager loadSoundWithKey:@"voice5" soundFile:@"Lady voice.caf"];
	[sharedSoundManager loadSoundWithKey:@"katana" soundFile:@"fightsound.caf"];
	[sharedSoundManager loadSoundWithKey:@"hit" soundFile:@"punch1.caf"];
	[sharedSoundManager loadSoundWithKey:@"powerup" soundFile:@"powup8.caf"];

	[sharedSoundManager loadSoundWithKey:@"katanaSwing" soundFile:@"katana.caf"];
	[sharedSoundManager loadSoundWithKey:@"gun" soundFile:@"punch1.caf"];
	[sharedSoundManager loadSoundWithKey:@"fireGun" soundFile:@"LAZER.caf"];
    // Initialize the background music
	if(nextMusic != nil){
		[sharedSoundManager stopMusic];
		[sharedSoundManager loadMusicWithKey:@"ingame" musicFile:nextMusic];
	}

	sharedSoundManager.loopLastPlaylistTrack = NO;
}


- (void)checkJoypadSettings {

    // If the joypad is marked as being on the left the set the joypads center left, otherwise,
	// you guessed it, set the joypad center to the right.  This also adjusts the location of
	// the settings button which needs to also be moved
	if (sharedGameController.joypadPosition == 0) {
        joypadCenter.x = 70;

    } else if (sharedGameController.joypadPosition == 1) {
	    joypadCenter.x = 430;
    }
	
	// Calculate the rectangle that we check for touches to know someone has touched the joypad
	joypadBounds = CGRectMake(joypadCenter.x - joypadRectangleSize.width, 
						joypadCenter.y - joypadRectangleSize.height, 
						joypadRectangleSize.width * 2, 
						joypadRectangleSize.height * 2);
}

- (void)initPortals {
    
    // Get the object groups that were found in the tilemap
    NSMutableDictionary *portalObjects = sceneTileMap.objectGroups;

    // Calculate the height of the tilemap in pixels.  We also add an extra tile to the height
    // so that objects pixel location is correct.  This is needed as the tile map has a zero
    // index which means we actually loose a tile when calculating a pixel position within the
    // map
    float tileMapPixelHeight = (kTile_Height * (sceneTileMap.mapHeight -1   ));
    
    // Loop through all objects in the object group called Portals
    NSMutableDictionary *objects = [[portalObjects objectForKey:@"Portals"] objectForKey:@"Objects"];
    for (NSString *objectKey in objects) {
        
        // Get the location of the portal
        float portal_x = [[[[objects objectForKey:objectKey] 
                            objectForKey:@"Attributes"] 
                           objectForKey:@"x"] floatValue] / kTile_Width;
        
        // As the tilemap coordinates have been reversed on the y-axis, we need to also reverse
        // y-axis pixel locaiton for objects.  This is done by subtracting the objects current
        // y value from the full pixel height of the tilemap
        float portal_y = (tileMapPixelHeight - [[[[objects objectForKey:objectKey] 
                                                  objectForKey:@"Attributes"] 
                                                 objectForKey:@"y"] floatValue]) / kTile_Height;
        
        // Get the location to where the portal will transport the player
        float dest_x = [[[[objects objectForKey:objectKey]
                          objectForKey:@"Properties"] 
                         objectForKey:@"dest_x"] floatValue];
        
        float dest_y = [[[[objects objectForKey:objectKey]
                          objectForKey:@"Properties"]
                         objectForKey:@"dest_y"] floatValue];
        
		// Get the name of the destination this portal takes you too
		uint destinationName = [[[[objects objectForKey:objectKey]
								  objectForKey:@"Properties"]
								 objectForKey:@"locationName"] intValue];
		
        // Create a portal instance and add it to the portals array
		NSLog(@"Successfully parsed x: %f y: %f destx: %f desty: %f", portal_x, portal_y, dest_x, dest_y);

        Portal *portal = [[Portal alloc] initWithTileLocation:CGPointMake(portal_x, portal_y) beamLocation:CGPointMake(dest_x, dest_y)];
        portal.state = kEntityState_Alive;
		portal.locationName = destinationName;
      //  [portals addObject:portal];	//hannabarbara uncomment to add portal support
        [portal release];
        portal = nil;
    }
	NSMutableDictionary *zoneObjects = [[portalObjects objectForKey:@"Zones"] objectForKey:@"Objects"];
	for(NSString *objectKey in zoneObjects) {
		float zone_x = [[[[zoneObjects objectForKey:objectKey]
						  objectForKey:@"Attributes"]
						 objectForKey:@"x"] floatValue] / kTile_Width;
		float zone_y = (tileMapPixelHeight -[[[[zoneObjects objectForKey:objectKey]
						  objectForKey:@"Attributes"]
						 objectForKey:@"y"] floatValue]) / kTile_Height;
		float dest_x = [[[[zoneObjects objectForKey:objectKey]
                          objectForKey:@"Properties"]
                         objectForKey:@"dest_x"] floatValue];
		float dest_y = [[[[zoneObjects objectForKey:objectKey]
						  objectForKey: @"Properties"]
						  objectForKey:@"dest_y"] floatValue];
						
		uint destinationName = [[[[zoneObjects objectForKey:objectKey]
								   objectForKey:@"Properties"]
								   objectForKey:@"locationName"] intValue];
		NSString *tileMapName = [[[zoneObjects objectForKey:objectKey]
								   objectForKey:@"Properties"]
								  objectForKey:@"tilemap"];
		NSString *music = [[[zoneObjects objectForKey:objectKey]
							objectForKey:@"Properties"]
						   objectForKey:@"music"];
		NSLog(@"Successfully parsed x: %f y: %f destx: %f desty: %f tilemap: %@ music: %@", zone_x, zone_y, dest_x, dest_y, tileMapName, music);
		
		Zone *zone = [[Zone alloc] initWithTileLocation:CGPointMake(zone_x, zone_y) beamLocation:CGPointMake(dest_x, dest_y) tileMap:tileMapName music:music];
		zone.state = kEntityState_Alive;
		zone.locationName = destinationName;
		for(zone in zones)
			NSLog(@"zone name in zones: %@", [zone tilemap]);
		[zone release];
		zone = nil;
		
	}
}

- (void)initItems {
    // Get the object groups that were found in the tilemap
    NSMutableDictionary *objectGroups = sceneTileMap.objectGroups;
    
    // Calculate the height of the tilemap in pixels.  All tile locations are zero indexed
	// so we need to reduce the mapHeight by 1 to calculate the pixels correctly.
    // so that objects pixel location is correct.
    float tileMapPixelHeight = (kTile_Height * (sceneTileMap.mapHeight - 1));
    
    // Loop through all objects in the object group called Game Objects
    NSMutableDictionary *objects = [[objectGroups objectForKey:@"Game Objects"] objectForKey:@"Objects"];
    
    for (NSString *objectKey in objects) {
        
        // Get the x location of the object
        float object_x = [[[[objects objectForKey:objectKey] 
                            objectForKey:@"Attributes"] 
                           objectForKey:@"x"] floatValue] / kTile_Width;
        
        // As the tilemap coordinates have been reversed on the y-axis, we need to also reverse
        // y-axis pixel location for objects.  This is done by subtracting the objects current
        // y value from the full pixel height of the tilemap
        
		float object_y = (tileMapPixelHeight - [[[[objects objectForKey:objectKey]
                                                  objectForKey:@"Attributes"] 
                                                 objectForKey:@"y"] floatValue]) / kTile_Height;
		float objectWidth = [[[[objects objectForKey:objectKey] objectForKey:@"Attributes"] objectForKey:@"width"] floatValue];
		float objectHeight = [[[[objects objectForKey:objectKey] objectForKey:@"Attributes"] objectForKey:@"height"] floatValue];
		
        // Get the type of the object
        uint type = [[[[objects objectForKey:objectKey]
                          objectForKey:@"Attributes"] 
                         objectForKey:@"type"] intValue];

        // Get the subtype of the object
        uint subType = [[[[objects objectForKey:objectKey]
                       objectForKey:@"Properties"] 
                      objectForKey:@"subtype"] intValue];
        
        // Based on the type and subtype of the object in the map create the correct object instance
        // and add it to the game objects array
        switch (type) {
            case kObjectType_Energy:
            {
				EnergyObject *object = [[EnergyObject alloc] initWithTileLocation:CGPointMake(object_x, object_y) type:type subType:subType];
				[gameObjects addObject:object];
				[object release];
				break;
            }
                
            case kObjectType_Key:
			{
				KeyObject *key = [[KeyObject alloc] initWithTileLocation:CGPointMake(object_x, object_y) type:type subType:subType width:objectWidth height:objectHeight];
				[gameObjects addObject:key];
				[key release];
                break;
			}
                
            case kObjectType_General:
			{
				switch (subType) {


					case kObjectSubType_Wall:
					{
						MapObject *object = [[MapObject alloc] initWithTileLocation:CGPointMake(object_x, object_y) type:type subType:subType width:objectWidth height:objectHeight];
						[gameObjects addObject:object];
						[object release];
						break;
					}
					
					default:
						break;
				}
             }
						
            default:
                break;
        }
    }
}

- (void)initTileMap {
    
    // Create a new instance of TiledMap
	if(nextMap != nil){
		sceneTileMap = [[TiledMap alloc] initWithFileName:nextMap fileExtension:@"tmx"];
	}
	else{
		sceneTileMap = [[TiledMap alloc] initWithFileName:@"Level1" fileExtension:@"tmx"]; //Level1
    }
    // Grab the map width and height in tiles
    tileMapWidth = [sceneTileMap mapWidth];
    tileMapHeight = [sceneTileMap mapHeight];
    
    // Calculate how many tiles it takes to fill the screen for width and height
    screenTilesWide = screenBounds.size.height / kTile_Width;
    screenTilesHeight = screenBounds.size.width / kTile_Height;
    

    bottomOffsetInTiles = screenTilesHeight / 2;
    leftOffsetInTiles = screenTilesWide / 2;
}

- (void)initNewTileMap:(NSString*) aTilemap song:(NSString*) aSong{
	[sceneTileMap release];
	
	sceneTileMap = [[TiledMap alloc] initWithFileName:aTilemap fileExtension:@"tmx"];
    // Grab the map width and height in tiles
    tileMapWidth = [sceneTileMap mapWidth];
    tileMapHeight = [sceneTileMap mapHeight];
    
    // Calculate how many tiles it takes to fill the screen for width and height
    screenTilesWide = screenBounds.size.height / kTile_Width;
    screenTilesHeight = screenBounds.size.width / kTile_Height;
    [sharedSoundManager stopMusic];
	[sharedSoundManager loadMusicWithKey:@"ingame" musicFile:aSong];
	[sharedSoundManager playMusicWithKey:@"ingame" timesToRepeat:-1];
	
    bottomOffsetInTiles = screenTilesHeight / 2;
    leftOffsetInTiles = screenTilesWide / 2;
	[self initCollisionMapAndDoors];
    [self initPortals];
}

- (void)initCollisionMapAndDoors {
    
    // Build a map of blocked locations within the tilemap.  This information is held on a layer called Collision
    // within the tilemap
    SLQLOG(@"INFO - GameScene: Creating tilemap collision array and doors.");

    // Grab the layer index for the layer in the tile map called Collision
    int collisionLayerIndex = [sceneTileMap layerIndexWithName:@"Collision"];
    Door *door = nil;
    Spawn *spawn;
    // Loop through the map tile by tile
    Layer *collisionLayer = [[sceneTileMap layers] objectAtIndex:collisionLayerIndex];
    for(int yy=0; yy < sceneTileMap.mapHeight; yy++) {
        for(int xx=0; xx < sceneTileMap.mapWidth; xx++) {
            
            // Grab the global tile id from the tile map for the current location
            int globalTileID = [collisionLayer globalTileIDAtTile:CGPointMake(xx, yy)];
            if(globalTileID < 13 && globalTileID > 1) {
				NSLog(@"Found green ninja tile on collision layer and added to spawnpoints array");
				spawn = [[Spawn alloc] initWithTileLocation:CGPointMake(xx,yy) type:globalTileID arrayIndex: [spawnPoints count]];
				[spawnPoints addObject: spawn];
				NSLog(@"Current spawn tile count: %i", [spawnPoints count]);
				[spawn release];
			}
				
            // If the global tile ID is the blocking tile image then this location is blocked.  If it is a door object
            // then a door is created and placed in the doors array.  The value below is the tileid from the tileset used in the 
			// tile map.  If this tile is present in the collision layer then we mark that tile as blocked.
			
            else if(globalTileID == kBlockedTileGlobalID) {
                blocked[xx][yy] = YES;
            } else  {
                
                // If the game is being resumed, then we do not need to load the doors array
                if (!sharedGameController.shouldResumeGame) {
                    // Check to see if the tileid for the current tile is a door tile.  If not then move on else check the type
					// of the door and create a door instance.  If the tile map sprite sheet changes then these numbers need to be
					// checked.  Also this assumes that the door tile are contiguous in the sprite sheet
					if (globalTileID >= kFirstDoorTileGlobalID && globalTileID <= kLastDoorTileGlobalID) {
						int doorType = [[sceneTileMap tilePropertyForGlobalTileID:globalTileID key:@"type" defaultValue:@"-1"] intValue];
						if (doorType != -1) {
							// Create a new door instance of the correct type.  As we create the door we set the doors array
							// index to be its index in the doors array.  At this point we have not actually added the door to 
							// the array so we can use the current array count which will give us the correct number
							door = [[Door alloc] initWithTileLocation:CGPointMake(xx, yy) type:doorType arrayIndex:[doors count]];
							[doors addObject:door];
							[door release];
						}
					}
                }
            }
        }
		
    }
	SLQLOG(@"INFO - GameScene: Finished constructing collision array and doors.");
}

- (void)calculatePlayersTileMapLocation {
	// Round the players tile location
	playerTileX = (int) player.tileLocation.x;
    playerTileY = (int) player.tileLocation.y;

    // Calculate the players tile x and y offset.  This allows us to keep the player in the middle of
	// the screen and have the map render correctly under the player.  This information is used when
	// rendering the tile map layers in the render method
	playerTileOffsetX = (int) ((playerTileX - player.tileLocation.x) * kTile_Width);
    playerTileOffsetY = (int) ((playerTileY - player.tileLocation.y) * kTile_Height);
}

- (void)initLocalDoors {
	// Calculate the tile bounds around the player. We clamp the possbile values to between
	// 0 and the width/height of the tile map.  We remove 1 from the width and height
	// as the tile map is zero indexed in the game.  These values can then be used when
	// checking if objects, portals or doors should be updated
	int minScreenTile_x = CLAMP(player.tileLocation.x - 8, 0, kMax_Map_Width-1);
	int maxScreenTile_x = CLAMP(player.tileLocation.x + 8, 0, kMax_Map_Width-1);
	int minScreenTile_y = CLAMP(player.tileLocation.y - 6, 0, kMax_Map_Height-1);
	int maxScreenTile_y = CLAMP(player.tileLocation.y + 6, 0, kMax_Map_Height-1);
	
	// Populate the localDoors array with any doors that are found around the player.  This allows
	// us to reduce the number of doors we are rendering and updating in any single frame.  We only
	// perform this check if the player has moved from one tile to another on the tile map to save cycles
	if ((int)player.tileLocation.x != (int)playersLastLocation.x || (int)player.tileLocation.y != (int)playersLastLocation.y) {
		
		// Clear the localDoors array as we are about to populate it again based on the 
		// players new position
		[localDoors removeAllObjects];
		
		// Find doors that are close to the player and add them to the localDoors loop.  Layer 3 in the 
		// tile map holds the door information
		Layer *layer = [[sceneTileMap layers] objectAtIndex:2];
		for (int yy=minScreenTile_y; yy < maxScreenTile_y; yy++) {
			for (int xx=minScreenTile_x; xx < maxScreenTile_x; xx++) {
				
				// If the value property for this tile is not -1 then this must be a door and
				// we should add it to the localDoors array
				if ([layer valueAtTile:CGPointMake(xx, yy)] > -1) {
					int index = [layer valueAtTile:CGPointMake(xx, yy)];
					[localDoors addObject:[NSNumber numberWithInt:index]];
				}
			}
		}
	}
}


- (NSMutableArray *) getSpawnPoints {
	return spawnPoints;
}

- (void)createDamageTextbox:(NSString *)aText aLocation:(CGPoint)aPoint{
	DamageText *dtext = [[DamageText alloc] initWithText:aText aLocation:aPoint];
	[damageText addObject:dtext];
}


- (void)deallocResources {

	// Release the images
	[fadeImage release];
	[jumpButton release];
	[openMainDoor release];
	[closedMainDoor release];
	[joypad release];
	[lifebar release];
	[pause release];
	[menuScreen release];
	// Release fonts
	[smallFont release];
	[digitFont release];

	// Release game entities
	[doors release];
	[spawnPoints release];
	[gameEntities release];
	[enemyProjectiles release];

	[playerAttack release];
	[localDoors release];
	[gameObjects release];
	[portals release];
	[zones release];
	[sceneTileMap release];
	[damageText release];
	[player release];
	
	// Release sounds
	[sharedSoundManager removeSoundWithKey:@"encounter"];
	[sharedSoundManager removeSoundWithKey:@"casting"];
	[sharedSoundManager removeSoundWithKey:@"castingDown"];
	[sharedSoundManager removeSoundWithKey:@"throw"];
	[sharedSoundManager removeSoundWithKey:@"cure"];
	[sharedSoundManager removeSoundWithKey:@"scream"];
	[sharedSoundManager removeSoundWithKey:@"swoosh"];
	[sharedSoundManager removeSoundWithKey:@"hurt"];
	[sharedSoundManager removeMusicWithKey:@"ingame"];
	[sharedSoundManager removeSoundWithKey:@"voice1"];
	[sharedSoundManager removeSoundWithKey:@"voice2"];
	[sharedSoundManager removeSoundWithKey:@"voice3"];
	[sharedSoundManager removeSoundWithKey:@"voice4"];
	[sharedSoundManager removeSoundWithKey:@"voice5"];
	[sharedSoundManager removeSoundWithKey:@"katana"];
	[sharedSoundManager removeSoundWithKey:@"katanaSwing"];
	[sharedSoundManager removeSoundWithKey:@"skiddGun"];
	[sharedSoundManager removeSoundWithKey:@"fireGun"];
	

}


@end

