//
//  TBPConstants.h
//  terrible-player
//
//  Created by Ben Roth on 10/8/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBPConstants <NSObject>

#define TBP_FONT @"HelveticaNeue"
#define TBP_FONT_BOLD @"HelveticaNeue-Bold"
#define TBP_FONT_LIGHT @"HelveticaNeue-Light"

#define TBP_COLOR_BACKGROUND 0x000000
#define TBP_COLOR_TEXT_LIGHT 0xffffff
#define TBP_COLOR_TEXT_DIM 0xaaaaaa

#define TBP_COLOR_GREY_DEFAULT 0x222222
#define TBP_COLOR_GREY_SELECTED 0x444444

#define TBP_COLOR_ACTION 0xbb0000

#define kTBPAPIEndpointLastFM @"TBPAPIEndpointLastFM"
#define kTBPConfigLastFMKey @"TBPConfigLastFMKey"
#define kTBPConfigLastFMSecret @"TBPConfigLastFMSecret"

@end
