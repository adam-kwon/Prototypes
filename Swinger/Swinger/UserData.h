//
//  UserData.h
//  Scroller
//
//  Created by min on 3/26/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "DeviceDetection.h"
#import "Constants.h"
#import <MediaPlayer/MediaPlayer.h>

typedef enum {
    kPerformanceNone,
    kPerformanceLow,
    kPerformanceMedium,
    kPerformanceHigh
} PerformanceProfile;

@interface UserData : NSObject {
    float                   fxVolumeLevel;
    float                   musicVolumeLevel;
    DeviceType              device;
    PerformanceProfile      profile;
    MPMediaItemCollection   *playList;
    
    BOOL                    isCustomMusic;
    BOOL                    reduceVolume;
    NSDate                  *date;
    NSString                *gameVersion;
    NSString                *deviceId;
    
    PlayerHead              headSkin;
    PlayerBody              bodySkin;
    
    // game persisted data
    unsigned long           totalCoins;
    unsigned long           totalStars;
    NSMutableDictionary    *levels; // highest level acheived in each world
    NSMutableDictionary    *highScores;
    NSMutableDictionary    *bestTimes;
    
    // Level based data
    unsigned long           currentCoins;
    unsigned long           currentStars;
    unsigned long           currentScore;
    unsigned long           currentTime;
    
    // used for scoring
    unsigned long           landingBonus;
    unsigned long           perfectJumpCount;
    unsigned long           imperfectJumpCount;
    unsigned long           restartCount; // number of tries before completing level
    unsigned long           skipCount;
}

+ (UserData*) sharedInstance;
- (void) readOptionsFromDisk;
- (void) persist;
- (void) savePlayList:(MPMediaItemCollection*)collection;
- (void) loadPlayList;

- (unsigned int) getLevel: (NSString*) world;
- (void) setLevel: (NSString*) world level: (unsigned int) level;

- (BOOL) isHighScore: (NSString *) world level: (unsigned int) level;
- (unsigned long) getHighScore: (NSString*) world level: (unsigned int) level;
- (void) setHighScore: (NSString*) world level: (unsigned int) level;

- (BOOL) isBestTime: (NSString *) world level: (unsigned int) level;
- (unsigned long) getBestTime: (NSString*) world level: (unsigned int) level;
- (void) setBestTime: (NSString*) world level: (unsigned int) level;

@property (nonatomic, readwrite, assign) NSDate *date;
@property (nonatomic, readwrite, assign) MPMediaItemCollection *playList;
@property (nonatomic, readwrite, assign) BOOL reduceVolume;
@property (nonatomic, readwrite, assign) float musicVolumeLevel;
@property (nonatomic, readwrite, assign) float fxVolumeLevel;
@property (nonatomic, readwrite, assign) DeviceType device;
@property (nonatomic, readwrite, assign) PerformanceProfile profile;
@property (nonatomic, readwrite, assign) BOOL isCustomMusic;
@property (nonatomic, readwrite, assign) NSString *gameVersion;
@property (nonatomic, readwrite, retain) NSString *deviceId;

@property (nonatomic, readwrite, assign) PlayerHead headSkin;
@property (nonatomic, readwrite, assign) PlayerBody bodySkin;

@property (nonatomic, readwrite, assign) unsigned long totalCoins;
@property (nonatomic, readwrite, assign) unsigned long totalStars;

@property (nonatomic, readwrite, assign) unsigned long currentCoins;
@property (nonatomic, readwrite, assign) unsigned long currentStars;
@property (nonatomic, readwrite, assign) unsigned long currentScore;
@property (nonatomic, readwrite, assign) unsigned long currentTime;

// used for scoring
@property (nonatomic, readwrite, assign) unsigned long landingBonus;
@property (nonatomic, readwrite, assign) unsigned long perfectJumpCount;
@property (nonatomic, readwrite, assign) unsigned long imperfectJumpCount;
@property (nonatomic, readwrite, assign) unsigned long restartCount;
@property (nonatomic, readwrite, assign) unsigned long skipCount;

@end
