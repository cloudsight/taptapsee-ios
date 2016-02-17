//
//  AboutViewController.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface AboutViewController : UIViewController <MFMailComposeViewControllerDelegate>
{
    __weak IBOutlet NSLayoutConstraint *topLayoutConstraint;
    __weak IBOutlet UILabel *versionLabel;
    __weak IBOutlet UISwitch *focusLockSwitch;
    __weak IBOutlet UISwitch *flashSwitch;
    __weak IBOutlet UILabel *pictureCreditLabel;
    __weak IBOutlet UILabel *pictureCreditTitleLabel;
}

@property (nonatomic, assign) BOOL focusLockSoundEnabled;
@property (nonatomic, assign) BOOL flashEnabled;

- (IBAction)onPrivacyPolicyButton:(id)sender;
- (IBAction)onTermsOfService:(id)sender;
- (IBAction)onFocusLockSwitchDidToggle:(id)sender;
- (IBAction)onContactUs:(id)sender;
- (IBAction)onFlashSwitchDidToggle:(id)sender;

@end
