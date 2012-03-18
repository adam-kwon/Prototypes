//
//  GameRules.h
//  Scroller
//
//  Created by min on 3/21/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

typedef struct {
    // Amount of time in seconds the runner will start slowing down after getting the speed boost powerup.
    float           speed_boost_duration;

    float           meteor_base_interval;
    float           meteor_random_interval;
    
    char            num_jumps_allowed_in_air;
    
    float           speed_extension_duration;
        
    char            num_buildings_before_speed_boost_x_1;
    char            num_buildings_before_speed_boost_x_2;
    char            num_buildings_before_double_jump;
    char            num_buildings_before_speed_boost_extender;
    char            num_buildings_before_flight;
    
    float           max_zoom_out;
    
    float           bldg_crumble_probability;
    
    float           jump_force;
} GameRules;