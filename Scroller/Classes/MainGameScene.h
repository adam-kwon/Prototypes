//
//  MainGameScene.h
//  Scroller
//
//  Created by min on 3/9/11.
//  Copyright 2011 L00Kout. All rights reserved.
//
#import "Box2D.h"
#import "GLES-Render.h"
#import "ContactListener.h"
#import "DeviceDetection.h"
#import "SimpleAudioEngine.h"
#import "GameOptions.h"

@class Runner;
@class GamePlayLayer;
@class MainGameScene;
@class ParallaxBackgroundLayer;
@class UserInterfaceLayer;
@class StaticBackgroundLayer;

@interface MainGameScene : CCScene
{
    ParallaxBackgroundLayer* parallaxBackground;
    UserInterfaceLayer* uiLayer;
    CGSize screenSize;
}

-(ParallaxBackgroundLayer*) parallaxBackground;
-(UserInterfaceLayer*) uiLayer;

-(void) stopRain;
-(void) addParallaxBackgroundLayer;
-(void) addStaticBackgroundLayer;
-(void) addGamePlayLayer;
-(void) addUiLayer;
-(void) loadSpriteAtlas;
-(void) quake;

@end
