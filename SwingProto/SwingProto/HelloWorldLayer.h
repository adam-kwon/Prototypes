//
//  HelloWorldLayer.h
//  SwingProto
//
//  Created by James Sandoz on 3/11/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "ContactListener.h"




@class SwingingRopeDude;
@class JumpingDude;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
	b2World* world;
    ContactListener *contactListener;
	GLESDebugDraw *m_debugDraw;
    
//    b2Body *holderBody;
//    b2Body *catcherBody;
    
    b2Body *jumperBody;
    
    JumpingDude *jumper;
    b2Joint *jumperJoint;
    
    b2RevoluteJoint *revJoint;
    b2RevoluteJoint *revJoint2;
    
    float minAngleRads;
    float maxAngleRads;
    float baseSpeed;
    float baseXDelta;
    float catcherXPos;
    float catcherYPos;
        
    SwingingRopeDude *nextCatcher;
    SwingingRopeDude *lastCatcher;
    
    float leadoutOffset;
    float lastJumperPos;
    
    BOOL finishScrolling;
    float leadOut;
    float scrollDelta;
    
    float targetScrollPos;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
// adds a new sprite at a given coordinate
-(void) addNewSpriteWithCoords:(CGPoint)p;


+ (HelloWorldLayer*) sharedLayer;
- (SwingingRopeDude *) createNextCatcher;
- (void) catchJumper:(SwingingRopeDude *)catcher;
- (void) createJumperJoint;


@end
