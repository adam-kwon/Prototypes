//
//  Constants.h
//  SwingProto
//
//  Created by James Sandoz on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef SwingProto_Constants_h
#define SwingProto_Constants_h

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

#define CATEGORY_HOLDER     0x0000
#define CATEGORY_ANCHOR     0x0000
#define CATEGORY_ROPE       0x0001
#define CATEGORY_CATCHER    0x0002
#define CATEGORY_JUMPER     0x0004


#define MOTOR_SPEED 3


typedef enum {
    kGameObjectNone,
    kGameObjectCatcher,
    kGameObjectJumper
} GameObjectType;

typedef enum {
    kContactNone,
    kContactTop,
    kContactBottom
} ContactLocation;

#endif
