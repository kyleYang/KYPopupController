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

@interface ViewController ()

@property (nonatomic, strong) KYPopupController *popupController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)style1:(id)sender
{
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"你的拼单码" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor], NSParagraphStyleAttributeName : paragraphStyle}];

    
    NSAttributedString *checkTitle = [[NSAttributedString alloc] initWithString:@"确定" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:18], NSForegroundColorAttributeName : HexRGB(0xf27473), NSParagraphStyleAttributeName : paragraphStyle}];
    
    NSAttributedString *spaceTitle = [[NSAttributedString alloc] initWithString:@" " attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:4],NSForegroundColorAttributeName:[UIColor clearColor]}];
    

    
    KYPopupButtonItem *checkItem = [KYPopupButtonItem defaultButtonItemWithTitle:checkTitle backgroundColor:HexRGB(0xffffff)];
    checkItem.selectionHandler = ^(KYPopupButtonItem *item){
        
    };
    checkItem.buttonHeight = 40;

    
    self.popupController = [[KYPopupController alloc] initWithWithTitle:title content:nil buttonItems:@[checkItem] destructiveButtonItem:nil];
    self.popupController.theme = [KYPopupTheme defaultTheme];
    self.popupController.theme.backgroundColor = [UIColor blueColor];
    self.popupController.theme.detectBackgroundDismissTouch = FALSE;
    self.popupController.theme.style = KYPopupStyleCentered;
    self.popupController.delegate = self;
    self.popupController.theme.presentationStyle = KYPopupPresentationStyleFadeIn;
    [self.popupController presentPopupControllerAnimated:YES];

}
- (IBAction)style2:(id)sender
{
    
}
- (IBAction)style3:(id)sender
{
    
}

@end
