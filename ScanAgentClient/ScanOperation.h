//
//  ScanOperation.h
//  ScanService
//
//  Created by It's me! on 11/12/13.
//  Copyright (c) 2013 comodo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScanAgent.h"

@protocol ProgressProtocol <NSObject>

- (void)onBeginScanWithTotals:(NSInteger)number;
- (void)onDidScanFile:(NSString *)file withGUIDs:(NSArray *)guids;
- (void)onCompleteScan;

@end

@interface ScanOperation : NSOperation {
    id<ScanAgent> _agent;
    NSArray *_selection;
    id<ProgressProtocol> _delegate;
}

- (id)initWithSelection:(NSArray *)selection
               delegate:(id<ProgressProtocol>)delegate;

@end
