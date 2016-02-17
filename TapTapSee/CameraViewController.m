//
//  CameraViewController.m
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "AboutViewController.h"
#import "Config.h"
#import "CWTranslate.h"
#import "CameraViewController.h"
#import "HistoryItemStore.h"
#import "HistoryItem.h"
#import "SpeakQueue.h"
#import "UIImage+FitToRange.h"
#import "UIImage+Resize.h"

@implementation CameraViewController

- (void)viewDidLoad
{
    // Setup the tag query manager
    [[TagQueryManager sharedManager] setDelegate:self];
    queryCount = 0;
    currentZoom = 1.0;

    // Initialize the video layer manager
    // TODO: Make this viewfinder a UIView to get this stuff out of here
    cameraManager = [[CameraManager alloc] init];
    cameraManager.delegate = self;
    [self addVideoPreviewLayer];

    // View controller misc setup
    if (kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1)
        [self setNeedsStatusBarAppearanceUpdate];

    [outputLabel setText:@""];

    // Setup observers
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(previewLayerDidStart:)
                                                 name:AVCaptureSessionDidStartRunningNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(previewLayerDidStop:)
                                                 name:AVCaptureSessionDidStopRunningNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Check to see if accessibility is turned on (in iOS7 we're using AVSpeechSynthesizer)
    if (!UIAccessibilityIsVoiceOverRunning()) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"VoiceOver is Off", @"")
                              message:NSLocalizedString(@"In order to hear the descriptions of the pictures taken, please enable VoiceOver in your device Settings.", @"")
                              delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    }
    
    // Show user offensive image notice
    bool userAcceptedOffensiveImagePolicy = [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULT_USER_ACCEPTED_OFFENSIVE_IMAGE_POLICY];
    if (!userAcceptedOffensiveImagePolicy) {
        offensiveImagePolicyAlertView = [[UIAlertView alloc]
                                         initWithTitle:NSLocalizedString(@"Notice", @"")
                                         message:NSLocalizedString(@"Your use will be suspended if you take any violent, nude, partially nude, discriminatory, unlawful, infringing, hateful or pornographic pictures. See our privacy policy for more details.", @"")
                                         delegate:self cancelButtonTitle:NSLocalizedString(@"Decline", @"") otherButtonTitles:NSLocalizedString(@"Accept", @""), nil];
        [offensiveImagePolicyAlertView show];
    }

    // Turn on the camera
    [self enableInput];
    [cameraManager startCamera];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self disableInput];
    [cameraManager stopCamera];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)dealloc
{
    [[TagQueryManager sharedManager] setDelegate:nil];
    
    [cameraManager setDelegate:nil];
    [cameraManager stopCamera];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)disableInput
{
    [cameraButton setEnabled:NO];
}

- (void)enableInput
{
    [cameraButton setEnabled:YES];
}

- (void)simulateShutterFlashOfWhite
{
    UIView *whiteFlashView = [[UIView alloc] initWithFrame:viewfinder.frame];
    whiteFlashView.alpha = 1.0f;
    whiteFlashView.backgroundColor = [UIColor whiteColor];
    [[self view] insertSubview:whiteFlashView aboveSubview:viewfinder];
    [UIView animateWithDuration:2 animations: ^{
        whiteFlashView.alpha = 0.0f;
    } completion: ^(BOOL finished) {
        [whiteFlashView removeFromSuperview];
    }];
}

- (UIImage *)fitImageToViewfinderSize:(UIImage *)image
{
    CGSize outputSize = CGSizeMultiply(viewfinder.frame.size, (CGFloat)[[UIScreen mainScreen] scale]);
    float minSize = outputSize.height < outputSize.width ? outputSize.height : outputSize.width;
    float maxSize = outputSize.height > outputSize.width ? outputSize.height : outputSize.width;
    
    if ((image.size.width > maxSize || image.size.height > minSize)
        && (image.size.width > minSize || image.size.height > maxSize)) {
        
        UIImage *resizedImage = [image fitToRangeFrom:minSize to:maxSize];
        DDLogDebug(@"AVCaptureStillImageOutput image resized from %@ to %@", NSStringFromCGSize(image.size), NSStringFromCGSize(resizedImage.size));
        
        return resizedImage;
    }
    
    return image;
}

- (void)addImage:(UIImage *)image
{
    queryCount++;
    if (queryCount > MAX_QUERY_COUNT)
        queryCount = 1;
    
    NSString *photoFormat = [[NSString alloc]initWithFormat:NSLocalizedString(@"Picture %i in progress", @""), queryCount];
    [outputLabel setText:photoFormat];
    [[SpeakQueue sharedQueue] speak:photoFormat];
    
    HistoryItem *historyItem = [[HistoryItemStore sharedStore] createItemForImage:image];
    [historyItem setQueryNumber:queryCount];
    [historyItem setStatus:@"Waiting..."];
    
    TagQueryManager *tagQueryManager = [TagQueryManager sharedManager];
    [tagQueryManager queryWithImage:image withFocus:CGPointMake(0, 0) withHistoryItem:historyItem];
}

- (void)previewLayerDidStart:(id)sender
{
    // Provide a nice animation when the preview layer starts
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25];
    
    [viewfinder setAlpha:1.0];
    [UIView commitAnimations];
}

- (void)previewLayerDidStop:(id)sender
{
    [viewfinder setAlpha:0.0];
}

- (void)addVideoPreviewLayer
{
    // Init size and create preview/image capture layer
    [self resetVideoPreviewLayerSize];
    [[viewfinder layer] addSublayer:cameraManager.previewLayer];

    // Add feature indicator
    [self setFeatureIndicator:[[UIView alloc] initWithFrame:CGRectZero]];
    [[self featureIndicator] setBackgroundColor:[UIColor colorWithRed:0.0f/255.0f green:114.0f/255.0 blue:255.0/255.0f alpha:0.5f]];
    [viewfinder insertSubview:[self featureIndicator] atIndex:3];
}

- (void)resetVideoPreviewLayerSize
{
    CGRect layerRect = CGRectMake((viewfinder.layer.bounds.size.width  - (viewfinder.layer.bounds.size.width  * currentZoom)) / 2,
                                  (viewfinder.layer.bounds.size.height - (viewfinder.layer.bounds.size.height * currentZoom)) / 2,
                                  viewfinder.layer.bounds.size.width  * currentZoom,
                                  viewfinder.layer.bounds.size.height * currentZoom);
    
    cameraManager.previewLayer.frame = layerRect;
}

# pragma mark CameraManagerDelegate implementation

- (void)cameraManager:(CameraManager *)manager didCaptureMetadata:(NSArray *)metadataObjects
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type]) {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[cameraManager.previewLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barCodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil)
            break;
    }
    
    if (detectionString != nil && barcodeContentDetector == nil) {
        // We had a match with the iOS content detector
        barcodeContentDetector = [[BarcodeContentDetector alloc] initWithDelegate:self
                                                                  withFeatureType:barCodeObject.type
                                                                  withFeatureDescription:detectionString];
        [barcodeContentDetector start];
    }
    
    [[self featureIndicator] setFrame:highlightViewRect];
}

- (void)cameraManager:(CameraManager *)manager didCaptureStillFrame:(UIImage *)image
{
    DDLogDebug(@"Captured still image: %@", image);
    [self simulateShutterFlashOfWhite];
    
    // Control the image size
    UIImage *resizedImage = [self fitImageToViewfinderSize:image];
    
    // Crop image to account for zoomed in viewport
    CGRect cropRect = CGRectMake((resizedImage.size.width  - (resizedImage.size.width  / currentZoom)) / 2,
                                 (resizedImage.size.height - (resizedImage.size.height / currentZoom)) / 2,
                                 resizedImage.size.width  / currentZoom,
                                 resizedImage.size.height / currentZoom);
    UIImage *croppedImage = [resizedImage croppedImage:cropRect];
    
    [self addImage:croppedImage];
}

- (void)cameraManager:(CameraManager *)manager didFailToCaptureStillFrameWithError:(NSError *)error
{
    DDLogDebug(@"Camera error: %@", error);
}

#pragma mark TagQueryDelegate implementation

- (void)didIdentifyItem:(HistoryItem *)item withQuery:(TagQuery *)query
{
    lastIdentifiedItem = item;
    
    // Show offensive warning
    if ([[item title] isEqualToString:@"offensive"]) {
        offensiveImageAlertView = [[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"Warning", @"")
                                   message:NSLocalizedString(@"Your use will be suspended if you take any violent, nude, partially nude, discriminatory, unlawful, infringing, hateful or pornographic pictures. See our privacy policy for more details.", @"")
                                   delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Accept", @""), nil];
        [offensiveImageAlertView show];
    } else {
        // Do the translation here (so we still get the 'offensive' above)
        NSString *translatedTitle = [CWTranslate translate:[item title]
                                        withSourceLanguage:@"en"
                                   withDestinationLanguage:[CWTranslate currentLanguageIdentifier]];
        DebugLog(@"translatedTitle: %@", translatedTitle);
        [item setTitle:translatedTitle];
        
        // Form the VO message and speak
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Picture %i is %@", @""), [item queryNumber], [item title]];
        [outputLabel setText:message];
        [[SpeakQueue sharedQueue] speak:message];
        
        // Reset "live item"
        lastIdentifiedLiveItem = nil;
    }
    
    // Enable the share picture
    [shareButton setEnabled:YES];
}

- (void)didDequeueItem:(HistoryItem *)item withQuery:(TagQuery *)query
{
    // Ignore
}

- (void)didUploadItem:(HistoryItem *)item withQuery:(TagQuery *)query
{
    // Ignore
}

- (void)didFailItem:(HistoryItem *)item withQuery:(TagQuery *)query
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Picture %i failed: %@", @""), [item queryNumber], [item status]];
    [outputLabel setText:message];
    [[SpeakQueue sharedQueue] speak:message];
}

# pragma mark BarcodeContentDetectorDelegate implementation

- (void)barcodeContentDetector:(id)sender didIdentifyWithString:(NSString *)item
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (item != nil && ![item isEqualToString:lastIdentifiedLiveItem]) {
            DDLogDebug(@"live item: %@", item);
            
            NSString *message = [NSString stringWithFormat:@"Barcode: %@", item];
            [outputLabel setText:message];
            [[SpeakQueue sharedQueue] speak:message];
        }

        lastIdentifiedLiveItem = item;
    });

    barcodeContentDetector = nil;
}

#pragma mark UIImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self addImage:image];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIAlertViewDelegate implementation

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == offensiveImagePolicyAlertView) {
        if (buttonIndex == 1) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:DEFAULT_USER_ACCEPTED_OFFENSIVE_IMAGE_POLICY];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
            exit(0);
    }
}

#pragma mark IBActions

- (IBAction)onCameraButton:(id)sender
{
    if ([[TagQueryManager sharedManager] busyCount] >= MAX_QUERY_COUNT) {
        NSString *maxImagesMessage = [NSString stringWithFormat:NSLocalizedString(@"Sorry, but I can only handle %i images at a time.  Please wait for some to finish before taking another picture", @""), MAX_QUERY_COUNT];
        [[SpeakQueue sharedQueue] speak:maxImagesMessage];
    } else {
        [cameraManager captureStillFrame];
    }
}

- (IBAction)onInfoButton:(id)sender
{
    AboutViewController *aboutVC = [[AboutViewController alloc] init];
    [[self navigationController] pushViewController:aboutVC animated:YES];
}

- (IBAction)onRepeatButton:(id)sender
{
    NSString *message = nil;
    if (lastIdentifiedItem)
        message = [NSString stringWithFormat:NSLocalizedString(@"Repeating. Picture %i is %@", @""), [lastIdentifiedItem queryNumber], [lastIdentifiedItem title]];
    else
        message = NSLocalizedString(@"No pictures taken. Take a picture first.", @"");
    
    [[SpeakQueue sharedQueue] speak:message];
}

- (IBAction)onShareButton:(id)sender
{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:[lastIdentifiedItem shareActivityItems]
                                                                                         applicationActivities:nil];
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (IBAction)onLibraryButton:(id)sender
{
    UIImagePickerController *imagePickController = [[UIImagePickerController alloc] init];
    imagePickController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickController.delegate = self;
    imagePickController.allowsEditing = NO;
    
    [self presentViewController:imagePickController animated:YES completion:nil];
}

@end
