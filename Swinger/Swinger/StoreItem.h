//
//  StoreItem.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/28/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "CCNode.h"

@class StoreChooser;

typedef enum {
    kStoreHeadType,
    kStoreBodyType,
    kStorePowerUpsType,
    kStoreLifeLinesType,
    kStoreBankType
} StoreItemType;

typedef enum {
    kStoreItemSelected,
    // states below indicate item is not selected
    kStoreItemUnlocked,
    // states below indicate item is locked
    kStoreItemLocked,
    kStoreItemOnSale,
    kStoreItemNew,
    
} StoreItemStatus;

@interface StoreItem : CCNode {
    
    StoreChooser    *itemParent;
    StoreItemType   itemType;
    int             itemId;
    NSString        *itemName;
    NSString        *itemDescription;
    float           itemPrice;
    StoreItemStatus itemStatus;        
    CCSprite        *itemSprite;
    
    CGPoint         touchStart;
    CGPoint         lastMoved;
}

@property (nonatomic, readonly) StoreItemType itemType;
@property (nonatomic, readonly) int itemId;
@property (nonatomic, readonly) NSString *itemName;
@property (nonatomic, readonly) NSString *itemDescription;
@property (nonatomic, readonly) float itemPrice;
@property (nonatomic, readonly) StoreItemStatus itemStatus;
@property (nonatomic, readonly) CCSprite *itemSprite;
@property (nonatomic, readonly) StoreChooser *itemParent;

+ (id) make: (CCSprite *) theSprite 
       size: (CGSize) theSize
     parent: (StoreChooser *) theParent
       type: (StoreItemType) theType
     itemId: (int) theItemId
       name: (NSString *) theName 
description: (NSString *) theDescription 
      price: (float) thePrice 
     status: (StoreItemStatus) theStatus;

- (void) refresh;

@end
