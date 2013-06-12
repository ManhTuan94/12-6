//
//  AppDelegate.h
//  demoPhoto
//
//  Created by TechmasterVietNam on 5/31/13.
//  Copyright (c) 2013 TechmasterVietNam. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UINavigationControllerDelegate,UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property (strong, nonatomic) UINavigationController* navigationViewController;

@end
