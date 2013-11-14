//
//  ScanOperation.m
//  ScanService
//
//  Created by It's me! on 11/12/13.
//  Copyright (c) 2013 comodo. All rights reserved.
//

#import "ScanOperation.h"

@implementation ScanOperation

- (id)initWithSelection:(NSArray *)selection delegate:(id<ProgressProtocol>)delegate {
    if (self = [super init]) {
        _selection = selection;
        _delegate = delegate;
        
        // Insert code here to initialize your application
        NSXPCConnection *connection =
        [[NSXPCConnection alloc] initWithServiceName:@"com.comodo.ScanService"];
        connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ScanAgent)];
        
        [connection resume];
        
        _agent = [connection remoteObjectProxy];
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
            continue;
        }
        
        __block BOOL respondProcessed = NO;
        [_agent scanFileByPath:filePath
                  malwareGUIDs:^(NSArray *guids){
                      respondProcessed = YES;
                      dispatch_async( dispatch_get_main_queue(), ^{
                          [_delegate onDidScanFile:filePath withGUIDs:guids];
                      });
                  }];
        
        while(!respondProcessed && ![self isCancelled]) {
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        }
    }
}

- (void)main {

    int total = 0;
    for(NSURL *nextItem in _selection) {
        [self openEachFileAt:nextItem.path total:&total];
    }

    dispatch_async( dispatch_get_main_queue(), ^{
        [_delegate onBeginScanWithTotals:total];
    });

    for(NSURL *nextItem in _selection) {
        [self openEachFileAt:nextItem.path total:nil];
    }
}

@end
