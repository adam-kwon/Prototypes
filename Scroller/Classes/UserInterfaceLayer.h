//
//  UserInterfaceLayer.h
//  Scroller
//
//  Created by Yongrim Rhee on 3/9/11.
//  Copyright 2011 L00Kout LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInterfaceLayer : CCLayer {
}

-(void) returnToMenu;
-(void) restartGame;
-(void) showGameOverMenu:(int) distance;

@end
