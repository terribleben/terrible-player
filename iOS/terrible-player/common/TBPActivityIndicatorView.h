//
//  TBPActivityIndicatorView.h
//  terrible-player
//
//  Created by Ben Roth on 10/9/14.
//  Copyright (c) 2014 Ben Roth. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum TBPActivityIndicatorViewStyle : NSUInteger {
    kTBPActivityIndicatorViewStyleSmall,
    kTBPActivityIndicatorViewStyleLarge
} TBPActivityIndicatorViewStyle;

@interface TBPActivityIndicatorView : UIView

- (id) initWithActivityIndicatorViewStyle: (TBPActivityIndicatorViewStyle)style;
- (void) startAnimating;
- (void) stopAnimating;

@end
