//
//  Building.m
//  Scroller
//
//  Created by James on 3/11/11.
//  Copyright 2011 L00Kout. All rights reserved.
//

#import "Building.h"
#import "SimpleAudioEngine.h"

#define BLDG_CORNER_LEFT    0
#define BLDG_CORNER_RIGHT   1
#define BLDG_SIDE_TOP       2
#define BLDG_SIDE_LEFT      4
#define BLDG_SIDE_RIGHT     3
#define BLDG_INSIDE         5


@implementation Building

@synthesize size;
@synthesize isLandingBuilding;
@synthesize numTilesHigh;
@synthesize isCrumbling;

- (id) initAt:(int)x_offset isLanding:(BOOL)isLanding withHeight:(int)noTilesHigh {
    if ((self = [super init]))
    {        
        gameObjectType = kGameObjectPlatform;
        isLandingBuilding = NO;        
        if (!isLanding && noTilesHigh == 0) {
            numTilesWide = BUILDING_MIN_WIDTH_TILES + (CCRANDOM_0_1() * (BUILDING_MAX_WIDTH_TILES - BUILDING_MIN_WIDTH_TILES));
            numTilesHigh = BUILDING_MIN_HEIGHT_TILES + (CCRANDOM_0_1() * (BUILDING_MAX_HEIGHT_TILES - BUILDING_MIN_HEIGHT_TILES));
        } else if (!isLanding && noTilesHigh > 0) {
            numTilesWide = BUILDING_MIN_WIDTH_TILES + (CCRANDOM_0_1() * (BUILDING_MAX_WIDTH_TILES - BUILDING_MIN_WIDTH_TILES));
            numTilesHigh = noTilesHigh;
        } else if (isLanding) {
            numTilesWide = BUILDING_MAX_WIDTH_TILES * 3;
            numTilesHigh = BUILDING_MIN_HEIGHT_TILES + 1;
            isLandingBuilding = YES;
        }

        batch = [CCSpriteBatchNode batchNodeWithFile:@"BuildingTileAtlas.png" capacity:572];
        [self addChild:batch];
        
        // x and y coordinates for setting the individual tile positions
        float x=0, y=0;
        
        // Build from the bottom up
        for (int i=0; i <= numTilesHigh; i++)
        {
            CCSprite *left;
            CCSprite *right;
            NSString *insideTile;        
            
            // If we are at the top of the building use the top tiles,
            // otherwise use side tiles
            if (i == numTilesHigh)
            {
                left  = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"BuildingTile1-%d.png", BLDG_CORNER_LEFT]];
                right = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"BuildingTile1-%d.png", BLDG_CORNER_RIGHT]];
                insideTile = [NSString stringWithFormat:@"BuildingTile1-%d.png", BLDG_SIDE_TOP];
            }
            else
            {
                left  = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"BuildingTile1-%d.png", BLDG_SIDE_LEFT]];
                right = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"BuildingTile1-%d.png", BLDG_SIDE_RIGHT]];
                insideTile = [NSString stringWithFormat:@"BuildingTile1-%d.png", BLDG_INSIDE];
            }
            
            // reinitialize x to 0
            x=0;
            
            // setup the left tile and add it as a child
            left.anchorPoint = ccp(0,0);
            left.position = ccp(x, y);
            [left.texture setAliasTexParameters];
            [batch addChild:left];
            
            // update the position
            x += [left boundingBox].size.width;
            
            // The leftmost and rightmost tiles are handled outside of this loop
            // which is why we only iterate numTilesWide-2 times
            for (int j=0; j < (numTilesWide-2); j++)
            {
                CCSprite *inside = [CCSprite spriteWithSpriteFrameName:insideTile];
                inside.anchorPoint = ccp(0,0);
                inside.position = ccp(x,y);
                [inside.texture setAliasTexParameters];
                [batch addChild:inside];
                
                // update the position
                x += ([inside boundingBox].size.width - 2);
            }
            
            // Add the rightmost tile
            right.anchorPoint = ccp(0,0);
            right.position = ccp(x,y);
            [right.texture setAliasTexParameters];
            [batch addChild:right];
            
            // update the width and y and reset x for the next row
            x += ([right boundingBox].size.width - 2);
            y += ([right boundingBox].size.height - 2);
        }
        
        // set the position + size
        self.position = ccp(x_offset, 0);
        size = CGSizeMake(x, y);
        
//        CCLOG(@"  building created at (%.02f, %.02f) size=(%.02f, %.02f)",
//              position_.x, position_.y, size.width, size.height);
    }
    
    return self;   
}

- (id) initBuildingWithHeight:(int)noTilesHigh {
    return [self initAt:-10000 isLanding:NO withHeight:noTilesHigh];
}

- (id) initAt:(int)x_offset {
    return [self initAt:x_offset isLanding:NO withHeight:0];
}


- (id) initLandingBuilding {
    return [self initAt:-20000 isLanding:YES withHeight:0];
}

- (void) createPhysicsObject:(b2World *)theWorld
{
    [super createPhysicsObject:theWorld];
//	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    world = theWorld;
    
    //
    // Create the Box2D collision object for the building
    //

    CGPoint p = ccp(position_.x + size.width/2, size.height/2);
        
    // Hardcoding relevant values from drawCollisionTiles method
    float rotation = 0.0f;
    float friction = 0.0f;
    float density = 0.001f;
    float restitution = 0.0;
    
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.angle = rotation * M_PI/180;
//    bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
    
	bodyDef.userData = self;
	body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
    //These are mid points for our 1m box
	dynamicBox.SetAsBox((size.width+JUMP_ERROR_BUFFER+20)/2/PTM_RATIO, size.height/2/PTM_RATIO);
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = density;
	fixtureDef.friction = friction;
	fixtureDef.restitution = restitution;
	body->CreateFixture(&fixtureDef);
    
    body->SetTransform(b2Vec2((p.x+JUMP_ERROR_BUFFER)/PTM_RATIO, p.y/PTM_RATIO), 0);
}


-(void)setVisible:(BOOL)v
{
    [super setVisible:v];
    body->SetActive(v);
    [batch setVisible:v];
}

- (void) updateObject:(ccTime)dt {
    if (isCrumbling) {
        if (self.position.y <= -size.height) {
            [self stopAllActions];
            [self setVisible:NO];
            self.position = ccp(-10000.0f, 0.0f);
            isCrumbling = NO;
        }
    }
}

- (void) moveUp {
    body->SetTransform(b2Vec2(body->GetPosition().x, body->GetPosition().y + 3.0f / PTM_RATIO), 0);
    self.position = ccp(self.position.x, self.position.y + 3.0f);
}

- (void) moveDown {
    body->SetTransform(b2Vec2(body->GetPosition().x, body->GetPosition().y - 7.0f / PTM_RATIO), 0);
    self.position = ccp(self.position.x, self.position.y - 7.0f);
}

- (void) stopCrumble {
    if (isCrumbling) {
        isCrumbling = NO;
        [self stopAllActions];
    }
}

- (void) crumble {
    if (isLandingBuilding || isCrumbling) {
        return;
    }
    isCrumbling = YES;
    [[SimpleAudioEngine sharedEngine] playEffect:@"crumble.caf"];
    id seq = [CCSequence actions:[CCCallFunc actionWithTarget:self selector:@selector(moveUp)], 
                                                                            [CCDelayTime actionWithDuration:0.05f],
                                                                            [CCCallFunc actionWithTarget:self selector:@selector(moveDown)],
                                                                            [CCDelayTime actionWithDuration:0.05f],
                                                                            nil];
    id rep = [CCRepeat actionWithAction:seq times:ceil(size.height)];
    [self runAction:rep];
}
@end
