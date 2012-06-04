//
//  HelloWorldLayer.h
//  SimplePendulumSimulation
//
//  Created by Min Kwon on 6/4/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    CGSize winSize;
    
    CCSprite *catcher;
    
    double timeNow;
    double tRef;

    float omega;
    float ropeLength;
    float swingSpeed;
    float swingAngle;
    float gravity;
    
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
