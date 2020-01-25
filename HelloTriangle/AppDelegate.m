//
//  AppDelegate.m
//  HelloTriangle
//
//  Created by Joss Manger on 1/25/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

#import "AppDelegate.h"
#import "Renderer.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) MTKView *metalView;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
  
  id device = MTLCreateSystemDefaultDevice();
  
  if (device != NULL){
    NSLog(@"Notnull %@",device);
  }
  
  MTKView *metalView = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, _window.frame.size.width, _window.frame.size.width) device:device];
  metalView.translatesAutoresizingMaskIntoConstraints = false;

  
  
  self.renderer = [[Renderer alloc] initWithDevice:device andView:metalView];
  
  _metalView = metalView;
  
  
  
  [_window.contentView addSubview:_metalView];
  
  
  NSArray<NSLayoutConstraint*> *constraints = [NSArray arrayWithObjects:[metalView.topAnchor constraintEqualToAnchor:_window.contentView.topAnchor],
     [metalView.leadingAnchor constraintEqualToAnchor:_window.contentView.leadingAnchor],
     [_window.contentView.trailingAnchor constraintEqualToAnchor:metalView.trailingAnchor],
  [_window.contentView.bottomAnchor constraintEqualToAnchor:metalView.bottomAnchor], nil];

  [NSLayoutConstraint activateConstraints:constraints];
  
  [self.renderer tellMeAboutMyDevice];
  
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}


@end
