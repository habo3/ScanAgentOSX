//
//  ScanAgentImpl.m
//  ScanService
//
//  Created by It's me! on 11/8/13.
//  Copyright (c) 2013 comodo. All rights reserved.
//

#import "ScanAgentImpl.h"

@interface ScanAgentImpl()

-(NSData*)convertHexStringToNSData:(NSString *)hex;

@end

@implementation ScanAgentImpl

#pragma mark - Private methods
-(NSData *)convertHexStringToNSData:(NSString *)hexString {
    
    NSMutableData *results = [NSMutableData new];
    char byte_chars[3] = {'\0','\0','\0'};
    for (int i=0; i < [hexString length]/2; ++i) {
        byte_chars[0] = [hexString characterAtIndex:i*2];
        byte_chars[1] = [hexString characterAtIndex:i*2+1];
        unsigned char whole_byte = strtol(byte_chars, NULL, 16);
        [results appendBytes:&whole_byte length:1];
    }
    
    return [NSData dataWithData:results];
}


#pragma mark - Public methods
-(id)init {
    if ( self = [super init] ) {
        [self initSignatures];
    }
    
    return self;
}

-(void)initSignatures {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"malware_data" ofType:@"txt"];
    
    NSError *error = nil;
    NSString *contents = [NSString stringWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    for(NSString *line in [contents componentsSeparatedByString:@"\n"]) {
        NSArray *seqAndGuid = [line componentsSeparatedByString:@"."];
        if( [seqAndGuid count] == 2) {
            
            NSData *bytes = [self convertHexStringToNSData:seqAndGuid[0]];
            NSLog(@"%@ converted to %@", seqAndGuid[0], bytes);
            
            [data setObject:seqAndGuid[1]
                     forKey:bytes];
        }
    }

    _signatures = [NSDictionary dictionaryWithDictionary:data];
}

#pragma mark - ScanAgent protocol implementation

-(void)scanFileByPath:(NSString *)path malwareGUIDs:(ReplyBlock)reply {
    NSString *fullPath = [path stringByExpandingTildeInPath];
    NSLog(@"scanning %@", path);

    BOOL isDir = NO;
    // return if there is no specified file exist or it is a directory
    if( NO == [[NSFileManager defaultManager] fileExistsAtPath:fullPath
                                                   isDirectory:&isDir] ||
       YES == isDir) {
        reply([NSArray array]);
        return;
    }
    
    NSData *data = [NSData dataWithContentsOfMappedFile:fullPath];
    [self scanBytes:data malwareGUIDs:reply];
}

-(void)scanBytes:(NSData*)input malwareGUIDs:(ReplyBlock)reply {
    
    NSMutableArray *guids = [NSMutableArray array];
    
    for(NSData *sample in [_signatures allKeys]) {
        
        if( [input rangeOfData:sample
                       options:0
                         range:NSMakeRange(0, [input length])].location != NSNotFound ) {
            [guids addObject:[_signatures objectForKey:sample] ];
        }
    }
    
    reply([NSArray arrayWithArray:guids]);
}


@end
