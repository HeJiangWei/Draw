/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"
#import "CodePush.h"

#import "RCTBundleURLProvider.h"
#import "RCTRootView.h"

#import "UMMobClick/MobClick.h"
#import "RCTUmengPush.h"
#import "HQNetWorkingApi.h"

#import "LoadingViewController.h"
#import "ViewController.h"

// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif


@interface AppDelegate ()<JPUSHRegisterDelegate>

@property (nonatomic, strong) NSDictionary *launchOptions;

@property (nonatomic, strong) UIViewController *nativeRootController;
@property (nonatomic, strong) UIViewController *reactNativeRootController;
@property (nonatomic, strong) UIViewController *loadingController;

@end

@implementation AppDelegate

static NSString *const ShowReactNativeContent = @"interestingThingsHappen";

#pragma mark - applicaton life circle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.launchOptions = launchOptions;
    
    self.window = [[UIWindow alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    [self showReactNativeControllerIfInNeed];
    [self.window makeKeyAndVisible];
    
    // FIXME: 友盟推送配置
    [self registerForUmentWithAppKey:@"59e8706bb27b0a4963000786"];
    
    // FIXME: 极光推送配置
    [self registerForJpushWithAppKey:@"5d8103da01abd55640049586"];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //获取deviceToken
    [RCTUmengPush application:application didRegisterDeviceToken:deviceToken];
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //获取远程推送消息
    [RCTUmengPush application:application didReceiveRemoteNotification:userInfo];
    
    [JPUSHService handleRemoteNotification:userInfo];
}

#pragma mark - custom methods

-  (void)restoreRootViewController:(UIViewController *)newRootController {
    [UIView transitionWithView:self.window duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        BOOL oldState = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        if (self.window.rootViewController!=newRootController) {
            self.window.rootViewController = newRootController;
        }
        [UIView setAnimationsEnabled:oldState];
    } completion:nil];
}

- (void)showReactNativeControllerIfInNeed {
    // 网络更新本地配置会有延迟，先根据本地配置进行展示，防止闪退
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL showRNContentAtFirst = [userDefaults boolForKey:ShowReactNativeContent];
    id containKey = [userDefaults objectForKey:ShowReactNativeContent];
    if (containKey!=nil) {
        if (showRNContentAtFirst) {
            self.window.rootViewController = self.reactNativeRootController;
        } else {
            self.window.rootViewController = self.nativeRootController;
        }
    } else {
        self.window.rootViewController = self.loadingController;
    }
    
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleVersion = [infoPlist objectForKey:@"CFBundleVersion"];
    NSString *bundleIdentifer = [infoPlist objectForKey:@"CFBundleIdentifier"];
    [HQNetWorkingApi requestReviewInfoWithPlatform:@"1" channel:@"AppStore" appUniqueId:bundleIdentifer version:bundleVersion handler:^(NSDictionary *allHeaderFields, NSDictionary *responseObject) {
        NSInteger statusCode = [responseObject[@"code"] integerValue];
        if (statusCode>=200 && statusCode<=206) {
            // 请求成功的情况
            NSDictionary *dataDic = responseObject[@"data"];
            NSInteger reviewStatusCode = [dataDic[@"reviewStatus"] integerValue];
            if (reviewStatusCode==2) {
                // 已经通过审核
                [userDefaults setBool:YES forKey:ShowReactNativeContent];
            } else {
                // 没有通过审核
                [userDefaults setBool:NO forKey:ShowReactNativeContent];
            }
        } else {
            // 请求失败的情况
            [userDefaults setBool:NO forKey:ShowReactNativeContent];
        }
        // 根据缓存来展示RN内容
        BOOL showRNContent = [userDefaults boolForKey:ShowReactNativeContent];
        dispatch_async(dispatch_get_main_queue(), ^{
            // 切换主线程进行展示
            if (showRNContent) {
                [self restoreRootViewController:self.reactNativeRootController];
            } else {
                [self restoreRootViewController:self.nativeRootController];
            }
        });
    }];
}

#pragma mark - 第三方

- (void)registerForJpushWithAppKey:(NSString *)appKey {
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:self.launchOptions
                           appKey:appKey
                          channel:@"App Store"
                 apsForProduction:YES];
}


/**
 注册友盟服务
 
 @param appKey 友盟key
 */
- (void)registerForUmentWithAppKey:(NSString *)appKey {
    //注册友盟推送
    [RCTUmengPush registerWithAppkey:appKey launchOptions:self.launchOptions];
    UMConfigInstance.appKey = appKey;
    UMConfigInstance.channelId = @"App Store";
    //  UMConfigInstance.eSType=E_UM_GAME;//友盟游戏统计，如不设置默认为应用统计
    [MobClick startWithConfigure:UMConfigInstance];
    [MobClick setLogEnabled:YES];
}

#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark - getter and setter

- (UIViewController *)loadingController {
    if (!_loadingController) {
        _loadingController = [[LoadingViewController alloc] init];
    }
    return _loadingController;
}

/**
 懒加载
 
 @return React-Native的控制器
 */
- (UIViewController *)reactNativeRootController {
    if (!_reactNativeRootController) {
        _reactNativeRootController = [[UIViewController alloc] init];
        NSURL *jsCodeLocation;
        [CodePush overrideAppVersion:@"1.0.0"];
#ifdef DEBUG
        jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];
#else
        jsCodeLocation = [CodePush bundleURL];
#endif
        
        RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                            moduleName:@"hatsune"
                                                     initialProperties:nil
                                                         launchOptions:self.launchOptions];
        rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];
        _reactNativeRootController.view = rootView;
    }
    return _reactNativeRootController;
}


/**
 懒加载
 
 @return Native的控制器
 */
- (UIViewController *)nativeRootController {
    if (!_nativeRootController) {
        _nativeRootController = [[ViewController alloc] init];
        _nativeRootController.view.backgroundColor = [UIColor redColor];
    }
    return _nativeRootController;
}

@end
