//
//  PeakLocker.h
//  PeakLocker-Samples
//
//  Created by conis on 9/17/13.
//  Copyright (c) 2013 conis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KKGestureLockView.h"

@protocol PeakLockerDelegate;

typedef enum{
  //模式解锁
  PeakLockerPattern,
  //密码解锁
  PeakLockerPassword
}PeakLockerType;

@interface PeakLocker : NSObject<KKGestureLockViewDelegate>
//校验完成成功的通知
extern const NSString * kPeakLockerNotificationValidation;
extern const NSString * kPeakLockerUserDefaultPassword;

@property (nonatomic, weak) id<PeakLockerDelegate> delegate;
//密码最小长度
@property (nonatomic) NSInteger minimumLength;
//背景图片
@property (nonatomic, strong) UIImage *backgroundImage;
//app logo的图片
@property (nonatomic, strong) UIImage *appIcon;
//app的名称
@property (nonatomic, strong) NSString *appName;
//注册
@property (nonatomic, strong) NSString *signupMessage;
//登陆
@property (nonatomic, strong) NSString *signinMessage;
//修改密码
@property (nonatomic, strong) NSString *changePasswordMessage;
//单位时间最大允许尝试次数，0表示不限制
@property (nonatomic) NSInteger maxTryCount;
//最大尝试的单位时间，以分钟为单位
@property (nonatomic) NSInteger minutesOfMaxTry;
//是否允许用户切换解锁方式，默认为不允许
@property (nonatomic) BOOL allowUserChangeLockerType;
//是否自己保存密码到用户配置文件中(通过MD5加密)
@property (nonatomic) BOOL storedPassword;

//清除所保存的密码，如果是使用PeakLocker保存密码的话
-(void) removePassword;

//注册，让用户设置密码，用户是否可以选择取消。在注册的时候可以选择解锁方式
-(void) signupWithType: (PeakLockerType) lockerType cancel: (BOOL) cancel;
//登陆
-(void) signin: (BOOL) cancel;
//修改密码
-(void) changePassword: (BOOL) cancel;
//切换密码校验方式
-(void) changeLockerType: (PeakLockerType) lockerType;

+(id) sharedManager;
@end

@protocol PeakLockerDelegate <NSObject>

//完成
-(void) peakLockerDidFinishWithCancel: (BOOL) cancel password: (NSString *) password;
//校验密码是否正确（也可能是在修改密码的时候）
-(BOOL) peakLockerValidateWithPassword: (NSString *) password;
@end
