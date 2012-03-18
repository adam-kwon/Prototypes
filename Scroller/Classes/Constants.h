/*
 *  Constants.h
 *  Scroller
 *
 *  Created by min on 1/11/11.
 *  Copyright 2011 Min Kwon. All rights reserved.
 *
 */

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32.0f

#define GAME_MUSIC			"DONOTUSEFORRELEASEoutlands.mp3"
#define MENU_MUSIC			"MindHeist_Inception.mp3"

/* 
 * ANIMATION_SPEED is how fast the guy appears to be running. 
 * RUN_SPEED is the actual scroll speed.
 * Both values work together to make running look natural.
 */
#define MAX_RUN_SPEED                       18.1f
#define MAX_RUN_SPEED_ADJ                   (MAX_RUN_SPEED / 2.25)  // Adjust this along with MAX_RUN_SPEED above
#define INITIAL_RUN_SPEED                   1.1f    
#define RUN_ACCELERATION_FORCE              5.0f
#define RUN_DECELERATION_FORCE              2.0f
#define RUN_DECELERATION_FORCE_ENTRANCE     (RUN_DECELERATION_FORCE*1.5)
#define RUN_DECELERATION_FORCE_AFTER_FLIGHT 6.5f
#define PLAYER_LEADOUT_OFFSET               100.0f			// Offset from left edge of screen
#define COOL_OFF_SPEED                      60.0f
#define FLIGHT_ATTEMPT_GRAVITY              -9.0f
#define FLIGHT_CHECK_FREQUENCY              (1.f/10)
#define FLIGHT_TIME_PER_POWERUP             5.0f
#define FLIGHTBAR_UNIT_SIZE                 5.0f

#define JUMP_ERROR_BUFFER                   25.0f

#define ZOOM_BACKMOST_PARALLAX              1

/*
 * MAX_IN_AIR_THRESHOLD if player is in air longer than this amount, he will roll when he lands.
 *      The max on a normal jump is around 1.31.
 * PLAYER_ROLL_THRESHOLD is the threshold distance for rolling. On a normal jump, the max height that the player can
 *      reach is around 4.166538. Max double jump can read over 10. 
 */
#define MAX_IN_AIR_TRESHOLD_NORMAL_JUMP         1.3f           
#define MAX_IN_AIR_TRESHOLD_LONG_JUMP           1.8f
#define ROLL_THRESHOLD_NORMAL_HEIGHT            4.0f
#define ROLL_THRESHOLD_HIGH_HEIGHT              7.0f

/*
 * GRAVITY is the world gravity.
 * FLOAT_FORCE is the upward force applied to the player when the mouse button is held down
 *		to give it a more epic feel to the jump.
 * JUMP_IMPULSE_FORCE is the initial impulse force applied to the player to catapult him up
 */
#define HIT_CIRCLE_RADIUS	0.3f
#define GRAVITY				-55.0f
#define JUMP_IMPULSE_FORCE	13.0f
#define FLOAT_FORCE			37.0f
#define PLAYER_SCALE		1.0f
#define PLAYER_Y_OFFSET		33.0


/*
 * Zoom constants.
 */
#define ZOOM_FACTOR		1.0f
#define ZOOM_OUT_FACTOR 0.3f
#define SMOOTH_ZOOM		1
#define ZOOM_RATE		0.5 // pixels/sec
#define MAX_ZOOM_OUT    0.3f

#define TAG_METEOR                  7000
#define TAG_METEOR_EXPLODE          7010
#define TAG_POWERUP_EXPLODE         7020
#define TAG_PARTICLE_SYSTEM_RAIN    7030
#define TAG_STATIC_BG_LAYER         7040

/*
 * Uncomment just one from below
 */
#define USE_SEMI_FIXED_TIMESTEP 1
//#define USE_FIXED_TIMESTEP      1
//#define USE_VARIABLE_TIMESTEP   1


// Define game object types here
typedef enum {
	kGameObjectNone,
	kGameObjectRunner,
	kGameObjectMeteor,
	kGameObjectGround,
	kGameObjectPowerUp,
    kGameObjectPowerUpSpeedBoost,
    kGameObjectPowerUpDoubleJump,
    kGameObjectPowerUpSpeedBoostExtender,
    kGameObjectPowerUpFlight,
	kGameObjectPlatform,
    kGameObjectCrow
} GameObjectType;

/*
 * Random Building Generation Constants
 * All values refer to a number of tiles
 */
#define USE_RANDOM_BUILDINGS        1

#define BUILDING_MIN_HEIGHT_TILES   1
#define BUILDING_MAX_HEIGHT_TILES   5
#define BUILDING_MIN_WIDTH_TILES    25
#define BUILDING_MAX_WIDTH_TILES    50
#define BUILDING_MIN_GAP_PX         100
#define BUILDING_MAX_GAP_PX         620

#define NUM_BUILDINGS               36
