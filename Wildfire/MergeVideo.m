//
//  MergeVideo.m
//  VideoPlayRecord
//
//  Created by Abdul Azeem Khan on 5/9/12.
//  Copyright (c) 2012 DataInvent. All rights reserved.
//

#import "MergeVideo.h"
#import "MoviePlayerViewController.h"

@implementation MergeVideo
@synthesize ActivityView;
@synthesize asset1,asset2,asset3,asset4,asset5,asset6,asset7,asset8,asset9,asset10,audioAsset;

/*- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }
 - (void)viewDidLoad
 {
 [super viewDidLoad];
 NSLog(@"Loaded");
 // Do any additional setup after loading the view, typically from a nib.
 }
 - (void)didReceiveMemoryWarning
 {
 // Releases the view if it doesn't have a superview.
 [super didReceiveMemoryWarning];
 
 // Release any cached data, images, etc that aren't in use.
 }
 
 #pragma mark - View lifecycle
 
 - (void)viewDidUnload
 {
 [self setActivityView:nil];
 [super viewDidUnload];
 // Release any retained subviews of the main view.
 // e.g. self.myOutlet = nil;
 }*/

- (id)init {
    
    self = [super init];
    
    if (self) {
        
        NSLog(@"Merge Videos Class initialized");
        //_assetArray = [[NSMutableArray alloc]init];
        
    }
    
    _vidSaved = NO;
    
    return self;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)LoadAssetOne:(id)sender{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Saved Album Found"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
        [alert show];
    }else{
        isSelectingAssetOne = TRUE;
        [self startMediaBrowserFromViewController: self
                                    usingDelegate: self];
    }
}
- (IBAction)LoadAssetTwo:(id)sender{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No Saved Album Found"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
        [alert show];
        
    }else{
        isSelectingAssetOne = FALSE;
        [self startMediaBrowserFromViewController: self
                                    usingDelegate: self];
    }
}

- (IBAction)LoadAudio:(id)sender{
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
    mediaPicker.delegate = self;
    mediaPicker.prompt = @"Select Audio";
    //[self presentModalViewController:mediaPicker animated:YES];
}


- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    NSArray * SelectedSong = [mediaItemCollection items];
    if([SelectedSong count]>0){
        MPMediaItem * SongItem = [SelectedSong objectAtIndex:0];
        NSURL *SongURL = [SongItem valueForProperty: MPMediaItemPropertyAssetURL];
        
        audioAsset = [AVAsset assetWithURL:SongURL];
        NSLog(@"Audio Loaded");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Audio Loaded"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
        [alert show];
    }
    
    // [self dismissModalViewControllerAnimated: YES];
}
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    //  [self dismissModalViewControllerAnimated: YES];
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    // [self dismissModalViewControllerAnimated: YES];
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = YES;
    
    mediaUI.delegate = delegate;
    
    [controller presentModalViewController: mediaUI animated: YES];
    return YES;
}
// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    //[self dismissModalViewControllerAnimated:NO];
    // Handle a movie capture
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {
        if(isSelectingAssetOne){
            NSLog(@"Video One  Loaded");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video One Loaded"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
            [alert show];
            //asset1 = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
            // asset1 = [AVAsset assetWithURL:[NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"IMG_1629" ofType:@"MOV"]]];
        }else{
            NSLog(@"Video two Loaded");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Video Two Loaded"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
            [alert show];
            //asset2 = [AVAsset assetWithURL:[info objectForKey:UIImagePickerControllerMediaURL]];
            //asset2 = [AVAsset assetWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"IMG_1629" ofType:@"MOV"]]];
        }
    }
}

- (void)MergeAndSave{
    if(asset1 !=nil && asset2!=nil){
        [ActivityView startAnimating];
        //Create AVMutableComposition Object.This object will hold our multiple AVMutableCompositionTrack.
        AVMutableComposition* mixComposition = [[AVMutableComposition alloc] init];
        
        if(_movieClipsCount>5)_movieClipsCount = 5;
        
        NSLog(@"Number of objects in movieClipCount = %d",_movieClipsCount);
        //AVAsset *asset1 = (AVAsset*)_assetArray[0];
        // NSLog(@"Time of Asset 1: %f",CMTimeGetSeconds(asset1.duration));
        CMTime time = kCMTimeZero;
        //VIDEO TRACK
        AVMutableCompositionTrack *firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [firstTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset1.duration) ofTrack:[[(AVAsset*)asset1 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        
        time = CMTimeAdd(time, asset1.duration);
        
        AVMutableCompositionTrack *secondTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [secondTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset2.duration) ofTrack:[[(AVAsset*)asset2 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:time error:nil];
        
        
        AVMutableCompositionTrack *thirdTrack;
        if(_movieClipsCount >= 3){
            time = CMTimeAdd(time, asset2.duration);
            
            thirdTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [thirdTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset3.duration) ofTrack:[[(AVAsset*)asset3 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:time error:nil];
        }
        
        AVMutableCompositionTrack *fourthTrack;
        if(_movieClipsCount >= 4){
            time = CMTimeAdd(time, asset3.duration);
            
            fourthTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [fourthTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset4.duration) ofTrack:[[(AVAsset*)asset4 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:time error:nil];
        }
        
        AVMutableCompositionTrack *fifthTrack;
        if(_movieClipsCount >= 5){
            time = CMTimeAdd(time, asset4.duration);
            
            fifthTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [fifthTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset5.duration) ofTrack:[[(AVAsset*)asset5 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:time error:nil];
        }
        
        AVMutableCompositionTrack *sixthTrack;
        if(_movieClipsCount >= 6){
            time = CMTimeAdd(time, asset5.duration);
            
            sixthTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [sixthTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset6.duration) ofTrack:[[(AVAsset*)asset6 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:time error:nil];
        }
        
        AVMutableCompositionTrack *seventhTrack;
        if(_movieClipsCount >= 7){
            time = CMTimeAdd(time, asset6.duration);
            
            seventhTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [seventhTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset7.duration) ofTrack:[[(AVAsset*)asset7 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:time error:nil];
        }
        
        AVMutableCompositionTrack *eighthTrack;
        if(_movieClipsCount >= 8){
            time = CMTimeAdd(time, asset7.duration);
            
            eighthTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [eighthTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset8.duration) ofTrack:[[(AVAsset*)asset8 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:time error:nil];
        }
        
        AVMutableCompositionTrack *ninthTrack;
        if(_movieClipsCount >= 9){
            time = CMTimeAdd(time, asset8.duration);
            
            ninthTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [eighthTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset9.duration) ofTrack:[[(AVAsset*)asset9 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:time error:nil];
        }
        
        AVMutableCompositionTrack *tenthTrack;
        if(_movieClipsCount >= 10){
            time = CMTimeAdd(time, asset9.duration);
            
            tenthTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
            [tenthTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset10.duration) ofTrack:[[(AVAsset*)asset10 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:time error:nil];
        }
        
        
        
        //My code start 1
        time = kCMTimeZero;
        
        AVMutableCompositionTrack *AudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset1.duration)
                            ofTrack:[[asset1 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        
        time = CMTimeAdd(time, asset1.duration);
        
        [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset2.duration)
                            ofTrack:[[asset2 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:time error:nil];
        
        time = CMTimeAdd(time, asset2.duration);
        
        if(_movieClipsCount >= 3){
            [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset3.duration)
                                ofTrack:[[asset3 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:time error:nil];
            time = CMTimeAdd(time, asset3.duration);
        }
        if(_movieClipsCount >= 4){
            [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset4.duration)
                                ofTrack:[[asset4 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:time error:nil];
            time = CMTimeAdd(time, asset4.duration);
        }
        if(_movieClipsCount >= 5){
            [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset5.duration)
                                ofTrack:[[asset5 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:time error:nil];
            time = CMTimeAdd(time, asset5.duration);
        }
        if(_movieClipsCount >= 6){
            [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset6.duration)
                                ofTrack:[[asset6 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:time error:nil];
            time = CMTimeAdd(time, asset6.duration);
        }
        if(_movieClipsCount >= 7){
            [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset7.duration)
                                ofTrack:[[asset7 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:time error:nil];
            time = CMTimeAdd(time, asset7.duration);
        }
        if(_movieClipsCount >= 8){
            [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset8.duration)
                                ofTrack:[[asset8 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:time error:nil];
            time = CMTimeAdd(time, asset8.duration);
        }
        if(_movieClipsCount >= 9){
            [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset9.duration)
                                ofTrack:[[asset9 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:time error:nil];
            time = CMTimeAdd(time, asset9.duration);
        }
        if(_movieClipsCount >= 10){
            [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, asset10.duration)
                                ofTrack:[[asset10 tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:time error:nil];
            time = CMTimeAdd(time, asset10.duration);
        }
        //My code end 1
        
        
        //AUDIO TRACK
        if(audioAsset!=nil){
            AVMutableCompositionTrack *AudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
            [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, time) ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
        }
        
        AVMutableVideoCompositionInstruction * MainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        MainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, time);
        
        
        time = kCMTimeZero;
        //FIXING ORIENTATION//
        AVMutableVideoCompositionLayerInstruction *FirstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:firstTrack];
        AVAssetTrack *FirstAssetTrack = [[asset1 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        UIImageOrientation FirstAssetOrientation_  = UIImageOrientationUp;
        BOOL  isFirstAssetPortrait_  = NO;
        CGAffineTransform firstTransform = FirstAssetTrack.preferredTransform;
        if(firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0)  {FirstAssetOrientation_= UIImageOrientationRight; isFirstAssetPortrait_ = YES;}
        if(firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0)  {FirstAssetOrientation_ =  UIImageOrientationLeft; isFirstAssetPortrait_ = YES;}
        if(firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0)   {FirstAssetOrientation_ =  UIImageOrientationUp;}
        if(firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0) {FirstAssetOrientation_ = UIImageOrientationDown;}
        CGFloat FirstAssetScaleToFitRatio = 320.0/FirstAssetTrack.naturalSize.width;
        NSLog(@"First Asset Track.Natural Size. Width: %f",FirstAssetTrack.naturalSize.width);
        NSLog(@"First Asset Track.Natural Size. Height: %f",FirstAssetTrack.naturalSize.height);
        if(isFirstAssetPortrait_){
            FirstAssetScaleToFitRatio = 320.0/FirstAssetTrack.naturalSize.height;
            CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
            [FirstlayerInstruction setTransform:CGAffineTransformConcat(FirstAssetTrack.preferredTransform, FirstAssetScaleFactor) atTime:kCMTimeZero];
        }else{
            CGAffineTransform FirstAssetScaleFactor = CGAffineTransformMakeScale(FirstAssetScaleToFitRatio,FirstAssetScaleToFitRatio);
            [FirstlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(FirstAssetTrack.preferredTransform, FirstAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:kCMTimeZero];
        }
        
        time = CMTimeAdd(time, asset1.duration);
        [FirstlayerInstruction setOpacity:0.0 atTime:time];
        
        AVMutableVideoCompositionLayerInstruction *SecondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:secondTrack];
        AVAssetTrack *SecondAssetTrack = [[asset2 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        UIImageOrientation SecondAssetOrientation_  = UIImageOrientationUp;
        BOOL  isSecondAssetPortrait_  = NO;
        CGAffineTransform secondTransform = SecondAssetTrack.preferredTransform;
        if(secondTransform.a == 0 && secondTransform.b == 1.0 && secondTransform.c == -1.0 && secondTransform.d == 0)  {SecondAssetOrientation_= UIImageOrientationRight; isSecondAssetPortrait_ = YES;}
        if(secondTransform.a == 0 && secondTransform.b == -1.0 && secondTransform.c == 1.0 && secondTransform.d == 0)  {SecondAssetOrientation_ =  UIImageOrientationLeft; isSecondAssetPortrait_ = YES;}
        if(secondTransform.a == 1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == 1.0)   {SecondAssetOrientation_ =  UIImageOrientationUp;}
        if(secondTransform.a == -1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == -1.0) {SecondAssetOrientation_ = UIImageOrientationDown;}
        CGFloat SecondAssetScaleToFitRatio = 320.0/SecondAssetTrack.naturalSize.width;
        if(isSecondAssetPortrait_){
            SecondAssetScaleToFitRatio = 320.0/SecondAssetTrack.naturalSize.height;
            CGAffineTransform SecondAssetScaleFactor = CGAffineTransformMakeScale(SecondAssetScaleToFitRatio,SecondAssetScaleToFitRatio);
            [SecondlayerInstruction setTransform:CGAffineTransformConcat(SecondAssetTrack.preferredTransform, SecondAssetScaleFactor) atTime:time];
        }else{
            ;
            CGAffineTransform SecondAssetScaleFactor = CGAffineTransformMakeScale(SecondAssetScaleToFitRatio,SecondAssetScaleToFitRatio);
            [SecondlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(SecondAssetTrack.preferredTransform, SecondAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:time];
        }
        
        AVMutableVideoCompositionLayerInstruction *ThirdlayerInstruction;
        if(_movieClipsCount >= 3){
            time = CMTimeAdd(time, asset2.duration);
            [SecondlayerInstruction setOpacity:0.0 atTime:time];
            
            //3rd Track Start**************************
            ThirdlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:thirdTrack];
            AVAssetTrack *ThirdAssetTrack = [[asset3 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            UIImageOrientation ThirdAssetOrientation_  = UIImageOrientationUp;
            BOOL  isThirdAssetPortrait_  = NO;
            CGAffineTransform thirdTransform = ThirdAssetTrack.preferredTransform;
            if(thirdTransform.a == 0 && thirdTransform.b == 1.0 && thirdTransform.c == -1.0 && thirdTransform.d == 0)  {ThirdAssetOrientation_= UIImageOrientationRight; isThirdAssetPortrait_ = YES;}
            if(thirdTransform.a == 0 && thirdTransform.b == -1.0 && thirdTransform.c == 1.0 && thirdTransform.d == 0)  {ThirdAssetOrientation_ =  UIImageOrientationLeft; isThirdAssetPortrait_ = YES;}
            if(thirdTransform.a == 1.0 && thirdTransform.b == 0 && thirdTransform.c == 0 && thirdTransform.d == 1.0)   {ThirdAssetOrientation_ =  UIImageOrientationUp;}
            if(thirdTransform.a == -1.0 && thirdTransform.b == 0 && thirdTransform.c == 0 && thirdTransform.d == -1.0) {ThirdAssetOrientation_ = UIImageOrientationDown;}
            CGFloat ThirdAssetScaleToFitRatio = 320.0/ThirdAssetTrack.naturalSize.width;
            if(isThirdAssetPortrait_){
                ThirdAssetScaleToFitRatio = 320.0/ThirdAssetTrack.naturalSize.height;
                CGAffineTransform ThirdAssetScaleFactor = CGAffineTransformMakeScale(ThirdAssetScaleToFitRatio,ThirdAssetScaleToFitRatio);
                [ThirdlayerInstruction setTransform:CGAffineTransformConcat(ThirdAssetTrack.preferredTransform, ThirdAssetScaleFactor) atTime:time];
            }else{
                ;
                CGAffineTransform ThirdAssetScaleFactor = CGAffineTransformMakeScale(ThirdAssetScaleToFitRatio,ThirdAssetScaleToFitRatio);
                [ThirdlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(ThirdAssetTrack.preferredTransform, ThirdAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:time];
            }
            //3rd Track End**************************
        }
        
        AVMutableVideoCompositionLayerInstruction *FourthlayerInstruction;
        if(_movieClipsCount >= 4){
            time = CMTimeAdd(time, asset3.duration);
            [ThirdlayerInstruction setOpacity:0.0 atTime:time];
            
            //4th Track Start**************************
            FourthlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:fourthTrack];
            AVAssetTrack *FourthAssetTrack = [[asset3 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            UIImageOrientation FourthAssetOrientation_  = UIImageOrientationUp;
            BOOL  isFourthAssetPortrait_  = NO;
            CGAffineTransform fourthTransform = FourthAssetTrack.preferredTransform;
            if(fourthTransform.a == 0 && fourthTransform.b == 1.0 && fourthTransform.c == -1.0 && fourthTransform.d == 0)  {FourthAssetOrientation_= UIImageOrientationRight; isFourthAssetPortrait_ = YES;}
            if(fourthTransform.a == 0 && fourthTransform.b == -1.0 && fourthTransform.c == 1.0 && fourthTransform.d == 0)  {FourthAssetOrientation_ =  UIImageOrientationLeft; isFourthAssetPortrait_ = YES;}
            if(fourthTransform.a == 1.0 && fourthTransform.b == 0 && fourthTransform.c == 0 && fourthTransform.d == 1.0)   {FourthAssetOrientation_ =  UIImageOrientationUp;}
            if(fourthTransform.a == -1.0 && fourthTransform.b == 0 && fourthTransform.c == 0 && fourthTransform.d == -1.0) {FourthAssetOrientation_ = UIImageOrientationDown;}
            CGFloat FourthAssetScaleToFitRatio = 320.0/FourthAssetTrack.naturalSize.width;
            if(isFourthAssetPortrait_){
                FourthAssetScaleToFitRatio = 320.0/FourthAssetTrack.naturalSize.height;
                CGAffineTransform FourthAssetScaleFactor = CGAffineTransformMakeScale(FourthAssetScaleToFitRatio,FourthAssetScaleToFitRatio);
                [FourthlayerInstruction setTransform:CGAffineTransformConcat(FourthAssetTrack.preferredTransform, FourthAssetScaleFactor) atTime:time];
            }else{
                ;
                CGAffineTransform FourthAssetScaleFactor = CGAffineTransformMakeScale(FourthAssetScaleToFitRatio,FourthAssetScaleToFitRatio);
                [FourthlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(FourthAssetTrack.preferredTransform, FourthAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:time];
            }
            //4th Track End**************************
        }
        
        AVMutableVideoCompositionLayerInstruction *FifthlayerInstruction;
        if(_movieClipsCount >= 5){
            time = CMTimeAdd(time, asset4.duration);
            [FourthlayerInstruction setOpacity:0.0 atTime:time];
            
            //5th Track Start**************************
            FifthlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:fifthTrack];
            AVAssetTrack *FifthAssetTrack = [[asset3 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            UIImageOrientation FifthAssetOrientation_  = UIImageOrientationUp;
            BOOL  isFifthAssetPortrait_  = NO;
            CGAffineTransform fifthTransform = FifthAssetTrack.preferredTransform;
            if(fifthTransform.a == 0 && fifthTransform.b == 1.0 && fifthTransform.c == -1.0 && fifthTransform.d == 0)  {FifthAssetOrientation_= UIImageOrientationRight; isFifthAssetPortrait_ = YES;}
            if(fifthTransform.a == 0 && fifthTransform.b == -1.0 && fifthTransform.c == 1.0 && fifthTransform.d == 0)  {FifthAssetOrientation_ =  UIImageOrientationLeft; isFifthAssetPortrait_ = YES;}
            if(fifthTransform.a == 1.0 && fifthTransform.b == 0 && fifthTransform.c == 0 && fifthTransform.d == 1.0)   {FifthAssetOrientation_ =  UIImageOrientationUp;}
            if(fifthTransform.a == -1.0 && fifthTransform.b == 0 && fifthTransform.c == 0 && fifthTransform.d == -1.0) {FifthAssetOrientation_ = UIImageOrientationDown;}
            CGFloat FifthAssetScaleToFitRatio = 320.0/FifthAssetTrack.naturalSize.width;
            if(isFifthAssetPortrait_){
                FifthAssetScaleToFitRatio = 320.0/FifthAssetTrack.naturalSize.height;
                CGAffineTransform FifthAssetScaleFactor = CGAffineTransformMakeScale(FifthAssetScaleToFitRatio,FifthAssetScaleToFitRatio);
                [FifthlayerInstruction setTransform:CGAffineTransformConcat(FifthAssetTrack.preferredTransform, FifthAssetScaleFactor) atTime:time];
            }else{
                ;
                CGAffineTransform FifthAssetScaleFactor = CGAffineTransformMakeScale(FifthAssetScaleToFitRatio,FifthAssetScaleToFitRatio);
                [FifthlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(FifthAssetTrack.preferredTransform, FifthAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:time];
            }
            //5th Track End**************************
        }
        
        AVMutableVideoCompositionLayerInstruction *SixthlayerInstruction;
        if(_movieClipsCount >= 6){
            time = CMTimeAdd(time, asset5.duration);
            [FifthlayerInstruction setOpacity:0.0 atTime:time];
            
            //6th Track Start**************************
            SixthlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:sixthTrack];
            AVAssetTrack *SixthAssetTrack = [[asset3 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            UIImageOrientation SixthAssetOrientation_  = UIImageOrientationUp;
            BOOL  isSixthAssetPortrait_  = NO;
            CGAffineTransform sixthTransform = SixthAssetTrack.preferredTransform;
            if(sixthTransform.a == 0 && sixthTransform.b == 1.0 && sixthTransform.c == -1.0 && sixthTransform.d == 0)  {SixthAssetOrientation_= UIImageOrientationRight; isSixthAssetPortrait_ = YES;}
            if(sixthTransform.a == 0 && sixthTransform.b == -1.0 && sixthTransform.c == 1.0 && sixthTransform.d == 0)  {SixthAssetOrientation_ =  UIImageOrientationLeft; isSixthAssetPortrait_ = YES;}
            if(sixthTransform.a == 1.0 && sixthTransform.b == 0 && sixthTransform.c == 0 && sixthTransform.d == 1.0)   {SixthAssetOrientation_ =  UIImageOrientationUp;}
            if(sixthTransform.a == -1.0 && sixthTransform.b == 0 && sixthTransform.c == 0 && sixthTransform.d == -1.0) {SixthAssetOrientation_ = UIImageOrientationDown;}
            CGFloat SixthAssetScaleToFitRatio = 320.0/SixthAssetTrack.naturalSize.width;
            if(isSixthAssetPortrait_){
                SixthAssetScaleToFitRatio = 320.0/SixthAssetTrack.naturalSize.height;
                CGAffineTransform SixthAssetScaleFactor = CGAffineTransformMakeScale(SixthAssetScaleToFitRatio,SixthAssetScaleToFitRatio);
                [SixthlayerInstruction setTransform:CGAffineTransformConcat(SixthAssetTrack.preferredTransform, SixthAssetScaleFactor) atTime:time];
            }else{
                ;
                CGAffineTransform SixthAssetScaleFactor = CGAffineTransformMakeScale(SixthAssetScaleToFitRatio,SixthAssetScaleToFitRatio);
                [SixthlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(SixthAssetTrack.preferredTransform, SixthAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:time];
            }
            //6th Track End**************************
        }
        
        AVMutableVideoCompositionLayerInstruction *SeventhlayerInstruction;
        if(_movieClipsCount >= 7){
            time = CMTimeAdd(time, asset6.duration);
            [SixthlayerInstruction setOpacity:0.0 atTime:time];
            
            //7th Track Start**************************
            SeventhlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:seventhTrack];
            AVAssetTrack *SeventhAssetTrack = [[asset3 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            UIImageOrientation SeventhAssetOrientation_  = UIImageOrientationUp;
            BOOL  isSeventhAssetPortrait_  = NO;
            CGAffineTransform seventhTransform = SeventhAssetTrack.preferredTransform;
            if(seventhTransform.a == 0 && seventhTransform.b == 1.0 && seventhTransform.c == -1.0 && seventhTransform.d == 0)  {SeventhAssetOrientation_= UIImageOrientationRight; isSeventhAssetPortrait_ = YES;}
            if(seventhTransform.a == 0 && seventhTransform.b == -1.0 && seventhTransform.c == 1.0 && seventhTransform.d == 0)  {SeventhAssetOrientation_ =  UIImageOrientationLeft; isSeventhAssetPortrait_ = YES;}
            if(seventhTransform.a == 1.0 && seventhTransform.b == 0 && seventhTransform.c == 0 && seventhTransform.d == 1.0)   {SeventhAssetOrientation_ =  UIImageOrientationUp;}
            if(seventhTransform.a == -1.0 && seventhTransform.b == 0 && seventhTransform.c == 0 && seventhTransform.d == -1.0) {SeventhAssetOrientation_ = UIImageOrientationDown;}
            CGFloat SeventhAssetScaleToFitRatio = 320.0/SeventhAssetTrack.naturalSize.width;
            if(isSeventhAssetPortrait_){
                SeventhAssetScaleToFitRatio = 320.0/SeventhAssetTrack.naturalSize.height;
                CGAffineTransform SeventhAssetScaleFactor = CGAffineTransformMakeScale(SeventhAssetScaleToFitRatio,SeventhAssetScaleToFitRatio);
                [SeventhlayerInstruction setTransform:CGAffineTransformConcat(SeventhAssetTrack.preferredTransform, SeventhAssetScaleFactor) atTime:time];
            }else{
                ;
                CGAffineTransform SeventhAssetScaleFactor = CGAffineTransformMakeScale(SeventhAssetScaleToFitRatio,SeventhAssetScaleToFitRatio);
                [SeventhlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(SeventhAssetTrack.preferredTransform, SeventhAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:time];
            }
            //7th Track End**************************
        }
        
        AVMutableVideoCompositionLayerInstruction *EighthlayerInstruction;
        if(_movieClipsCount >= 8){
            time = CMTimeAdd(time, asset7.duration);
            [SeventhlayerInstruction setOpacity:0.0 atTime:time];
            
            //8th Track Start**************************
            EighthlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:eighthTrack];
            AVAssetTrack *EighthAssetTrack = [[asset3 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            UIImageOrientation EighthAssetOrientation_  = UIImageOrientationUp;
            BOOL  isEighthAssetPortrait_  = NO;
            CGAffineTransform eighthTransform = EighthAssetTrack.preferredTransform;
            if(eighthTransform.a == 0 && eighthTransform.b == 1.0 && eighthTransform.c == -1.0 && eighthTransform.d == 0)  {EighthAssetOrientation_= UIImageOrientationRight; isEighthAssetPortrait_ = YES;}
            if(eighthTransform.a == 0 && eighthTransform.b == -1.0 && eighthTransform.c == 1.0 && eighthTransform.d == 0)  {EighthAssetOrientation_ =  UIImageOrientationLeft; isEighthAssetPortrait_ = YES;}
            if(eighthTransform.a == 1.0 && eighthTransform.b == 0 && eighthTransform.c == 0 && eighthTransform.d == 1.0)   {EighthAssetOrientation_ =  UIImageOrientationUp;}
            if(eighthTransform.a == -1.0 && eighthTransform.b == 0 && eighthTransform.c == 0 && eighthTransform.d == -1.0) {EighthAssetOrientation_ = UIImageOrientationDown;}
            CGFloat EighthAssetScaleToFitRatio = 320.0/EighthAssetTrack.naturalSize.width;
            if(isEighthAssetPortrait_){
                EighthAssetScaleToFitRatio = 320.0/EighthAssetTrack.naturalSize.height;
                CGAffineTransform EighthAssetScaleFactor = CGAffineTransformMakeScale(EighthAssetScaleToFitRatio,EighthAssetScaleToFitRatio);
                [EighthlayerInstruction setTransform:CGAffineTransformConcat(EighthAssetTrack.preferredTransform, EighthAssetScaleFactor) atTime:time];
            }else{
                ;
                CGAffineTransform EighthAssetScaleFactor = CGAffineTransformMakeScale(EighthAssetScaleToFitRatio,EighthAssetScaleToFitRatio);
                [EighthlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(EighthAssetTrack.preferredTransform, EighthAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:time];
            }
            //8th Track End**************************
        }
        
        
        AVMutableVideoCompositionLayerInstruction *NinthlayerInstruction;
        if(_movieClipsCount >= 9){
            time = CMTimeAdd(time, asset8.duration);
            [EighthlayerInstruction setOpacity:0.0 atTime:time];
            
            //9th Track Start**************************
            NinthlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:ninthTrack];
            AVAssetTrack *NinthAssetTrack = [[asset3 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            UIImageOrientation NinthAssetOrientation_  = UIImageOrientationUp;
            BOOL  isNinthAssetPortrait_  = NO;
            CGAffineTransform ninthTransform = NinthAssetTrack.preferredTransform;
            if(ninthTransform.a == 0 && ninthTransform.b == 1.0 && ninthTransform.c == -1.0 && ninthTransform.d == 0)  {NinthAssetOrientation_= UIImageOrientationRight; isNinthAssetPortrait_ = YES;}
            if(ninthTransform.a == 0 && ninthTransform.b == -1.0 && ninthTransform.c == 1.0 && ninthTransform.d == 0)  {NinthAssetOrientation_ =  UIImageOrientationLeft; isNinthAssetPortrait_ = YES;}
            if(ninthTransform.a == 1.0 && ninthTransform.b == 0 && ninthTransform.c == 0 && ninthTransform.d == 1.0)   {NinthAssetOrientation_ =  UIImageOrientationUp;}
            if(ninthTransform.a == -1.0 && ninthTransform.b == 0 && ninthTransform.c == 0 && ninthTransform.d == -1.0) {NinthAssetOrientation_ = UIImageOrientationDown;}
            CGFloat NinthAssetScaleToFitRatio = 320.0/NinthAssetTrack.naturalSize.width;
            if(isNinthAssetPortrait_){
                NinthAssetScaleToFitRatio = 320.0/NinthAssetTrack.naturalSize.height;
                CGAffineTransform NinthAssetScaleFactor = CGAffineTransformMakeScale(NinthAssetScaleToFitRatio,NinthAssetScaleToFitRatio);
                [NinthlayerInstruction setTransform:CGAffineTransformConcat(NinthAssetTrack.preferredTransform, NinthAssetScaleFactor) atTime:time];
            }else{
                ;
                CGAffineTransform NinthAssetScaleFactor = CGAffineTransformMakeScale(NinthAssetScaleToFitRatio,NinthAssetScaleToFitRatio);
                [NinthlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(NinthAssetTrack.preferredTransform, NinthAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:time];
            }
            //9th Track End**************************
        }
        
        
        AVMutableVideoCompositionLayerInstruction *TenthlayerInstruction;
        if(_movieClipsCount >= 10){
            time = CMTimeAdd(time, asset9.duration);
            [NinthlayerInstruction setOpacity:0.0 atTime:time];
            
            //10th Track Start**************************
            TenthlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:tenthTrack];
            AVAssetTrack *TenthAssetTrack = [[asset3 tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
            UIImageOrientation TenthAssetOrientation_  = UIImageOrientationUp;
            BOOL  isTenthAssetPortrait_  = NO;
            CGAffineTransform tenthTransform = TenthAssetTrack.preferredTransform;
            if(tenthTransform.a == 0 && tenthTransform.b == 1.0 && tenthTransform.c == -1.0 && tenthTransform.d == 0)  {TenthAssetOrientation_= UIImageOrientationRight; isTenthAssetPortrait_ = YES;}
            if(tenthTransform.a == 0 && tenthTransform.b == -1.0 && tenthTransform.c == 1.0 && tenthTransform.d == 0)  {TenthAssetOrientation_ =  UIImageOrientationLeft; isTenthAssetPortrait_ = YES;}
            if(tenthTransform.a == 1.0 && tenthTransform.b == 0 && tenthTransform.c == 0 && tenthTransform.d == 1.0)   {TenthAssetOrientation_ =  UIImageOrientationUp;}
            if(tenthTransform.a == -1.0 && tenthTransform.b == 0 && tenthTransform.c == 0 && tenthTransform.d == -1.0) {TenthAssetOrientation_ = UIImageOrientationDown;}
            CGFloat TenthAssetScaleToFitRatio = 320.0/TenthAssetTrack.naturalSize.width;
            if(isTenthAssetPortrait_){
                TenthAssetScaleToFitRatio = 320.0/TenthAssetTrack.naturalSize.height;
                CGAffineTransform TenthAssetScaleFactor = CGAffineTransformMakeScale(TenthAssetScaleToFitRatio,TenthAssetScaleToFitRatio);
                [TenthlayerInstruction setTransform:CGAffineTransformConcat(TenthAssetTrack.preferredTransform, TenthAssetScaleFactor) atTime:time];
            }else{
                ;
                CGAffineTransform TenthAssetScaleFactor = CGAffineTransformMakeScale(TenthAssetScaleToFitRatio,TenthAssetScaleToFitRatio);
                [TenthlayerInstruction setTransform:CGAffineTransformConcat(CGAffineTransformConcat(TenthAssetTrack.preferredTransform, TenthAssetScaleFactor),CGAffineTransformMakeTranslation(0, 160)) atTime:time];
            }
            //10th Track End**************************
        }
        
        
        
        
        
        
        
        if(_movieClipsCount==2)MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,nil];
        else if(_movieClipsCount==3)MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,ThirdlayerInstruction,nil];
        else if(_movieClipsCount==4)MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,ThirdlayerInstruction, FourthlayerInstruction, nil];
        else if(_movieClipsCount==5)MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,ThirdlayerInstruction, FourthlayerInstruction, FifthlayerInstruction, nil];
        else if(_movieClipsCount==6)MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,ThirdlayerInstruction, FourthlayerInstruction, FifthlayerInstruction,SixthlayerInstruction, nil];
        else if(_movieClipsCount==7)MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,ThirdlayerInstruction, FourthlayerInstruction, FifthlayerInstruction,SixthlayerInstruction, SeventhlayerInstruction, nil];
        else if(_movieClipsCount==8)MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,ThirdlayerInstruction, FourthlayerInstruction, FifthlayerInstruction, SixthlayerInstruction, SeventhlayerInstruction, EighthlayerInstruction, nil];
        else if(_movieClipsCount==9)MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,ThirdlayerInstruction, FourthlayerInstruction, FifthlayerInstruction, SixthlayerInstruction, SeventhlayerInstruction, EighthlayerInstruction, NinthlayerInstruction, nil];
        else if(_movieClipsCount==10)MainInstruction.layerInstructions = [NSArray arrayWithObjects:FirstlayerInstruction,SecondlayerInstruction,ThirdlayerInstruction, FourthlayerInstruction, FifthlayerInstruction, SixthlayerInstruction, SeventhlayerInstruction, EighthlayerInstruction, NinthlayerInstruction, TenthlayerInstruction, nil];
        
        AVMutableVideoComposition *MainCompositionInst = [AVMutableVideoComposition videoComposition];
        MainCompositionInst.instructions = [NSArray arrayWithObject:MainInstruction];
        MainCompositionInst.frameDuration = CMTimeMake(1, 30);
        MainCompositionInst.renderSize = CGSizeMake(320.0, 480.0);
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo-%d.mov",arc4random() % 1000]];
        
        NSURL *url = [NSURL fileURLWithPath:myPathDocs];
        
        AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
        exporter.outputURL=url;
        
        exporter.outputFileType = AVFileTypeQuickTimeMovie;
        exporter.videoComposition = MainCompositionInst;
        exporter.shouldOptimizeForNetworkUse = YES;
        NSLog(@"exporter.outputURL: %@",exporter.outputURL);
        [exporter exportAsynchronouslyWithCompletionHandler:^
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self exportDidFinish:exporter];
             });
         }];
    }
    //[_assetArray removeAllObjects];
}
- (void)exportDidFinish:(AVAssetExportSession*)session
{
    NSLog(@"exporterDidFinish Start************");
    if(session.status == AVAssetExportSessionStatusCompleted){
        NSURL *outputURL = session.outputURL;
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
            [library writeVideoAtPathToSavedPhotosAlbum:outputURL
                                        completionBlock:^(NSURL *assetURL, NSError *error){
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                if (error) {
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
                                                    [alert show];
                                                }else{
                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                                    [alert show];
                                                    _vidSaved = YES;
                                                    //asset1 = [AVAsset assetWithURL:outputURL];
                                                    //[self MergeAndSave];
                                                }
                                                
                                            });
                                            
                                        }];
        }
    }
	
    //audioAsset = nil;
    //asset1 = nil;
    //asset2 = nil;
    [ActivityView stopAnimating];
}
@end
