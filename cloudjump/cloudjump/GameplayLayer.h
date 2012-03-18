//
//  HelloWorldLayer.h
//  cloudjump
//
//  Created by Min Kwon on 3/9/12.
//  Copyright GAMEPEONS, LLC 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"
#import "PhysicsWorld.h"

@class Player;

// HelloWorldLayer
@interface GameplayLayer : CCLayer
{
	b2World         *world;
	GLESDebugDraw   *m_debugDraw;
    PhysicsWorld    *physicsWorld;
    
    float           accelX;
    Player          *player;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
