//
//  StretchView.m
//  SwingerLevelDesigner
//
//  Created by Min Kwon on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StretchView.h"
#import "GameObject.h"

@interface StretchView(Private)
- (void) drawGrid:(CGContextRef)ctx;
@end

@implementation StretchView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        gameObjects = [[NSMutableArray alloc] init];
        currentPoint = CGPointZero;
        opacity = 1.0;
    }
    
    return self;
}


- (void) drawGrid:(CGContextRef)ctx {
    // Origin is lower left corner
    NSBezierPath *gridLinePath = [NSBezierPath bezierPath];
    //CGFloat pattern[2] = {2, 2};
    //[gridLinePath setLineDash:pattern count:2 phase:0];
    [gridLinePath moveToPoint:CGPointMake(10, 0)];
    [gridLinePath lineToPoint:CGPointMake(10, 640)];
    
    [[NSColor grayColor] set];
    [gridLinePath setLineWidth:0.2];
    [gridLinePath stroke];
    
    
    CGContextSaveGState(ctx);
    
    for (int i = 1; i < 960/10; i++) {
        CGContextTranslateCTM(ctx, 10, 0);
        [gridLinePath stroke];
    }
    
    CGContextRestoreGState(ctx);    
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];

    NSRect bounds = [self bounds];
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:bounds];

    [self drawGrid:ctx];
        
    for (GameObject *gameObject in gameObjects) {
        [gameObject draw:ctx];
    }
}

#pragma mark Accessors

- (void) addGameObject:(GameObject*)gameObject {
    gameObject.position = CGPointZero;
    [gameObjects addObject:gameObject];
    [self setNeedsDisplay:YES];
}

- (float) opacity {
    return opacity;
}

- (void) setOpacity:(float)x {
    opacity = x;
    [self setNeedsDisplay:YES];
}

#pragma mark Events
- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint p = [theEvent locationInWindow];
    downPoint = [self convertPoint:p fromView:nil];
    currentPoint = downPoint;
    
    for (GameObject *gameObject in gameObjects) {
        CGRect imageRect = [gameObject imageRect];
        if (CGRectContainsPoint(imageRect, downPoint)) {
            gameObject.selected = YES;
        }
    }

    
//    NSLog(@"mouseDown: %f %f   imagepos: %f %f", downPoint.x, downPoint.y, image.position.x, image.position.y);


    [self setNeedsDisplay:YES];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    NSPoint p = [theEvent locationInWindow];
    currentPoint = [self convertPoint:p fromView:nil];
    [self autoscroll:theEvent];
    [self setNeedsDisplay:YES];
    for (GameObject *gameObject in gameObjects) {
        if (gameObject.selected) {
            CGFloat deltaX = currentPoint.x - downPoint.x;
            CGFloat deltaY = currentPoint.y - downPoint.y;
            NSLog(@"x=%f y=%f", deltaX, deltaY);
            gameObject.position = CGPointMake(gameObject.position.x + deltaX, gameObject.position.y + deltaY);
            downPoint = currentPoint;
        }
    }
    
}

- (void)mouseUp:(NSEvent *)theEvent {
    for (GameObject *gameObject in gameObjects) {
        gameObject.selected = NO;
    }

//    NSPoint p = [theEvent locationInWindow];
//    currentPoint = [self convertPoint:p fromView:nil];
//    [self setNeedsDisplay:YES];
//    NSLog(@"mouseUp");
}

- (NSRect) currentRect {
//    float minX = MIN(downPoint.x, currentPoint.x);
//    float maxX = MAX(downPoint.x, currentPoint.x);
//    float minY = MIN(downPoint.y, currentPoint.y);
//    float maxY = MAX(downPoint.y, currentPoint.y);
}
@end
