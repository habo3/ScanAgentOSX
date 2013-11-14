//
//  ScanOperation.h
//  ScanService
//
//  Created by It's me! on 11/12/13.
//  Copyright (c) 2013 comodo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScanAgent.h"

#pragma mark - ProgressProtocol definition
@protocol ProgressProtocol <NSObject>

- (void)onProgressTotalUpdate:(NSInteger)number clearStats:(BOOL)doClear;
- (void)onDidScanFile:(NSString *)file withGUIDs:(NSArray *)guids;
- (void)onCompleteScan;

@end

#pragma mark - ControllerOperation (initiate worker operations)
@interface ControllerOperation : NSOperation {
    NSArray *_selection;
    NSOperationQueue *_queue;
    id<ProgressProtocol> _delegate;
}

- (id)initWithSelection:(NSArray *)selection
         operationQueue:(NSOperationQueue *)queue
               delegate:(id<ProgressProtocol>)delegate;

@end

#pragma mark - ScanOperation (do the scan job)
@interface ScanOperation : NSOperation {
    NSString *_filePath;
    id<ScanAgent> _agent;
    id<ProgressProtocol> _delegate;
}

- (id)initWithFilePath:(NSString *)filePath
               delegate:(id<ProgressProtocol>)delegate;

@end
