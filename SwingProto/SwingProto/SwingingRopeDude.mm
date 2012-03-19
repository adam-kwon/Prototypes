//
//  SwingingRopeDude.m
//  SwingProto
//
//  Created by James Sandoz on 3/16/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SwingingRopeDude.h"

#import "Constants.h"


@implementation SwingingRopeDude


- (id) initWithParent:(CCNode *)parent {
	if ((self = [super init])) {
        minAngleRads = -45*(M_PI/180.0);
        maxAngleRads = 45*(M_PI/180.0);
    }
    
    return self;
}

- (void) createPhysicsObjectAsBox:(b2World*)theWorld {
    world = theWorld;
    
    
    //
    // Create the invisible anchor
    //
    b2BodyDef anchorBodyDef;
    anchor = world->CreateBody(&anchorBodyDef);
    
    b2PolygonShape anchorBox;
    anchorBox.SetAsBox(.2f, .2f);
    
    b2Fixture *anchorFixture = anchor->CreateFixture(&anchorBox,0);
    b2Filter anchorFilter = anchorFixture->GetFilterData();
    anchorFilter.categoryBits = CATEGORY_ANCHOR;
    anchorFilter.maskBits = 0;
    
    
    //
    // Create the swinging rope
    //
    CCSprite *ropeSprite = [CCSprite spriteWithFile:@"rope.png"];
    [self addChild:ropeSprite];
    
    b2BodyDef ropeBodyDef;
    ropeBodyDef.type = b2_dynamicBody;
    ropeBodyDef.userData = ropeSprite;
    rope = world->CreateBody(&ropeBodyDef);
    
    // Create the rope's body
    b2PolygonShape ropeBox;
    ropeBox.SetAsBox([ropeSprite boundingBox].size.width/PTM_RATIO/2, [ropeSprite boundingBox].size.height/PTM_RATIO/2);
    
    // Create the rope fixture
    b2FixtureDef ropeFixtureDef;
    ropeFixtureDef.shape = &ropeBox;
    ropeFixtureDef.density = 0.5f;
    ropeFixtureDef.friction = 0.3f;
    b2Fixture *ropeFixture = rope->CreateFixture(&ropeFixtureDef);
    b2Filter ropeFilter = ropeFixture->GetFilterData();
    ropeFilter.categoryBits = CATEGORY_ROPE;
    ropeFilter.maskBits = 0;
    
    // create a revolute joint with a motor to oscillate between two points
    b2RevoluteJointDef revJointDef;
    revJointDef.Initialize(anchor, rope, anchor->GetWorldCenter());
    
    // set the anchor for the rope to be the top edge
    revJointDef.localAnchorB = b2Vec2(0, ([ropeSprite boundingBox].size.height/PTM_RATIO/2.1));
    revJointDef.motorSpeed = MOTOR_SPEED;
    revJointDef.lowerAngle = minAngleRads;
    revJointDef.upperAngle = maxAngleRads;
    revJointDef.enableLimit = YES;
    revJointDef.maxMotorTorque = 10000000;
    revJointDef.referenceAngle = 0;
    revJointDef.enableMotor = YES;
    revJoint = (b2RevoluteJoint *)world->CreateJoint(&revJointDef);
}

// make the motor oscillate by switching directions when the limits are reached
- (void) updateObject:(ccTime)dt {
    if (revJoint->GetJointAngle() >= maxAngleRads) {
        revJoint->SetMotorSpeed(-MOTOR_SPEED);
    } else if (revJoint->GetJointAngle() <= minAngleRads) {
        revJoint->SetMotorSpeed(MOTOR_SPEED);
    }
}

-(void) moveTo:(CGPoint)pos {
    self.position = pos;

    anchor->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);    
    
}

-(void) showAt:(CGPoint)pos {

    // Move the building
    [self moveTo:pos];
    
    // make it active and visible
    [self setVisible:YES];
}


@end
