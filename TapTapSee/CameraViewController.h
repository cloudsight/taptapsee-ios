//
//  CameraViewController.h
//  TapTapSee
//
//  Copyright (c) 2016 CamFind Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CameraManager.h"
#import "CameraManagerDelegate.h"
#import "TagQueryManager.h"
#import "BarcodeContentDetector.h"
#import "BarcodeContentDetectorDelegate.h"

@interface CameraViewController : UIViewController <CameraManagerDelegate, TagQueryDelegate, BarcodeContentDetectorDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    int queryCount;
    float currentZoom;
    HistoryItem *lastIdentifiedItem;
    NSString *lastIdentifiedLiveItem;
    CameraManager *cameraManager;
    BarcodeContentDetector *barcodeContentDetector;
    
    UIAlertView *offensiveImagePolicyAlertView;
    UIAlertView *offensiveImageAlertView;

    __weak IBOutlet UIView     *viewfinder;
    __weak IBOutlet UIButton   *libraryButton;
    __weak IBOutlet UIButton   *shareButton;
    __weak IBOutlet UIButton   *cameraButton;
    __weak IBOutlet UIButton   *infoButton;
    __weak IBOutlet UIButton   *repeatButton;
    
    __weak IBOutlet UILabel    *outputLabel;
}

@property (nonatomic, retain) UIView *featureIndicator;

- (IBAction)onCameraButton:(id)sender;
- (IBAction)onInfoButton:(id)sender;
- (IBAction)onRepeatButton:(id)sender;
- (IBAction)onLibraryButton:(id)sender;
- (IBAction)onShareButton:(id)sender;

@end
