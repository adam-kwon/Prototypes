//
//  Player.m
//  Grappler
//
//  Created by James Sandoz on 8/3/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Player.h"

#import "GamePlayLayer.h"

#define MIN_ROPE_LENGTH 2

@implementation Player

@synthesize currentAnchor;
@synthesize maxRopeLength;
@synthesize swingJoint;


- (id) init {
    if ((self = [super init])) {

    }
    
    return self;
}

- (void) swingFrom:(b2Body *)anchor {
    CCLOG(@"In swingFrom, anchor pos=(%f,%f)[%f,%f], player pos=(%f,%f)[%f,%f]{%f,%f}\n",
          anchor->GetPosition().x, anchor->GetPosition().y, 
          anchor->GetPosition().x*PTM_RATIO, anchor->GetPosition().y*PTM_RATIO, 
          body->GetPosition().x, body->GetPosition().y,
          body->GetPosition().x*PTM_RATIO, body->GetPosition().y*PTM_RATIO,
          self.position.x, self.position.y);
    
    float xDelta = anchor->GetPosition().x - body->GetPosition().x;
    float yDelta = anchor->GetPosition().y - body->GetPosition().y;
    float distance = sqrtf(xDelta*xDelta + yDelta*yDelta);
    
    b2DistanceJointDef jointDef;
    jointDef.Initialize(body, anchor, body->GetPosition(), anchor->GetPosition());
    
//    jointDef.localAnchorA = b2Vec2(-20/PTM_RATIO, 16/PTM_RATIO);
    swingJoint = (b2DistanceJoint *)world->CreateJoint(&jointDef);
    
    CCLOG(@"  calc distance=%f, joint dist=%f\n", distance, swingJoint->GetLength());
    
    if (swingJoint->GetLength() > maxRopeLength) {
        ropeLengthDelta = swingJoint->GetLength() - maxRopeLength;
    } else {
        ropeLengthDelta = 0;
    }
    
    float xForce = 15.f;
    float yForce = 0.f;
    if (body->GetPosition().x > anchor->GetPosition().x) {
        xForce *= -1;
    }
    body->ApplyLinearImpulse(b2Vec2(xForce, yForce), body->GetPosition());
    
    currentAnchor = anchor;
}


- (void) destroyRopeJoint {
    currentAnchor = NULL;
    world->DestroyJoint(swingJoint);
    swingJoint = NULL;
}

- (void) shortenRope:(float)dt {
    float newLength = swingJoint->GetLength() - 5*dt;
    if (newLength >= MIN_ROPE_LENGTH) {
        swingJoint->SetLength(newLength);
        
        float xForce = 10*dt;
        float yForce = 10*dt;
        
        if (body->GetLinearVelocity().x < 0) {
            xForce *= -1;
        }
        
        if (body->GetLinearVelocity().y < 0) {
            yForce *= -1;
        }
        
        body->ApplyLinearImpulse(b2Vec2(xForce, yForce), body->GetWorldCenter());
        
        
        //XXX figure out a smarter way to do this, but for now just amplify the
        //XXX current velocity
//        b2Vec2 currVel = body->GetLinearVelocity();
//        body->SetLinearVelocity(b2Vec2(currVel.x*1.5*dt, currVel.y*1.5*dt));
    }
}

- (void) dealloc {
    
    [super dealloc];
}


#pragma mark - GameObject protocol
- (GameObjectType) gameObjectType {
    return kGameObjectPlayer;
}

- (void) updateObject:(ccTime)dt {
    self.position = CGPointMake( body->GetPosition().x * PTM_RATIO, body->GetPosition().y * PTM_RATIO);
    self.rotation = -1 * CC_RADIANS_TO_DEGREES(body->GetAngle());

    //XXX changed to allow any length and holding tap shortens the rope
//    if (swingJoint != NULL && swingJoint->GetLength() > maxRopeLength) {
//        // shorten the rope length over 1 second
//        float jointDelta = ropeLengthDelta*dt;
//        swingJoint->SetLength(swingJoint->GetLength() - jointDelta);
//        
//        //XXX not sure how much of a performance hit this is
//        [[GamePlayLayer sharedLayer] updateVRope];
//    }
}

- (BOOL) isSafeToDelete {
    return safeToDelete;
}

- (void) safeToDelete {
    safeToDelete = YES;
}

- (void) show {
    self.visible = YES;
    body->SetActive(YES);
}

- (void) hide {
    self.visible = NO;
    body->SetActive(NO);
}

-(void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    body->SetTransform(b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO), 0);
}

- (void) showAt:(CGPoint)pos {
    [self moveTo:pos];
    [self show];
}



#pragma mark - PhysicsObject protocol
- (void) createPhysicsObject:(b2World *)theWorld {
    
    world = theWorld;
    
    CGPoint p = ccp(0,0);
    
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    bodyDef.userData = self;
    body = world->CreateBody(&bodyDef);
    
    // Set the body to the size of the sprite
    b2PolygonShape shape;
    shape.SetAsBox(self.contentSize.width/PTM_RATIO/2 * self.scale, self.contentSize.height/PTM_RATIO/2 * self.scale);
    
    b2FixtureDef fixtureDef;
    fixtureDef.shape = &shape;
    fixtureDef.density = 1.f;
    fixtureDef.friction = 1.f;
    fixtureDef.filter.categoryBits = CATEGORY_PLAYER;
    fixtureDef.filter.maskBits = CATEGORY_PLAYER;
    body->CreateFixture(&fixtureDef);
}

- (void) destroyPhysicsObject {
    
}

- (b2Body*) getPhysicsBody {
    return body;
}

@end
