//
//  AppDelegate.h
//  Swinger
//
//  Created by Min Kwon on 3/18/12.
//  Copyright GAMEPEONS, LLC 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
