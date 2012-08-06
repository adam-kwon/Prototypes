//
//  Constants.h
//  Grappler
//
//  Created by James Sandoz on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef Grappler_Constants_h
#define Grappler_Constants_h


//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32


typedef enum {
    kGameObjectNone,
    kGameObjectPlayer
} GameObjectType;

#define CATEGORY_PLAYER 0x0000
#define CATEGORY_ANCHOR 0x0001

#endif
