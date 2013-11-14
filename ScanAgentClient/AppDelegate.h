//
//  AppDelegate.h
//  ScanAgentClient
//
//  Created by It's me! on 11/8/13.
//  Copyright (c) 2013 comodo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ScanOperation.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, ProgressProtocol> {
    NSOperationQueue *_scanningQueue;
    
    struct ScanState {
        int infectedCount;
        int processedCount;
        int totalToScan;
    } _state;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet NSTextField *progress;
@property (assign) IBOutlet NSTextField *statistics;
@property (assign) IBOutlet NSButton *closeButton;

- (IBAction)onDialogClose:(id)sender;
- (IBAction)selectFilesForScanning:(id)sender;

@end
