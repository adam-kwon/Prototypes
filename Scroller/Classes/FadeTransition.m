//
//  FadeTransition.m
//  Scroller
//
//  Created by Yongrim Rhee on 3/14/11.
//  Copyright 2011 L00Kout LLC. All rights reserved.
//

#import "FadeTransition.h"


@implementation CCDirector (FadeTransition)

+(void) fadeIntoScene:(CCScene*) scene {
    CCTransitionFade* tran = [CCTransitionFade transitionWithDuration:1 scene:scene withColor:ccBLACK];
    [[CCDirector sharedDirector] replaceScene:tran];
}

@end
