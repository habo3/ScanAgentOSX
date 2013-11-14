//
//  ScanAgent.h
//  ScanService
//
//  Created by It's me! on 11/8/13.
//  Copyright (c) 2013 comodo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ReplyBlock)(NSArray *);

@protocol ScanAgent <NSObject>

// scan single file, return Array of detected signature GUIDs
-(void)scanFileByPath:(NSString *)path malwareGUIDs:(ReplyBlock)block;

// scan byte sequence, return Array of detected signature GUIDs
-(void)scanBytes:(NSData *)bytes malwareGUIDs:(ReplyBlock)block;

@end
