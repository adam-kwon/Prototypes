//
//  Building.h
//  RandomBackground
//
//  Created by J S on 1/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Building : CCNode
{
	int spriteSize;
	int width;
	int height;
	
	NSString *LEFT_CORNER;
	NSString *TOP_SIDE;
	NSString *RIGHT_CORNER;
	NSString *LEFT_SIDE;
	NSString *RIGHT_SIDE;
	NSString *INSIDE;
}

+(id) buildingWithMaxHeight:(int)maxHeight;
-(id) initWithMaxHeight:(int)maxHeight;

-(int) width;
-(int) height;


@end
