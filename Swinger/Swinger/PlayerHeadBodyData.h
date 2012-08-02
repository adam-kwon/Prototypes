//
//  PlayerHeadBodyData.h
//  Swinger
//
//  Created by Isonguyo Udoka on 7/30/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "UserData.h"

@interface PlayerHeadBodyData : NSObject {
    
    PlayerHead head;
    PlayerBody body;
    NSString  *name;
    NSString  *description;
    NSString  *headSpriteName;
    NSString  *bodySpriteName;
    float      price;
}

@property (nonatomic, readwrite, assign) PlayerHead head;
@property (nonatomic, readwrite, assign) PlayerBody body;
@property (nonatomic, readwrite, assign) NSString* name;
@property (nonatomic, readwrite, assign) NSString* description;
@property (nonatomic, readwrite, assign) NSString* headSpriteName;
@property (nonatomic, readwrite, assign) NSString* bodySpriteName;
@property (nonatomic, readwrite, assign) float price;

@end
