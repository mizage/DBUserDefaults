#import <Cocoa/Cocoa.h>

@interface NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL;
+(id)hyperlinkFromString:(NSString *)inString 
                 withURL:(NSURL *)aURL 
               withColor:(NSColor*)color;
+(id)hyperlinkFromString:(NSString *)inString 
                 withURL:(NSURL *)aURL 
               withColor:(NSColor*)color
              underlined:(BOOL)underlined;
+(id)hyperlinkFromString:(NSString *)inString 
                 withURL:(NSURL *)aURL 
               withColor:(NSColor*)color
                withFont:(NSFont*)font
              underlined:(BOOL)underlined;

@end