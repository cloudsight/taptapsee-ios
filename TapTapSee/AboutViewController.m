//
//  AboutViewController.m
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import "AboutViewController.h"
#import "Config.h"
#import "Reachability.h"

@implementation AboutViewController

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];

    // iOS 6/7 compatibility
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7) {
        topLayoutConstraint.constant = 19;
    }

    // Setup version label
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *versionStr = [NSString stringWithFormat:NSLocalizedString(@"Version: %@ (build %@)", @""),
                            [appInfo objectForKey:@"CFBundleShortVersionString"],
                            [appInfo objectForKey:@"CFBundleVersion"]];
    
    [versionLabel setText:versionStr];
    
    // Setup switch default states
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [focusLockSwitch setOn:[defaults boolForKey:DEFAULT_FOCUS_LOCK_SOUND_KEY]];
    [flashSwitch     setOn:[defaults boolForKey:DEFAULT_FLASH_KEY]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1)
        [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidUnload
{
    versionLabel = nil;
    [super viewDidUnload];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleBlackTranslucent;
}

- (void)saveDefaults
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:[self focusLockSoundEnabled] forKey:DEFAULT_FOCUS_LOCK_SOUND_KEY];
    [defaults setBool:[self flashEnabled]          forKey:DEFAULT_FLASH_KEY];
    
    [defaults synchronize];
}

- (NSString *)versionInfoString
{
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *versionStr = [NSString stringWithFormat:@"Version: %@ (%@)",
                            [appInfo objectForKey:@"CFBundleShortVersionString"],
                            [appInfo objectForKey:@"CFBundleVersion"]];
    
    return versionStr;
}

#pragma mark IBActions

- (IBAction)onPrivacyPolicyButton:(id)sender
{
    NSURL *privacyPolicyURL = [[NSURL alloc] initWithString:@"http://www.taptapseeapp.com/privacy"];
    [[UIApplication sharedApplication] openURL:privacyPolicyURL];
}

- (IBAction)onTermsOfService:(id)sender
{
    NSURL *termsOfServiceURL = [[NSURL alloc] initWithString:@"http://www.taptapseeapp.com/terms_of_use"];
    [[UIApplication sharedApplication] openURL:termsOfServiceURL];
}

- (IBAction)onFocusLockSwitchDidToggle:(id)sender
{
    [self setFocusLockSoundEnabled:[focusLockSwitch isOn]];
    [self saveDefaults];
}

- (IBAction)onFlashSwitchDidToggle:(id)sender
{
    [self setFlashEnabled:[flashSwitch isOn]];
    [self saveDefaults];
}

- (IBAction)onContactUs:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setToRecipients:[NSArray arrayWithObject:@"contact@taptapseeapp.com"]];
        [mailer setSubject:@"TapTapSee - Contact Us"];
        [mailer setMessageBody:[NSString stringWithFormat:@"Your Message:<br/><br/><br/><br/><br/><br/><br/>Version: %@<br/>Model: %@<br/>System: %@, %@<br/>Locale: %@<br/>Network: %@", [self versionInfoString], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion], [[NSLocale currentLocale] localeIdentifier], [[TMReachability reachabilityForInternetConnection] currentReachabilityString]] isHTML:YES];
        
        [self presentViewController:mailer animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"Accept"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

#pragma mark Email callbacks

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
//    switch (result)
//    {
//        case MFMailComposeResultCancelled:
//            DebugLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
//            break;
//        case MFMailComposeResultSaved:
//            DebugLog(@"Mail saved: you saved the email message in the drafts folder.");
//            break;
//        case MFMailComposeResultSent:
//            DebugLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
//            break;
//        case MFMailComposeResultFailed:
//            DebugLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
//            break;
//        default:
//            DebugLog(@"Unknown MFMailComposeResult value.");
//            break;
//    }
//    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
