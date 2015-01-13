//
//  Score.m


#import "Score.h"


#pragma mark -
#pragma mark Public implementation

@implementation Score

@synthesize dateTime;
@synthesize score;
@synthesize time;
@synthesize name;
@synthesize didWin;

- (void)dealloc {
	[self.time release];
	[super dealloc];
}

- (id) initWithScore:(int)aScore gameTime:(NSString*)aGameTime playersName:(NSString*)aPlayersName didWin:(BOOL)aDidWin {
	self = [super init];
	if (self != nil) {
		self.dateTime = [NSDate date];
		self.score = aScore;
		self.time = aGameTime;
		self.name = aPlayersName;
		self.didWin = aDidWin;
	}
	return self;
}

#pragma mark -
#pragma mark Encoding/Decoding

- (id)initWithCoder:(NSCoder *)aDecoder {
	// Decode the values we need to create a new Score instance
	int aScore = [aDecoder decodeIntForKey:@"score"];
	NSString *aTime = [aDecoder decodeObjectForKey:@"gameTime"];
	NSString *aName = [aDecoder decodeObjectForKey:@"name"];
	BOOL won = [aDecoder decodeIntForKey:@"didWin"];
	
	// Create a new instance of Score
	[self initWithScore:aScore gameTime:aTime playersName:aName didWin:won];
	
	// dateTime is set to "Now" by default so we set it to the dateTime that
	// was stored
	self.dateTime = [aDecoder decodeObjectForKey:@"dateTime"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
	[aCoder encodeObject:self.dateTime forKey:@"dateTime"];
	[aCoder encodeInt:self.score forKey:@"score"];
	[aCoder encodeObject:self.time forKey:@"gameTime"];
	[aCoder encodeObject:self.name forKey:@"name"];
	[aCoder encodeInt:self.didWin forKey:@"didWin"];
}

@end
