//
//  ScanOperation.m
//  ScanService
//
//  Created by It's me! on 11/12/13.
//  Copyright (c) 2013 comodo. All rights reserved.
//

#import "ScanOperation.h"

#pragma mark - ControllerOperation implementation
@implementation ControllerOperation

- (id)initWithSelection:(NSArray *)selection
         operationQueue:(NSOperationQueue *)queue
               delegate:(id<ProgressProtocol>)delegate
 {
    if (self = [super init]) {
        _queue = queue;
        _selection = selection;
        _delegate = delegate;
    }
    
    return self;
}


-(void)openEachFileAt:(NSString*)path total:(int *)number {
    
    // check if it's a directory
    BOOL isDirectory = NO;
    if( NO == [[NSFileManager defaultManager] fileExistsAtPath:path
                                             isDirectory:&isDirectory] ) {
        return;
    }
    
    if( NO == isDirectory) {
        NSAssert(NO, @"path should be folder");
    }
    
    NSDirectoryEnumerator *enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    
    NSString *file;
    while (file = [enumerator nextObject]) {
        
        if( [self isCancelled] )
            return;
        
        NSString *filePath = [path stringByAppendingPathComponent:file];
        if( NO == [[NSFileManager defaultManager] fileExistsAtPath:filePath
                                                       isDirectory:&isDirectory] &&
           isDirectory) {
            continue;
        }

        if( number ) {
            ++(*number);
            dispatch_sync( dispatch_get_main_queue(), ^{
                [_delegate onProgressTotalUpdate:*number clearStats:NO];
            });
        }
        
        ScanOperation *nextOperation = [[ScanOperation alloc] initWithFilePath:filePath
                                                                      delegate:_delegate];
        [_queue addOperation:nextOperation];
        
    }
}

- (void)main {

    dispatch_sync( dispatch_get_main_queue(), ^{
        [_delegate onProgressTotalUpdate:1 clearStats:YES];
    });

    int total = 0;
    for(NSURL *nextItem in _selection) {
        [self openEachFileAt:nextItem.path total:&total];
    }
}

@end

#pragma mark - ScanOperation implementation
@implementation ScanOperation

- (id)initWithFilePath:(NSString *)filePath delegate:(id<ProgressProtocol>)delegate {
    
    if( self = [super init]) {
        _filePath = filePath;
        _delegate = delegate;
        NSXPCConnection *connection =
        [[NSXPCConnection alloc] initWithServiceName:@"com.comodo.ScanService"];
        connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ScanAgent)];
        [connection resume];
        
        _agent = [connection remoteObjectProxy];
    }
    
    return self;
}

- (void)main {
    __block BOOL respondProcessed = NO;
    [_agent scanFileByPath:_filePath
              malwareGUIDs:^(NSArray *guids){
                  respondProcessed = YES;
                  dispatch_async( dispatch_get_main_queue(), ^{
                      [_delegate onDidScanFile:_filePath withGUIDs:guids];
                  });
              }];
    
    while(!respondProcessed && ![self isCancelled]) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
}

@end
