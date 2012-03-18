//
//  OptionsScene.m
//  Scroller
//
//  Created by Yongrim Rhee on 3/14/11.
//  Copyright 2011 L00Kout LLC. All rights reserved.
//

#import "OptionsScene.h"


@implementation OptionsScene

- (id)init
{
    self = [super init];
    if (self) {
        CGSize size = [[CCDirector sharedDirector] winSize];
        CCLabelBMFont* titleLabel = [CCLabelBMFont labelWithString:@"Options.. yeah." fntFile:@"courier.fnt"];
        titleLabel.position = CGPointMake(size.width / 2, size.height / 2);
        [self addChild:titleLabel];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end
