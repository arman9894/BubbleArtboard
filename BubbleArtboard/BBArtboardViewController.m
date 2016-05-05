//
//  BBArtboardViewController.m
//  BubbleArtboard
//
//  Created by Arman Markosyan on 04.05.16.
//  Copyright © 2016 Arman Markosyan. All rights reserved.
//

#import "BBArtboardViewController.h"
#import "BBGridView.h"
#import "MBProgressHUD.h"

@interface BBArtboardViewController () <UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *artboardView;
@property (weak, nonatomic) IBOutlet UIView *gridView;
@property (weak, nonatomic) UIView* draggingView;
@property (nonatomic) CGFloat viewScale;
@property (nonatomic) CGFloat viewRotation;
@property (nonatomic) CGPoint touchOffset;

@end

@implementation BBArtboardViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[MBProgressHUD appearance] setAnimationType:MBProgressHUDAnimationZoom];

    self.artboardView.layer.masksToBounds = YES;
    
    UILongPressGestureRecognizer *longPressGesture =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleLongPressGesture:)];
    
    [self.artboardView addGestureRecognizer:longPressGesture];
    
    UIPinchGestureRecognizer *pinchGesture =
    [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(handlePinchGesture:)];
    pinchGesture.delegate = self;
    
    UIRotationGestureRecognizer *rotationGesture =
    [[UIRotationGestureRecognizer alloc] initWithTarget:self
                                                 action:@selector(handleRotation:)];
    rotationGesture.delegate = self;
    
    [self.view addGestureRecognizer:rotationGesture];
    
    [self.artboardView addGestureRecognizer:pinchGesture];
   
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}

#pragma mark - UIGestures

- (void)orientationChanged:(NSNotification *)notification {
    [self.gridView setNeedsDisplay];
}

- (void)handleRotation:(UIRotationGestureRecognizer *)rotationGesture {
    
    if (rotationGesture.state == UIGestureRecognizerStateBegan) {
        self.viewRotation = 0;
    }
    
    CGFloat newRotation = rotationGesture.rotation - self.viewRotation;
    
    CGAffineTransform currentTransform = self.draggingView.transform;
    CGAffineTransform newTransform = CGAffineTransformRotate(currentTransform, newRotation);
    
    self.draggingView.transform = newTransform;
    
    self.viewRotation = rotationGesture.rotation;
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)pinch {
    
    if (pinch.state == UIGestureRecognizerStateBegan) {
        self.viewScale = 1.0;
    }
    
    CGFloat newScale = 1.0 + pinch.scale - self.viewScale ;
    
    CGAffineTransform currentTransform = self.draggingView.transform;
    CGAffineTransform cnewTransform = CGAffineTransformScale(currentTransform, newScale, newScale);
    
    self.draggingView.transform = cnewTransform;
    self.viewScale = pinch.scale;
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)press {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@""
                                message:@"Are you sure you want to delete this object?"
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *deleteButton = [UIAlertAction
                                   actionWithTitle:@"Delete"
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction *action) {
                                       
                                       [UIView animateWithDuration:0.3
                                                        animations:^{
                                                            self.draggingView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
                                                        } completion:^(BOOL finished) {
                                                            [self.draggingView removeFromSuperview];
                                                        }];
                                   }];
    
    UIAlertAction *cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    [alert addAction:deleteButton];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma mark - IBActions

- (IBAction)shareProject:(UIBarButtonItem *)sender {
    
    [self showGridView:NO];
    self.artboardView.backgroundColor = [UIColor whiteColor];
    
    UIImage *imageToShare = [self imageSnapshotFromView:self.artboardView];
    
    [self showGridView:YES];
    self.artboardView.backgroundColor = [UIColor clearColor];
    
    NSArray *objectsToShare = @[imageToShare];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (IBAction)addCircle:(UIBarButtonItem *)sender {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"What kind of object you want to add?"
                                message:@""
                                preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *circleAction = [UIAlertAction
                                   actionWithTitle:@"Circle"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       
                                       UIColor *randomColor = [self randomColor];
                                       CGRect randomFrame = [self randomRect];
                                       UIImageView *imageView = [self imageViewWithColor:randomColor andFrame:randomFrame];
                                       [self addImageViewInArtboard:imageView];
                                       
                                   }];
    
    UIAlertAction *photoAction = [UIAlertAction
                                  actionWithTitle:@"Photo"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction *action) {
                                      
                                      UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                      picker.delegate = self;
                                      picker.allowsEditing = YES;
                                      picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                      
                                      [self presentViewController:picker animated:YES completion:nil];
                                  }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleCancel
                                   handler:nil];
    
    [alert addAction:circleAction];
    [alert addAction:photoAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Private Methods

- (void)addImageViewInArtboard:(UIImageView *)imageView {
    
    [self.artboardView addSubview:imageView];
    
    self.draggingView = imageView;
    
    CGAffineTransform currentTransform = self.draggingView.transform;
    self.draggingView.transform = CGAffineTransformScale(self.draggingView.transform, 0.1f, 0.1f);
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5
                     animations:^{
                         weakSelf.draggingView.transform = currentTransform;
                     }];
}

- (UIImageView *)imageViewWithImage:(UIImage *)image andFrame:(CGRect)frame {
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    imageView.frame = frame;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.cornerRadius = CGRectGetHeight(frame) / 2;
    imageView.layer.masksToBounds = YES;
    imageView.userInteractionEnabled = YES;
    
    return imageView;
}

- (UIImageView *)imageViewWithColor:(UIColor *)color andFrame:(CGRect)frame {
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    imageView.backgroundColor = color;
    imageView.layer.cornerRadius = CGRectGetHeight(frame) / 2;
    imageView.layer.masksToBounds = YES;
    imageView.userInteractionEnabled = YES;
    
    return imageView;
}

- (UIImage *)imageSnapshotFromView:(UIView *)view {
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size,
                                           YES, view.contentScaleFactor);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)showGridView:(BOOL)isShow {
    [self.gridView setHidden:!isShow];
}

- (UIColor *)randomColor {
    CGFloat r = (float)(arc4random() % 256) / 255.f;
    CGFloat g = (float)(arc4random() % 256) / 255.f;
    CGFloat b = (float)(arc4random() % 256) / 255.f;
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1.f];
}

- (CGRect)randomRect {
    
    CGFloat viewWidth = self.artboardView.frame.size.width;
    CGFloat viewHeight = self.artboardView.frame.size.height;
    
    CGFloat randomRadius = (arc4random() % (kRADIUS_MAX - kRADIUS_MIN) + kRADIUS_MIN);
    
    CGFloat circleWidth = randomRadius*2;
    CGFloat circleHeight = randomRadius*2;
    
    CGFloat circleX = arc4random() % (int)(viewWidth - circleWidth);
    CGFloat circleY = arc4random() % (int)(viewHeight - circleHeight);
    
    return CGRectMake(circleX, circleY, circleWidth, circleHeight);
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    CGPoint pointOnMainView = [touch locationInView:self.artboardView];
    
    UIView *view = [self.artboardView hitTest:pointOnMainView withEvent:event];
    
    if (![view isEqual:self.artboardView]) {
        
        self.draggingView = view;
        
        [self.artboardView bringSubviewToFront:self.draggingView];
        
        CGPoint touchPoint = [touch locationInView:self.draggingView];
        
        self.touchOffset = CGPointMake(CGRectGetMidX(self.draggingView.bounds) - touchPoint.x,
                                       CGRectGetMidY(self.draggingView.bounds) - touchPoint.y);
       
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.draggingView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
                             self.draggingView.alpha = 0.6f;
                         }];
        
    } else {
        
        self.draggingView = nil;
        
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.draggingView) {
        
        UITouch *touch = [touches anyObject];
        
        CGPoint pointOnMainView = [touch locationInView:self.artboardView];
        
        CGPoint correction = CGPointMake(pointOnMainView.x + self.touchOffset.x,
                                         pointOnMainView.y + self.touchOffset.y);
        
        self.draggingView.center = correction;
    }
    
}

- (void)onTouchesEnded {
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.draggingView.transform = CGAffineTransformIdentity;
                         self.draggingView.alpha = 1.f;
                     }];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self onTouchesEnded];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self onTouchesEnded];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
    
    UIImageView *imageViewWithSelectedImage = [self imageViewWithImage:selectedImage andFrame:[self randomRect]];
    
    __weak typeof(self) weakSelf = self;
    [picker dismissViewControllerAnimated:YES
                               completion:^{
                                   [weakSelf showHUDWithCompletion:^{
                                   [weakSelf addImageViewInArtboard:imageViewWithSelectedImage];
                                   }];
                                   
                               }];
    
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - MBProgressHUD methods

- (void)showHUDWithCompletion:(void(^)())completion {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        completion();
    });
    
}

@end
