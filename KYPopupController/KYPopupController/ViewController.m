//
//  ViewController.m
//  KYPopupController
//
//  Created by Kyle on 15/7/8.
//  Copyright (c) 2015年 xiaoluuu. All rights reserved.
//

#import "ViewController.h"
#import "KYPopupController.h"

#define HexRGB(hexRGB) [UIColor colorWithRed:((float)((hexRGB & 0xFF0000) >> 16))/255.0 green:((float)((hexRGB & 0xFF00) >> 8))/255.0 blue:((float)(hexRGB & 0xFF))/255.0 alpha:1.0]  //0xFFFFFF

@interface ViewController ()<KYPopupControllerDelegate,UITextFieldDelegate>

@property (nonatomic, strong) KYPopupController *popupController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)style1:(id)sender
{
    NSMutableParagraphStyle *centerStyle = NSMutableParagraphStyle.new;
    centerStyle.lineBreakMode = NSLineBreakByWordWrapping;
    centerStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableParagraphStyle *leftStyle = NSMutableParagraphStyle.new;
    leftStyle.lineBreakMode = NSLineBreakByWordWrapping;
    leftStyle.alignment = NSTextAlignmentLeft;
    
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"你的拼单码" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor], NSParagraphStyleAttributeName : centerStyle}];

    
    //setup a line for separate
    UIImageView *line = [[UIImageView alloc] init];
    line.image = [[UIImage imageNamed:@"dark_pix_line"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    line.viewHeight = @(1);
    line.viewWidth = @(4000);
    
    
    
    //setup a custome view (circle view has some label;

    UIView *circleView = [[UIView alloc] init];
    circleView.viewWidth = @(100);
    circleView.viewHeight = @(100);
    circleView.layer.cornerRadius = 50;
    circleView.backgroundColor = HexRGB(0xffffff);
    
    
    
    UILabel *titlelabel = [[UILabel alloc] init];
    titlelabel.textColor = HexRGB(0x3c3c3c);
    titlelabel.text = @"您的拼单码";
    titlelabel.font = [UIFont systemFontOfSize:14.0f];
    titlelabel.translatesAutoresizingMaskIntoConstraints = NO;
    [circleView addSubview:titlelabel];
    
    UILabel *nmberLabel = [[UILabel alloc] init];
    nmberLabel.textColor = HexRGB(0xf27473);
    nmberLabel.text = @"28FM9";
    nmberLabel.font = [UIFont systemFontOfSize:16.0f];
    nmberLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [circleView addSubview:nmberLabel];
    
    
    [circleView addConstraint:[NSLayoutConstraint constraintWithItem:titlelabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:circleView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:-3]];
    [circleView addConstraint:[NSLayoutConstraint constraintWithItem:titlelabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:circleView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
    [circleView addConstraint:[NSLayoutConstraint constraintWithItem:nmberLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:circleView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:3]];
    [circleView addConstraint:[NSLayoutConstraint constraintWithItem:nmberLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:circleView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];

    
     NSAttributedString *noticeString = [[NSAttributedString alloc] initWithString:@"分享拼单码，邀请朋友一起拼单，更快拿到拼单优惠哦~" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor blackColor], NSParagraphStyleAttributeName : leftStyle}];
    
    
    KYPopupButtonItem *checkItem = [KYPopupButtonItem defaultButtonItemWithTitle:title backgroundColor:HexRGB(0xffffff)];
    checkItem.backgroundColor = [UIColor redColor];
    checkItem.selectionHandler = ^(){
        
        NSLog(@"确定");
        
    };
    checkItem.buttonHeight = 40;

    
    self.popupController = [[KYPopupController alloc] initWithWithTitle:nil content:@[line,circleView,noticeString] buttonItems:nil destructiveButtonItem:nil];
    self.popupController.theme = [KYPopupTheme defaultTheme];
    self.popupController.theme.backgroundColor = HexRGB(0xe5e5e5);
    self.popupController.theme.detectBackgroundDismissTouch = FALSE;
    self.popupController.theme.popupStyle = KYPopupStyleCentered;
    self.popupController.delegate = self;
    self.popupController.theme.presentationStyle = KYPopupPresentationStyleFadeIn;
    [self.popupController presentPopupControllerAnimated:YES];
    
    self.popupController.noticeLable.text = @"发起拼单成功";

}
- (IBAction)style2:(id)sender
{
    
    NSMutableParagraphStyle *centerStyle = NSMutableParagraphStyle.new;
    centerStyle.lineBreakMode = NSLineBreakByWordWrapping;
    centerStyle.alignment = NSTextAlignmentCenter;
    
    NSMutableParagraphStyle *leftStyle = NSMutableParagraphStyle.new;
    leftStyle.lineBreakMode = NSLineBreakByWordWrapping;
    leftStyle.alignment = NSTextAlignmentLeft;
    
    
    
    
    //setup a line for separate
    UIImageView *line = [[UIImageView alloc] init];
    line.image = [[UIImage imageNamed:@"dark_pix_line"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    line.viewHeight = @(1);
    line.viewWidth = @(4000);
    
    
    
    //setup a custome view (circle view has some label;
    
    UITextField *textField = [[UITextField alloc] init];
    textField.backgroundColor = [UIColor whiteColor];
    textField.delegate = self;
    textField.placeholder = @"请输入拼单码";
    textField.viewHeight = @(37);
    
    UIButton *surebutton = [[UIButton alloc] init];
    surebutton.backgroundColor = [UIColor whiteColor];
    surebutton.viewHeight = @(37);
    [surebutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [surebutton setTitle:@"确认" forState:UIControlStateNormal];
    surebutton.actionBlock = ^(){
        
        NSLog(@"确定");
        
    };
    
    

    NSAttributedString *noticeString = [[NSAttributedString alloc] initWithString:@"温馨提示，一个商品参与一次拼单，不能取消" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor blackColor], NSParagraphStyleAttributeName : leftStyle}];
   
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"测试kypopupbutton" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor], NSParagraphStyleAttributeName : centerStyle}];
    
    KYPopupButtonItem *checkItem = [KYPopupButtonItem defaultButtonItemWithTitle:title backgroundColor:HexRGB(0xffffff)];
    checkItem.backgroundColor = [UIColor redColor];
    checkItem.selectionHandler = ^(){
        
        NSLog(@"测试kypopupbutton");
        
    };
    checkItem.buttonHeight = 40;
    
    
    
    self.popupController = [[KYPopupController alloc] initWithWithTitle:nil content:@[line,textField,surebutton,noticeString] buttonItems:@[checkItem] destructiveButtonItem:nil];
    self.popupController.theme = [KYPopupTheme defaultTheme];
    self.popupController.theme.backgroundColor = HexRGB(0xe5e5e5);
    self.popupController.theme.detectBackgroundDismissTouch = FALSE;
    self.popupController.theme.popupStyle = KYPopupStyleCentered;
    self.popupController.delegate = self;
    self.popupController.theme.presentationStyle = KYPopupPresentationStyleFadeIn;
    [self.popupController presentPopupControllerAnimated:YES];
    
    self.popupController.noticeLable.text = @"输入拼单码";

    
}
- (IBAction)style3:(id)sender
{
    
}

@end
