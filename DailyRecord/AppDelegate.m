//
//  AppDelegate.m
//  DailyRecord
//
//  Created by Zheng Li on 2021/7/15.
//

#import "AppDelegate.h"
#import "MainPageViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
    UIViewController *rootVC = [[MainPageViewController alloc] init];
    UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:rootVC];
    
    self.window.rootViewController = navCtrl;
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end
