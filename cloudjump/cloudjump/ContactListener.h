//
//  ContactListener.h
//  Scroller
//
//  Created by min on 1/16/11.
//  Copyright 2011 GAMEPEONS LLC. All rights reserved.
//

#import "Box2D.h"
#import "GameObject.h"
#import "cocos2d.h"

class ContactListener : public b2ContactListener {
	CFTimeInterval  startContactTime;
public:
	ContactListener();
	~ContactListener();
	
    void handlePlatformPlayerCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handlePlatformZombieCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handlePlatformMeteorCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handlePlatformMissileCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    
    void handleRunnerAttackingZombieCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleRunnerZombieCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleRunnerThermalWindCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleRunnerEnergyPointCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleRunnerMeteorCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleRunnerMissileCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleRunnerSurvivorCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleRunnerNukeCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleRunnerEnergyDoublerCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleRunnerLevitatingSurvivorCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    
    void handleForceFieldMeteorCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleForceFieldMissileCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleForceFieldZombieCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);

    void handleZombieThermalWindCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleZombieMeteorCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleZombieNukeCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleZombieSurvivorCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    
    void handleSurvivorMeteorCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleSurvivorNukeCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    
    
	virtual void BeginContact(b2Contact *contact);
	virtual void EndContact(b2Contact *contact);
	virtual void PreSolve(b2Contact *contact, const b2Manifold *oldManifold);
	virtual void PostSolve(b2Contact *contact, const b2ContactImpulse *impulse);
};