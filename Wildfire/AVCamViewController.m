/*
 File: AVCamViewController.m
 Abstract: View controller for camera interface.
 Version: 3.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "AVCamViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "AVCamPreviewView.h"
#import "PhotoEditViewController.h"
#import "MoviePlayerViewController.h"
#import "AudioPlayerViewController.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface AVCamViewController () <AVCaptureFileOutputRecordingDelegate>

// For use in the storyboards.
@property (nonatomic, weak) IBOutlet AVCamPreviewView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (nonatomic, weak) IBOutlet UIButton *stillButton;

- (IBAction)toggleMovieRecording:(id)sender;
- (IBAction)changeCamera:(id)sender;
- (IBAction)snapStillImage:(id)sender;
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

//Merge Videos Class
@property (nonatomic) MergeVideo *mergeVideoTest;
@property(nonatomic) int movieClipsCount;

@end

@implementation AVCamViewController

- (BOOL)isSessionRunningAndDeviceAuthorized
{
	return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
	return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Create the AVCaptureSession
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	[self setSession:session];
	
	// Setup the preview view
	[[self previewView] setSession:session];
	
	// Check for device authorization
	[self checkDeviceAuthorizationStatus];
	
	// In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
	// Why not do all of this on the main queue?
	// -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
	
	dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
	[self setSessionQueue:sessionQueue];
	
	dispatch_async(sessionQueue, ^{
		[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
		
		NSError *error = nil;
		
		AVCaptureDevice *videoDevice = [AVCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		
		if (error)
		{
			NSLog(@"%@", error);
		}
		
		if ([session canAddInput:videoDeviceInput])
		{
			[session addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
            
			dispatch_async(dispatch_get_main_queue(), ^{
				// Why are we dispatching this to the main queue?
				// Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
				// Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
				[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
			});
		}
		
		AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
		AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
		
		if (error)
		{
			NSLog(@"%@", error);
		}
		
		if ([session canAddInput:audioDeviceInput])
		{
			[session addInput:audioDeviceInput];
		}
		
		AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
		if ([session canAddOutput:movieFileOutput])
		{
			[session addOutput:movieFileOutput];
			AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
			if ([connection isVideoStabilizationSupported])
				[connection setEnablesVideoStabilizationWhenAvailable:YES];
			[self setMovieFileOutput:movieFileOutput];
		}
		
		AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
		if ([session canAddOutput:stillImageOutput])
		{
			[stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
			[session addOutput:stillImageOutput];
			[self setStillImageOutput:stillImageOutput];
		}
	});
    
    
    //Sound Recorder Code Start***********************
    NSArray *dirPaths;
    NSString *docsDir;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    
    NSString *soundFilePath = [docsDir
                               stringByAppendingPathComponent:@"sound.caf"];
    
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath];
    
    NSDictionary *recordSettings = [NSDictionary
                                    dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin],
                                    AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:16],
                                    AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: 2],
                                    AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:44100.0],
                                    AVSampleRateKey,
                                    nil];
    
    NSError *error = nil;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord
                        error:nil];
    
    _audioRecorder = [[AVAudioRecorder alloc]
                      initWithURL:soundFileURL
                      settings:recordSettings
                      error:&error];
    
    if (error)
    {
        NSLog(@"error: %@", [error localizedDescription]);
    } else {
        [_audioRecorder prepareToRecord];
    }
    //Sound Recorder Code End**********************
    
    [self setLibraryThumbnail];//Sets image of library button to thumbnail of last video or image taken.
    
    _mergeVideoTest = [[MergeVideo alloc]init];
    _movieClipsCount = 0;
    
    _testMergeButtonOutlet.hidden = YES;
    _photoLibraryOutlet.hidden = NO;
    _removeLastClipOutlet.hidden = YES;
    _cameraButton.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
	dispatch_async([self sessionQueue], ^{
		[self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
		[self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
		[self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		
		__weak AVCamViewController *weakSelf = self;
		[self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
			AVCamViewController *strongSelf = weakSelf;
			dispatch_async([strongSelf sessionQueue], ^{
				// Manually restarting the session since it must have been stopped due to an error.
				[[strongSelf session] startRunning];
				[[strongSelf recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
			});
		}]];
		[[self session] startRunning];
	});
    
    audioIsRecording = NO;
    
    NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: .3f target: self selector: @selector(mainLoop:) userInfo: nil repeats: YES];
    
    [self setLibraryThumbnail];//Sets image of library button to thumbnail of last video or image taken.
    
    _mergeVideoTest = [[MergeVideo alloc]init];
    _movieClipsCount = 0;
    
    _testMergeButtonOutlet.hidden = YES;
    _photoLibraryOutlet.hidden = NO;
    _removeLastClipOutlet.hidden = YES;
    _cameraButton.hidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
	dispatch_async([self sessionQueue], ^{
		[[self session] stopRunning];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
		[[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
		
		[self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
		[self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
		[self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
	});
    
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (BOOL)shouldAutorotate
{
	// Disable autorotation of the interface when recording is in progress.
	return ![self lockInterfaceRotation];
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CapturingStillImageContext)
	{
		BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
		
		if (isCapturingStillImage)
		{
			[self runStillImageCaptureAnimation];
		}
	}
	else if (context == RecordingContext)
	{
		BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (isRecording)
			{
				[[self cameraButton] setEnabled:NO];
				[[self recordButton] setTitle:NSLocalizedString(@"Stop", @"Recording button stop title") forState:UIControlStateNormal];
				[[self recordButton] setEnabled:YES];
			}
			else
			{
				[[self cameraButton] setEnabled:YES];
				[[self recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
				[[self recordButton] setEnabled:YES];
			}
		});
	}
	else if (context == SessionRunningAndDeviceAuthorizedContext)
	{
		BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (isRunning)
			{
				[[self cameraButton] setEnabled:YES];
				[[self recordButton] setEnabled:YES];
				[[self stillButton] setEnabled:YES];
			}
			else
			{
				[[self cameraButton] setEnabled:NO];
				[[self recordButton] setEnabled:NO];
				[[self stillButton] setEnabled:NO];
			}
		});
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark Actions

- (IBAction)toggleMovieRecording:(id)sender
{
	/*[[self recordButton] setEnabled:NO];
     
     if(_recordingFormatToggleOutlet.selectedSegmentIndex==1){
     dispatch_async([self sessionQueue], ^{
     if (![[self movieFileOutput] isRecording])
     {
     [self setLockInterfaceRotation:YES];
     
     if ([[UIDevice currentDevice] isMultitaskingSupported])
     {
     // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
     [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
     }
     
     // Update the orientation on the movie file output video connection before starting recording.
     [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
     
     // Turning OFF flash for video recording
     [AVCamViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
     
     // Start recording to a temporary file.
     NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
     [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
     
     }
     else
     {
     [[self movieFileOutput] stopRecording];
     
     }
     });
     }*/
}

- (IBAction)changeCamera:(id)sender
{
	[[self cameraButton] setEnabled:NO];
	[[self recordButton] setEnabled:NO];
	[[self stillButton] setEnabled:NO];
	
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
		AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
		AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
		
		switch (currentPosition)
		{
			case AVCaptureDevicePositionUnspecified:
				preferredPosition = AVCaptureDevicePositionBack;
				break;
			case AVCaptureDevicePositionBack:
				preferredPosition = AVCaptureDevicePositionFront;
				break;
			case AVCaptureDevicePositionFront:
				preferredPosition = AVCaptureDevicePositionBack;
				break;
		}
		
		AVCaptureDevice *videoDevice = [AVCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
		
		[[self session] beginConfiguration];
		
		[[self session] removeInput:[self videoDeviceInput]];
		if ([[self session] canAddInput:videoDeviceInput])
		{
			[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
			
			[AVCamViewController setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
			
			[[self session] addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
		}
		else
		{
			[[self session] addInput:[self videoDeviceInput]];
		}
		
		[[self session] commitConfiguration];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[[self cameraButton] setEnabled:YES];
			[[self recordButton] setEnabled:YES];
			[[self stillButton] setEnabled:YES];
		});
	});
}

- (IBAction)snapStillImage:(id)sender
{
    /*if(_recordingFormatToggleOutlet.selectedSegmentIndex==0){
     dispatch_async([self sessionQueue], ^{
     // Update the orientation on the still image output video connection before capturing.
     [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
     
     // Flash set to Auto for Still Capture
     [AVCamViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
     
     // Capture a still image.
     [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
     
     if (imageDataSampleBuffer)
     {
     NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
     UIImage *image = [[UIImage alloc] initWithData:imageData];
     
     
     
     [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
     
     NSLog(@"Did Save Picture");
     
     //Pushing to Photo Screen
     NSLog(@"Pushing to Photo Screen");
     PhotoEditViewController *photoEditController = [self.storyboard instantiateViewControllerWithIdentifier:@"photoEditScreen"];
     photoEditController.capturedPic = imageData;
     [self.navigationController pushViewController:photoEditController animated:YES];
     
     
     
     
     
     }
     }];
     });
     }*/
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
	CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
	[self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
	CGPoint devicePoint = CGPointMake(.5, .5);
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}



-(void) mainLoop:(NSTimer*) t
{
    
    if([[self movieFileOutput] isRecording]){
        NSString *appFile;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        float recDur = CMTimeGetSeconds( _movieFileOutput.recordedDuration);
        for(int i = 1;i<=_movieClipsCount;i++){
            if(i == 1)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile1.MOV"];
            else if(i == 2)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile2.MOV"];
            else if(i == 3)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile3.MOV"];
            else if(i == 4)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile4.MOV"];
            else if(i == 5)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile5.MOV"];
            else if(i == 6)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile6.MOV"];
            else if(i == 7)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile7.MOV"];
            else if(i == 8)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile8.MOV"];
            else if(i == 9)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile9.MOV"];
            else if(i == 10)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile10.MOV"];
            
            NSURL *movieUrl = [NSURL fileURLWithPath:appFile];
            AVAsset* tempAsset = [AVAsset assetWithURL:movieUrl];
            recDur += CMTimeGetSeconds(tempAsset.duration);
        }
        NSLog(@"Recording duration: %f",recDur);
        
        if(recDur>10.0f){
            NSLog(@"Stop Rec");
            [self recordAction:nil];
        }
        
    }
    
    if(_mergeVideoTest.vidSaved && ![[self movieFileOutput]isRecording])
    {
        _mergeVideoTest.vidSaved = NO;
        _movieClipsCount = 0;
        [self pushLastVideoToMoviePlayerViewController];
        
    }
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput willFinishRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections error:(NSError *)error{
    
}

#pragma mark File Output Delegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
	if (error){
		NSLog(@"%@", error);
        NSLog(@"Error: 8896285");
    }
	
	[self setLockInterfaceRotation:NO];
	
	// Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
	UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
	[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    
    NSString *appFile;
	NSData *testData = [[NSData alloc]initWithContentsOfURL:outputFileURL];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    if(_movieClipsCount == 0)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile1.MOV"];
    if(_movieClipsCount == 1)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile2.MOV"];
    if(_movieClipsCount == 2)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile3.MOV"];
    if(_movieClipsCount == 3)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile4.MOV"];
    if(_movieClipsCount == 4)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile5.MOV"];
    if(_movieClipsCount == 5)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile6.MOV"];
    if(_movieClipsCount == 6)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile7.MOV"];
    if(_movieClipsCount == 7)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile8.MOV"];
    if(_movieClipsCount == 8)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile9.MOV"];
    if(_movieClipsCount == 9)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile10.MOV"];
    
    _movieClipsCount++;
    if(_movieClipsCount>=5){
        _captureButtonOutlet.hidden=YES;
        _movieClipsCount = 5;
    }
    _testMergeButtonOutlet.hidden=NO;
    _removeLastClipOutlet.hidden=NO;
    
    [testData writeToFile:appFile atomically:YES];
    //NSURL *movieUrl = [NSURL fileURLWithPath:appFile];
    
    
    
    
    //_mergeVideoTest.firstAsset = [AVAsset assetWithURL:movieUrl];
    //_mergeVideoTest.secondAsset = [AVAsset assetWithURL:movieUrl];
    //[_mergeVideoTest.assetArray removeAllObjects];
    
    //[_mergeVideoTest.assetArray addObject:[AVAsset assetWithURL:movieUrl]];
    //[_mergeVideoTest.assetArray addObject:[AVAsset assetWithURL:movieUrl]];
    //[_mergeVideoTest.assetArray addObject:[AVAsset assetWithURL:movieUrl]];
    [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
    //[_mergeVideoTest MergeAndSave];
    
	//[[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
    //if (error)
    //NSLog(@"%@", error);
    
    
    
    
    
    
    if (backgroundRecordingID != UIBackgroundTaskInvalid)
        [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
    
    
    
    
    
    //NSLog(@"Did Save Video");
    
    
    
    /*
     //Search for video Start*******************************************
     __block NSData *tempData;
     __block ALAssetRepresentation *representation;
     
     ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
     [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
     [group enumerateAssetsUsingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop)
     {
     if (alAsset)
     {
     representation =[alAsset defaultRepresentation];
     
     
     
     NSURL *url = [representation url];
     NSString *assetType=[alAsset valueForProperty:ALAssetPropertyType];
     //UIImage *thumbNailImage=[UIImage imageWithCGImage:alAsset.thumbnail];
     
     //if([assetType  isEqual: @"ALAssetTypeVideo"] && url != nil){
     //_videoURL= url;
     //NSLog(@"This is %@: ",_videoURL);
     //}
     }
     }];
     if(group==nil)
     {
     Byte *buffer = (Byte*)malloc(representation.size);
     NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:representation.size error:nil];
     tempData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
     
     NSLog(@"Pushing to Video Screen");
     MoviePlayerViewController *moviePlayerController = [self.storyboard instantiateViewControllerWithIdentifier:@"moviePlayerScreen"];
     moviePlayerController.tempData = tempData;
     [self.navigationController pushViewController:moviePlayerController animated:YES];
     //NSLog(@"Output File URL***********************: %@", outputFileURL);
     }
     } failureBlock: ^(NSError *error)
     {
     // may be photo privacy setting disabled
     }
     ];
     */
    
    //Search for video End*****************************
    
    
    
	//}];
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *device = [[self videoDeviceInput] device];
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
			{
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
			{
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	});
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
	if ([device hasFlash] && [device isFlashModeSupported:flashMode])
	{
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			[device setFlashMode:flashMode];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	}
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == position)
		{
			captureDevice = device;
			break;
		}
	}
	
	return captureDevice;
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[[self previewView] layer] setOpacity:0.0];
		[UIView animateWithDuration:.25 animations:^{
			[[[self previewView] layer] setOpacity:1.0];
		}];
	});
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted)
		{
			//Granted access to mediaType
			[self setDeviceAuthorized:YES];
		}
		else
		{
			//Not granted access to mediaType
			dispatch_async(dispatch_get_main_queue(), ^{
				[[[UIAlertView alloc] initWithTitle:@"AVCam!"
											message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
				[self setDeviceAuthorized:NO];
			});
		}
	}];
}

- (IBAction)testButton:(id)sender {
    /* //SignUpViewController *signUpController = [self.storyboard instantiateViewControllerWithIdentifier:@"signUpScreen"];
     // [self.navigationController pushViewController:signUpController animated:NO];
     
     PhotoEditViewController *photoEditController = [self.storyboard instantiateViewControllerWithIdentifier:@"photoEditScreen"];
     //photoEditController.mainImageView.image = [UIImage imageWithData:_capturedPic];
     photoEditController.capturedPic = _capturedPic;
     [self.navigationController pushViewController:photoEditController animated:YES];
     NSLog(@"Test Button Pressed");*/
    NSLog(@"Recording Format Toggle = %i",_recordingFormatToggleOutlet.selectedSegmentIndex);
}

- (IBAction)videoTestButton:(id)sender {
    /* MoviePlayerViewController *moviePlayerController = [self.storyboard instantiateViewControllerWithIdentifier:@"moviePlayerScreen"];
     
     [self.navigationController pushViewController:moviePlayerController animated:YES];*/
}

- (IBAction)recordAudioAction:(id)sender {
    /*if(_recordingFormatToggleOutlet.selectedSegmentIndex==0){
     if([_recordAudioOutlet.titleLabel.text  isEqualToString: @"Record Audio"]){
     [_recordAudioOutlet setTitle:@"Stop Rec" forState:UIControlStateNormal];
     NSLog(@"Recording");
     [_audioRecorder record];
     }else{
     [_recordAudioOutlet setTitle:@"Record Audio" forState:UIControlStateNormal];
     NSLog(@"Stoppped Recording");
     [_audioRecorder stop];
     
     //Go to playAudioScreen
     AudioPlayerViewController *audioPlayerController = [self.storyboard instantiateViewControllerWithIdentifier:@"audioPlayerScreen"];
     audioPlayerController.audioUrl = _audioRecorder.url;
     [self.navigationController pushViewController:audioPlayerController animated:YES];
     }
     
     }*/
}

- (IBAction)LoadAudio:(id)sender{
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
    mediaPicker.delegate = self;
    mediaPicker.prompt = @"Select Audio";
    [self presentModalViewController:mediaPicker animated:YES];
}


- (void) mediaPicker: (MPMediaPickerController *) mediaPicker
   didPickMediaItems: (MPMediaItemCollection *) collection {
    
    
    /*MPMediaItem *item = [[collection items] objectAtIndex:0];
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    [self dismissModalViewControllerAnimated: YES];
    
    // Play the item using MPMusicPlayer
    
    MPMusicPlayerController* appMusicPlayer = [MPMusicPlayerController applicationMusicPlayer];
    
    [appMusicPlayer setQueueWithItemCollection:collection];
    [appMusicPlayer play];
    
    
    // Play the item using AVPlayer
    
    NSData* testData = [[NSData alloc] initWithContentsOfURL:url];
    NSLog(@"Audio Data********************: %@",[testData description]);
    
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
   // AVPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    [player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:url]];
    [player play];
    
    [player play];*/
    
    [self dismissViewControllerAnimated:YES completion:nil];
    NSURL* assetUrl = [collection.representativeItem
                       valueForProperty:MPMediaItemPropertyAssetURL];
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:assetUrl options:nil];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithAsset:asset];
    NSLog(@"Asset url: %@",assetUrl);
    AVPlayer * myPlayer = [AVPlayer playerWithPlayerItem:playerItem];
    [myPlayer play];
    
}

/*- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    AudioPlayerViewController *audioPlayerController = [self.storyboard instantiateViewControllerWithIdentifier:@"audioPlayerScreen"];
    
     //NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];//Delete this
    
    NSArray * SelectedSong = [mediaItemCollection items];
    if([SelectedSong count]>0){
        MPMediaItem * SongItem = [SelectedSong objectAtIndex:0];
        //NSURL *SongURL = [SongItem valueForProperty: MPMediaItemPropertyAssetURL];
        NSURL *SongURL =[[SelectedSong objectAtIndex: 0] valueForProperty:MPMediaItemPropertyAssetURL];
        
        NSLog(@"Song URL: %@",SongURL);
        
        //Go to playAudioScreen
        
        _audioAsset = [AVAsset assetWithURL:SongURL];
        
        NSData* testData = [[NSData alloc] initWithContentsOfURL:SongURL];
        NSLog(@"Audio Data********************: %@",[testData description]);
        
        audioPlayerController.audioData = [NSData dataWithContentsOfURL:SongURL];//Storing audio in NSDATA.
        
        NSLog(@"Audio Loaded");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Asset Loaded" message:@"Audio Loaded"  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil, nil];
        [alert show];
    }
    
    [self dismissModalViewControllerAnimated: YES];
    [self.navigationController pushViewController:audioPlayerController animated:YES];
}*/

- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissModalViewControllerAnimated: YES];
}

-(void)recordAudio{
    if(_recordingFormatToggleOutlet.selectedSegmentIndex==2){
        if(audioIsRecording == NO){
            [_recordAudioOutlet setTitle:@"Stop Rec" forState:UIControlStateNormal];
            NSLog(@"Recording");
            [_audioRecorder record];
            audioIsRecording = YES;
        }else{
            [_recordAudioOutlet setTitle:@"Record Audio" forState:UIControlStateNormal];
            NSLog(@"Stoppped Recording");
            [_audioRecorder stop];
            audioIsRecording = NO;
            
            //Go to playAudioScreen
            AudioPlayerViewController *audioPlayerController = [self.storyboard instantiateViewControllerWithIdentifier:@"audioPlayerScreen"];
            audioPlayerController.audioData = [NSData dataWithContentsOfURL:_audioRecorder.url];//Storing audio in NSDATA.
            [self.navigationController pushViewController:audioPlayerController animated:YES];
        }
        
    }
    
}

-(void)takePhoto{
    
    __block NSData *imageData;
    __block UIImage *image;

    if(_recordingFormatToggleOutlet.selectedSegmentIndex==0){
        dispatch_async([self sessionQueue], ^{
            // Update the orientation on the still image output video connection before capturing.
            [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
            
            // Flash set to Auto for Still Capture
            [AVCamViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
            
            // Capture a still image.
            [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                
                if (imageDataSampleBuffer)
                {
                    imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                    image = [[UIImage alloc] initWithData:imageData];
                    
                    //UIImage* tempImage = ;
                    
                   
                    
                     //Pushing to Photo Screen
                    NSLog(@"Pushing to Photo Screen");
                    PhotoEditViewController *photoEditController = [self.storyboard instantiateViewControllerWithIdentifier:@"photoEditScreen"];
                    photoEditController.capturedPic = UIImagePNGRepresentation([self cropImage:[self normalizeImage:image]]);
                    [self.navigationController pushViewController:photoEditController animated:YES];
                    
                    [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
                    
                    NSLog(@"Did Save Picture");
                    
                   
                    
                }
            }];
        });
    }
    
}

-(void)recordVideo{
    [[self recordButton] setEnabled:NO];
    
    if(_recordingFormatToggleOutlet.selectedSegmentIndex==1){
        dispatch_async([self sessionQueue], ^{
            if (![[self movieFileOutput] isRecording])
            {
                [self setLockInterfaceRotation:YES];
                
                if ([[UIDevice currentDevice] isMultitaskingSupported])
                {
                    // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
                    [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
                }
                
                // Update the orientation on the movie file output video connection before starting recording.
                [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
                
                // Turning OFF flash for video recording
                [AVCamViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
                
                // Start recording to a temporary file.
                NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
                [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
            }else{
                [[self movieFileOutput] stopRecording];
                
            }
        });
    }
}

- (IBAction)recordAction:(id)sender {
    if(![[self movieFileOutput] isRecording] && [_captureButtonOutlet.currentTitle isEqualToString:@"Record Video"])
    {
        [_captureButtonOutlet setTitle:@"Stop Video" forState:UIControlStateNormal];
        
        _testMergeButtonOutlet.hidden = YES;
        _photoLibraryOutlet.hidden = YES;
        _removeLastClipOutlet.hidden = YES;
        _recordingFormatToggleOutlet.hidden = YES;
        _cameraButton.hidden = YES;
        [self recordVideo];
    }
    else if([[self movieFileOutput] isRecording] && [_captureButtonOutlet.currentTitle isEqualToString:@"Stop Video"]){
        [_captureButtonOutlet setTitle:@"Record Video" forState:UIControlStateNormal];
        
        _testMergeButtonOutlet.hidden = YES;
        _photoLibraryOutlet.hidden = NO;
        _removeLastClipOutlet.hidden = YES;
        _recordingFormatToggleOutlet.hidden = NO;
        _cameraButton.hidden = NO;
        [self recordVideo];
    }
    else if([_captureButtonOutlet.currentTitle isEqualToString:@"Record Audio"]){
        [_captureButtonOutlet setTitle:@"Stop Audio" forState:UIControlStateNormal];
        [self recordAudio];
    }
    else if([_captureButtonOutlet.currentTitle isEqualToString:@"Stop Audio"]){
        [_captureButtonOutlet setTitle:@"Record Audio" forState:UIControlStateNormal];
        [self recordAudio];
    }
    
    [self takePhoto];
    
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeVideo] ||
        [mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        
        // Get the selected Video.
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        // Convert to Video data.
        NSData *imageData = [NSData dataWithContentsOfURL:videoURL];
        // NSLog(@"Vid Data********************: %@",[imageData description]);
        NSLog(@"Picked a Video!");
        
        NSLog(@"Pushing to Video Screen");
        MoviePlayerViewController *moviePlayerController = [self.storyboard instantiateViewControllerWithIdentifier:@"moviePlayerScreen"];
        moviePlayerController.tempData = imageData;
        [self.navigationController pushViewController:moviePlayerController animated:YES];
        
        
        NSURL* localUrl = info[UIImagePickerControllerReferenceURL];// [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"URL***************: %@",localUrl);
        
    }else{
        NSLog(@"Picked a Photo!");
        // [_photoLibraryOutlet setBackgroundImage:[info objectForKey:UIImagePickerControllerEditedImage]forState:UIControlStateNormal];
        //[_photoLibraryOutlet setBackgroundImage:[UIImage imageWithContentsOfFile: @"assets-library://asset/asset.JPG?id=929157AA-8B50-4359-9268-F45B95599EA7&ext=JPG"] forState:UIControlStateNormal];
        //[_photoLibraryOutlet setBackgroundImage:(UIImage*) [info objectForKey:UIImagePickerControllerOriginalImage] forState:UIControlStateNormal];
        
        
        // NSURL* localUrl = info[UIImagePickerControllerReferenceURL];// [info objectForKey:UIImagePickerControllerMediaURL];
        // NSLog(@"URL***************: %@",localUrl);
        
        // NSString *testString = @"assets-library://asset/asset.JPG?id=929157AA-8B50-4359-9268-F45B95599EA7&ext=JPG";
        
        
        // NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:[localUrl path]]];
        PhotoEditViewController *photoEditController = [self.storyboard instantiateViewControllerWithIdentifier:@"photoEditScreen"];
        photoEditController.capturedPic  = UIImageJPEGRepresentation((UIImage*) [info objectForKey:UIImagePickerControllerOriginalImage], 0.7); // 0.7 is JPG quality;
        [self.navigationController pushViewController:photoEditController animated:YES];
    }
    
    
}


/*#pragma mark - Image Picker Delegate
 -(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
 NSURL* localUrl = (NSURL*)[editingInfo valueForKey:UIImagePickerControllerReferenceURL];
 
 [_photoLibraryOutlet setBackgroundImage:[UIImage imageWithContentsOfFile: @"assets-library://asset/asset.JPG?id=929157AA-8B50-4359-9268-F45B95599EA7&ext=JPG"] forState:UIControlStateNormal];
 
 NSLog(@"URL***************: %@",localUrl);
 
 
 
 NSData *data=[NSData dataWithContentsOfURL:[NSURL URLWithString:[localUrl absoluteString]]];
 
 
 PhotoEditViewController *photoEditController = [self.storyboard instantiateViewControllerWithIdentifier:@"photoEditScreen"];
 photoEditController.capturedPic = data;
 [self.navigationController pushViewController:photoEditController animated:YES];
 
 [picker dismissViewControllerAnimated:YES completion:nil];
 
 }*/



-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)picVidPickerAction:(id)sender { UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    
    picker.delegate = self;
    
    picker.allowsEditing = YES;
    
    picker.videoMaximumDuration = 10.0f;
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    picker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:
                         UIImagePickerControllerSourceTypeCamera];
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)testMergeAction:(id)sender {
    NSString *appFile;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *movieUrl;
    _mergeVideoTest.movieClipsCount = _movieClipsCount;
    for(int i = 0;i<_movieClipsCount;i++){
        if(i == 0)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile1.MOV"];
        else if(i == 1)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile2.MOV"];
        else if(i == 2)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile3.MOV"];
        else if(i == 3)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile4.MOV"];
        else if(i == 4)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile5.MOV"];
        else if(i == 5)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile6.MOV"];
        else if(i == 6)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile7.MOV"];
        else if(i == 7)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile8.MOV"];
        else if(i == 8)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile9.MOV"];
        else if(i == 9)appFile = [documentsDirectory stringByAppendingPathComponent:@"myMovieFile10.MOV"];
        movieUrl = [NSURL fileURLWithPath:appFile];
        
        
        if(i == 0)_mergeVideoTest.asset1 = [AVAsset assetWithURL:movieUrl];
        else if(i == 1)_mergeVideoTest.asset2 = [AVAsset assetWithURL:movieUrl];
        else if(i == 2)_mergeVideoTest.asset3 = [AVAsset assetWithURL:movieUrl];
        else if(i == 3)_mergeVideoTest.asset4 = [AVAsset assetWithURL:movieUrl];
        else if(i == 4)_mergeVideoTest.asset5 = [AVAsset assetWithURL:movieUrl];
        else if(i == 5)_mergeVideoTest.asset6 = [AVAsset assetWithURL:movieUrl];
        else if(i == 6)_mergeVideoTest.asset7 = [AVAsset assetWithURL:movieUrl];
        else if(i == 7)_mergeVideoTest.asset8 = [AVAsset assetWithURL:movieUrl];
        else if(i == 8)_mergeVideoTest.asset9 = [AVAsset assetWithURL:movieUrl];
        else if(i == 9)_mergeVideoTest.asset10 = [AVAsset assetWithURL:movieUrl];
        
        //[_mergeVideoTest.assetArray addObject:[AVAsset assetWithURL:movieUrl]];
    }
    
    if (_movieClipsCount == 1) {
        [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:movieUrl completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error)
                NSLog(@"%@", error);
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            
            
        }];
    }else if(_movieClipsCount > 1)[_mergeVideoTest MergeAndSave];
    
    _movieClipsCount = 0;
    
    [self setLibraryThumbnail];
}

- (IBAction)removeLastClip:(id)sender {
    _movieClipsCount--;
    if(_movieClipsCount<=0){
        _movieClipsCount=0;
        _testMergeButtonOutlet.hidden = YES;
        _removeLastClipOutlet.hidden = YES;
    }
    _captureButtonOutlet.hidden = NO;
}

- (IBAction)recordingFormatToggleAction:(id)sender {
    if(_recordingFormatToggleOutlet.selectedSegmentIndex == 0){
        [_captureButtonOutlet setTitle:@"Capture Photo" forState:UIControlStateNormal];
        
        _testMergeButtonOutlet.hidden = YES;
        _photoLibraryOutlet.hidden = NO;
        _removeLastClipOutlet.hidden = YES;
        _cameraButton.hidden = NO;
        _topBlackBarOutlet.hidden = NO;
        _bottomBlackBarOutlet.hidden = NO;
        
        [self LoadAudio:nil];
    }
    else if(_recordingFormatToggleOutlet.selectedSegmentIndex == 1){
        [_captureButtonOutlet setTitle:@"Record Video" forState:UIControlStateNormal];
        
        _testMergeButtonOutlet.hidden = YES;
        _photoLibraryOutlet.hidden = NO;
        _removeLastClipOutlet.hidden = YES;
        _cameraButton.hidden = NO;
        _movieClipsCount = 0;
        
        _topBlackBarOutlet.hidden = YES;
        _bottomBlackBarOutlet.hidden = YES;
    }
    else if(_recordingFormatToggleOutlet.selectedSegmentIndex == 2){
        [_captureButtonOutlet setTitle:@"Record Audio" forState:UIControlStateNormal];
        
        _testMergeButtonOutlet.hidden = YES;
        _photoLibraryOutlet.hidden = YES;
        _removeLastClipOutlet.hidden = YES;
        _cameraButton.hidden = YES;
        
        _topBlackBarOutlet.hidden = YES;
        _bottomBlackBarOutlet.hidden = YES;
    }
}


- (IBAction)goToAudioAction:(id)sender {
}

-(void)setLibraryThumbnail{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
         [group enumerateAssetsUsingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop)
          {
              if (alAsset)
              {
                  //ALAssetRepresentation *representation =[alAsset defaultRepresentation];
                  // NSURL *url = [representation url];
                  // NSString *assetType=[alAsset valueForProperty:ALAssetPropertyType];
                  UIImage *thumbnailImage =[UIImage imageWithCGImage:alAsset.thumbnail];
                  [_photoLibraryOutlet setBackgroundImage:thumbnailImage
                                                 forState:UIControlStateNormal];
                  _photoLibraryOutlet.backgroundColor = [UIColor clearColor];
                  
              }
          }];
         if(group==nil)
         {
             // do what ever if group getting null
             
         }
     } failureBlock: ^(NSError *error)
     {
         // may be photo privacy setting disabled
     }
     ];
    
}

-(void)pushLastVideoToMoviePlayerViewController{
     //Search for video Start*******************************************
     __block NSData *tempData;
     __block ALAssetRepresentation *representation;
     
     ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
     [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop)
     {
     [group enumerateAssetsUsingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop)
     {
     if (alAsset)
     {
     representation =[alAsset defaultRepresentation];
     
     
     
     NSURL *url = [representation url];
     NSString *assetType=[alAsset valueForProperty:ALAssetPropertyType];
     //UIImage *thumbNailImage=[UIImage imageWithCGImage:alAsset.thumbnail];
     
     //if([assetType  isEqual: @"ALAssetTypeVideo"] && url != nil){
     //_videoURL= url;
     //NSLog(@"This is %@: ",_videoURL);
     //}
     }
     }];
     if(group==nil)
     {
     Byte *buffer = (Byte*)malloc(representation.size);
     NSUInteger buffered = [representation getBytes:buffer fromOffset:0.0 length:representation.size error:nil];
     tempData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
         
     NSLog(@"Pushing to Video Screen");
     MoviePlayerViewController *moviePlayerController = [self.storyboard instantiateViewControllerWithIdentifier:@"moviePlayerScreen"];
     moviePlayerController.tempData = tempData;
     [self.navigationController pushViewController:moviePlayerController animated:YES];
     //NSLog(@"Output File URL***********************: %@", outputFileURL);
     }
     } failureBlock: ^(NSError *error)
     {
     // may be photo privacy setting disabled
     }
     ];
    
    //Search for video End*****************************
}

-(UIImage *)cropImage:(UIImage *)raw {
    float width = raw.size.width;
    float yPos = (raw.size.height/2) - (width/2);
    CGRect rect = CGRectMake(0.0, yPos, width, width);
    CGImageRef tempImage = CGImageCreateWithImageInRect([raw CGImage], rect);
    UIImage *newImage = [UIImage imageWithCGImage:tempImage];
    CGImageRelease(tempImage);
    return newImage;
}

-(UIImage *)normalizeImage:(UIImage *)raw {
    if (raw.imageOrientation == UIImageOrientationUp) return raw;
    UIGraphicsBeginImageContextWithOptions(raw.size, NO, raw.scale);
    [raw drawInRect:(CGRect){0, 0, raw.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

@end
