//
//  StoreItem.mm
//  Swinger
//
//  Created by Isonguyo Udoka on 7/28/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "Macros.h"
#import "StoreItem.h"
#import "GPLabel.h"
#import "GPUtil.h"
#import "CCLayerColor+extension.h"
#import "Constants.h"
#import "GPImageButton.h"
#import "UserData.h"
#import "StoreChooser.h"

@implementation StoreItem

@synthesize itemType;
@synthesize itemId;
@synthesize itemName;
@synthesize itemDescription;
@synthesize itemPrice;
@synthesize itemStatus;
@synthesize itemSprite;
@synthesize itemParent;

+ (id) make: (CCSprite *) theSprite 
       size: (CGSize) theSize
     parent: (StoreChooser *) theParent
       type: (StoreItemType) theType
     itemId: (int) theItemId
       name: (NSString *) theName 
description: (NSString *) theDescription 
      price: (float) thePrice 
     status: (StoreItemStatus) theStatus {
   
    return [[[self alloc] initWithSprite: theSprite size: theSize parent: theParent type: theType itemId: theItemId name:theName description:theDescription price:thePrice status:theStatus] autorelease];
}

- (id) initWithSprite: (CCSprite *) theSprite 
                 size: (CGSize) theSize
               parent: (StoreChooser *) theParent
                 type: (StoreItemType) theType 
               itemId: (int) theItemId
                 name: (NSString *) theName 
          description: (NSString *) theDescription 
                price: (float) thePrice 
               status: (StoreItemStatus) theStatus {
    
    self = [super init];
    if (self != nil) {
        //
        
        itemParent = theParent;
        itemType = theType;
        itemId = theItemId;
        itemName = theName;
        itemDescription = theDescription;
        itemPrice = thePrice;
        itemSprite = theSprite;
        itemStatus = theStatus;
        
        self.contentSize = theSize;
        self.anchorPoint = ccp(0,1);
        
        theSprite.position = ccp(ssipadauto(10), [self boundingBox].size.height - ssipadauto(10));
        theSprite.anchorPoint = ccp(0,1);
        [self addChild: theSprite];
        
        CCLabelBMFont * name = [CCLabelBMFont labelWithString:theName fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        name.color = CC3_COLOR_CANTALOPE;
        name.anchorPoint = ccp(0,1);
        name.position = ccp(theSprite.position.x + [theSprite boundingBox].size.width + ssipadauto(10), theSprite.position.y);
        [self addChild: name];
        
        
        if (theStatus == kStoreItemSelected) {
            // Already selected put check mark next to sprite
            CCSprite * check = [CCSprite spriteWithFile:@"highscore.png"];
            check.scale = 0.1f;
            check.position = ccp(theSprite.position.x + [theSprite boundingBox].size.width + ssipadauto(1), theSprite.position.y - [theSprite boundingBox].size.height + ssipadauto(10));
            [self addChild: check z:2];
        } else {
            
            if (theStatus == kStoreItemUnlocked) {
                // show select button
                GPImageButton * btn = [GPImageButton controlOnTarget:self andSelector:@selector(chooseMe) imageFromFile:@"Button_Options.png"];
                btn.position = ccp(self.contentSize.width - [btn boundingBox].size.width - ssipadauto(60), name.position.y - ssipadauto(10));
                [self addChild:btn];
                
                CCLabelBMFont * select = [CCLabelBMFont labelWithString:@"Choose Me" fntFile:ssall(FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_64, FONT_BUBBLEGUM_32)];
                select.scale = 0.8f;
                [btn setText: select];
                btn.scale = 0.7f;
                
            } else {
                // Show price button needed to unlock item
                GPImageButton * btn = [GPImageButton controlOnTarget:self andSelector:@selector(buyMe) imageFromFile:@"Button_Options.png"];
                btn.position = ccp(self.contentSize.width - [btn boundingBox].size.width - ssipadauto(60), name.position.y - ssipadauto(10));
                [self addChild:btn];
                
                CCLabelBMFont * coins = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"%.f", thePrice] fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
                
                CCSprite *coin1 = [CCSprite spriteWithSpriteFrameName:@"Coin1.png"];
                coin1.scale = 0.5;
                coin1.position = ccp(-([coins boundingBox].size.width/2 + ssipadauto(8)), 0);
                
                CCNode * myPrice = [CCNode node];
                [myPrice addChild: coins];
                [myPrice addChild: coin1];
                
                [btn addChild: myPrice];
                btn.scale = 0.7f;
            }
        }
        
        CCLabelBMFont * descr = [CCLabelBMFont labelWithString:theDescription fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        descr.scale = 0.75f;
        descr.anchorPoint = ccp(0,1);
        descr.position = ccp(name.position.x, name.position.y - ssipad(50,25));
        [self addChild: descr];
        
        CCLayerColor * background = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_STEEL_BLUE, 245)];
        background.contentSize = self.contentSize;
        background.anchorPoint = self.anchorPoint;
        background.position = ccp(0,0);
        [self addChild: background z:-2];
        
        // Borders
        CCLayerColor * border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_BLUE, 255)];
        border.contentSize = CGSizeMake(self.contentSize.width, 1);
        border.anchorPoint = self.anchorPoint;
        border.position = ccp(0,0);
        [self addChild: border z:-1];
        
        border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_BLUE, 255)];
        border.contentSize = CGSizeMake(2, self.contentSize.height);
        border.anchorPoint = self.anchorPoint;
        border.position = ccp(self.contentSize.width - 2, 0);
        [self addChild: border z:-1];
        
        border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_BLUE, 255)];
        border.contentSize = CGSizeMake(1, self.contentSize.height);
        border.anchorPoint = self.anchorPoint;
        border.position = ccp(0, 0);
        [self addChild: border z:-1];
        
        border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_BLUE, 255)];
        border.contentSize = CGSizeMake(self.contentSize.width, 1);
        border.anchorPoint = self.anchorPoint;
        border.position = ccp(0, self.contentSize.height - 1);
        [self addChild: border z:-1];
    }
    
    return self;
}

- (void) refresh {
    
}

- (void) chooseMe {
    [itemParent select: self];
}

- (void) buyMe {
    [itemParent buy: self];
}


@end
