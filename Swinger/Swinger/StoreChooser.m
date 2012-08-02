//
//  StoreChooser.m
//  Swinger
//
//  Created by Isonguyo Udoka on 7/30/12.
//  Copyright (c) 2012 GAMEPEONS, LLC. All rights reserved.
//

#import "StoreChooser.h"
#import "StoreItem.h"

@implementation StoreChooser

- (id) initWithSize:(CGSize)theSize {
    self = [super init];
    self.contentSize = theSize;
    
    return self;
}

- (BOOL) select:(StoreItem *)item {
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return YES;
}

- (BOOL) buy:(StoreItem *)item {
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return NO;
}

- (void) refresh {
    NSAssert(NO, @"This is an abstract method and should be overridden");
}

@end
