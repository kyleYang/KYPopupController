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

@interface ViewController ()<KYPopupControllerDelegate,UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) KYPopupController *popupController;

@end

@implementation ViewController
{
    BOOL _keybordShow;
    CGRect _keyboardRect;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    
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
    self.popupController.theme.bordePadding = -80;
    self.popupController.delegate = self;
    self.popupController.theme.presentationStyle = KYPopupPresentationStyleSlideInFromLeft;
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
    
    __weak typeof(self) weakSelf = self;
    surebutton.actionBlock = ^(){
        
        weakSelf.popupController.noticeLable.text = @"兑换成功";
        
    };
    
    

    NSAttributedString *noticeString = [[NSAttributedString alloc] initWithString:@"温馨提示，一个商品参与一次拼单，不能取消" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor blackColor], NSParagraphStyleAttributeName : leftStyle}];
   
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"测试kypopupbutton" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor], NSParagraphStyleAttributeName : centerStyle}];
    
    KYPopupButtonItem *checkItem = [KYPopupButtonItem defaultButtonItemWithTitle:title backgroundColor:HexRGB(0xffffff)];
    checkItem.backgroundColor = [UIColor redColor];
    checkItem.selectionHandler = ^(){
        
        NSLog(@"测试kypopupbutton");
        [weakSelf.popupController dismissPopupControllerAnimated:YES];
        
    };
    checkItem.buttonHeight = 40;
    
    
    
    self.popupController = [[KYPopupController alloc] initWithWithTitle:nil content:@[line,textField,surebutton,noticeString] buttonItems:@[checkItem] destructiveButtonItem:nil];
    self.popupController.theme = [KYPopupTheme defaultTheme];
    self.popupController.theme.backgroundColor = HexRGB(0xe5e5e5);
    self.popupController.theme.detectBackgroundDismissTouch = TRUE;
    self.popupController.theme.popupStyle = KYPopupStyleFullscreen;
    self.popupController.delegate = self;
    self.popupController.theme.presentationStyle = KYPopupPresentationStyleFadeIn;
    [self.popupController presentPopupControllerAnimated:YES];
    
    self.popupController.noticeLable.text = @"输入拼单码";

    
}
- (IBAction)style3:(id)sender
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
    
    
    
    //setup a custome view (tableView view has some label);
    UITableView *tableView =[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.viewHeight = @(200);
   
    
    
    NSAttributedString *noticeString = [[NSAttributedString alloc] initWithString:@"分享拼单码，邀请朋友一起拼单，更快拿到拼单优惠哦~" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor blackColor], NSParagraphStyleAttributeName : leftStyle}];
    
    
    KYPopupButtonItem *checkItem = [KYPopupButtonItem defaultButtonItemWithTitle:title backgroundColor:HexRGB(0xffffff)];
    checkItem.backgroundColor = [UIColor redColor];
    checkItem.selectionHandler = ^(){
        
        NSLog(@"确定");
        
    };
    checkItem.buttonHeight = 40;
    
    
    self.popupController = [[KYPopupController alloc] initWithWithTitle:nil content:@[line,tableView,noticeString] buttonItems:nil destructiveButtonItem:nil];
    self.popupController.theme = [KYPopupTheme defaultTheme];
    self.popupController.theme.backgroundColor = HexRGB(0xe5e5e5);
    self.popupController.theme.maskViewColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
    self.popupController.theme.detectBackgroundDismissTouch = YES;
    self.popupController.theme.popupStyle = KYPopupStyleActionSheet;
    self.popupController.delegate = self;
    self.popupController.theme.presentationStyle = KYPopupPresentationStyleFadeIn;
    [self.popupController presentPopupControllerAnimated:YES];
    self.popupController.noticeLable.text = @"表格测试";

    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

#pragma mark tableviewdelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"cell %ld",indexPath.row];
    return cell;
    
}


#pragma mark keyboard

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSLog(@"keyboardWillShow : %@",notification);
    if (_keybordShow) {
        
        return;
    }
    
    
    _keyboardRect = [self.view convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    CGSize kbSize = _keyboardRect.size;
   __block CGFloat contentHeight = CGRectGetHeight(self.popupController.contentView.frame);
    

    if(contentHeight/2 + kbSize.height > CGRectGetHeight(self.view.frame)/2){ //when the keyboard is show, the view is covered。
        
        CGFloat offset = CGRectGetHeight(self.view.frame)/2 - contentHeight/2 - kbSize.height-20;
        NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        NSTimeInterval opration = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
        
        [UIView animateWithDuration:duration delay:0 options:opration animations:^{
            
            self.popupController.contentViewCenterYConstraint.constant = offset;
            
        } completion:^(BOOL finished) {
            
        }];

        
    }
    
    

    
    _keybordShow = TRUE;
    
    
}


- (void)keyboardWillHide:(NSNotification*)notification
{
    NSLog(@"keyboardWillHide : %@",notification);
    if (!_keybordShow) {
        return;
    }
    
    _keybordShow = FALSE;
    
    NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSTimeInterval opration = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    
    [UIView animateWithDuration:duration delay:0 options:opration animations:^{
        
        self.popupController.contentViewCenterYConstraint.constant = 0;
        
    } completion:^(BOOL finished) {
        
    }];
    
}


- (void)keyboardDidChange:(NSNotification*)notification
{
    
    if (!_keybordShow) {
        return;
    }
    
    _keyboardRect = [self.view convertRect:[[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
    CGSize kbSize = _keyboardRect.size;
    CGFloat contentHeight = CGRectGetHeight(self.popupController.contentView.frame);

    
    if(contentHeight/2 + kbSize.height > CGRectGetHeight(self.view.frame)/2){ //when the keyboard is show, the view is covered。
        
        CGFloat offset = CGRectGetHeight(self.view.frame)/2 - contentHeight/2 - kbSize.height-20;
        NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        
        NSTimeInterval opration = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
        
        [UIView animateWithDuration:duration delay:0 options:opration animations:^{
            
            self.popupController.contentViewCenterYConstraint.constant = offset;
            
        } completion:^(BOOL finished) {
            
        }];
    }

    
}




@end
