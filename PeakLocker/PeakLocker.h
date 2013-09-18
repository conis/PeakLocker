//
//  PeakLocker.h
//  PeakLocker-Samples
//
//  Created by conis on 9/17/13.
//  Copyright (c) 2013 conis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKGestureLockView.h"
#import "UIView+Peak.h"
#import <CommonCrypto/CommonDigest.h>

@protocol PeakLockerDelegate;


typedef enum{
  //模式解锁
  PeakLockerPanelPattern,
  //密码解锁
  PeakLockerPanelPassword
}PeakLockerPanel;


typedef enum{
  PeakLockerTypeSignin,
  PeakLockerTypeSignup,
  PeakLockerTypeChangePassword,
  PeakLockerTypeSwitch
}PeakLockerType;

@interface PeakLocker : UIViewController<KKGestureLockViewDelegate>

//校验完成成功的通知
extern NSString * const kPeakLockerNotificationValidation;
extern NSString * const kPeakLockerUserDefaultPassword;

//是否为空密码，即未设置密码
@property (nonatomic) BOOL isEmptyPassword;

@property (nonatomic, strong) UIColor *appNameTextColor;
@property (nonatomic, weak) id<PeakLockerDelegate> delegate;
//密码最小长度
@property (nonatomic) NSInteger minimumLength;
//背景图片
@property (nonatomic, strong) UIImage *backgroundImage;
//app logo的图片
@property (nonatomic, strong) UIImage *appIcon;
//app的名称
@property (nonatomic, strong) NSString *appName;
//单位时间最大允许尝试次数，0表示不限制
@property (nonatomic) NSInteger maxTryCount;
//最大尝试的单位时间，以分钟为单位
@property (nonatomic) NSInteger minutesOfMaxTry;
//是否允许用户切换解锁方式，默认为不允许
@property (nonatomic) BOOL allowUserChangeLockerType;
//是否自己保存密码到用户配置文件中(通过MD5加密)
@property (nonatomic) BOOL storedPassword;
//模式解锁默认的图片
@property (nonatomic, strong) UIImage *patternLockNormalImage;
//模式解锁调试的图片
@property (nonatomic, strong) UIImage *patternLockHighlightImage;
//解锁的类型
@property (nonatomic) PeakLockerPanel lockerPanel;

@property (nonatomic, strong) UIViewController *rootViewController;
//清除所保存的密码，如果是使用PeakLocker保存密码的话
-(void) removePassword;

//注册，让用户设置密码，用户是否可以选择取消。在注册的时候可以选择解锁方式
-(void) signup: (BOOL) cancel;
//登陆
-(void) signin: (BOOL) cancel;
//修改密码
-(void) changePassword: (BOOL) cancel;
//切换密码校验方式
//-(void) changeLockerType: (PeakLockerType) lockerType;

+(id) sharedManager;
@end

@protocol PeakLockerDelegate <NSObject>
@optional
//完成
-(void) peakLockerDidFinish: (PeakLocker *) locker type: (PeakLockerType) type password: (NSString *) password;
//取消
-(void) peakLockerDidCancel: (PeakLocker *) locker type: (PeakLockerType) type;
//校验密码是否正确（也可能是在修改密码的时候）
-(BOOL) peakLockerValidateWithPassword: (NSString *) password;
@end
