//
//  SkyLayer.h
//  Swinger
//
//  Created by Min Kwon on 6/10/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

@class StarsFirework;

@interface SkyLayer : CCLayer {
    CGSize              screenSize;
    CCArray             *clouds;
    CCNode              *celestialBodyHolder;
    CCSprite            *celestialBody;

    StarsFirework       *fireWork;
    int                 fireWorkCount;
    int                 numFireWorksToPlay;

    CCSpriteBatchNode   *batchNode;
}

+ (SkyLayer*) sharedLayer;
- (void) cleanupLayer;
- (void) zoomBy: (float) scaleAmount;
- (void) scaleBy: (float)scaleAmount duration:(ccTime)duration;
- (void) showFireWork;
- (void) scrollUp:(float)dy;

@end
