//
//  MBProgressHUD+Extension.h
//  LefenStore1.0
//
//  Created by Young on 15/10/30.
//  Copyright © 2015年 lefen58.com. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Extension)
+ (MBProgressHUD *)hudWithText:(NSString *)lableText withView:(UIView *)parentView isGraceTime:(BOOL)isGraceTime;


+ (MBProgressHUD *)hudWithText:(NSString *)lableText withView:(UIView *)parentView;

+ (void)showHudWithText:(NSString *)labelText View:(UIView *)parentView;


+ (void)showHudWithOutAcitity:(NSString *)labelText View:(UIView *)parentView;

+ (void)showHud:(NSString *)text icon:(NSString *)icon view:(UIView *)view;

+ (void)showSuccess:(NSString *)success toView:(UIView *)view;

+ (void)showFailure:(NSString *)failure toView:(UIView *)view;

+ (void)showError;
@end
