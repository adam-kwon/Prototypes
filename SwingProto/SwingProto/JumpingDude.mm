//
//  JumpingDude.m
//  SwingProto
//
//  Created by James Sandoz on 3/25/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "JumpingDude.h"


@implementation JumpingDude

@synthesize body;
@synthesize sprite;


-(id) initWithParent:(CCNode *)theParent {
	if ((self = [super init])) {
        parent = theParent;
        
        top = kContactTop;
        bottom = kContactBottom;
    }
    
    return self;
}

- (void) createPhysicsObject:(b2World*)theWorld at:(CGPoint)p {

    world = theWorld;
    
    sprite = [CCSprite spriteWithFile:@"jumper.png"];
    sprite.position = p;
    [parent addChild:sprite];
    
    b2BodyDef jumperBodyDef;
    jumperBodyDef.type = b2_dynamicBody;
    jumperBodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    jumperBodyDef.userData = self;
    body = world->CreateBody(&jumperBodyDef);
    
//    b2PolygonShape jumperBox;
//    jumperBox.SetAsBox([sprite boundingBox].size.width/PTM_RATIO/2, [sprite boundingBox].size.height/PTM_RATIO/2);
//    
//    b2FixtureDef jumperFixtureDef;
//    jumperFixtureDef.shape = &jumperBox;
//    jumperFixtureDef.density = 2.0f;
//    jumperFixtureDef.friction = 0.3f;
//    b2Fixture *jumperFixture = body->CreateFixture(&jumperFixtureDef);
    
    b2Filter jumperFilter;
    jumperFilter.categoryBits = CATEGORY_JUMPER;
    jumperFilter.maskBits = CATEGORY_CATCHER;
//    jumperFixture->SetFilterData(jumperFilter);
    
    b2PolygonShape topShape;
    topShape.SetAsBox([sprite boundingBox].size.width/PTM_RATIO/2, [sprite boundingBox].size.height/PTM_RATIO/4, b2Vec2(0, [sprite boundingBox].size.height/PTM_RATIO/4), 0);
    b2FixtureDef topFixtureDef;
    topFixtureDef.shape = &topShape;
    topFixtureDef.density = 2.0f;
    topFixtureDef.friction = 0.3f;
    b2Fixture *topFixture = body->CreateFixture(&topFixtureDef);
    topFixture->SetFilterData(jumperFilter);
    topFixture->SetUserData(&top);
    
    b2PolygonShape bottomShape;
    bottomShape.SetAsBox([sprite boundingBox].size.width/PTM_RATIO/2, [sprite boundingBox].size.height/PTM_RATIO/4, b2Vec2(0, -[sprite boundingBox].size.height/PTM_RATIO/4), 0);
    b2FixtureDef bottomFixtureDef;
    bottomFixtureDef.shape = &bottomShape;
    bottomFixtureDef.density = 2.0f;
    bottomFixtureDef.friction = 0.3f;
    b2Fixture *bottomFixture = body->CreateFixture(&bottomFixtureDef);
    bottomFixture->SetFilterData(jumperFilter);
    bottomFixture->SetUserData(&bottom);
}


- (void) updateObject:(ccTime)dt {
    sprite.position = CGPointMake( body->GetPosition().x * PTM_RATIO, body->GetPosition().y * PTM_RATIO);
    sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(body->GetAngle());
}



- (GameObjectType) gameObjectType {
    return kGameObjectJumper;
}


@end
