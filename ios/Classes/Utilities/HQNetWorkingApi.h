//
//  HQNetWorkingApi.h
//  hatsune
//
//  Created by Mike Leong on 12/05/2017.
//  Copyright © 2017 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HQNetworking.h"

@interface HQNetWorkingApi : NSObject


/**
 查询审核情况

 @param platform 用户设备平台:(1:iOS, 2:android)
 @param channel (可选)渠道, 默认是default
 @param uniqueId 应用唯一标识, iOS为BundleID, android为packageID
 @param version 应用内部构件版本, ios为BuildVersion, android为VersionCode
 @param handler 成功回调
 */
+ (void)requestReviewInfoWithPlatform:(NSString *)platform channel:(NSString *)channel appUniqueId:(NSString *)uniqueId version:(NSString *)version handler:(ResponseHandler)handler;

@end
