//
//  GamePlayLayer.h
//  Grappler
//
//  Created by James Sandoz on 8/1/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

@class Player;
@class VRope;

// GamePlayLayer
@interface GamePlayLayer : CCLayer
{
    CGSize screenSize;
    
	b2World* world;
	GLESDebugDraw *m_debugDraw;
    
    b2Body *ropeAnchor;    
    Player *player;
    
    CCSpriteBatchNode *ropeSegmentSprite;
    VRope *vrope;
    
    BOOL isHolding;
}

// returns a CCScene that contains the GamePlayLayer as the only child
+(CCScene *) scene;
+(GamePlayLayer*) sharedLayer;

-(void) updateVRope;




@end
