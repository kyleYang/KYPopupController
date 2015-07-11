//
//  KYPopupController.h
//  KYPopupController
//
//  Created by Kyle on 15/7/8.
//  Copyright (c) 2015年 xiaoluuu. All rights reserved.
//

#import <UIKit/UIKit.h>


@class KYPopupTheme;
@class KYPopupButtonItem;




// KYPopupStyle: Controls how the popup looks once presented
typedef NS_ENUM(NSUInteger, KYPopupStyle) {
    KYPopupStyleActionSheet = 0, // Displays the popup similar to an action sheet from the bottom.
    KYPopupStyleCentered, // Displays the popup in the center of the screen.
    KYPopupStyleFullscreen // Displays the popup similar to a fullscreen viewcontroller.
};



// CNPPopupPresentationStyle: Controls how the popup is presented
typedef NS_ENUM(NSInteger, KYPopupPresentationStyle) {
    KYPopupPresentationStyleFadeIn = 0,
    KYPopupPresentationStyleSlideInFromTop,
    KYPopupPresentationStyleSlideInFromBottom,
    KYPopupPresentationStyleSlideInFromLeft,
    KYPopupPresentationStyleSlideInFromRight
};


@protocol KYPopupControllerDelegate;

@interface KYPopupController : NSObject

//the content view of the popup view
@property (nonatomic, strong, readonly) UIView *contentView;

//The top-left notice label.
@property (nonatomic, strong, readonly) UILabel *noticeLable;

//the popup title
@property (nonatomic, strong) NSAttributedString *popupTitle;

//the popup contents. can be NSString(convert to ULLabel), UIImage(convert to UIImageView) or  UIView;
@property (nonatomic, strong) NSArray *contents;

//the popup contents of KYPopupButtonItem. Its display in vertical.
@property (nonatomic, strong) NSArray *buttonItems;

//the popup destructive button.
@property (nonatomic, strong) KYPopupButtonItem *destructiveButtonItem;

//the theme of popup. deault value is Default Theme.
@property (nonatomic, strong) KYPopupTheme *theme;

@property (nonatomic, weak) id <KYPopupControllerDelegate> delegate;

//position constraint for view when popup need to change it's position like a keyboard show
@property (nonatomic, strong, readonly) NSLayoutConstraint *contentViewCenterXConstraint;
@property (nonatomic, strong, readonly) NSLayoutConstraint *contentViewCenterYConstraint;
@property (nonatomic, strong, readonly) NSLayoutConstraint *contentViewWidth;
@property (nonatomic, strong, readonly) NSLayoutConstraint *contentViewHeight;
@property (nonatomic, strong, readonly) NSLayoutConstraint *contentViewBottom;


//init the popup with ttile , contents(if content is a view, the height and width should have value, if not it will be seted a default value) and button.
-(instancetype)initWithWithTitle:(NSAttributedString *)title
                         content:(NSArray *)contents buttonItems:(NSArray*)items
           destructiveButtonItem:(KYPopupButtonItem *)destructiveButtonItem;

//present popup controller
- (void)presentPopupControllerAnimated:(BOOL)flag;

//dismiss popup controller
- (void)dismissPopupControllerAnimated:(BOOL)flag;


@end

@protocol KYPopupControllerDelegate <NSObject>

@optional
- (void)popupControllerWillPresent:(KYPopupController *)controller;
- (void)popupControllerDidPresent:(KYPopupController *)controller;
- (void)popupControllerWillDismis:(KYPopupController *)controller;
- (void)popupControllerDidDismiss:(KYPopupController *)controller;

@end




@interface KYPopupTheme : NSObject

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


+(KYPopupTheme *)defaultTheme;

@end


typedef void(^SelectionHandler) (void);

@interface KYPopupButtonItem : NSObject

@property (nonatomic, strong) NSAttributedString *buttonTitle;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat buttonHeight;
@property (nonatomic, strong) SelectionHandler selectionHandler;

+ (KYPopupButtonItem *)defaultButtonItemWithTitle:(NSAttributedString *)title backgroundColor:(UIColor *)color;


@end



@interface UIView(popup)

@property (nonatomic, strong) NSNumber *viewWidth;
@property (nonatomic, strong) NSNumber *viewHeight;

@end




@interface UIButton (Blocks)

@property (nonatomic, copy) SelectionHandler actionBlock;

- (id)initWitActionBlock:(SelectionHandler)block;

@end



