//
//  EAGLView.h
//  SLQTSOR
//
//  Created by Michael Daley on 18/08/2009.
//  Copyright Michael Daley 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "ESRenderer.h"

@class GameController;
@class ImageRenderManager;

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
//
@interface EAGLView : UIView {    

@private
	id <ESRenderer> renderer;
	BOOL animating;
	BOOL displayLinkSupported;
	NSInteger animationFrameInterval;
	id displayLink;
    NSTimer *animationTimer;
    GameController *sharedGameController;
    CFTimeInterval lastTime;	

}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

// Starts the CADisplayLink or NSTimer which starts the game loop updating
- (void) startAnimation;

// Stops the CADisplayLink or NSTimer which stops the game loop from updating
- (void) stopAnimation;

// Draws the current scene to the screen
- (void) drawView:(id)sender;

@end
