//
//  TBPAudioTask.h
//  terrible-player
//
//  Created by Ben Roth on 10/22/17.
//  Copyright © 2017 Ben Roth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TBPAudioTask : NSObject

/**
 *  Listen to music library change events and application state changes.
 *  This class initiates a looping, silent audio task whenever there is system music playing,
 *  so that iOS doesn't terminate the app in the background and we continue receiving system
 *  notifications while in the background.
 *
 *  The audio task will be terminated when music stops in order to conserve battery.
 */
- (void)beginMonitoring;

@end
