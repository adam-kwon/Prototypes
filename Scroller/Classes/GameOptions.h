//
//  GameOptions.h
//  Scroller
//
//  Created by min on 3/26/11.
//  Copyright 2011 Min Kwon. All rights reserved.
//

#import "DeviceDetection.h"

typedef enum {
    kPerformanceNone,
    kPerformanceLow,
    kPerformanceMedium,
    kPerformanceHigh
} PerformanceProfile;

typedef struct {
	DeviceType              device;
    PerformanceProfile      profile;
} GameOptions;