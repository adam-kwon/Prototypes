//
//  StretchView.h
//  SwingerLevelDesigner
//
//  Created by Min Kwon on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GameObject;

@interface StretchView : NSView {
    NSBezierPath *path;
    NSMutableArray *gameObjects;
    float opacity;
    NSPoint downPoint;
    NSPoint currentPoint;
}

- (NSRect)currentRect;

- (void) addGameObject:(GameObject*)gameObject;

@property (assign) float opacity;
//@property (strong) NSMutableArray *gameObjects;

@end
