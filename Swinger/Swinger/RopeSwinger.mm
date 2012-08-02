//
//  RopeSwinger.m
//  SwingProto
//
//  Created by James Sandoz on 3/16/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "RopeSwinger.h"
#import "Constants.h"
#import "GamePlayLayer.h"
#import "Ground.h"
#import "AudioEngine.h"
#import "Player.h"
#import "Macros.h"
#import "MainGameScene.h"
#import "Notifications.h"

#define USE_ESTIMATED_FORCE 0

#define BASE_JUMP_X 3.5
#define BASE_JUMP_Y 2.5
#define BASE_LENGTH ssipadauto(100)
#define BASE_RATIO 30


@implementation RopeSwinger

@synthesize catcherSprite;
@synthesize anchorPos;
@synthesize swingAngle;
@synthesize period;
@synthesize swingScale;
@synthesize ropeSwivelPosition;
@synthesize poleSprite;
@synthesize grip;
@synthesize poleScale;
@synthesize jumpForce;


- (id) init {
	if ((self = [super init])) {
        screenSize = [[CCDirector sharedDirector] winSize];
        scrollBufferZone = screenSize.width/5;
        
        swingAngle = CC_DEGREES_TO_RADIANS(80);
        gravity = 9.8f;
        ropeLength = 2.0f;
        
        period = 2 * M_PI * sqrtf(ropeLength / gravity);
        CCLOG(@"************ period = %f", period);
    }
    
    return self;
}



- (void) createPhysicsObject:(b2World*)theWorld {
    world = theWorld;
    
    // Calculating the rope length given the period (from levels plist)
    // Shorter rope will swing  
    ropeLength = (gravity * period * period) / (4 * M_PI * M_PI);
    CCLOG(@"********** period = %f ropeLen = %f", period, ropeLength);

    
    poleSprite = [CCSprite spriteWithSpriteFrameName:@"SwingPole1.png"];
    poleSprite.anchorPoint = ccp(0.5,0);
    poleSprite.position = ccp(self.position.x, 0);
    poleSprite.scaleY = poleScale;
    poleSprite.visible = NO;
    [[GamePlayLayer sharedLayer] addChild:poleSprite];
    
    // The pivote point for the pendulum
    ropeSwivelPosition = ccp(poleSprite.position.x, poleSprite.position.y + [poleSprite boundingBox].size.height);
        
    catcherSprite = [CCSprite spriteWithSpriteFrameName:@"Catcher.png"];
        
    CGPoint catcherPos = ccp(anchorPos.x, anchorPos.y - [catcherSprite boundingBox].size.height);
    catcherSprite.position = catcherPos;
    [[GamePlayLayer sharedLayer] addChild:catcherSprite];

    cap = [CCSprite spriteWithSpriteFrameName:@"SwingPoleTop1.png"];
    cap.position = CGPointMake(poleSprite.position.x, poleSprite.position.y + [poleSprite boundingBox].size.height);
    [[GamePlayLayer sharedLayer] addChild:cap];
    
    b2BodyDef catcherBodyDef;
    catcherBodyDef.type = b2_dynamicBody;
    catcherBodyDef.fixedRotation = YES;
    catcherBodyDef.userData = self;
    catcherBodyDef.position.Set(catcherPos.x/PTM_RATIO, catcherPos.y/PTM_RATIO);
    body = world->CreateBody(&catcherBodyDef);
    //body->SetSleepingAllowed(false);
    
    b2PolygonShape catcherBox;
    catcherBox.SetAsBox(([catcherSprite boundingBox].size.width)/PTM_RATIO, ([catcherSprite boundingBox].size.height)/PTM_RATIO);
    
    b2FixtureDef catcherFixtureDef;
    catcherFixtureDef.shape = &catcherBox;
#ifdef USE_CONSISTENT_PTM_RATIO
    catcherFixtureDef.density = 1.f;
#else
    catcherFixtureDef.density = 1.f/ssipad(4.0, 1.0);
#endif
    catcherFixtureDef.friction = 3.0f;
    catcherFixtureDef.isSensor = YES;
    
    collideWithPlayer.categoryBits = CATEGORY_CATCHER;
    collideWithPlayer.maskBits = CATEGORY_JUMPER;
    noCollideWithPlayer.categoryBits = 0;
    noCollideWithPlayer.maskBits = 0;
    
    catcherFixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
    catcherFixtureDef.filter.maskBits = collideWithPlayer.maskBits;
    catcherFixture = body->CreateFixture(&catcherFixtureDef);   
    
    // create the mouse joint to move the catcher
    b2MouseJointDef mouseJointDef;
    mouseJointDef.collideConnected = NO;
    mouseJointDef.bodyA = [[GamePlayLayer sharedLayer] getGround].groundBody;
    mouseJointDef.bodyB = body;
    
    mouseJointDef.maxForce = 10000*body->GetMass();
    mouseJointDef.dampingRatio = 0;
    mouseJointDef.frequencyHz = 100;
    mouseJointDef.target = body->GetPosition();
    
    mouseJoint = (b2MouseJoint *)world->CreateJoint(&mouseJointDef);
    
    
    swingerHead = [CCSprite spriteWithSpriteFrameName:@"Default_H_Swing1.png"];
    swingerHead.position = ccp(ssipad(-18.75*2, -15.75), ssipad(23.23*2, 23.23));
    [catcherSprite addChild:swingerHead];
    swingerHead.visible = NO;
    
    swingerBody = [CCSprite spriteWithSpriteFrameName:@"Default_B_Swing1.png"];
    swingerBody.position = ccp(23.75*ssipad(2, 1), -8.25*ssipad(2, 1));
    [swingerHead addChild:swingerBody];
    
    // calculate the jump force
    [self calcJumpForce];
 }

- (void) calcJumpForce {

#ifdef USE_ESTIMATED_FORCE
    // Estimate an appropriate jump force based on observed values from testing
    float lengthScale = swingScale/BASE_LENGTH;
    lengthScale *= lengthScale;
    
    float anglePeriodScale = CC_RADIANS_TO_DEGREES(swingAngle)/period/BASE_RATIO;
    
    jumpForce = b2Vec2(BASE_JUMP_X*(lengthScale + anglePeriodScale), BASE_JUMP_Y*(lengthScale + anglePeriodScale));
    
    CCLOG(@"\n\n###  set jumpForce=(%f, %f)  length=%f, max angle=%f, period=%f  ###\n\n", jumpForce.x, jumpForce.y, swingScale, CC_RADIANS_TO_DEGREES(swingAngle), period);
    
#else
    // Calculate the effective gravity for the given period and length.
    //   period = 2*pi*sqrt(L/g)
    //
    // Solve for g:
    //   g = (4*pi*pi*L)/period*period
    gravity = (4*M_PI*M_PI*swingScale/PTM_RATIO)/(period*period);
    
    // determine the velocity for half of the max angle (semi arbitrary but seems reasonable)
    // and then break down to the x and y component velocities
    // v = sqrt(2*gravity*ropeLength*(1-cos(angle)))
    float angle = swingAngle/2;
    float velocity = sqrtf(2*gravity*swingScale/PTM_RATIO*(1-cosf(angle)));
    
    float velX = velocity * cosf(angle);
    float velY = velocity * sinf(angle);
    jumpForce = b2Vec2(velX, velY);
    
    CCLOG(@"\n\n###  set gravity=%f, velocity=%f, jumpForce=(%f,%f)  ###\n\n", gravity, velocity, velX, velY);
#endif
}

- (void) swing: (Player *) player {
    
    float limitAngle = CC_RADIANS_TO_DEGREES(swingAngle);
    float currentAngle = -1*catcherSprite.rotation;
    
    if (fabsf((limitAngle - currentAngle) <= 5)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NICE_JUMP object:self];
    }
    
    // jump backwards if on the backswing
    //    if (self.position.x < currentCatcher.position.x) {
    //        jumpForce = b2Vec2(-jumpForce.x, jumpForce.y);
    //    }
    [player getPhysicsBody]->SetLinearVelocity(jumpForce);
}

- (void) createMagneticGrip : (float) radius {
    // destroy any existing magnetic grip
    [self destroyMagneticGrip];
    
    b2CircleShape magneGrip;
    magneGrip.m_radius = radius/PTM_RATIO;
    
    b2FixtureDef magneGripFixtureDef;
    magneGripFixtureDef.shape = &magneGrip;
#ifdef USE_CONSISTENT_PTM_RATIO
    magneGripFixtureDef.density = 0.1f;
#else
    magneGripFixtureDef.density = 0.1f/ssipad(4.0, 1.0);
#endif
    magneGripFixtureDef.friction = 1.0f;
    magneGripFixtureDef.isSensor = YES;
    
    magneGripFixtureDef.filter.categoryBits = collideWithPlayer.categoryBits;
    magneGripFixtureDef.filter.maskBits = collideWithPlayer.maskBits;
    magneticGripFixture = body->CreateFixture(&magneGripFixtureDef); 
}

- (void) destroyMagneticGrip {
    if(magneticGripFixture == nil)
        return;
    
    body->DestroyFixture(magneticGripFixture);
    magneticGripFixture = nil;
}

- (void) setCollideWithPlayer:(BOOL)doCollide {
    if (doCollide) {
        catcherFixture->SetFilterData(collideWithPlayer);
    } else {
        catcherFixture->SetFilterData(noCollideWithPlayer);        
    }
}

- (void) updateObject:(ccTime)dt scale:(float)scale {
    
    Player *player = [[GamePlayLayer sharedLayer] getPlayer];
    
    // Hide if off screen and show if on screen. We should let each object control itself instead
    // of managing everythign from GamePlayLayer. May want to add some buffer so swinger will still 
    // show even if pole is off screen. Convert to world coordinate first, and then compare.
    CGPoint gamePlayPosition = [[GamePlayLayer sharedLayer] getNode].position;
    float worldPos = normalizeToScreenCoord(gamePlayPosition.x, poleSprite.position.x, scale);
    if (worldPos < -scrollBufferZone || worldPos > screenSize.width+scrollBufferZone) {
        if (catcherSprite.visible && player.currentCatcher != self) {
            [self hide];
        }
    } else if (worldPos >= -scrollBufferZone && worldPos <= screenSize.width+scrollBufferZone) {
        if (!catcherSprite.visible) {
            [self show];
        }
    }
    
    //if (!catcherSprite.visible) {
    //    return;
    //}
    
    // Equations used (http://en.wikipedia.org/wiki/Pendulum)
    // period = (2*PI) * sqrt(length/gravity)
    // theta(t) = maxTheta * cos(2*PI*t / period)
        
    float phase = swingAngle * cosf((2*M_PI*(dtSum))/period);
    float x = ropeSwivelPosition.x - swingScale * sinf(phase);
    float y = ropeSwivelPosition.y - (swingScale * cosf(phase));
    dtSum += dt;

    catcherSprite.position = ccp(x, y);
    catcherSprite.rotation = CC_RADIANS_TO_DEGREES(phase);
    
    // Play swing sound fx each time he swings back and forth
    if (player.currentCatcher == self) {
        if (player.state == kSwingerSwinging) {
            previousSign = sign;
            if (phase > 0) {
                sign = kSignPositive;
            } else {
                sign = kSignNegative;
            }
            
            if (previousSign != sign) {
                [[AudioEngine sharedEngine] playEffect:SND_SWOOSH];
            }
        }
    }
    
    mouseJoint->SetTarget(b2Vec2(x/PTM_RATIO, y/PTM_RATIO));
    
    // Displays the correct catcher sprite animation frame based on angle of pendulum
    CCArray *swingHeadFrames = [Player getSwingHeadFrames];
    CCArray *swingBodyFrames = [Player getSwingBodyFrames];
    CCSpriteFrame *headFrame = [swingHeadFrames objectAtIndex:0];
    CCSpriteFrame *bodyFrame = [swingBodyFrames objectAtIndex:0];
    if (catcherSprite.rotation < -22) {
        headFrame = [swingHeadFrames objectAtIndex:4];
        bodyFrame = [swingBodyFrames objectAtIndex:4];
    } else if (catcherSprite.rotation < -7) {
        headFrame = [swingHeadFrames objectAtIndex:3];
        bodyFrame = [swingBodyFrames objectAtIndex:3];
    } else if (catcherSprite.rotation < 7) {
        headFrame = [swingHeadFrames objectAtIndex:2];
        bodyFrame = [swingBodyFrames objectAtIndex:2];
    } else if (catcherSprite.rotation < 22) {
        headFrame = [swingHeadFrames objectAtIndex:1];
        bodyFrame = [swingBodyFrames objectAtIndex:1];
    }
    
    [swingerHead setDisplayFrame:headFrame];
    [swingerBody setDisplayFrame:bodyFrame];

    // Draw the rope. Using a CCLayerColor instead of doing it in
    // OpenGL draw so that z-order issues can be easily managed.
    if (rope == nil) {
        float xDiff = poleSprite.position.x - x;
        float yDiff = (poleSprite.position.y + [poleSprite boundingBox].size.height) - (y);
        float dist = (sqrt(xDiff*xDiff + yDiff*yDiff)/catcherSprite.scale - 17*ssipad(2, 1));
        
        ccColor4B color = ccc4(51,102,153,255);
        
        if ([[[MainGameScene sharedScene] world] isEqualToString: WORLD_FOREST_RETREAT]) {
            color = ccc4(255,255,255,255);
        }
        
        rope = [CCLayerColor layerWithColor:color width:2 height:dist];
        [catcherSprite addChild:rope];

        rope.position = ccp(17*ssipad(2, 1), 45*ssipad(2, 1));
    }
    
    [self scaleTrajectoryPoints: scale];
}

- (void) scaleTrajectoryPoints: (float) currentScale {
    
    if (currentScale > 1) {
        currentScale = 1;
    }
    
    for (CCSprite * dot in dashes) {
        if (!dot.visible) {
            break;
        }
        dot.scale = 1/currentScale;
    }
}

/**
 * Draw the trajectory at the angle which it can shoot the player the furthest - usually 45 degrees
 * If the cannon does not sweep through angle 45 then we plot the trajectory at its largest angle
 */
- (void) drawTrajectory {
    
    if (trajectoryDrawn) {
        return;
    }
    
    double angleDegs = 90;
    double swingAngleDegs = CC_RADIANS_TO_DEGREES(swingAngle);
    
    if (swingAngleDegs < angleDegs) {
        angleDegs = swingAngleDegs;
    }
    
    angleDegs = 90 - angleDegs;
    
    b2Vec2 windForce = b2Vec2(0,0);
    
    if (wind != nil) {
        windForce = [wind getWindForce:1];
    }
    
    double angle = CC_DEGREES_TO_RADIANS(angleDegs);
    b2Vec2 origin = b2Vec2((ropeSwivelPosition.x/PTM_RATIO), (ropeSwivelPosition.y/PTM_RATIO));
    float x0 = origin.x + (((swingScale)/PTM_RATIO) * cosf(angle)) + (([catcherSprite boundingBox].size.width/2) - ssipadauto(10))/PTM_RATIO; // starting x position in meters
    float y0 = origin.y - (((swingScale)/PTM_RATIO) * sinf(angle)) - ssipadauto(10)/PTM_RATIO; // starting y position in meters
    float v01 = jumpForce.x + 3 + windForce.x; // initial x velocity in meters/sec + small buffer + wind force
    float v02 = jumpForce.y + 3 + windForce.y; // initial y velocity in meters/sec + small buffer + wind force
    
    float g = fabsf(world->GetGravity().y); // gravity in meters/sec + a small buffer
    
    float v0x = v01*cos(angle);
    float v0y = v02*sin(angle);
    
     // range of the swing in meters + buffer since range is based on origin, and player lands below origin
    float range = ((2*(v0x*v0y))/g) + 2 + ((swingScale + [catcherSprite boundingBox].size.height)/PTM_RATIO);
    
    float t = 0; // time in seconds
    float stepAmt = v01/400; //0.05; // time step in fractions of a second
    
    dashes = [[CCArray alloc] init];
    while(true) 
    {
        float xPos = x0 + (cosf(angle)*v01*t); // x position over time
        float yPos = y0 + ((sinf(angle)*v02*t) - (g/2)*pow(t,2)); // y position over time taking gravity into consideration
        
        //CCLOG(@"DRAWING DASH AT %f,%f", xPos*PTM_RATIO, yPos*PTM_RATIO);
        
        CGPoint pos = ccp((xPos*PTM_RATIO), (yPos*PTM_RATIO));
        [dashes addObject:[[GamePlayLayer sharedLayer] addTrajectoryPoint: pos]];
        
        t += stepAmt;
        
        if (xPos > (x0 + range)) {
            break;
        }
    }
    
    trajectoryDrawn = YES;
}


-(void) moveTo:(CGPoint)pos {
    self.position = pos;
    
    // catcher position
    CGPoint catcherPos = ccp(pos.x, pos.y);
    
    //XXX necessary?  Will the weld joint automatically move him with the rope?
    body->SetTransform(b2Vec2(catcherPos.x/PTM_RATIO, catcherPos.y/PTM_RATIO), 0);
    catcherSprite.position = catcherPos;
    
    poleSprite.position = ccp(pos.x, pos.y);
    cap.position = CGPointMake(pos.x, pos.y + [poleSprite boundingBox].size.height);
    
    ropeSwivelPosition = ccp(poleSprite.position.x, poleSprite.position.y + [poleSprite boundingBox].size.height);
}

-(void) showAt:(CGPoint)pos {

    // Move the building
    [self moveTo:pos];
    [self show];
}

- (GameObjectType) gameObjectType {
    return kGameObjectCatcher;
}

- (void) hide {
    if(!swingerHead.visible) {
        [catcherSprite setVisible:NO];
        [rope setVisible:NO];
        swingerHead.visible = NO;
        [self showTrajectory: NO];
    
        body->SetActive(NO);
    }
}

- (void) show {
    [catcherSprite setVisible:YES];
    [rope setVisible:YES];
    
    // Looks like there is a delay with the mouse joint. Move it initially.
    body->SetTransform(b2Vec2(catcherSprite.position.x/PTM_RATIO, catcherSprite.position.y/PTM_RATIO), 0);
    
    if (swingerHead.visible) {
        [self showTrajectory:YES];
    } else {
        [self showTrajectory:NO];
    }

    body->SetActive(YES);
}

- (void) showTrajectory: (BOOL) show {
    
    if (dashes == nil) {
        [self drawTrajectory];
    }
    
    for (CCSprite * dash in dashes) {
        [dash setVisible:show];
    }
}

#pragma mark - CatcherGameObject protocl

- (void) setSwingerVisible:(BOOL)visible {
    swingerHead.visible = visible;
    [self showTrajectory:visible];
    
}

- (CGPoint) getCatchPoint {
    return catcherSprite.position;
}

- (float) getHeight {
    return poleSprite.position.y + [poleSprite boundingBox].size.height;
}

- (void) reset {
    [self setSwingerVisible:NO];
    [super reset];
}

- (void) dealloc {
    CCLOG(@"------------------------------ RopeSwinger being deallocated");

    // DO NOT DESTROY PHYSICS OBJECTS HERE!
    // SOMETHING WILL CALL destroyPhysicsObject
    [cap removeFromParentAndCleanup:YES];
    [swingerBody removeFromParentAndCleanup:YES];
    [swingerHead removeFromParentAndCleanup:YES];
    [rope removeFromParentAndCleanup:YES];
    [catcherSprite removeFromParentAndCleanup:YES];
    [poleSprite removeFromParentAndCleanup:YES];
    
    if (dashes != nil) {
        // clean up trajectory dashes
        for (CCSprite * dash in dashes) {
            [dash removeFromParentAndCleanup:YES];
        }
        
        [dashes removeAllObjects];
        [dashes release];
        dashes = nil;
    }
    
    [super dealloc];
}



@end
