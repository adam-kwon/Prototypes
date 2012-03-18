//
//  ContactListener.m
//  Scroller
//
//  Created by min on 1/16/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "ContactListener.h"
#import "Constants.h"
#import "GamePlayLayer.h"
#import "GamePlayLayer.h"

#define IS_RUNNER(x,y)              ([x gameObjectType] == kGameObjectRunner || [y gameObjectType] == kGameObjectRunner)
#define IS_PLATFORM(x,y)            ([x gameObjectType] == kGameObjectPlatform || [y gameObjectType] == kGameObjectPlatform)
#define IS_METEOR(x,y)              ([x gameObjectType] == kGameObjectMeteor || [y gameObjectType] == kGameObjectMeteor)
#define IS_SPEED_BOOST(x,y)         ([x gameObjectType] == kGameObjectPowerUpSpeedBoost || [y gameObjectType] == kGameObjectPowerUpSpeedBoost)
#define IS_DOUBLE_JUMP(x,y)         ([x gameObjectType] == kGameObjectPowerUpDoubleJump || [y gameObjectType] == kGameObjectPowerUpDoubleJump)
#define IS_SPEED_BOOST_EXT(x,y)     ([x gameObjectType] == kGameObjectPowerUpSpeedBoostExtender || [y gameObjectType] == kGameObjectPowerUpSpeedBoostExtender)
#define IS_FLIGHT(x,y)              ([x gameObjectType] == kGameObjectPowerUpFlight || [y gameObjectType] == kGameObjectPowerUpFlight)
#define IS_THERMAL_WIND(x,y)        ([x gameObjectType] == kGameObjectThermalWind || [y gameObjectType] == kGameObjectThermalWind)
#define IS_DESTRUCTIBLE_BLOCK(x,y)  ([x gameObjectType] == kGameObjectDestructibleBlock || [y gameObjectType] == kGameObjectDestructibleBlock)
#define IS_ENERGY_POINT(x,y)        ([x gameObjectType] == kGameObjectEnergyPoint || [y gameObjectType] == kGameObjectEnergyPoint)
#define IS_FORCE_FIELD(x, y)        ([x gameObjectType] == kGameObjectForceField || [y gameObjectType] == kGameObjectForceField)
#define IS_MISSILE(x,y)             ([x gameObjectType] == kGameObjectMissile || [y gameObjectType] == kGameObjectMissile)
#define IS_LOGO(x, y)               ([x gameObjectType] == kGameObjectLogo || [y gameObjectType] == kGameObjectLogo)
#define IS_ZOMBIE(x, y)             ([x gameObjectType] == kGameObjectZombie || [y gameObjectType] == kGameObjectZombie) 
#define IS_ATTACKING_ZOMBIE(x, y)   ([x gameObjectType] == kGameObjectAttackingZombie || [y gameObjectType] == kGameObjectAttackingZombie) 
#define IS_SURVIVOR(x, y)           ([x gameObjectType] == kGameObjectSurvivor || [y gameObjectType] == kGameObjectSurvivor) 
#define IS_LEVITATING_SURVIVOR(x, y)([x gameObjectType] == kGameObjectLevitatingSurvivor || [y gameObjectType] == kGameObjectLevitatingSurvivor) 
#define IS_NUKE(x,y)                ([x gameObjectType] == kGameObjectNuke || [y gameObjectType] == kGameObjectNuke)
#define IS_ENERGY_DOUBLER(x, y)     ([x gameObjectType] == kGameObjectEnergyDoubler || [y gameObjectType] == kGameObjectEnergyDoubler)

#define GAMEOBJECT_OF_TYPE(class, type, o1, o2)    (class*)([o1 gameObjectType] == type ? o1 : o2)

ContactListener::ContactListener() {
}

ContactListener::~ContactListener() {
}


void ContactListener::BeginContact(b2Contact *contact) {
	CCNode<GameObject> *o1 = (CCNode<GameObject>*)contact->GetFixtureA()->GetBody()->GetUserData();
	CCNode<GameObject> *o2 = (CCNode<GameObject>*)contact->GetFixtureB()->GetBody()->GetUserData();    
}

// EndContact is called when the contact end OR when the body is destroyed.
void ContactListener::EndContact(b2Contact *contact) {    
	CCNode<GameObject> *o1 = (CCNode<GameObject>*)contact->GetFixtureA()->GetBody()->GetUserData();
	CCNode<GameObject> *o2 = (CCNode<GameObject>*)contact->GetFixtureB()->GetBody()->GetUserData();    
}

void ContactListener::PreSolve(b2Contact *contact, const b2Manifold *oldManifold) {
}

void ContactListener::PostSolve(b2Contact *contact, const b2ContactImpulse *impulse) {
}