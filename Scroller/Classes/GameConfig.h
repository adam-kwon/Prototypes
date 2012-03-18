//
//  GameConfig.h
//  Scroller
//
//  Created by min on 1/11/11.
//  Copyright Min Kwon 2011. All rights reserved.
//

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
#define kGameAutorotationNone 0
#define kGameAutorotationCCDirector 1
#define kGameAutorotationUIViewController 2

//
// Define here the type of autorotation that you want for your game
//
// Note: DO NOT USE kGameAutorotationUIViewController. It'll drop the drame rate significantly.
#define GAME_AUTOROTATION None

#endif // __GAME_CONFIG_H