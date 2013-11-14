//
//  ScanAgentImpl.h
//  ScanService
//
//  Created by It's me! on 11/8/13.
//  Copyright (c) 2013 comodo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScanAgent.h"

@interface ScanAgentImpl : NSObject<ScanAgent> {
    NSDictionary *_signatures;
}

@end
