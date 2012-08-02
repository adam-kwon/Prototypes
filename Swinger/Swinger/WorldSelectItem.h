//
//  WorldSelectItem.h
//  Swinger
//
//  Created by Min Kwon on 7/5/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCNode.h"

@interface WorldSelectItem : CCNode<CCTargetedTouchDelegate> {
    NSString *worldName;
    CCSprite *thumbNailSprite;
        
    CGPoint touchStart;
    CGPoint lastMoved;
}

+ (id) nodeWithWorldName:(NSString*)world;

@property (nonatomic, readonly) NSString *worldName;

@end
