//
//  MBProgressHUD+Extension.m
//  LefenStore1.0
//
//  Created by Young on 15/10/30.
//  Copyright © 2015年 lefen58.com. All rights reserved.
//

#import "MBProgressHUD+Extension.h"

@implementation MBProgressHUD (Extension)

+ (MBProgressHUD *)hudWithText:(NSString *)lableText withView:(UIView *)parentView{

    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    hud.labelFont = [UIFont systemFontOfSize:12.0];
    [parentView addSubview:hud];
    hud.labelText = lableText;

    return hud;
}

+ (void)showHudWithText:(NSString *)labelText View:(UIView *)parentView {
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    hud.labelFont = [UIFont systemFontOfSize:12.0];
    [parentView addSubview:hud];
    hud.labelText = labelText;
    
    [hud show:YES];
    [hud hide:YES afterDelay:1.0];
}

+ (void)showHudWithOutAcitity:(NSString *)labelText View:(UIView *)parentView {
    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    hud.mode = MBProgressHUDModeText;
    hud.labelFont = [UIFont systemFontOfSize:12.0];
    [parentView addSubview:hud];
    hud.labelText = labelText;
    
    [hud show:YES];
    [hud hide:YES afterDelay:1.0];
}

+ (MBProgressHUD *)hudWithText:(NSString *)lableText withView:(UIView *)parentView isGraceTime:(BOOL)isGraceTime{
    
    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    if (isGraceTime) {
        hud.graceTime = 0.5;
        hud.taskInProgress = YES;
    }
    hud.labelFont = [UIFont systemFontOfSize:12.0];
    [parentView addSubview:hud];

    hud.labelText = lableText;
    
    return hud;
}

+ (void)showHud:(NSString *)text icon:(NSString *)icon view:(UIView *)view {
    
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    hud.labelFont = [UIFont systemFontOfSize:12.0];
    
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:icon]];
    
    hud.mode = MBProgressHUDModeCustomView;
    
    hud.removeFromSuperViewOnHide = YES;
    
    [hud hide:YES afterDelay:1.0];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view {
    
    [self showHud:success icon:@"hud_success" view:view];
}

+ (void)showFailure:(NSString *)failure toView:(UIView *)view {

    [self showHud:failure icon:@"hud_error" view:view];
}

+ (void)showError{
    
    [self showHudWithOutAcitity:@"网络错误" View:[[UIApplication sharedApplication].windows lastObject]];
}


@end
