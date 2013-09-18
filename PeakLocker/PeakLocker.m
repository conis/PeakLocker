//
//  PeakLocker.m
//  PeakLocker-Samples
//
//  Created by conis on 9/17/13.
//  Copyright (c) 2013 conis. All rights reserved.
//

#import "PeakLocker.h"

typedef enum{
  //无状态
  PeakLockerStatusBegin,
  //密码已经确认
  PeakLockerStatusValidation,
  //设置新密码
  PeakLockerStatusNew,
  //确认密码成功
  PeakLockerStatusConfirm,
  //完成
  PeakLockerStatusDone
} PeakLockerStatus;

@interface PeakLocker()
@property (nonatomic) PeakLockerType type;
@property (nonatomic, strong) NSString *lastPassword;
@property (nonatomic) PeakLockerStatus status;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) KKGestureLockView *patternLock;
@property (nonatomic, strong) UILabel *appNameLabel;
//显示信息的label
@property (nonatomic, strong) UILabel *tipsLabel;
//显示警告
//@property (nonatomic, strong) UILabel *warningLabel;
//最后的提示时间
@property (nonatomic, strong) NSDate *tipsDate;
//取消按钮
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation PeakLocker
NSString * const kPeakLockerUserDefaultPassword = @"PeakLockerUserDefaultPassword";
NSString * const kPeakLockerNotificationValidation = @"PeakLockerNotificationValidation";

static PeakLocker *instance;

#pragma mark 初始化相关
+ (PeakLocker *)sharedManager
{
  if (!instance) {
    instance = [[PeakLocker alloc] init];
  }
  return instance;
}

-(id) init{
  self = [super init];
  if(self){
    [self createComponent];
  }
  return self;
}

//初始化默认数据
-(void) initDefault{
  self.appNameTextColor = [UIColor colorWithRed:175/255.f green:175/255.f blue:175/255.f alpha:1];
  self.storedPassword = YES;
  self.allowUserChangeLockerType = NO;
  //不限制
  self.maxTryCount = 0;
  self.minutesOfMaxTry = 10;
  self.minimumLength = 4;
  //self.lockerType = PeakLockerPattern;
  
  self.modalPresentationStyle = UIModalPresentationFullScreen;
  self.view.backgroundColor = [UIColor grayColor];
}

//创建模式解锁
-(void) createPatternLock{
  self.patternLock = [[KKGestureLockView alloc] initWithFrame: self.view.bounds];

  //这个以后要替换，暂时用这个
  self.patternLock.normalGestureNodeImage = [UIImage imageNamed:@"gesture_node_normal.png"];
  self.patternLock.selectedGestureNodeImage = [UIImage imageNamed:@"gesture_node_selected.png"];
  self.patternLock.lineColor = [[UIColor orangeColor] colorWithAlphaComponent:0.3];
  self.patternLock.lineWidth = 12;
  self.patternLock.delegate = self;
  //self.patternLock.contentInsets = UIEdgeInsetsMake(150, 20, 100, 20);
  
  [self.view addSubview: self.patternLock];
}

//创建软件名称的Label
-(void) createAppNameLabel{
  self.appNameLabel = [[UILabel alloc] init];
  self.appNameLabel.left = 10;
  self.appNameLabel.backgroundColor = [UIColor clearColor];
  self.appNameLabel.width = self.headerView.width - self.appNameLabel.left * 2;
  self.appNameLabel.top = 25;
  self.appNameLabel.height = 60;
  self.appNameLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.appNameLabel.font = [UIFont boldSystemFontOfSize: 40];
  self.appNameLabel.minimumScaleFactor = 0.4;
  self.appNameLabel.textColor = self.appNameTextColor;
  self.appNameLabel.adjustsFontSizeToFitWidth = YES;
  self.appNameLabel.textAlignment = NSTextAlignmentCenter;
  [self.headerView addSubview: self.appNameLabel];
}

//创建提示信息与警告信息的Label
-(void) createInfoLabel{
  self.tipsLabel = [[UILabel alloc] init];
  self.tipsLabel.top = self.appNameLabel.bottomY;
  self.tipsLabel.width = self.appNameLabel.width;
  self.tipsLabel.height = 30;
  self.tipsLabel.backgroundColor = [UIColor clearColor];
  self.tipsLabel.left = self.appNameLabel.left;
  self.tipsLabel.textColor = [UIColor colorWithRed:4/255.f green:152/255.f blue:213/255.f alpha:1];
  [self.headerView addSubview: self.tipsLabel];
  
  /*
  self.warningLabel = [[UILabel alloc] initWithFrame: self.tipsLabel.frame];
  self.warningLabel.top = self.tipsLabel.bottomY + 5;
  self.warningLabel.textColor = [UIColor colorWithRed:4/255.f green:152/255.f blue:213/255.f alpha:1];
  [self.headerView addSubview: self.warningLabel];
  */
}

//创建Header部分
-(void) createHeaderViw{
  self.headerView = [[UIView alloc] initWithSize:CGSizeMake(self.view.frameSizeWidth, 130)];
  self.headerView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.6];
  [self.view addSubview: self.headerView];
  
  [self createAppNameLabel];
  
  //创建取消按钮
  self.cancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
  UIImage *cancelImage = [UIImage imageNamed: @"peaklocker_cancel"];
  self.cancelButton.size = cancelImage.size;
  [self.cancelButton setBackgroundImage: cancelImage forState:UIControlStateNormal];
  self.cancelButton.showsTouchWhenHighlighted = YES;
  [self.cancelButton addTarget:self action:@selector(clickedCancel: ) forControlEvents:UIControlEventTouchUpInside];
  [self.headerView addSubview: self.cancelButton];
  [self.cancelButton rightAlignForSuperView];
  [self.cancelButton bottomAlignForSuperView];
}

//创建所有的组件
-(void) createComponent{
  [self initDefault];

  //添加模式解锁
  [self createPatternLock];
  [self createHeaderViw];
  [self createInfoLabel];
}

//取消
-(void) clickedCancel: (id) sender{
  if(self.delegate && [self.delegate respondsToSelector:@selector(peakLockerDidCancel:type:)]){
    [self.delegate peakLockerDidCancel:self type:self.type];
  }
}

#pragma mark 属性相关
-(void) setBackgroundImage:(UIImage *)backgroundImage{
  _backgroundImage = backgroundImage;
  self.view.backgroundColor = [UIColor colorWithPatternImage: backgroundImage];
}

//设置软件的名称
-(void) setAppName:(NSString *)appName{
  _appName = appName;
  self.appNameLabel.text = _appName;
}

//是否为空密码，即未设置密码
-(BOOL) isEmptyPassword:(BOOL)isEmptyPassword{
  NSString *password = [self getUserDefaults: kPeakLockerUserDefaultPassword];
  return password.length == 0;
}

//设置提示
-(void) setTips: (NSString *) tips{
  self.tipsLabel.text = tips;
}

/*
-(void) hideWarning{
  if([[NSDate date] timeIntervalSinceDate: self.tipsDate] < 10){
    return;
  }
  
  [UIView animateWithDuration:0.5 animations:^{
    self.warningLabel.alpha = 0;
  }];
}
*/
//设置警告信息
/*
-(void) setwarning: (NSString *) warning{
  self.warningLabel.text = warning;
  self.warningLabel.alpha = 1;
  
  
  //self.tipsDate = [NSDate date];
  //设置5秒钟后关闭
  //[self performSelector:@selector(hideWarning) withObject:nil afterDelay:10];
}
 
*/
//重置控件的位置，一般在旋转的时候调用
-(void) resetSubviews{
  //设置模式解锁的位置
  CGFloat margin = 30;
  CGRect rect = CGRectMake(margin, self.headerView.bottomY + margin, self.view.width - margin * 2, self.view.height - self.headerView.bottomY - margin * 2);
  self.patternLock.frame = rect;
}

#pragma mark 密码校验相关
//校验密码，检查密码是否匹配
-(BOOL) validatePassword: (NSString *) password{
  BOOL result = false;
  //有委托，由委托校验密码
  if(self.delegate && [self.delegate respondsToSelector: @selector(peakLockerValidateWithPassword:)]){
    result = [self.delegate peakLockerValidateWithPassword: password];
  }else{
    //由PeakLocker校验密码
    result = [self peaLockerValidateWithPassword: password];
  }
    
  if(!result){
    [self setTips: @"您的密码校验未能通过"];
  }
  
  return result;
}

//校验用PeakLocker保存的密码，从userDefaults读取
-(BOOL) peaLockerValidateWithPassword: (NSString *) password{
  NSString *oldPassword = [self getUserDefaults: kPeakLockerUserDefaultPassword];
  return [oldPassword isEqualToString: [self md5:password]];
}

//如果是由PeakLocker管理密码，则保存密码
-(void) savePasswordIfNeed: (NSString *) password{
  //由PeakLocker保存密码
  if(self.storedPassword){
    NSString *encodePwd = [self md5: password];
    [self setUserDefaults:kPeakLockerUserDefaultPassword value:encodePwd];
  }
}

//成功地完成某个设置
-(void) completedWithSuccess: (NSString *) password{
  //通知委托，密码已经设置成功
  if(self.delegate && [self.delegate respondsToSelector: @selector(peakLockerDidFinish: type: password: )]){
    [self.delegate peakLockerDidFinish: self type: self.type password: password];
  }
}

//创建新密码，需要检查两次密码是否一致
-(BOOL) createPassword: (NSString *) password{
  //第一次，还没有创建密码，则检查密码长度
  if(self.status == PeakLockerStatusNew){
    //检查密码是否符合规范
    BOOL result = [self validForPassword: password];
    if(result){
      //记住这一次的密码
      self.lastPassword = password;
      //变更状态
      [self changeToStatus: PeakLockerStatusConfirm];
    }
    return result;
  }
  
  if(self.status == PeakLockerStatusConfirm){
    BOOL isSame = [self.lastPassword isEqualToString: password];
    self.lastPassword = nil;
    //检查这一次的密码，与新密码是否一至
    if(isSame){
      //保存密码，如果需要的话
      [self savePasswordIfNeed: password];
      [self changeToStatus: PeakLockerStatusDone];
    }else{
      //回滚状态
      [self changeToStatus: PeakLockerStatusNew];
      [self setTips: @"您两次设定的密码不一致"];
    }
    
    return isSame;
  }

  return NO;
}

//校验密码是否符合规则
-(BOOL) validForPassword: (NSString *) password{
  NSInteger length;
  
  //模式解锁是用数组的方式
  if(self.lockerPanel == PeakLockerPanelPattern){
    NSArray *list = [password componentsSeparatedByString: @","];
    length = list.count;
  }else{
    length = password.length;
  }
  
  BOOL result = length >= self.minimumLength;
  if(!result){
    //提示用户
    NSString *tips = [NSString stringWithFormat: @"至少连接%d个点", self.minimumLength];
    [self setTips: tips];
  }
  return result;
}


//用户注册
-(void) signupWithPassword: (NSString *) password{
  if([self createPassword: password] && self.status == PeakLockerStatusDone){
    //操作成功，通知委托完成
    [self completedWithSuccess: password];
  };
}

//登陆操作
-(void) signinWithPassword: (NSString *) password{
  //校验密码是否正确
  if ([self validatePassword: password]){
    //操作成功，通知委托完成
    [self completedWithSuccess: password];
  }
}


-(void) changePasswordWithPassword: (NSString *) password{
  BOOL result;
  //校验密码
  if(self.status == PeakLockerStatusBegin){
    result = [self validatePassword: password];
    //密码校验通过，跳转到下一个状态
    if(result) {
      [self changeToStatus: PeakLockerStatusNew];
    }
    return;
  }
  
  //创建新密码
  if(self.status == PeakLockerStatusNew || self.status == PeakLockerStatusConfirm){
    result = [self createPassword: password];
    //创建成功，并且状态为完成，则调用完成的方法
    if(result && self.status == PeakLockerStatusDone){
      [self completedWithSuccess: password];
    }
  }
}

#pragma mark 模式解锁的委托
- (void)gestureLockView:(KKGestureLockView *)gestureLockView didBeginWithPasscode:(NSString *)passcode{
  [self setTips:@"完成时松开手指"];
}

//手势结束
- (void)gestureLockView:(KKGestureLockView *)gestureLockView didEndWithPasscode:(NSString *)passcode{
  switch (self.type) {
    case PeakLockerTypeSignup:
      [self signupWithPassword: passcode];
      break;
    case PeakLockerTypeSignin:
      [self signinWithPassword: passcode];
      break;
    case PeakLockerTypeChangePassword:
      [self changePasswordWithPassword: passcode];
      break;
    default:
      NSLog(@"未知类型");
      break;
  }
}

- (void)gestureLockView:(KKGestureLockView *)gestureLockView didCanceledWithPasscode:(NSString *)passcode{
}

//切换到某个状态，状态要结合type一起使用
-(void) changeToStatus: (PeakLockerStatus) status{
  self.status = status;
  NSString *tips = nil;
  switch (status) {
    case PeakLockerStatusBegin:
      tips = @"您需要授权才能访问";
      break;
    case PeakLockerStatusNew:  //密码校验通过
      tips = @"请设置您的密码";
      break;
    case PeakLockerStatusConfirm:
      tips = @"请重复您刚刚设置的密码";
      break;
    default:
      break;
  }
  
  //到达新的状态，需要清除warning
  //[self setwarning: nil];
  [self setTips: tips];
}

//开始锁定
-(void) startLocker: (PeakLockerType) lockerType status: (PeakLockerStatus) status cancel: (BOOL) cancel{
  [self resetSubviews];
  self.cancelButton.hidden = !cancel;
  self.type = lockerType;
  [self changeToStatus: status];
}

#pragma mark 公有方法
-(void) signup:(BOOL)cancel{
  [self startLocker: PeakLockerTypeSignup status:PeakLockerStatusNew cancel:cancel];
}

-(void) signin:(BOOL)cancel{
  [self startLocker: PeakLockerTypeSignin status:PeakLockerStatusBegin cancel:cancel];
}

-(void) changePassword:(BOOL)cancel{
  [self startLocker: PeakLockerTypeChangePassword status:PeakLockerStatusBegin cancel:cancel];
}

#pragma  makr 与UserDefaults相关
//设置用户的默认配置
-(void) setUserDefaults:(NSString *)key value:(id)value
{
  NSUserDefaults  *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject: value forKey: key];
  [defaults synchronize];
}

//根据字典设置值
-(void) setUserDefaults:(NSDictionary *)dict
{
  NSUserDefaults  *defaults = [NSUserDefaults standardUserDefaults];
  NSArray *keys = [dict allKeys];
  
  for(int i = 0; i < keys.count; i ++){
    NSString *key = [keys objectAtIndex: i];
    [defaults setObject: [dict objectForKey: key] forKey: key];
  }
  [defaults synchronize];
}

//读取用户的默认配置
-(id) getUserDefaults:(NSString *)key
{
  NSUserDefaults  *defaults = [NSUserDefaults standardUserDefaults];
  return [defaults objectForKey: key];
}

-(void) removeUserDefaultsWithKey:(NSString *)key{
  NSUserDefaults  *defaults = [NSUserDefaults standardUserDefaults];
  [defaults removeObjectForKey: key];
  [defaults synchronize];
}

//将数据加密
//Md5一个字符
-(NSString *)md5:(NSString *)str {
  const char *cStr = [str UTF8String];
  unsigned char digest[CC_MD5_DIGEST_LENGTH];
  CC_MD5( cStr, strlen(cStr), digest );
  
  NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
  
  for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
  
  return output;
}
@end
