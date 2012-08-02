//
//  PlayerChooser.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/29/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "PlayerChooser.h"
#import "StoreItem.h"
#import "Macros.h"
#import "UserData.h"
#import "PlayerHeadBodyData.h"
#import "GPImageButton.h"

@implementation PlayerChooser

+ (id) make: (CGSize) theSize {
    return [[[self alloc] initWithUserData: [UserData sharedInstance] size: theSize] autorelease];
}

- (id) initWithUserData: (UserData *) theUserData size: (CGSize) theSize {
    self = [super initWithSize:theSize];
    
    if (self != nil) {
        userData = theUserData;
        // load available players
        [self load];
        
        float myWidth = self.contentSize.width - ssipadauto(60);
        float startHeight = self.contentSize.height - ssipadauto(30);
        float rowHeight = startHeight/4;
        float currentHeight = startHeight;
        
        // XXX - Buttons for now, will turn them into tabs
        headTab = [GPImageButton controlOnTarget:self andSelector:@selector(showHeadTab) imageFromFile:@"backButton.png"];
        CCLabelBMFont *text = [CCLabelBMFont labelWithString:@"HEAD" fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        [(GPImageButton *)headTab setText:text];
        headTab.position = ccp(ssipadauto(40), self.contentSize.height - ssipadauto(18) - [headTab boundingBox].size.height/2);
        [self addChild: headTab];
        
        bodyTab = [GPImageButton controlOnTarget:self andSelector:@selector(showBodyTab) imageFromFile:@"backButton.png"];
        text = [CCLabelBMFont labelWithString:@"BODY" fntFile:ssall(FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_32, FONT_BUBBLEGUM_16)];
        [(GPImageButton *)bodyTab setText:text];
        bodyTab.position = ccp(headTab.position.x + [headTab boundingBox].size.width + ssipadauto(80), self.contentSize.height - ssipadauto(18) - [bodyTab boundingBox].size.height/2);
        [self addChild: bodyTab];
        
        headPane = [CCNode node];
        headPane.contentSize = CGSizeMake(myWidth, startHeight);
        [self addChild: headPane z:1];
        
        bodyPane = [CCNode node];
        bodyPane.contentSize = CGSizeMake(myWidth, startHeight);
        [self addChild: bodyPane z:1];
        
        // create head/body skin item
        for (PlayerHeadBodyData * phb in availablePlayers) {
            StoreItem * item = [StoreItem make: [CCSprite spriteWithSpriteFrameName: phb.headSpriteName]
                                          size: CGSizeMake(headPane.contentSize.width, rowHeight)
                                        parent: self
                                          type: kStoreHeadType 
                                        itemId: phb.head
                                          name: phb.name 
                                   description: phb.description 
                                         price: phb.price 
                                        status: userData.headSkin == phb.head ? kStoreItemSelected : kStoreItemUnlocked];
            
            item.anchorPoint = ccp(0,1);
            item.position = ccp(ssipadauto(2), currentHeight);
            [headPane addChild: item];
            
            item = nil;
            
            item = [StoreItem make: [CCSprite spriteWithSpriteFrameName: phb.bodySpriteName]
                              size: CGSizeMake(bodyPane.contentSize.width, rowHeight)
                            parent: self
                              type: kStoreBodyType 
                            itemId: phb.body
                              name: phb.name 
                       description: phb.description 
                             price: phb.price 
                            status: userData.bodySkin == phb.body ? kStoreItemSelected : kStoreItemUnlocked];
            
            item.anchorPoint = ccp(0,1);
            item.position = ccp(ssipadauto(2), currentHeight);
            [bodyPane addChild: item];
            
            currentHeight -= item.contentSize.height + ssipadauto(1);
        }
        
        preview = [CCNode node];
        preview.contentSize = CGSizeMake(ssipadauto(58), startHeight);
        preview.anchorPoint = ccp(0,1);
        preview.position = ccp(myWidth + ssipadauto(4), startHeight);
        [self addChild: preview z:1];
        
        // Borders
        CCLayerColor * border = [CCLayerColor layerWithColor:ccc3to4(CC3_COLOR_CANTALOPE, 255)];
        border.contentSize = CGSizeMake(1, self.contentSize.height - ssipadauto(30));
        border.anchorPoint = preview.anchorPoint;
        border.position = ccp(0,0);
        [preview addChild: border];
        
        [self showHeadTab];
    }
    
    return self;
}

- (void) showHeadTab {
    headPane.visible = YES;
    bodyPane.visible = NO;
}

- (void) showBodyTab {
    headPane.visible = NO;
    bodyPane.visible = YES;
}

- (void) load {
    // load head/body skins
    // HARD CODED FOR NOW - TODO: LOAD THESE VALUES FROM A DICTIONARY
    availablePlayers = [[CCArray alloc] initWithCapacity:2];
    
    PlayerHeadBodyData *phb = [[[PlayerHeadBodyData alloc] init] autorelease];
    phb.head = kPlayerHeadDareDevilDave;
    phb.body = kPlayerBodyDareDevilDave;
    phb.name = @"Dare Devil Dave";
    phb.description = @"The Original Swing Star!";
    phb.headSpriteName = @"Default_H_Pose1.png";
    phb.bodySpriteName = @"Default_B_Pose1.png";
    
    [availablePlayers addObject: phb];
    
    phb = [[[PlayerHeadBodyData alloc] init] autorelease];
    phb.head = kPlayerHeadRebel;
    phb.body = kPlayerBodyRebel;
    phb.name = @"The Rebel";
    phb.description = @"The Heartbreak kid!";
    phb.headSpriteName = @"Rebel_H_Pose1.png";
    phb.bodySpriteName = @"Rebel_B_Pose1.png";
    
    [availablePlayers addObject: phb];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    return YES;
}

- (BOOL) select:(StoreItem *)item {

    CCLOG(@"%@ was selected!", item.itemName);
    
    if (item.itemType == kStoreHeadType) {
        userData.headSkin = item.itemId;
    } else if (item.itemType == kStoreBodyType) {
        userData.bodySkin = item.itemId;
    }
    
    return YES;
}

- (BOOL) buy:(StoreItem *)item {
    CCLOG(@"%@ was bought!", item.itemName);
    return YES;
}

- (void) refresh {
    
}

@end
