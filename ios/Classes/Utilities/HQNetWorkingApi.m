//
//  HQNetWorkingApi.m
//  hatsune
//
//  Created by Mike Leong on 12/05/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import "HQNetWorkingApi.h"

@implementation HQNetWorkingApi

+ (void)requestReviewInfoWithPlatform:(NSString *)platform channel:(NSString *)channel appUniqueId:(NSString *)uniqueId version:(NSString *)version handler:(ResponseHandler)handler {
    [HQNetworking getWithUrl:HQNetworkingReviewUrl ParamsHandler:^(NSMutableDictionary *allHeaderFields, NSMutableDictionary *params) {
        params[@"platform"] = platform;
        params[@"channel"] = channel;
        params[@"appUniqueId"] = uniqueId;
        params[@"version"] = version;
    } handler:handler];
}

@end
