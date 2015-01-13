//
//  Score.h



// This class is used to store a single score for the game.  A class instance
// is created when a game is completed and is then stored in the high scores
// array.  This array is then stored to disk and also used from within the
// high score view controller.
//
@interface Score : NSObject <NSCoding> {

	NSDate *dateTime;		// Date and time the score was achieved
	int score;				// Score
	NSString *time;			// Time playing
	NSString *name;			// Players name
	BOOL didWin;			// YES if the player won the game

}

@property (nonatomic, retain) NSDate *dateTime;
@property (nonatomic, assign) int score;
@property (nonatomic, retain) NSString *time;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, assign) BOOL didWin;

// Designated initializer that creates a new score instance that contains the players name
// their score and the date and time they achieved that score
- (id) initWithScore:(int)aScore gameTime:(NSString*)aGameTime playersName:(NSString*)aPlayerName didWin:(BOOL)aDidWin;

@end
