//
//  LevelItem.h
//  Swinger
//
//  Created by James Sandoz on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Constants.h"

@interface LevelItem : NSObject {
    GameObjectType type;
    
    NSString *typeName;

    CGPoint position;
    float speed;
    float force; // force to release the player with - mainly for cannon

    float period;   // rope, periof of pendulum (swing speed will be calcualted from this value_
    float swingAngle;
    float ropeLength;
    float grip;
    
    float bounce;   // Spring bounce
    
    float poleScale; // y-scale of the pole, used to vary the height
    
    float width; // floating platform width
    
    // left and right edges, used to determine where the elephant will walk
    float leftEdge;
    float rightEdge;
    float walkVelocity;
    
    // wind
    float windSpeed;
    NSString * windDirection;
    
    // fire ring
    CGPoint movement;
}

@property (readwrite, nonatomic, assign) GameObjectType type;
@property (readwrite, nonatomic, assign) CGPoint position;
@property (readwrite, nonatomic, assign) float speed;
@property (readwrite, nonatomic, assign) float force;
@property (readwrite, nonatomic, assign) float period;
@property (readwrite, nonatomic, assign) float swingAngle;
@property (readwrite, nonatomic, assign) float ropeLength;
@property (readwrite, nonatomic, assign) float grip;
@property (readwrite, nonatomic, assign) float poleScale;
@property (readwrite, nonatomic, assign) float windSpeed;
@property (readwrite, nonatomic, assign) float bounce;
@property (readwrite, nonatomic, assign) float leftEdge;
@property (readwrite, nonatomic, assign) float rightEdge;
@property (readwrite, nonatomic, assign) float walkVelocity;
@property (readwrite, nonatomic, assign) float width;
@property (readwrite, nonatomic, assign) CGPoint movement;
@property (nonatomic, retain) NSString* windDirection;
@property (nonatomic, retain) NSString* typeName;

@end
