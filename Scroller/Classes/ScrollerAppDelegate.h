//
//  ScrollerAppDelegate.h
//  Scroller
//
//  Created by min on 1/11/11.
//  Copyright Min Kwon 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface ScrollerAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
