//
//  AppDelegate.h
//  SwingerLevelDesigner
//
//  Created by Min Kwon on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class StretchView;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet StretchView *stretchView;
}

@property (assign) IBOutlet NSWindow *window;

- (IBAction)showOpenPanel:(id)sender;

@end
