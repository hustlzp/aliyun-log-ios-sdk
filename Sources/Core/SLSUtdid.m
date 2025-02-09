//
//  Utdid.m
//  AliyunLogCommon
//
//  Created by gordon on 2021/6/1.
//

#import "SLSUtdid.h"
#import "SLSStorage.h"

@interface SLSUtdid ()

@end

@implementation SLSUtdid
+ (NSString *) getUtdid {
    NSString *utdid = [SLSStorage getUtdid];
    if(utdid.length > 0) {
        return [utdid copy];
    }
    
    NSString *uuid = [[NSUUID UUID] UUIDString];
    [SLSStorage setUtdid:uuid];
    
    return [uuid copy];
}

+ (void) setUtdid: (NSString *) utdid {
    if (utdid.length == 0) {
        return;
    }
    
    [SLSStorage setUtdid:utdid];
}

@end

