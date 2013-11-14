//
//  main.m
//  ScanService
//
//  Created by It's me! on 11/7/13.
//  Copyright (c) 2013 comodo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScanAgentImpl.h"

@interface MyListenerDelegate : NSObject<NSXPCListenerDelegate>
@end

@implementation MyListenerDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)connection
{
    connection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(ScanAgent)];
    connection.exportedObject = [ScanAgentImpl new];
    [connection resume];
    return YES;
}

@end

int main(int argc, const char *argv[])
{
    NSXPCListener *listener = [NSXPCListener serviceListener];
    
    id<NSXPCListenerDelegate> delegate = [MyListenerDelegate new];
    listener.delegate = delegate;
    [listener resume];
    
    // The resume method never returns.
    exit(EXIT_FAILURE);
    return 0;
}
