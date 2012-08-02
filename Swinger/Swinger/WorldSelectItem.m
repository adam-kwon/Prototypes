//
//  WorldSelectItem.m
//  Swinger
//
//  Created by Min Kwon on 7/5/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "WorldSelectItem.h"
#import "Constants.h"
#import "Macros.h"
#import "LevelSelectScene.h"
#import "GPUtil.h"
#import "TextureTypes.h"
#import "AudioEngine.h"

@implementation WorldSelectItem

@synthesize worldName;

+ (id) nodeWithWorldName:(NSString*)world {
    return [[[self alloc] initWithWorldName:world] autorelease];
}

- (id) initWithWorldName:(NSString*)world {
    self = [super init];
    
    if (self) {
        worldName = world;
        
        if ([WORLD_GRASS_KNOLLS isEqualToString:worldName]) {
            thumbNailSprite = [CCSprite spriteWithFile:@"GrassKnollsThumb.png"];
        }
        else if ([WORLD_FOREST_RETREAT isEqualToString:worldName]) {
            thumbNailSprite = [CCSprite spriteWithFile:@"ForestRetreatThumb.png"];
        }
        
        [self addChild:thumbNailSprite];        
    }
    
    return self;
}

- (CGRect) boundingBox {
    return [thumbNailSprite boundingBox];
}

- (void) onEnter {
    CCLOG(@"**** WorldSelectItem onEnter");
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
	[super onEnter];
}

- (void) onExit {
    CCLOG(@"**** WorldSelectItem onExit");
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}

#pragma mark - Touch Handling
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    touchStart = [touch locationInView:[touch view]];
    touchStart = [[CCDirector sharedDirector] convertToGL:touchStart];
    
    lastMoved = touchStart;
    return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint;
    touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
    
    const int threshold = 40;
    float deltaScroll = touchPoint.x - touchStart.x;
    
    if (deltaScroll < -threshold) {
        // Scroll right to left
        
    } else if (deltaScroll > threshold) {
        // Scroll left to right
    } else {
        // Selection (touch)        
        float screenX = normalizeToScreenCoord(self.parent.position.x, self.position.x, 1.0);
        CGRect spriteRect = CGRectMake(screenX - [self boundingBox].size.width/2, 
                                       self.position.y - [self boundingBox].size.height/2, 
                                       [self boundingBox].size.width, 
                                       [self boundingBox].size.height);
        
        if (CGRectContainsPoint(spriteRect, touchPoint)) {
            // Remove old atlas, if any
            
            id press = [CCScaleTo actionWithDuration:0.05 scale:0.9];
            id press2 = [CCScaleTo actionWithDuration:0.05 scale:1.05];
            id press3 = [CCScaleTo actionWithDuration:0.02 scale:0.95];
            id press4 = [CCScaleTo actionWithDuration:0.02 scale:1.02];
            id press5 = [CCScaleTo actionWithDuration:0.02 scale:0.98];
            id press6 = [CCScaleTo actionWithDuration:0.02 scale:1.0];
            
            id cb = [CCCallFunc actionWithTarget:self selector:@selector(loadLevel)];
            id seq = [CCSequence actions:press, press2, press3, press4, press5, press6, cb, nil];
            [self runAction:seq];
            [[AudioEngine sharedEngine] playEffect:SND_BLOP];
        }
    }
}

- (void) loadLevel {
    
    
    NSString *atlasName;            
    if ([WORLD_GRASS_KNOLLS isEqualToString:worldName]) {
        atlasName = BACKGROUND_ATLAS;
    }
    else if ([WORLD_FOREST_RETREAT isEqualToString:worldName]) {
        atlasName = FOREST_RETREAT_ATLAS;
    }            
    g_currentWorldAtlas = atlasName;
    
    
    [[CCTextureCache sharedTextureCache] addImageAsync:[GPUtil getAtlasImageName:g_currentWorldAtlas] 
                                                target:self 
                                              selector:@selector(loadAtlas:)];

}

- (void) loadAtlas:(CCTexture2D*)tex {
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[GPUtil getAtlasPList:g_currentWorldAtlas] texture:tex];
    [tex setAliasTexParameters];
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 
                                                                                 scene:[LevelSelectScene nodeWithWorld:worldName]]];
}


- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint touchPoint;
    touchPoint = [touch locationInView:[touch view]];
    touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
        
    lastMoved = touchPoint;
}

- (void) dealloc {
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end
