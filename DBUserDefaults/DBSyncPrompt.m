//
//  DBSyncPrompt.m
//  DBUserDefaults
//
//  Created by Tyler Bunnell on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DBSyncPrompt.h"
#import <QuartzCore/QuartzCore.h>

static NSString* localLabel = @"Pull the preferences from Dropbox and use them for %@ on this Mac.";
static NSString* dropboxLabel = @"Push the preferences on this Mac up to Dropbox so all copies of %@ will use them.";

CGFloat DegreesToRadians(CGFloat degrees)
{
  return degrees * M_PI / 180;
};
NSNumber* DegreesToNumber(CGFloat degrees)
{
  return [NSNumber numberWithFloat:
          DegreesToRadians(degrees)];
}

@interface DBSyncPrompt ()
- (void)rotateArrowToDegrees:(NSInteger)degrees;
@end

@implementation DBSyncPrompt

- (id)init
{
  NSWindow* window = [[[NSWindow alloc] 
                       initWithContentRect:NSMakeRect(0, 0, 411, 322)
                       styleMask:NSBorderlessWindowMask
                       backing:NSBackingStoreBuffered
                       defer:NO] autorelease];
  if((self = [super initWithWindow:window]))
  {
    [window center];
    [window setLevel:NSFloatingWindowLevel];
    
    [NSBundle loadNibNamed:@"DBSyncPrompt" owner:self];
    
    [arrow setWantsLayer:YES];
    [[arrow layer] setAnchorPoint:CGPointMake(0.5, 0.5)];
    
    [dropboxButton setState:NSOnState];
    [dropboxButton setEnabled:NO];

    NSString* appName = [[[NSBundle mainBundle] infoDictionary] 
                         objectForKey:@"CFBundleDisplayName"];
    [detailText setStringValue:[NSString stringWithFormat:dropboxLabel,
                                appName != nil ? appName : @""]];
    
    NSString* appIconName = [[NSBundle mainBundle] objectForInfoDictionaryKey:
                             @"CFBundleIconFile"];
    NSImage* icon;
    if(appIconName)
      icon = [NSImage imageNamed:appIconName];
    else
      icon = [[NSWorkspace sharedWorkspace] 
              iconForFileType:
              NSFileTypeForHFSTypeCode(kGenericApplicationIcon)];
    
    [localButton setImage:icon];
    


    
    [window setContentView:view];
  }
  
  return self;
}

- (void)dealloc
{
  [super dealloc];
}

- (void)displayPrompt
{
  [[self window] makeKeyAndOrderFront:nil];
}

- (IBAction)dropboxClicked:(NSButton*)sender
{
  [self rotateArrowToDegrees:0];
  [dropboxButton setEnabled:NO];
  [localButton setEnabled:YES];  
  NSString* appName = [[[NSBundle mainBundle] infoDictionary] 
                       objectForKey:@"CFBundleDisplayName"];
  [detailText setStringValue:[NSString stringWithFormat:dropboxLabel,
                              appName != nil ? appName : @""]];
}

- (IBAction)localClicked:(NSButton*)sender
{
  [self rotateArrowToDegrees:-180];
  [dropboxButton setEnabled:YES];
  [localButton setEnabled:NO];
  NSString* appName = [[[NSBundle mainBundle] infoDictionary] 
                       objectForKey:@"CFBundleDisplayName"];
  [detailText setStringValue:[NSString stringWithFormat:localLabel,
                              appName != nil ? appName : @""]];
}

- (IBAction)acceptclicked:(id)sender
{
}

- (IBAction)cancelClicked:(id)sender
{
}

- (void)rotateArrowToDegrees:(NSInteger)degrees
{
  NSNumber* numDegrees = DegreesToNumber(degrees);
  CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
  rotationAnimation.toValue = numDegrees;
  rotationAnimation.duration = 0.25;
  [[arrow layer] addAnimation:rotationAnimation forKey:@"rotationAnimation"];
  [[arrow layer] setValue:numDegrees forKeyPath:@"transform.rotation.z"];
}

@end
