# KYPopupController
This reposityory is a porject for a popup viewcontroller that user can custom the style
Most of the code copy from CNPPopupController（https://github.com/carsonperrotti/CNPPopupController）
Thanks for @carsonperrotti.

Now , we can custom the popup view more easy. Three example show user how to use it.
In carsonperrotti's project, we can only add string,image and button.
Now we can add any view . if we set the category property viewWidth and viewHeight, or set the size of a view when we init it, the view will be displaied on the contentView as you set. If not seet, the view'widht will as big as the contentView,and the height will equal to the width.

#Introduction
It's easy to use the KYPopupController. I got the idea from carsonperrotti, and I change his code for I need to custom the popup view.

* ![The demo gif](https://raw.githubusercontent.com/kyleYang/KYPopupController/master/image/demo.gif)
* Welcome to the KYPopupController wiki!

#Customization
//The color of maskView.Begin alpha from 0.0f to 1.0f. Default is [UIColor clearColor];
@property (nonatomic, strong) UIColor *maskViewColor;

//The background color of the popup content view. default is withe.
@property (nonatomic, strong) UIColor *backgroundColor;

// Corner radius of the popup content view (Default 6.0)
@property (nonatomic, assign) CGFloat cornerRadius;

// border padding of the popup content view (Default -40.0)
@property (nonatomic, assign) CGFloat bordePadding;

// Inset of labels, images and buttons on the popup content view (Default 16.0 on all sides)
@property (nonatomic, assign) UIEdgeInsets popupContentInsets;

// Spacing between each vertical element (Default 12.0)
@property (nonatomic, assign) CGFloat contentVerticalPadding;

//The top-right close button is show. Default is show.
@property (nonatomic, assign) BOOL closeShow;

//The top-left notice label is show. Default is show.
@property (nonatomic, assign) BOOL noticeShow;

//THe style of sht popup. default is KYPopupStyleCentered;
@property (nonatomic, assign) KYPopupStyle popupStyle;

// How the popup is presented (Defauly slide in from bottom)
@property (nonatomic, assign) KYPopupPresentationStyle presentationStyle;

//When popup is show ,any touch out of the popup be detected. default is false.
@property (nonatomic, assign) BOOL detectBackgroundDismissTouch;

#example for present

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
