//
//  DBUtils.m
//  DBUserDefaults
//
//  Created by Tyler Bunnell on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DBUtils.h"
#import "DBNSString+Extensions.h"

static NSString* dropboxHostFile;
static NSString* dropboxPath;

@interface DBUtils ()
+ (NSString*)getHostFileContents;
@end

@implementation DBUtils

- (void)initialize
{
  dropboxHostFile = [@"~/.dropbox/host.db" stringByExpandingTildeInPath];
}

// This method checks to see if the Dropbox path exists
+ (BOOL)isDropboxAvailable
{
  return [self dropboxPath] != nil ? YES : NO;
}

// This method will attempt to read the second line of the Dropbox host file
//  and decode it to get the path to the Dropbox folder on the system
+ (NSString*)dropboxPath
{
  NSString* hostFileContents = [self getHostFileContents];
  
  if(!hostFileContents)
    return nil;
  
  NSArray* hostFileLines = 
  [hostFileContents componentsSeparatedByCharactersInSet:
   [NSCharacterSet newlineCharacterSet]];
  
  // Make sure we have a second line to read
  if([hostFileLines count] >= 2)
  {      
    // The location of the Dropbox folder is Base64 encoded on the second line
    //  of the host.db file
    NSString* base64DropboxPath = [hostFileLines objectAtIndex:1];
    
    @synchronized(dropboxPath)
    {    
      if(!dropboxPath)
        dropboxPath = [base64DropboxPath decodeBase64String];
    }
    
    return dropboxPath;    
  }
  
  return nil; 
}

// This method will attempt to read the contents of the Dropbox host file
//  located at ~/.dropbox/host.db
+ (NSString*)getHostFileContents
{
  return [NSString stringWithContentsOfFile:dropboxHostFile 
                                   encoding:NSUTF8StringEncoding error:nil];
}

@end
