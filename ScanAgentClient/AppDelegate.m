//
//  AppDelegate.m
//  ScanAgentClient
//
//  Created by It's me! on 11/8/13.
//  Copyright (c) 2013 comodo. All rights reserved.
//

#import "AppDelegate.h"
#import "ScanAgent.h"

@interface AppDelegate () {
    id<ScanAgent> _agentProxy;
}

@end

@implementation AppDelegate
@synthesize window, progress, progressIndicator;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    _scanningQueue = [NSOperationQueue new];
    [_scanningQueue setMaxConcurrentOperationCount:5];
    
    // Insert code here to initialize your application
    NSXPCConnection *connection =
    [[NSXPCConnection alloc] initWithServiceName:@"com.comodo.ScanService"];
    connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ScanAgent)];
    
    [connection resume];

    _agentProxy = [connection remoteObjectProxy];
    
    unsigned char bytes[] = { 0x01, 0x23, 0x45, 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF, 0x55,
                              0x01, 0x23, 0x45, 0x67, 0x89, 0xAB};
    
    [_agentProxy scanBytes:[NSData dataWithBytes:bytes
                                         length:sizeof(bytes)]
             malwareGUIDs:^(NSArray* guids) {
        NSLog(@"%@", guids);
    }];
    
}

- (IBAction)selectFilesForScanning:(id)sender {
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:YES];
    
    [openDlg setAllowsMultipleSelection:YES];
    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* selection = [openDlg URLs];
        [openDlg close];
        
        [_scanningQueue cancelAllOperations];
        [_scanningQueue addOperation:[[ScanOperation alloc] initWithSelection:selection
                                                                     delegate:self]];

        if( NO == [window isVisible]) {
            [window makeKeyAndOrderFront:self];
            [window center];
        }
        [self updateStatusWith:nil];

    }
}

- (void) onBeginScanWithTotals:(NSInteger)number {
    _state.processedCount = 0;
    _state.infectedCount = 0;
    _state.totalToScan = number;
    [self updateStatusWith:nil];
}

- (void) onDidScanFile:(NSString *)file withGUIDs:(NSArray *)guids {
    ++_state.processedCount;
    [self updateStatusWith:guids];
    
    if( _state.processedCount >= _state.totalToScan) {
        [self onCompleteScan];
    }
}

- (void) onCompleteScan {
    [self updateStatusWith:nil];
}

- (IBAction)onDialogClose:(id)sender {
    [_scanningQueue cancelAllOperations];
    [window orderOut:self];
}

- (void)updateStatusWith:(NSArray *)guids {
    
    BOOL activityIteratesFiles = (0 == _state.totalToScan);
    BOOL activityInProgress = (_state.processedCount && _state.processedCount < _state.totalToScan);
    BOOL activityCompleted = !activityIteratesFiles && (_state.processedCount >= _state.totalToScan);
    
    if(activityCompleted) {
        [progress setStringValue:@"Scanning completed"];
    } else
    if(activityInProgress) {
        [progressIndicator setDoubleValue:(double)_state.processedCount];
        
        [progress setStringValue:[NSString stringWithFormat:@"Scanning %d of %d",
                                  _state.processedCount, _state.totalToScan]];
        if([guids count]) {
            ++_state.infectedCount;
            [_statistics setStringValue:[NSString stringWithFormat:@"Infected %d files",
                                         _state.infectedCount]];
        }
        
    } else
    if(activityIteratesFiles){
        [progress setStringValue:@"Scanning initialisation..."];
        [_statistics setStringValue:@""];
        [progressIndicator setDoubleValue:0.0];
        [progressIndicator setMaxValue:1.0];
    } else {
        [progress setStringValue:@"Scanning started"];
        [_statistics setStringValue:[NSString stringWithFormat:@"Infected %d files", 0]];
        [progressIndicator setDoubleValue:0.0];
        [progressIndicator setMaxValue:(double)_state.totalToScan];
    }
}



@end
