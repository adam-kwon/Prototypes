//
//  StretchView.h
//  SwingerLevelDesigner
//
//  Created by Min Kwon on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StretchView : NSView {
    NSBezierPath *path;
    NSImage *image;
    float opacity;
}

- (NSPoint)randomPoint;
- (NSRect)currentRect;

@property (assign) float opacity;
@property (strong) NSImage *image;

@end
