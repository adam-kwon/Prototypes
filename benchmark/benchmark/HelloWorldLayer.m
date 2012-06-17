//
//  HelloWorldLayer.m
//  benchmark
//
//  Created by James Sandoz on 6/16/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) addSingleBatchnode:(int)numTrees doHide:(BOOL)hide {
    
    CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"backgroundAtlas.png"];
    [self addChild:batch];
    
    // 4 screen widths full of 250 trees each
    for (int i=0; i < 4; i++) {
        for (int j=0; j < numTrees; j++) {
            int tree = (CCRANDOM_0_1()*2) + 1;
            CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"L1a_Tree%d.png", tree]];
            
            float posx = (CCRANDOM_0_1()*screenSize.width) + (screenSize.width*i);
            float posy = CCRANDOM_0_1()*screenSize.height;
            sprite.position = ccp(posx, posy);
            [batch addChild:sprite];
            
            if (hide && i > 0)
                [sprite setVisible:NO];
        }
    }
}

-(void) addMultipleBatchnode:(int)numTrees doHide:(BOOL)hide {
    
    // 4 screen widths full of 250 trees each
    for (int i=0; i < 4; i++) {
        CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:@"backgroundAtlas.png"];
        [self addChild:batch];
        if (hide && i > 0)
            [batch setVisible:NO];
        
        for (int j=0; j < numTrees; j++) {
            int tree = (CCRANDOM_0_1()*2) + 1;
            CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"L1a_Tree%d.png", tree]];
            
            float posx = (CCRANDOM_0_1()*screenSize.width) + (screenSize.width*i);
            float posy = CCRANDOM_0_1()*screenSize.height;
            sprite.position = ccp(posx, posy);
            [batch addChild:sprite];
        }
    }
}

-(void) addSingleNode:(int)numTrees doHide:(BOOL)hide {

    CCNode *node = [CCNode node];
    [self addChild:node];
    
    // 4 screen widths full of 250 trees each
    for (int i=0; i < 4; i++) {

        for (int j=0; j < numTrees; j++) {
            int tree = (CCRANDOM_0_1()*2) + 1;
            CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"L1a_Tree%d.png", tree]];
            
            float posx = (CCRANDOM_0_1()*screenSize.width) + (screenSize.width*i);
            float posy = CCRANDOM_0_1()*screenSize.height;
            sprite.position = ccp(posx, posy);
            
            [node addChild:sprite];
            if (hide && i > 0)
                [sprite setVisible:NO];
        }
    }
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// ask director the the window size
		screenSize = [[CCDirector sharedDirector] winSize];
        
        CCTexture2D *tex = [[CCTextureCache sharedTextureCache] addImage:@"backgroundAtlas.png"];        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"backgroundAtlas.plist" texture:tex];
        [tex setAliasTexParameters];
	
        // hide anything more than x screen widths off screen
//        [self addSingleBatchnode:1000 doHide:YES];
//        [self addMultipleBatchnode:1000 doHide:YES];
        [self addSingleNode:1000 doHide:YES];
	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
