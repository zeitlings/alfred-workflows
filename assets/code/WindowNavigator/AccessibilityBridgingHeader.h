//
//  AccessibilityBridgingHeader.h
//  Window Navigator
//
//  Created by Patrick Sy on 22/05/2024.
//

#ifndef AccessibilityBridgingHeader_h
#define AccessibilityBridgingHeader_h

#import <AppKit/AppKit.h>

AXError _AXUIElementGetWindow(AXUIElementRef element, uint32_t *identifier);

#endif /* AccessibilityBridgingHeader_h */

