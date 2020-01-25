//
//  AppDelegate.h
//  HelloTriangle
//
//  Created by Joss Manger on 1/25/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Renderer.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (retain) Renderer *renderer;

@end

