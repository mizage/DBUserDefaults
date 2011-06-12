//
//  DBNSString+Extensions.h
//  DBUserDefaults
//
//  Created by Tyler Bunnell on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (Base64)

- (NSString*)decodeBase64String;
- (NSData*)decodeBase64;
- (NSData*)decodeBase64WithNewlines:(BOOL)encodedWithNewlines;

@end
