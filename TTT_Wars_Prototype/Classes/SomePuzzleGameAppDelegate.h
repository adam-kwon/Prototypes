//
//  SomePuzzleGameAppDelegate.h
//  SomePuzzleGame
//
//  Created by min on 12/27/10.
//  Copyright Min Kwon 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface SomePuzzleGameAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
