//
//  DBSyncPromptDelegate.h
//  DBUserDefaults
//
//  Created by Tyler Bunnell on 6/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum DBSyncPromptOption_
{
  DBSyncPromptOptionLocal = 0,
  DBSyncPromptOptionDropbox
} DBSyncPromptOption;

@protocol DBSyncPromptDelegate <NSObject>
- (void)syncPromptDidSelectOption:(DBSyncPromptOption)option;
- (void)syncPromptDidCancel;
@end
