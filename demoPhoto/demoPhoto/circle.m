//
//  ViewController.m
//  demoPhoto
//
//  Created by TechmasterVietNam on 5/31/13.
//  Copyright (c) 2013 TechmasterVietNam. All rights reserved.
//

#import "circle.h"
#import "GPUImage.h"
#import "GPUImagePixellatePositionFilter.h"
#import <QuartzCore/QuartzCore.h>
#import "GPUImageFilter.h"



@interface circle () {
    GPUImageStillCamera *stillCamera;
    UIImage *originalImage;
    BOOL cameraBool;
    UISlider* slider;
    AVCaptureStillImageOutput *photoOutput;
    GPUImageView *cameraView;
    GPUImagePicture *stillImageSource;
    
}
@property(strong,nonatomic) UIImageView* selectedImageView;
@property (readwrite, nonatomic) CGPoint localPoint;
@property(readwrite,nonatomic) GPUImagePixellatePositionFilter *pixelPositionFilter;
@property(readwrite,nonatomic) GPUImageCropFilter *cropFilter;
@property(readwrite,nonatomic) GPUImagePixellateFilter* pixel;
@property(readwrite,nonatomic) UIScrollView* scrollView;

@end

@implementation circle
@synthesize pixelPositionFilter,localPoint,cropFilter,pixel;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    localPoint = [touch locationInView:self.view];
    NSLog(@"X location: %f", localPoint.x);
    NSLog(@"Y Location: %f", localPoint.y);
    pixelPositionFilter.center = CGPointMake(localPoint.y/self.view.frame.size.height, (1-localPoint.x/self.view.frame.size.width));
    [stillImageSource addTarget:pixelPositionFilter];
    [stillImageSource processImage];
    UIImage *currentFilteredVideoFrame = [pixelPositionFilter imageFromCurrentlyProcessedOutput];
    self.selectedImageView.image = currentFilteredVideoFrame;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *output = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain
                                                              target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = output;
    
    UIBarButtonItem *input = [[UIBarButtonItem alloc] initWithTitle:@"Album" style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(input)];
    self.navigationItem.leftBarButtonItem = input;
    
    UIButton *camera = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    //    [[camera layer] setBorderWidth:2.0f];
    //    [[camera layer] setBorderColor:[UIColor blackColor].CGColor];
    [[camera layer] setCornerRadius:7.0f];
    
    [camera setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    [camera addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = camera;
    
    pixelPositionFilter = [[GPUImagePixellatePositionFilter alloc] init];
    pixelPositionFilter.center = CGPointMake(0.5, 0.5);
    pixelPositionFilter.fractionalWidthOfAPixel = 0.03;
    pixelPositionFilter.radius = 0.1;
    
    pixel = [[GPUImagePixellateFilter alloc]init];
    
    CGRect rectangle = CGRectMake(0, 0, 1, 1);
    cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:rectangle];
    
    stillCamera = [[GPUImageStillCamera alloc] init];
    //    [vc rotateCamera];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
       [stillCamera addTarget:pixelPositionFilter];
       cameraView = [[GPUImageView alloc] init];
       [pixelPositionFilter addTarget:cameraView];
    
    
    self.view=cameraView;
    
    cameraBool = YES;
    if (cameraBool==YES) {
        [stillCamera startCameraCapture];
    }
    
    slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 325, 280, 30)];
    slider.maximumValue=1;
    slider.minimumValue=0;
    [slider addTarget:self action:@selector(changeValue) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
}


-(void)changeValue{
    
    pixelPositionFilter.radius = slider.value;
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString *alertTitle;
    NSString *alertMessage;
    if(!error)
    {
        alertTitle   = @"Image Saved";
        alertMessage = @"Image saved to photo album successfully.";
    }
    else
    {
        alertTitle   = @"Error";
        alertMessage = @"Unable to save to photo album.";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"Okay"
                                          otherButtonTitles:nil];
    [alert show];
}


-(void)takePhoto{
    cameraBool=YES;
    [stillCamera startCameraCapture];
    [self.selectedImageView removeFromSuperview];
}



-(void)input{
    
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}


- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    stillImageSource = [[GPUImagePicture alloc] initWithImage:originalImage];


    self.selectedImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    
    self.selectedImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.selectedImageView.image = originalImage;
    
    [self.view addSubview:self.selectedImageView];
    [self.view addSubview:slider];

    
    [stillCamera stopCameraCapture];
//    [slider removeFromSuperview];
    
    
    cameraBool=NO;
    [self dismissViewControllerAnimated:YES completion:^{}];
}



-(void)save{
 
//        UIGraphicsBeginImageContext(cameraView.bounds.size);
//        [cameraView.layer renderInContext:UIGraphicsGetCurrentContext()];
//        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
    [stillImageSource processImage];
    UIImage *currentFilteredVideoFrame = [pixelPositionFilter imageFromCurrentlyProcessedOutput];
        UIImageWriteToSavedPhotosAlbum(currentFilteredVideoFrame, nil, nil, nil);
        //        GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] init];
        //        [stillImageSource addTarget:ppf];
        //        [stillImageSource processImage];
        //
        //        [vc capturePhotoAsJPEGProcessedUpToFilter:ppf withCompletionHandler:^(NSData *processedJPEG, NSError *error){
        //
        //            //1529x2048 when iPhone 4 and 2448x3265 when on 4s
        //            UIImage *rawImage = [[UIImage alloc]initWithCGImage:[[UIImage imageWithData:processedJPEG]CGImage]scale:1.0 orientation:UIImageOrientationUp];
        //
        //            CGRect rect = CGRectMake(0, 0, 200, 200);
        //            UIImage *imageFromRect = [rawImage imageAtRect:rect ];
        
        //        UIImage *currentFilteredVideoFrame = [stillImageSource imageFromCurrentlyProcessedOutput];        UIImageWriteToSavedPhotosAlbum(currentFilteredVideoFrame, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    [stillCamera startCameraCapture];
    NSLog(@"%c",cameraBool);
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

@end