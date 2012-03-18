//
//  ParallaxBackground.h
//  RandomBackground
//
//  Created by J S on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface ParallaxBackground : CCLayer
{
	CCArray* images;
	int numImages;
	
	CCArray* speedFactors;
	float scrollSpeed;
	
	CGSize screenSize;	
}

@end
