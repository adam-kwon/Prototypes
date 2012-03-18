//
//  Constants.h
//  cloudjump
//
//  Created by Min Kwon on 3/9/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#ifndef cloudjump_Constants_h
#define cloudjump_Constants_h

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// Define game object types here
typedef enum {
	kGameObjectNone,                            // 0
    kGameObjectPlayer,
    kGameObjectEnergy
} GameObjectType;

typedef enum {
    kLifeStateNone,
    kLifeStateAlive,
    kLifeStateDead
} LifeState;

#endif
