//
//  DBSyncPrompt.h
//  DBUserDefaults
//
//  Created by Tyler Bunnell on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBSyncPrompt : NSWindowController
{    
  IBOutlet NSView* view;
  IBOutlet NSButton* localButton;
  IBOutlet NSButton* dropboxButton;
  IBOutlet NSImageView* arrow;
  IBOutlet NSTextField *detailText;
}

- (void)displayPrompt;

- (IBAction)localClicked:(NSButton*)sender;
- (IBAction)dropboxClicked:(NSButton*)sender;
- (IBAction)acceptclicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;

@end
