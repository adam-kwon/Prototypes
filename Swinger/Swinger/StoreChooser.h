//
//  StoreChooser.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/30/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

@class StoreItem;

@interface StoreChooser : CCNode {
    
}

- (id) initWithSize: (CGSize) theSize;

- (BOOL) select: (StoreItem*)item;
- (BOOL) buy: (StoreItem*)item;
- (void) refresh;

@end
