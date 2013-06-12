//
//  ViewController.m
//  demoPhoto
//
//  Created by TechmasterVietNam on 5/31/13.
//  Copyright (c) 2013 TechmasterVietNam. All rights reserved.
//

#import "elipse.h"
#import "GPUImage.h"
#import "GPUImagePixellatePositionFilter.h"
#import <QuartzCore/QuartzCore.h>
#import "GPUImageFilter.h"



@interface elipse () {
    UIImage *originalImage;
    GPUImagePicture* stillImageSource;
    UIImage* newImage;
    CGPoint* localPoint;
}
@property(strong,nonatomic) UIImageView* selectedImageView;
@property (readwrite, nonatomic) UISlider* slider;
@property (readwrite, nonatomic) CGRect RectSize;

@property(readwrite,nonatomic) GPUImageCropFilter *cropFilter;
@property(readwrite,nonatomic) GPUImagePixellateFilter* pixel;

@property(readwrite,nonatomic) GPUImageView *subView;

@property(readwrite,nonatomic) UIScrollView *scrollView;
@property(readwrite,nonatomic) UIImageView* imageView;
@property(readwrite,nonatomic) UIView* rotateView;


@end

@implementation elipse
@synthesize cropFilter,pixel,scrollView,imageView,slider,RectSize,rotateView,subView;

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{
    CGPoint touchPoint=[gesture locationInView:scrollView];
    
    NSLog(@"X location: %f", touchPoint.x);
    NSLog(@"Y Location: %f", touchPoint.y);
    
    self.subView.center = touchPoint;
    
    if (touchPoint.x<(self.subView.frame.size.width/2)) {
        self.subView.center = CGPointMake(self.subView.frame.size.width/2, touchPoint.y);
    }
    if (touchPoint.y<(self.subView.frame.size.height/2)) {
        self.subView.center = CGPointMake(touchPoint.x,self.subView.frame.size.height/2);
    }
    if (touchPoint.y<(self.subView.frame.size.height/2) && touchPoint.x<(self.subView.frame.size.width/2)) {
        self.subView.center = CGPointMake(self.subView.frame.size.width/2,self.subView.frame.size.height/2);
    }
    
    [cropFilter setCropRegion:CGRectMake(self.subView.frame.origin.x/self.scrollView.contentSize.width,self.subView.frame.origin.y/self.scrollView.contentSize.height,self.subView.frame.size.width/self.scrollView.contentSize.width, self.subView.frame.size.height/self.scrollView.contentSize.height)];
    
    
    [stillImageSource addTarget:cropFilter];
    
    [stillImageSource processImage];
    
    UIImage *cropImage = [cropFilter imageFromCurrentlyProcessedOutput];
    
    GPUImagePicture* cropPicture = [[GPUImagePicture alloc] initWithImage:cropImage];
    
    [cropPicture addTarget:pixel];
    
    [cropPicture processImage];
    
    UIImage *pixelImage = [pixel imageFromCurrentlyProcessedOutput];
    
    

    
    UIGraphicsBeginImageContext( scrollView.contentSize );
    
    rotateView.center = subView.center;

    imageView.image = pixelImage;
        
    [scrollView addSubview:rotateView];

    UIGraphicsEndImageContext();
    
    self.selectedImageView.image = originalImage;
    
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
    
    [[camera layer] setCornerRadius:7.0f];
    
    [camera setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    [camera addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = camera;
    
    RectSize = CGRectMake(0, 0,200,200);
        
    self.subView = [[GPUImageView alloc] initWithFrame:RectSize];
    self.subView.center = CGPointMake(self.subView.frame.size.width/2,self.subView.frame.size.height/2);
    
    rotateView = [[UIView alloc] initWithFrame:CGRectMake(0,0,75,100)];
    rotateView.clipsToBounds =YES;
    [rotateView.layer setMasksToBounds:YES];
    [rotateView.layer setBorderWidth:0.6];
//    [rotateView.layer setCornerRadius:40];

    
    imageView =[[UIImageView alloc] initWithFrame:self.subView.frame];
//    [imageView.layer setCornerRadius:50];
//    [imageView.layer setMasksToBounds:YES];
    imageView.center = CGPointMake(rotateView.frame.size.width/2, rotateView.frame.size.height/2);
//    [imageView.layer setBorderWidth:0.6];

    
    [rotateView addSubview:imageView];

    

    
    pixel = [[GPUImagePixellateFilter alloc]init];
    
    cropFilter = [[GPUImageCropFilter alloc] initWithCropRegion:CGRectMake(self.subView.frame.origin.x/self.view.frame.size.width, self.subView.frame.origin.y/self.view.frame.size.height,self.subView.frame.size.width/self.view.frame.size.width, self.subView.frame.size.height/self.view.frame.size.height)];
        
    slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 330, 280, 30)];
    slider.minimumValue=0;
    slider.maximumValue=M_PI*2;
    [slider addTarget:self action:@selector(changeValue) forControlEvents:UIControlEventValueChanged];
    
    
    originalImage = [[UIImage alloc] init];

}

-(void)changeValue{
        
    self.rotateView.transform = CGAffineTransformMakeRotation(self.slider.value);
    self.imageView.transform = CGAffineTransformMakeRotation(-self.slider.value);

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
    
    self.selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, originalImage.size.width, originalImage.size.height)];
    
    self.selectedImageView.image = originalImage;
    
    self.selectedImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    
    scrollView.contentSize = originalImage.size;
    
    [scrollView addSubview:self.selectedImageView];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [scrollView addGestureRecognizer:singleTap];
    
    [self.view addSubview:self.scrollView];
    
    [self.view addSubview:slider];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}
-(void)save{[stillImageSource addTarget:cropFilter];
    
    [stillImageSource processImage];
    
    UIImage *cropImage = [cropFilter imageFromCurrentlyProcessedOutput];
    
    GPUImagePicture* cropPicture = [[GPUImagePicture alloc] initWithImage:cropImage];
    
    [cropPicture addTarget:pixel];
    
    [cropPicture processImage];
    
    UIImage *pixelImage = [pixel imageFromCurrentlyProcessedOutput];
    
    
    UIGraphicsBeginImageContext( scrollView.contentSize );
    
    [originalImage drawInRect:self.selectedImageView.frame];
    
    rotateView.center = subView.center;
    
    imageView.image = pixelImage;
    
    [scrollView addSubview:rotateView];

    [scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
    
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}
@end