//
//  MergeVideo.h
//  VideoPlayRecord
//
//  Created by Abdul Azeem Khan on 5/9/12.
//  Copyright (c) 2012 DataInvent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>
@interface MergeVideo : NSObject<UIImagePickerControllerDelegate,UINavigationControllerDelegate,MPMediaPickerControllerDelegate>{
    BOOL isSelectingAssetOne;
}

//@property(nonatomic,retain)NSMutableArray* assetArray;
@property(nonatomic,retain)AVAsset* asset1;
@property(nonatomic,retain)AVAsset* asset2;
@property(nonatomic,retain)AVAsset* asset3;
@property(nonatomic,retain)AVAsset* asset4;
@property(nonatomic,retain)AVAsset* asset5;
@property(nonatomic,retain)AVAsset* asset6;
@property(nonatomic,retain)AVAsset* asset7;
@property(nonatomic,retain)AVAsset* asset8;
@property(nonatomic,retain)AVAsset* asset9;
@property(nonatomic,retain)AVAsset* asset10;
@property(nonatomic,retain)AVAsset* audioAsset;
@property(nonatomic) int movieClipsCount;
@property(nonatomic)BOOL vidSaved;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *ActivityView;
- (IBAction)LoadAssetOne:(id)sender;
- (IBAction)LoadAssetTwo:(id)sender;
- (IBAction)LoadAudio:(id)sender;
- (bool)MergeAndSave;
- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate;
- (void)exportDidFinish:(AVAssetExportSession*)session;

@end
