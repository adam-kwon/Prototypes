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

@synthesize catcherBody;
@synthesize catcherSprite;
@synthesize anchorPos;

- (id) initWithParent:(CCNode *)theParent at:(CGPoint)pos withSpeed:(float)speed{
	if ((self = [super init])) {
        parent = theParent;
        anchorPos = pos;
        motorSpeed = speed;
        
        // set the angles
        //XXX should make these and the speed configurable, maybe properties?
        minAngleRads = -30*(M_PI/180.0);
        maxAngleRads = 30*(M_PI/180.0);
    }
    
    return self;
}

- (void) createPhysicsObject:(b2World*)theWorld {
    world = theWorld;
    
    
    //
    // Create the invisible anchor
    //
    b2BodyDef anchorBodyDef;
    anchorBodyDef.position.Set(anchorPos.x/PTM_RATIO, anchorPos.y/PTM_RATIO);
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
    ropeSprite = [CCSprite spriteWithFile:@"rope.png"];
    ropeSprite.position = anchorPos;
    [parent addChild:ropeSprite];
    
    b2BodyDef ropeBodyDef;
    ropeBodyDef.type = b2_dynamicBody;
    ropeBodyDef.userData = NULL;
    ropeBodyDef.position.Set(anchorPos.x/PTM_RATIO, anchorPos.y/PTM_RATIO);
    ropeBody = world->CreateBody(&ropeBodyDef);
    
    // Create the rope's body
    b2PolygonShape ropeBox;
    ropeBox.SetAsBox([ropeSprite boundingBox].size.width/PTM_RATIO/2, [ropeSprite boundingBox].size.height/PTM_RATIO/2);
    
    // Create the rope fixture
    b2FixtureDef ropeFixtureDef;
    ropeFixtureDef.shape = &ropeBox;
    ropeFixtureDef.density = 1.5f;
    ropeFixtureDef.friction = 0.3f;
    b2Fixture *ropeFixture = ropeBody->CreateFixture(&ropeFixtureDef);
    b2Filter ropeFilter;
    ropeFilter.categoryBits = CATEGORY_ROPE;
    ropeFilter.maskBits = 0;
    ropeFixture->SetFilterData(ropeFilter);
    
    // create a revolute joint with a motor to oscillate between two points
    b2RevoluteJointDef revJointDef;
    revJointDef.Initialize(anchor, ropeBody, anchor->GetWorldCenter());
    
    // set the anchor for the rope to be the top edge
    revJointDef.localAnchorB = b2Vec2(0, ([ropeSprite boundingBox].size.height/PTM_RATIO/2.1));
    revJointDef.motorSpeed = motorSpeed;
    revJointDef.lowerAngle = minAngleRads;
    revJointDef.upperAngle = maxAngleRads;
    revJointDef.enableLimit = YES;
    revJointDef.maxMotorTorque = 10000000;
    revJointDef.referenceAngle = 0;
    revJointDef.enableMotor = YES;
    revJoint = (b2RevoluteJoint *)world->CreateJoint(&revJointDef);
    
    
    // create the catcher (swinging dude)
    CGPoint catcherPos = ccp(anchorPos.x, anchorPos.y - [ropeSprite boundingBox].size.height);
    catcherSprite = [CCSprite spriteWithFile:@"catcher.png"];

    catcherSprite.position = catcherPos;
    [parent addChild:catcherSprite];
    
    b2BodyDef catcherBodyDef;
    catcherBodyDef.type = b2_dynamicBody;
    catcherBodyDef.userData = self;
    catcherBodyDef.position.Set(catcherPos.x/PTM_RATIO, catcherPos.y/PTM_RATIO);
    catcherBody = world->CreateBody(&catcherBodyDef);
    
    b2PolygonShape catcherBox;
    catcherBox.SetAsBox([catcherSprite boundingBox].size.width/PTM_RATIO/2, [catcherSprite boundingBox].size.height/PTM_RATIO/2);
    
    b2FixtureDef catcherFixtureDef;
    catcherFixtureDef.shape = &catcherBox;
    catcherFixtureDef.density = 1.0f;
    catcherFixtureDef.friction = 0.3f;
    catcherFixtureDef.isSensor = YES;
    
    b2Fixture *catcherFixture = catcherBody->CreateFixture(&catcherFixtureDef);
    b2Filter catcherFilter;
    catcherFilter.categoryBits = CATEGORY_CATCHER;
    catcherFilter.maskBits = CATEGORY_JUMPER;
    catcherFixture->SetFilterData(catcherFilter);
    
    b2WeldJointDef catcherJointDef;
    catcherJointDef.Initialize(ropeBody, catcherBody, catcherBody->GetWorldCenter());
    
    catcherJointDef.collideConnected = NO;
    catcherJointDef.bodyA = ropeBody;
    catcherJointDef.bodyB = catcherBody;
    catcherJointDef.localAnchorA = b2Vec2(0, 0);
    catcherJointDef.localAnchorB = b2Vec2(0,[catcherSprite boundingBox].size.height/PTM_RATIO);
    world->CreateJoint(&catcherJointDef);
}

// make the motor oscillate by switching directions when the limits are reached
- (void) updateObject:(ccTime)dt {
    
    // update the sprite positions
    catcherSprite.position = CGPointMake( catcherBody->GetPosition().x * PTM_RATIO, catcherBody->GetPosition().y * PTM_RATIO);
    catcherSprite.rotation = -1 * CC_RADIANS_TO_DEGREES(catcherBody->GetAngle());
    
    ropeSprite.position = CGPointMake( ropeBody->GetPosition().x * PTM_RATIO, ropeBody->GetPosition().y * PTM_RATIO);
    ropeSprite.rotation = -1 * CC_RADIANS_TO_DEGREES(ropeBody->GetAngle());
  
    if (revJoint->GetJointAngle() >= maxAngleRads) {
        revJoint->SetMotorSpeed(-motorSpeed);
    } else if (revJoint->GetJointAngle() <= minAngleRads) {
        revJoint->SetMotorSpeed(motorSpeed);
    }
}

-(void) moveTo:(CGPoint)pos {
//    self.position = pos;
    anchor->SetActive(NO);
    ropeBody->SetActive(NO);
    catcherBody->SetActive(NO);
    

    anchor->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);    

    ropeBody->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
    ropeSprite.position = pos;
    
    // catcher position
    CGPoint catcherPos = ccp(pos.x, pos.y - [ropeSprite boundingBox].size.height/2.1);
    
    //XXX necessary?  Will the weld joint automatically move him with the rope?
    catcherBody->SetTransform(b2Vec2(catcherPos.x/PTM_RATIO, catcherPos.y/PTM_RATIO), 0);
    catcherSprite.position = catcherPos;
    
}

-(void) showAt:(CGPoint)pos {

    // Move the building
    [self moveTo:pos];
    
    // make it active and visible
    [self setVisible:YES];
}

- (GameObjectType) gameObjectType {
    return kGameObjectCatcher;
}

- (void) dealloc {
 
    world->DestroyBody(catcherBody);
    world->DestroyBody(ropeBody);
    world->DestroyBody(anchor);
    
    [parent removeChild:catcherSprite cleanup:YES];
    [parent removeChild:ropeSprite cleanup:YES];
    
    [super dealloc];
}


@end
