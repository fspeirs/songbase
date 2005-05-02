// Copyright 1997-2003 Omni Development, Inc.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// http://www.omnigroup.com/DeveloperResources/OmniSourceLicense.html.

#import "OAFontView.h"

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface NSAttributedString (FontExtensions)
- (void)drawInRectangle:(NSRect)rectangle
			  alignment:(int)alignment
	 verticallyCentered:(BOOL)verticallyCenter;
@end

@interface NSString(FontExtensions)
+ (NSString *)horizontalEllipsisString;

- (void)drawWithFont:(NSFont *)font
			   color:(NSColor *)color
		   alignment:(int)alignment
	verticallyCenter:(BOOL)verticallyCenter
		 inRectangle:(NSRect)rectangle;

- (void)drawWithFontAttributes:(NSDictionary *)attributes
					 alignment:(int)alignment
			  verticallyCenter:(BOOL)verticallyCenter
				   inRectangle:(NSRect)rectangle;

@end

@implementation OAFontView

// Init and dealloc

- initWithFrame:(NSRect)frameRect
{
    if (![super initWithFrame:frameRect])
        return nil;

    [self setFont:[NSFont userFontOfSize:0]];

    return self;
}

- (void)dealloc;
{
    [font release];
    [fontDescription release];
    [super dealloc];
}

//

- (void) setDelegate: (id) aDelegate;
{
    delegate = aDelegate;
}

- (id) delegate;
{
    return delegate;
}

- (NSFont *)font;
{
    return font;
}

- (void)setFont:(NSFont *)newFont;
{
    if (font == newFont)
	return;

    [font release];
    font = [newFont retain];

    [fontDescription release];
    fontDescription = [[NSString alloc] initWithFormat:@"%@ %.1f", [font displayName], [font pointSize]];
    textSize.height = ceil(NSHeight([font boundingRectForFont]));
    textSize.width = ceil([font widthOfString:fontDescription]);
    [self setNeedsDisplay:YES];
}

- (IBAction)setFontUsingFontPanel:(id)sender;
{
    if ([[self window] makeFirstResponder:self]) {
        NSFontManager *manager;
        NSFontPanel *panel;
        
        manager = [NSFontManager sharedFontManager];
        panel = [manager fontPanel: YES];
        [panel setDelegate: self];
	[manager orderFrontFontPanel:sender];
    }
}

// NSFontManager sends -changeFont: up the responder chain

- (BOOL)fontManager:(id)sender willIncludeFont:(NSString *)fontName;
{
    if ([delegate respondsToSelector: @selector(fontView:fontManager:willIncludeFont:)])
        return [delegate fontView: self fontManager: sender willIncludeFont: fontName];
    return YES;
}

- (void)changeFont:(id)sender;
{
    if ([delegate respondsToSelector: @selector(fontView:shouldChangeToFont:)])
        if (![delegate fontView:self shouldChangeToFont:font])
            return;

    [self setFont:[sender convertFont:[sender selectedFont]]];
    
    if ([delegate respondsToSelector: @selector(fontView:didChangeToFont:)])
        [delegate fontView:self didChangeToFont:font];
}

// NSFontPanel delegate


// NSView subclass

- (void)drawRect:(NSRect)rect
{
    NSRect bounds;

    bounds = [self bounds];
    if ([NSGraphicsContext currentContextDrawingToScreen])
        [[NSColor windowBackgroundColor] set];
    else
        [[NSColor whiteColor] set];
    NSRectFill(bounds);

    [[NSColor gridColor] set];
    NSFrameRect(bounds);
    [fontDescription drawWithFont:font color:[NSColor textColor] alignment:NSCenterTextAlignment verticallyCenter:YES inRectangle:bounds];

    if ([NSGraphicsContext currentContextDrawingToScreen] && [[self window] firstResponder] == self) {
	[[NSColor keyboardFocusIndicatorColor] set];
        NSFrameRect(NSInsetRect(bounds, 1.0, 1.0));
    }
}

- (BOOL)isFlipped;
{
    return YES;
}

- (BOOL)isOpaque;
{
    return YES;
}

// NSResponder subclass

- (BOOL)acceptsFirstResponder;
{
    return YES;
}

- (BOOL)becomeFirstResponder;
{
    if ([super becomeFirstResponder]) {
	[[NSFontManager new] setSelectedFont:font isMultiple:NO];
	[self setNeedsDisplay:YES];
	return YES;
    }
    return NO;
}

- (BOOL)resignFirstResponder;
{
    if (![[self window] isKeyWindow] ||
	![super resignFirstResponder])
	return NO;
    [self setNeedsDisplay:YES];
    return YES;
}
@end

@implementation NSString(FontExtensions)
- (void)drawWithFont:(NSFont *)font color:(NSColor *)color alignment:(int)alignment verticallyCenter:(BOOL)verticallyCenter inRectangle:(NSRect)rectangle;
{
    NSMutableDictionary *attributes;
	
    attributes = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (font)
        [attributes setObject:font forKey:NSFontAttributeName];
    if (color)
        [attributes setObject:color forKey:NSForegroundColorAttributeName];
	
    [self drawWithFontAttributes:attributes 
					   alignment:alignment
				verticallyCenter:verticallyCenter
					 inRectangle:rectangle];
    [attributes release];
}

- (void)drawWithFontAttributes:(NSDictionary *)attributes alignment:(int)alignment verticallyCenter:(BOOL)verticallyCenter inRectangle:(NSRect)rectangle;
{
    NSAttributedString *attributedString;
    
    attributedString = [[NSAttributedString alloc] initWithString:self attributes:attributes];
    [attributedString drawInRectangle:rectangle alignment:alignment verticallyCentered:verticallyCenter];
    [attributedString release];
}

+ (NSString *)horizontalEllipsisString;
{
    static NSString *string = nil;
	
    if (!string)
        string = [[NSString stringWithFormat: @"%@%@", self, @"É"] retain];
	NSLog(string);
    return @"É";
}


@end

@implementation NSAttributedString (FontExtensions)
- (void)drawInRectangle:(NSRect)rectangle alignment:(int)alignment verticallyCentered:(BOOL)verticallyCenter;
		  // ASSUMPTION: This is for one line
{
    static NSTextStorage *showStringTextStorage = nil;
    static NSLayoutManager *showStringLayoutManager = nil;
    static NSTextContainer *showStringTextContainer = nil;
	
    NSRange drawGlyphRange;
    NSRange lineCharacterRange;
    NSRect lineFragmentRect;
    NSSize lineSize;
    NSString *ellipsisString;
    NSSize ellipsisSize;
    NSDictionary *ellipsisAttributes;
    BOOL requiresEllipsis;
    BOOL lineTooLong;
	
    if ([self length] == 0)
        return;
	
    if (showStringTextStorage == nil) {
        showStringTextStorage = [[NSTextStorage alloc] init];
		
        showStringLayoutManager = [[NSLayoutManager alloc] init];
        [showStringTextStorage addLayoutManager:showStringLayoutManager];
		
        showStringTextContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(1.0e7, 1.0e7)];
        [showStringTextContainer setLineFragmentPadding:0.0];
        [showStringLayoutManager addTextContainer:showStringTextContainer];
    }
    
    [showStringTextStorage setAttributedString:self];
    
    lineFragmentRect = [showStringLayoutManager lineFragmentUsedRectForGlyphAtIndex:0 effectiveRange:&drawGlyphRange];
    lineSize = lineFragmentRect.size;
    lineTooLong = lineSize.width > NSWidth(rectangle);
    lineCharacterRange = [showStringLayoutManager characterRangeForGlyphRange:drawGlyphRange actualGlyphRange:NULL];
    requiresEllipsis = lineTooLong || NSMaxRange(lineCharacterRange) < [self length];
    
    if (requiresEllipsis) {
        unsigned int ellipsisAttributeCharacterIndex;
        if (lineCharacterRange.length != 0)
            ellipsisAttributeCharacterIndex = NSMaxRange(lineCharacterRange) - 1;
        else
            ellipsisAttributeCharacterIndex = 0;
        ellipsisAttributes = [self attributesAtIndex:ellipsisAttributeCharacterIndex longestEffectiveRange:NULL inRange:NSMakeRange(0, 1)];
        ellipsisString = [NSString horizontalEllipsisString];
        ellipsisSize = [ellipsisString sizeWithAttributes:ellipsisAttributes];
		
        if (lineTooLong || lineSize.width + ellipsisSize.width > NSWidth(rectangle)) {
            drawGlyphRange.length = [showStringLayoutManager glyphIndexForPoint:NSMakePoint(NSWidth(rectangle) - ellipsisSize.width, 0.5 * lineSize.height) inTextContainer:showStringTextContainer];
			
            if (drawGlyphRange.length == 0) {
                // We couldn't fit any characters with the ellipsis, so try drawing some without it (rather than drawing nothing)
                requiresEllipsis = NO;
                drawGlyphRange.length = [showStringLayoutManager glyphIndexForPoint:NSMakePoint(NSWidth(rectangle), 0.5 * lineSize.height) inTextContainer:showStringTextContainer];
            }
            lineSize.width = [showStringLayoutManager locationForGlyphAtIndex:NSMaxRange(drawGlyphRange)].x;
        }
        if (requiresEllipsis) // NOTE: Could have been turned off if the ellipsis didn't fit
            lineSize.width += ellipsisSize.width;
    } else {
        // Make the compiler happy, since it doesn't know we're not going to take the requiresEllipsis branch later
        ellipsisString = nil;
        ellipsisSize = NSMakeSize(0, 0);
        ellipsisAttributes = nil;
    }
	
    if (drawGlyphRange.length) {
        NSPoint drawPoint;
		
        // determine drawPoint based on alignment
        drawPoint.y = NSMinY(rectangle);
        switch (alignment) {
            default:
            case NSLeftTextAlignment:
                drawPoint.x = NSMinX(rectangle);
                break;
            case NSCenterTextAlignment:
                drawPoint.x = NSMidX(rectangle) - lineSize.width / 2.0;
                break;
            case NSRightTextAlignment:
                drawPoint.x = NSMaxX(rectangle) - lineSize.width;
                break;
        }
        
        if (verticallyCenter)
            drawPoint.y = NSMidY(rectangle) - lineSize.height / 2.0;
		
        [showStringLayoutManager drawGlyphsForGlyphRange:drawGlyphRange atPoint:drawPoint];
        if (requiresEllipsis) {
            drawPoint.x += lineSize.width - ellipsisSize.width;
            [ellipsisString drawAtPoint:drawPoint withAttributes:ellipsisAttributes];
        }
    }
}
@end