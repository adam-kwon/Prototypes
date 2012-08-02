//
//  ContactListener.h
//  SwingProto
//
//  Created by James Sandoz on 3/16/12.
//  Copyright 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Box2D.h"
#import "GameObject.h"

class ContactListener : public b2ContactListener {
    
public:

	ContactListener();
	~ContactListener();
    
    void handleCatcherJumperCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperCannonCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperCoinCollison(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperElephantCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperFinalPlatformCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperGroundCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperSpringCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperStarCollison(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperWheelCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location);
    void handleJumperFireRingCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2);
    void handleJumperFloatingPlatformCollision(CCNode<GameObject> *o1, CCNode<GameObject> *o2, CGPoint location);
    
	virtual void BeginContact(b2Contact *contact);
	virtual void EndContact(b2Contact *contact);
	virtual void PreSolve(b2Contact *contact, const b2Manifold *oldManifold);
	virtual void PostSolve(b2Contact *contact, const b2ContactImpulse *impulse);
};

