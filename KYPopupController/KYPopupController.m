//
//  KYPopupController.m
//  KYPopupController
//
//  Created by Kyle on 15/7/8.
//  Copyright (c) 2015年 xiaoluuu. All rights reserved.
//

#import "KYPopupController.h"
#import <objc/runtime.h>

#define KY_SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define KY_IS_IPAD   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)


@interface KYPopupButton : UIButton

@property (nonatomic, strong) KYPopupButtonItem *item;

@end



@implementation KYPopupButton



@end


@interface KYPopupController()


@property (nonatomic, strong) UIWindow *applicationKeyWindow;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *noticeLable;
@property (nonatomic, strong) UIButton *closeButton;


@property (nonatomic, strong) NSLayoutConstraint *contentViewCenterXConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentViewCenterYConstraint;
@property (nonatomic, strong) NSLayoutConstraint *contentViewWidth;
@property (nonatomic, strong) NSLayoutConstraint *contentViewHeight;
@property (nonatomic, strong) NSLayoutConstraint *contentViewBottom;


@property (nonatomic, strong) UITapGestureRecognizer *backgroundDismissGesture;


@end







@implementation KYPopupController



- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(instancetype)initWithWithTitle:(NSAttributedString *)title
                         content:(NSArray *)contents buttonItems:(NSArray*)items
           destructiveButtonItem:(KYPopupButtonItem *)destructiveButtonItem
{
    self = [super init];
    if (self) {
        
        _popupTitle = title;
        _contents = contents;
        _buttonItems = items;
        _destructiveButtonItem = destructiveButtonItem;
        
        _theme = [KYPopupTheme defaultTheme];
        
        // Safety Checks
        if (contents) {
            for (id object in contents) {
                NSAssert([object class] != [NSAttributedString class] || [object class] != [UIImage class] || [object class] != [UIView class],@"Contents can only be of NSAttributedString or UIImage class or UIView class.");
            }
        }
        if (items) {
            for (id object in items) {
                NSAssert([object class] == [KYPopupButtonItem class],@"Button items can only be of KYPopupButtonItem.");
            }
        }
        
        // Window setup
        NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
        for (UIWindow *window in frontToBackWindows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                self.applicationKeyWindow = window;
                break;
            }
        }
        
        if (KY_SYSTEM_VERSION_LESS_THAN(@"8.0")) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameOrOrientationChanged:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameOrOrientationChanged:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
        }

        //init titleLabel and close button
        self.noticeLable = [[UILabel alloc] init];
        self.noticeLable.font = [UIFont systemFontOfSize:14.0f];
        self.noticeLable.textColor = [UIColor blackColor];
        self.noticeLable.translatesAutoresizingMaskIntoConstraints = NO;
        
        
        self.closeButton = [[UIButton alloc] init];
        [self.closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
       
        
    }
    
    return self;
}



- (void)presentPopupControllerAnimated:(BOOL)flag
{
    // Safety Checks
    NSAssert(self.theme!=nil,@"You must set a theme. You can use [CNPTheme defaultTheme] as a starting place");
    [self setupPopup];
    
    if (KY_SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
    }
    
    
    [self setDismissedConstraints];
    [self.maskView needsUpdateConstraints];
    [self.maskView layoutIfNeeded];
    [self setPresentedConstraints];
    
    if ([self.delegate respondsToSelector:@selector(popupControllerWillPresent:)]) {
        [self.delegate popupControllerWillPresent:self];
    }
    
    [UIView animateWithDuration:flag ? 0.3f : 0.0f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.maskView.alpha = 1.0f;
                         [self.maskView needsUpdateConstraints];
                         [self.maskView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(popupControllerDidPresent:)]) {
                             [self.delegate popupControllerDidPresent:self];
                         }
                     }];

}


- (void)dismissPopupControllerAnimated:(BOOL)flag
{
    if (self.theme.detectBackgroundDismissTouch) {
        [self setDismissedConstraints];
    } else {
        [self setOriginConstraints];
    }
    
    if ([self.delegate respondsToSelector:@selector(popupControllerWillDismis:)]) {
        [self.delegate popupControllerWillDismis:self];
    }
    
    [UIView animateWithDuration:flag ? 0.3f : 0.0f
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.maskView.alpha = 0.0f;
                         [self.maskView needsUpdateConstraints];
                         [self.maskView layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self.maskView removeFromSuperview];
                         self.maskView = nil;
                         self.contentView = nil;
                         if ([self.delegate respondsToSelector:@selector(popupControllerDidDismiss:)]) {
                             [self.delegate popupControllerDidDismiss:self];
                         }
                     }];

    
}




#pragma mark private

- (void)setupPopup
{
    //setup maskview
    self.maskView = [[UIView alloc] init];
    self.maskView.translatesAutoresizingMaskIntoConstraints = NO;
    self.maskView.alpha = 0.0f;
    self.maskView.backgroundColor = self.theme.maskViewColor;
    
    //setup background detect gesture
    if (self.theme.detectBackgroundDismissTouch) {
        
        self.backgroundDismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnMaskView)];
        self.backgroundDismissGesture.numberOfTapsRequired = 1;
        [self.maskView addGestureRecognizer:self.backgroundDismissGesture];
        
    }
    
    //layout maskview. maskview full screen of applicationKeyWindow
    [self.applicationKeyWindow addSubview:self.maskView];
    [self.applicationKeyWindow addConstraint:[NSLayoutConstraint constraintWithItem:self.maskView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.applicationKeyWindow attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.applicationKeyWindow addConstraint:[NSLayoutConstraint constraintWithItem:self.maskView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.applicationKeyWindow attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.applicationKeyWindow addConstraint:[NSLayoutConstraint constraintWithItem:self.maskView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.applicationKeyWindow attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.applicationKeyWindow addConstraint:[NSLayoutConstraint constraintWithItem:self.maskView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.applicationKeyWindow attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    //setup content view
    self.contentView = [[UIView alloc] init];
    [self.contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.contentView.clipsToBounds = YES;
    self.contentView.backgroundColor = self.theme.backgroundColor;
    self.contentView.layer.cornerRadius = self.theme.popupStyle == KYPopupStyleCentered ? self.theme.cornerRadius : 0.0f;
    [self.maskView addSubview:self.contentView];
        
    //have top notice or close button
    [self.contentView addSubview:self.noticeLable];
    self.noticeLable.hidden = !self.theme.noticeShow;
    
    [self.contentView addSubview:self.closeButton];
    self.closeButton.hidden = !self.theme.closeShow;
    UIImage *closeImage = [UIImage imageNamed:@"pop_delete"];
    [self.closeButton setBackgroundImage:closeImage forState:UIControlStateNormal];
    
    CGFloat closeWidth = closeImage.size.width;
    CGFloat closeHeight = closeImage.size.height;

    NSDictionary *views = NSDictionaryOfVariableBindings(_noticeLable,_closeButton);
    NSDictionary *metrics = @{@"left":@(self.theme.popupContentInsets.left),@"right":@(self.theme.popupContentInsets.right),@"width":@(closeWidth)};
    
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0f constant:self.theme.popupContentInsets.top]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.closeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0f constant:closeHeight]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-left-[_noticeLable]-20-[_closeButton(width)]-right-|" options:NSLayoutFormatAlignAllCenterY metrics:metrics views:views]];
    
    
    if (self.popupTitle) {
        UILabel *title = [self multilineLabelWithAttributedString:self.popupTitle];
        [self.contentView addSubview:title];
        
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:title attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.theme.popupContentInsets.left]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:title attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.theme.popupContentInsets.right]];
        
    }
    
    
    if (self.contents) {
        for (NSObject *content in self.contents) {
            if ([content isKindOfClass:[NSAttributedString class]]) {
                UILabel *label = [self multilineLabelWithAttributedString:(NSAttributedString *)content];
                [self.contentView addSubview:label];
                
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.theme.popupContentInsets.left]];
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.theme.popupContentInsets.right]];
            }
            else if ([content isKindOfClass:[UIImage class]]) {
                UIImageView *imageView = [self centeredImageViewForImage:(UIImage *)content];
                [imageView sizeToFit];
                [self.contentView addSubview:imageView];
                
                
                CGFloat precent = 1;
                if (CGRectGetWidth(imageView.frame) < 1 || CGRectGetHeight(imageView.frame) < 1) {
                    precent = 1;
                }else{
                    precent = CGRectGetHeight(imageView.frame)/CGRectGetWidth(imageView.frame);
                }
                
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeWidth multiplier:precent constant:0]];
                
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.theme.popupContentInsets.left]];
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.theme.popupContentInsets.right]];
                
            }
            else if([content isKindOfClass:[UIView class]]){
                
                UIView *view = (UIView *)content;
                view.clipsToBounds = YES;
                view.translatesAutoresizingMaskIntoConstraints = NO;
                [self.contentView addSubview:view];
                
                CGFloat width = 0.0f;
                if([view.viewWidth floatValue] >=1){
                    width = [view.viewWidth floatValue];
                }else if (CGRectGetWidth(view.frame) >= 1) {
                    width = CGRectGetWidth(view.frame);
                }
                
                CGFloat height = 0.0f;
                if([view.viewHeight floatValue] >=1){
                    height = [view.viewHeight floatValue];
                }else if (CGRectGetHeight(view.frame) >= 1) {
                    height = CGRectGetHeight(view.frame);
                }
                
                if (width > 0.0f) {
                    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeWidth multiplier:1.0 constant:width]];
                    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
                    
                }else{
                    
                    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.theme.popupContentInsets.left]];
                    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.theme.popupContentInsets.right]];
                    
                }
                
                
                if(height > 0.0f){
                    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:height]];
                    
                }else{
                    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0f]];
                    
                }
                
            
            }
            
        }
    }

    //setup buttonitems
    if (self.buttonItems) {
        for (KYPopupButtonItem *item in self.buttonItems) {
            KYPopupButton *button = [self buttonItem:item];
            [self.contentView addSubview:button];
            
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.theme.popupContentInsets.left]];
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.theme.popupContentInsets.right]];
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:button.item.buttonHeight]];
            
        }
    }


    [self.contentView.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if (idx < 2) {
            
            return ;
            
        }
        
        if (idx == 2) { //first view if noticeLable and second view is closeButton
            
            //have noticeLabel or closebutton show
            if (self.theme.closeShow || self.theme.noticeShow) {
                
                UIView *previousSubView = [self.contentView.subviews objectAtIndex:idx - 1];
                if (previousSubView) {
                    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:previousSubView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:self.theme.contentVerticalPadding]];
                }

                
            }else{
            
             [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.theme.popupContentInsets.top]];
           
            }
        }
        else {
            UIView *previousSubView = [self.contentView.subviews objectAtIndex:idx - 1];
            if (previousSubView) {
                [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:previousSubView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:self.theme.contentVerticalPadding]];
            }
        }
        
        if (idx == self.contentView.subviews.count - 1) {
            
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-(self.theme.popupContentInsets.bottom + (self.destructiveButtonItem ? self.destructiveButtonItem.buttonHeight : 0.0f))]];
        }
        
        if ([view isKindOfClass:[KYPopupButton class]]) {
            KYPopupButton *button = (KYPopupButton *)view;
            [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:button.item.buttonHeight]];
            [button addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [view setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
        [view setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
        
        if ([view isKindOfClass:[UIImageView class]]) {
            [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
            [view setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisVertical];
        }
        else {
            [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
            [view setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
        }
        
    }];

    
    if (self.destructiveButtonItem) {
        KYPopupButton *destructiveButton = [self buttonItem:self.destructiveButtonItem];
        [self.contentView addSubview:destructiveButton];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:destructiveButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.destructiveButtonItem.buttonHeight]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:destructiveButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:destructiveButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:destructiveButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
        [destructiveButton addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
        
        
    [self.maskView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.maskView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0]];
    [self.maskView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.maskView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
   
    
    
    if (self.theme.popupStyle == KYPopupStyleFullscreen) {
        self.contentViewWidth = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeWidth multiplier:KY_IS_IPAD?0.5:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewWidth];
        self.contentViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewCenterYConstraint];
        self.contentViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewCenterXConstraint];
    }
    else if (self.theme.popupStyle == KYPopupStyleActionSheet) {
        self.contentViewHeight = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeWidth multiplier:KY_IS_IPAD?0.5:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewHeight];
        self.contentViewBottom = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewBottom];
        self.contentViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewCenterXConstraint];
    }
    else {
        if (KY_IS_IPAD) {
            self.contentViewWidth = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeWidth multiplier:0.4 constant:0];
        }
        else {
            self.contentViewWidth = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:self.theme.bordePadding];
        }
        [self.maskView addConstraint:self.contentViewWidth];
        self.contentViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewCenterYConstraint];
        self.contentViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.maskView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        [self.maskView addConstraint:self.contentViewCenterXConstraint];
    }


    
}

- (UILabel *)multilineLabelWithAttributedString:(NSAttributedString *)attributedString {
    UILabel *label = [[UILabel alloc] init];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [label setAttributedText:attributedString];
    [label setNumberOfLines:0];
    return label;
}

- (UIImageView *)centeredImageViewForImage:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    return imageView;
}


- (KYPopupButton *)buttonItem:(KYPopupButtonItem *)item {
    KYPopupButton *button = [[KYPopupButton alloc] init];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button setAttributedTitle:item.buttonTitle forState:UIControlStateNormal];
    [button setBackgroundColor:item.backgroundColor];
    [button.layer setCornerRadius:item.cornerRadius];
    [button.layer setBorderColor:item.borderColor.CGColor];
    [button.layer setBorderWidth:item.borderWidth];
    button.actionBlock = item.selectionHandler;
    button.item = item;
    return button;
}



- (void)setOriginConstraints {
    
    if (self.theme.popupStyle == KYPopupStyleCentered) {
        switch (self.theme.presentationStyle) {
            case KYPopupPresentationStyleFadeIn:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = 0;
                break;
            case KYPopupPresentationStyleSlideInFromTop:
                self.contentViewCenterYConstraint.constant = -self.applicationKeyWindow.bounds.size.height;
                self.contentViewCenterXConstraint.constant = 0;
                break;
            case KYPopupPresentationStyleSlideInFromBottom:
                self.contentViewCenterYConstraint.constant = self.applicationKeyWindow.bounds.size.height;
                self.contentViewCenterXConstraint.constant = 0;
                break;
            case KYPopupPresentationStyleSlideInFromLeft:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = -self.applicationKeyWindow.bounds.size.height;
                break;
            case KYPopupPresentationStyleSlideInFromRight:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = self.applicationKeyWindow.bounds.size.height;
                break;
            default:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = 0;
                break;
        }
    }
    else if (self.theme.popupStyle == KYPopupStyleActionSheet) {
        self.contentViewBottom.constant = self.applicationKeyWindow.bounds.size.height;
    }
}



- (void)setDismissedConstraints {
    
    if (self.theme.popupStyle == KYPopupStyleCentered) {
        switch (self.theme.presentationStyle) {
            case KYPopupPresentationStyleFadeIn:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = 0;
                break;
            case KYPopupPresentationStyleSlideInFromTop:
                self.contentViewCenterYConstraint.constant = self.applicationKeyWindow.bounds.size.height;
                self.contentViewCenterXConstraint.constant = 0;
                break;
            case KYPopupPresentationStyleSlideInFromBottom:
                self.contentViewCenterYConstraint.constant = -self.applicationKeyWindow.bounds.size.height;
                self.contentViewCenterXConstraint.constant = 0;
                break;
            case KYPopupPresentationStyleSlideInFromLeft:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = self.applicationKeyWindow.bounds.size.height;
                break;
            case KYPopupPresentationStyleSlideInFromRight:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = -self.applicationKeyWindow.bounds.size.height;
                break;
            default:
                self.contentViewCenterYConstraint.constant = 0;
                self.contentViewCenterXConstraint.constant = 0;
                break;
        }
    }
    else if (self.theme.popupStyle == KYPopupStyleActionSheet) {
        self.contentViewBottom.constant = self.applicationKeyWindow.bounds.size.height;
    }
}

- (void)setPresentedConstraints {
    
    if (self.theme.popupStyle == KYPopupStyleCentered) {
        self.contentViewCenterYConstraint.constant = 0;
        self.contentViewCenterXConstraint.constant = 0;
    }
    else if (self.theme.popupStyle == KYPopupStyleActionSheet) {
        self.contentViewBottom.constant = 0;
    }
}


- (void)closeAction
{
    [self dismissPopupControllerAnimated:YES];
}

- (void)didTapOnMaskView
{
    if (self.theme.detectBackgroundDismissTouch) {
        [self dismissPopupControllerAnimated:YES];
    }
}


- (void)actionButtonPressed:(id)sender
{
    
}

#pragma mark - Window Handling

- (void)statusBarFrameOrOrientationChanged:(NSNotification *)notification
{
    [self rotateAccordingToStatusBarOrientationAndSupportedOrientations];
}

- (void)rotateAccordingToStatusBarOrientationAndSupportedOrientations
{
    UIInterfaceOrientation statusBarOrientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat angle = ESInterfaceOrientationAngleOfOrientation(statusBarOrientation);
    CGFloat statusBarHeight = [self getStatusBarHeight];
    
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    CGRect frame = [self rectInWindowBounds:self.applicationKeyWindow.bounds statusBarOrientation:statusBarOrientation statusBarHeight:statusBarHeight];
    
    [self setIfNotEqualTransform:transform frame:frame];
}

- (void)setIfNotEqualTransform:(CGAffineTransform)transform frame:(CGRect)frame
{
    if(!CGAffineTransformEqualToTransform(self.maskView.transform, transform))
    {
        self.maskView.transform = transform;
    }
    if(!CGRectEqualToRect(self.maskView.frame, frame))
    {
        self.maskView.frame = frame;
    }
}

- (CGFloat)getStatusBarHeight
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if(UIInterfaceOrientationIsLandscape(orientation))
    {
        return [UIApplication sharedApplication].statusBarFrame.size.width;
    }
    else
    {
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    }
}

- (CGRect)rectInWindowBounds:(CGRect)windowBounds statusBarOrientation:(UIInterfaceOrientation)statusBarOrientation statusBarHeight:(CGFloat)statusBarHeight
{
    CGRect frame = windowBounds;
    frame.origin.x += statusBarOrientation == UIInterfaceOrientationLandscapeLeft ? statusBarHeight : 0;
    frame.origin.y += statusBarOrientation == UIInterfaceOrientationPortrait ? statusBarHeight : 0;
    frame.size.width -= UIInterfaceOrientationIsLandscape(statusBarOrientation) ? statusBarHeight : 0;
    frame.size.height -= UIInterfaceOrientationIsPortrait(statusBarOrientation) ? statusBarHeight : 0;
    return frame;
}

CGFloat ESInterfaceOrientationAngleOfOrientation(UIInterfaceOrientation orientation)
{
    CGFloat angle;
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIInterfaceOrientationLandscapeLeft:
            angle = -M_PI_2;
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            break;
        default:
            angle = 0.0;
            break;
    }
    
    return angle;
}

UIInterfaceOrientationMask ESInterfaceOrientationMaskFromOrientation(UIInterfaceOrientation orientation)
{
    return 1 << orientation;
}




@end










@implementation KYPopupTheme




+(KYPopupTheme *)defaultTheme
{
    KYPopupTheme *theme = [[KYPopupTheme alloc] init];
    theme.maskViewColor = [UIColor clearColor];
    theme.backgroundColor = [UIColor whiteColor];
    theme.cornerRadius = 6.0f;
    theme.contentVerticalPadding = 12.0f;
    theme.bordePadding = -40;
    theme.popupContentInsets = UIEdgeInsetsMake(16.0f, 16.0f, 16.0f, 16.0f);
    theme.closeShow = YES;
    theme.noticeShow = YES;
    theme.detectBackgroundDismissTouch = FALSE;
    theme.popupStyle = KYPopupStyleCentered;
    return theme;
}

@end




@implementation KYPopupButtonItem


+ (KYPopupButtonItem *)defaultButtonItemWithTitle:(NSAttributedString *)title backgroundColor:(UIColor *)color
{
    KYPopupButtonItem *item = [[KYPopupButtonItem alloc] init];
    item.buttonTitle = title;
    item.backgroundColor = color;
    return item;
}


@end



static char KYPopupViewWidth;
static char KYPopupViewHeight;

@implementation UIView(popup)
@dynamic viewWidth;
@dynamic viewHeight;

- (void)setViewWidth:(NSNumber*)viewWidth
{
    objc_setAssociatedObject(self, &KYPopupViewWidth, viewWidth, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)viewWidth
{
    return objc_getAssociatedObject(self, &KYPopupViewWidth);
}


- (void)setViewHeight:(NSNumber*)viewHeight
{
    objc_setAssociatedObject(self, &KYPopupViewHeight, viewHeight, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)viewHeight
{
    return objc_getAssociatedObject(self, &KYPopupViewHeight);
}


@end



static char const * const ActionBlockKey = "ActionBlockKey";

@implementation UIButton (Blocks)
@dynamic actionBlock;

- (id)initWitActionBlock:(SelectionHandler)block{
    self = [super init];
    if (self) {
        self.actionBlock = [block copy];
        [self addTarget:self action:@selector(fireActionBlock) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)fireActionBlock {
    
    if (self.actionBlock) {
        self.actionBlock();
    }
    
}


- (SelectionHandler)actionBlock{
    return objc_getAssociatedObject(self, ActionBlockKey);
}

- (void)setActionBlock:(SelectionHandler)actionBlock{
    [self addTarget:self action:@selector(fireActionBlock) forControlEvents:UIControlEventTouchUpInside];
    objc_setAssociatedObject(self, ActionBlockKey, actionBlock,  OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end


