#import "NSAttributedString+Hyperlink.h"


@implementation NSAttributedString (Hyperlink)
+(id)hyperlinkFromString:(NSString*)inString withURL:(NSURL*)aURL
{
  return [self hyperlinkFromString:inString 
                           withURL:aURL 
                         withColor:[NSColor blueColor]];
}
+(id)hyperlinkFromString:(NSString *)inString 
                 withURL:(NSURL *)aURL 
               withColor:(NSColor*)color
{
  return [self hyperlinkFromString:inString 
                           withURL:aURL 
                         withColor:color
                        underlined:YES];
}
+(id)hyperlinkFromString:(NSString *)inString 
                 withURL:(NSURL *)aURL 
               withColor:(NSColor*)color
              underlined:(BOOL)underlined
{
  NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
  NSRange range = NSMakeRange(0, [attrString length]);
 	
  [attrString beginEditing];
  [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
 	
  // make the text appear in blue
  [attrString addAttribute:NSForegroundColorAttributeName value:color range:range];
 	
  // next make the text appear with an underline
  if(underlined)
  {
    [attrString addAttribute:
     NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
 	}
  [attrString endEditing];
 	
  return [attrString autorelease];
}
+(id)hyperlinkFromString:(NSString *)inString 
                 withURL:(NSURL *)aURL 
               withColor:(NSColor*)color
                withFont:(NSFont*)font
              underlined:(BOOL)underlined
{
  NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString: inString];
  NSRange range = NSMakeRange(0, [attrString length]);
 	
  [attrString beginEditing];
  [attrString addAttribute:NSLinkAttributeName value:[aURL absoluteString] range:range];
 	
  // make the text appear in blue
  [attrString addAttribute:NSForegroundColorAttributeName value:color range:range];
  
  // apply our font
  [attrString addAttribute:NSFontAttributeName value:font range:range];
 	
  // next make the text appear with an underline
  if(underlined)
  {
    [attrString addAttribute:
     NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:range];
 	}
  [attrString endEditing];
 	
  return [attrString autorelease];

}
@end