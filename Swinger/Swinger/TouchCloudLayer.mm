//
//  TouchSkyLayer.m
//  Swinger
//
//  Created by Isonguyo Udoka on 6/11/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "TouchCloudLayer.h"
#import "Macros.h"
#import "GamePlayLayer.h"
#import "Player.h"
#import "HUDLayer.h"

static const float cappedHeight = 1.5f;
static const float cappedHeightIpad = 1.5f;

@implementation TouchCloudLayer

static TouchCloudLayer* instanceOfLayer;

+ (TouchCloudLayer*) sharedLayer {
	NSAssert(instanceOfLayer != nil, @"TouchCloudLayer instance not yet initialized!");
	return instanceOfLayer;
}

- (id) init {    
    if ((self = [super init])) {
        instanceOfLayer = self;
        self.anchorPoint = ccp(0.f, 1.f);
        screenSize = [[CCDirector sharedDirector] winSize];
        
        [self initLayer];
    }
    
    return self;
}

- (void) initLayer {
    cappedPos = ccp(-5, ssipad((cappedHeightIpad*screenSize.height), cappedHeight*screenSize.height));
    
    clouds = [CCSprite spriteWithSpriteFrameName:@"CloudTop.png"];
    CCSprite * cloud2 = [CCSprite spriteWithSpriteFrameName:@"CloudTop.png"];
    cloud2.anchorPoint = ccp(0,1);
    cloud2.position = ccp([clouds boundingBox].size.width - ssipadauto(20), [clouds boundingBox].size.height);
    [clouds addChild: cloud2 z:-1];
    
    cloudScale = 1.f;
    clouds.anchorPoint = ccp(0,1);
    [self addChild: clouds z: 1];
    [self resetState];
    
    [self scheduleUpdate];
}

- (void) resetState {
    [clouds stopAllActions];
    currHeight = 0;
    prevHeight = 0;
    clouds.scale = cloudScale;
    clouds.position = cappedPos;
    scrolledToStart = NO;
    touchCloudReported = NO;
}

- (void) update:(ccTime)dt {
    Player * player = [[GamePlayLayer sharedLayer] getPlayer];
    
    if(player.state != kSwingerInAir) {
        // reset state
        [self resetState];
        return;
    }
    
    float cloudHeight = clouds.position.y;
    float deltaHeight = 0;
    float threshold =   screenSize.height/6;
    float playerPos = player.position.y;
    float gameScale = [GamePlayLayer sharedLayer].scale;
    float playerPosNormalized = normalizeToScreenCoord([[GamePlayLayer sharedLayer] getNode].position.y, playerPos, gameScale);
    float playerCloudDistance = cloudHeight - playerPos;
    
    //CCLOG(@"PLAYER HEIGHT: %f, CLOUD HEIGHT: %f --- THRESHOLD: %f", player.position.y, cloudHeight, threshold);
    if(playerCloudDistance <= threshold) {
        if(currHeight == 0) {
            prevHeight = currHeight;
            currHeight = player.position.y;
            
            deltaHeight = 0;
            
        } else {
            prevHeight = currHeight;
            currHeight = player.position.y;
            
            deltaHeight = (currHeight - prevHeight);// * scale; // get change in height
        }
        
        float slowScrollAmt = 0.75f; // how fast the touch clouds scroll into view
            
        if(deltaHeight > 0) {
            // player is accelerating up, scroll touch clouds into view
            if(clouds.position.y - deltaHeight <= screenSize.height + [clouds boundingBox].size.height) {
                if(!scrolledToStart) {
                    clouds.position = ccp(clouds.position.x, screenSize.height + [clouds boundingBox].size.height);
                    [clouds stopAllActions];
                    CCScaleTo *expand = [CCScaleTo actionWithDuration:2.f scale:0.80f*cloudScale];
                    [clouds runAction:expand];
                    scrolledToStart = YES;
                }
                deltaHeight = slowScrollAmt; // scroll the clouds in slower
            }
        
            float buffer = -ssipadauto(15); // how far down the screen the touch clouds go - higher the number less of the cloud appears on screen
            
            // glue clouds to top of the screen
            if(clouds.position.y - deltaHeight <= screenSize.height + buffer) {
                clouds.position = ccp(clouds.position.x, screenSize.height + buffer);
            } else {
                clouds.position = ccp(clouds.position.x, clouds.position.y - deltaHeight);
            }
        } else if(deltaHeight < 0) {
            //player is falling down scroll touch clouds out of view
            
            if(clouds.position.y < screenSize.height + [clouds boundingBox].size.height) { // its still on screen scroll it out slowly
                deltaHeight = -slowScrollAmt;
                
                [clouds stopAllActions];
                CCScaleTo *expand = [CCScaleTo actionWithDuration:1.f scale:1.f*cloudScale];
                [clouds runAction:expand];
                
                if (!touchCloudReported && playerPosNormalized >= (cloudHeight - [clouds boundingBox].size.height)) {
                    // on his way down, check if he touched the clouds - report it
                    [[HUDLayer sharedLayer] cloudTouch];
                    touchCloudReported = YES;
                }
            }
            
            clouds.position = ccp(clouds.position.x, clouds.position.y - deltaHeight);
        }
            
        //CCLOG(@">>> SETTING SCREEN POSITION TO: (%f, %f), CLOUD POSITION IS: (%f, %f) <<<<", player.position.x, player.position.y, clouds. position.x, clouds.position.y);
    }
}

- (void) cleanupLayer {
    [self stopAllActions];
    [self unscheduleAllSelectors];  
    
    [self removeAllChildrenWithCleanup:YES];
    
    clouds = nil;
}

- (void) dealloc {
    CCLOG(@"----------------------------- TouchCloudLayer dealloc");
    [self cleanupLayer];
    [super dealloc];
}

@end
