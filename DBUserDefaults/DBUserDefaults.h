//
//  DBUserDefaults.h
//  DBUserDefaults
//
//  Created by Tyler Bunnell on 6/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const DBUserDefaultsDidChangeNotification;

@interface DBUserDefaults : NSObject
{
  NSLock* deadbolt_; //Used to lock access to the defaults dictionary
  NSMutableDictionary* defaults_; //Stores the user data
}

- (void)enableDropboxSync;
- (void)disableDropboxSync;

@end

@interface DBUserDefaults (NSUserDefaultsPartialReplacement)

#pragma mark - NSUserDefaults (Partial) Replacement

+ (NSUserDefaults*)standardUserDefaults;
+ (void)resetStandardUserDefaults;

- (id)init;

- (id)objectForKey:(NSString*)defaultName;
- (void)setObject:(id)value forKey:(NSString*)defaultName;
- (void)removeObjectForKey:(NSString*)defaultName;

- (NSString*)stringForKey:(NSString*)defaultName;
- (NSArray*)arrayForKey:(NSString*)defaultName;
- (NSDictionary*)dictionaryForKey:(NSString*)defaultName;
- (NSData*)dataForKey:(NSString*)defaultName;
- (NSArray*)stringArrayForKey:(NSString*)defaultName;
- (NSInteger)integerForKey:(NSString*)defaultName;
- (float)floatForKey:(NSString*)defaultName;
- (double)doubleForKey:(NSString*)defaultName;
- (BOOL)boolForKey:(NSString*)defaultName;
- (NSURL*)URLForKey:(NSString*)defaultName AVAILABLE_MAC_OS_X_VERSION_10_6_AND_LATER;

- (void)setInteger:(NSInteger)value forKey:(NSString*)defaultName;
- (void)setFloat:(float)value forKey:(NSString*)defaultName;
- (void)setDouble:(double)value forKey:(NSString*)defaultName;
- (void)setBool:(BOOL)value forKey:(NSString*)defaultName;
- (void)setURL:(NSURL*)url forKey:(NSString*)defaultName AVAILABLE_MAC_OS_X_VERSION_10_6_AND_LATER;

- (void)registerDefaults:(NSDictionary*)registrationDictionary;

- (NSDictionary*)dictionaryRepresentation;

- (BOOL)synchronize;

@end
