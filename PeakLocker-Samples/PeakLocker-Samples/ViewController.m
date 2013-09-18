//
//  ViewController.m
//  PeakLocker-Samples
//
//  Created by conis on 9/17/13.
//  Copyright (c) 2013 conis. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  PeakLocker *locker = [PeakLocker sharedManager];
  locker.appName = @"PeakLocker";
  //locker.rootViewController = self;
  locker.delegate = self;
  locker.backgroundImage = [UIImage imageNamed: @"background"];
  /*
  UIViewController *ctrl = [[UIViewController alloc] init];
  ctrl.view.backgroundColor = [UIColor redColor];
  [self presentViewController:ctrl animated:NO completion:nil];
  */
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) peakLockerDidCancel:(PeakLocker *)locker type:(PeakLockerType)type{
  [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) peakLockerDidFinish:(PeakLocker *)locker type:(PeakLockerType)type password:(NSString *)password{
  NSString *msg = nil;
  switch (type) {
    case PeakLockerTypeSignin:
      msg = @"登陆成功";
      break;
    case PeakLockerTypeSignup:
      msg = @"注册成功";
      break;
    case PeakLockerTypeChangePassword:
      msg = @"更改密码成功";
      break;
    default:
      break;
  }
  
  [self dismissViewControllerAnimated:YES completion:nil];
  
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
  [alert show];
}

- (IBAction)clickedSignup:(id)sender {
  PeakLocker *locker = [PeakLocker sharedManager];
  [locker signup: NO];
  [self presentViewController: locker animated:YES completion:nil];
}

- (IBAction)clickedChangePassword:(id)sender {
  PeakLocker *locker = [PeakLocker sharedManager];
  [locker changePassword: YES];
  [self presentViewController: locker animated:YES completion:nil];
}

- (IBAction)clickedSignin:(id)sender {
  PeakLocker *locker = [PeakLocker sharedManager];
  [locker signin: NO];
  [self presentViewController: locker animated:YES completion:nil];
}


@end
