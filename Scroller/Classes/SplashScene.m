//
//  SplashScene.m
//  Scroller
//
//  Created by Yongrim Rhee on 3/19/11.
//  Copyright 2011 L00Kout LLC. All rights reserved.
//

#import "SplashScene.h"

@implementation SplashScene

-(id) init {
    self = [super init];
    if (self) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"L00kout_logo.png"];
//        background.anchorPoint = ccp(0,0);
        background.position = CGPointMake(size.width / 2, size.height / 2);
        [self addChild:background];
    }
    
    return self;
}

-(void) dealloc {
    [super dealloc];
}

@end