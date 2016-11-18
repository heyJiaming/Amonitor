//
//  AppDelegate.m
//  Amonitor
//
//  Created by iOS程序员 on 16/10/26.
//  Copyright © 2016年 leye. All rights reserved.
//

#import "AppDelegate.h"
#import "LYHomeViewController.h"
#import "LYGetIPAdress.h"
#import "LYUdpBroadcastTool.h"
#import "GCDSocketTools.h"
#import  "AsyncUdpSocket.h"
#import  "LYUdpBroadcastTool.h"

@interface AppDelegate ()<AsyncUdpSocketDelegate>

@end

@implementation AppDelegate

// 控制横竖屏的
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskLandscape;
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    //程序启动的时候就开始 请求数据
        [[LYUdpBroadcastTool defaultInstance] sendString:[NSString stringWithFormat:@"ksregister:%@",[LYGetIPAdress getIPAddress:YES]] Tag:1];
    LYHomeViewController *homeViewController = [[LYHomeViewController alloc]init];
    self.window.rootViewController = homeViewController;
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    

}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
     [[GCDSocketTools sharedInstance] sendDict:nil OrString:@"disconnect" returnMsg:nil returnError:nil andTag:110];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"SECTION"];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"ROW"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
//    [[GCDSocketTools sharedInstance].udpSocket close];
//   
//    [[LYUdpBroadcastTool defaultInstance].udpSocket close];
//
//    
//    NSError *error;
//    AsyncUdpSocket *socket = [[AsyncUdpSocket alloc]initIPv4];
//    socket.delegate = self;
//    [socket bindToPort:8604 error:&error];
//    NSLog(@"%@",error);
//    NSData *data = [@"disconnect" dataUsingEncoding:NSUTF8StringEncoding];
//    [socket sendData:data toHost:[GCDSocketTools sharedInstance].server_host port:8601 withTimeout:-1 tag:44];
    [[GCDSocketTools sharedInstance] sendDict:nil OrString:@"disconnect" returnMsg:nil returnError:nil andTag:110];
//    [[GCDSocketTools sharedInstance].udpSocket closeAfterSending];
    
}


@end
