//
//  MWPhotoBrowserPlus.m
//  MobileOffice
//
//  Created by .D. .D. on 9/12/18.
//  Copyright © 2018 RCO. All rights reserved.
//

#import "MWPhotoBrowserPlus.h"
#import <MWPhotoBrowser/MWPhotoBrowserPrivate.h>
//#import "MWPhotoBrowserPrivate.h"

@interface MWPhotoBrowserPlus ()
@property (nonatomic, strong) UIBarButtonItem *saveButton;
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) UIBarButtonItem *closeButton;
@end

@implementation MWPhotoBrowserPlus

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // set default
    self.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationBar.barTintColor = [UIColor lightGrayColor];
    self.title = @"Photos";
}

- (CGRect)frameForToolbarAtOrientation:(UIInterfaceOrientation)orientation {
    CGFloat height = 44;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone &&
        UIInterfaceOrientationIsLandscape(orientation)) height = 32;
    CGFloat adjust = 0;
    if (@available(iOS 11.0, *)) {
        //Account for possible notch
        UIEdgeInsets safeArea = [[UIApplication sharedApplication] keyWindow].safeAreaInsets;
        adjust = safeArea.bottom;
    }
    return CGRectIntegral(CGRectMake(0, self.view.bounds.size.height - height - adjust, self.view.bounds.size.width, height));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)updateNavigation {
    
    [super updateNavigation];
    
    // Disable action button if there is no image or it's a video
    MWPhoto *photo = [self photoAtIndex:self.currentIndex];
    /*
    if ([photo underlyingImage] == nil || ([photo respondsToSelector:@selector(isVideo)] && photo.isVideo)) {
        if (self.displayActionButtonAllTheTime) {
            // we should show the action button all the time
        } else {
            _actionButton.enabled = NO;
            _actionButton.tintColor = [UIColor clearColor]; // Tint to hide button
        }
    } else {
        _actionButton.enabled = YES;
        _actionButton.tintColor = nil;
    }
    */
}

-(void)performLayout {
    [super performLayout];
    if (self.displaySaveButton) {
        self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                        target:self
                                                                        action:@selector(saveButtonPressed:)];
        self.navigationItem.rightBarButtonItem = self.saveButton;
        if (DEVICE_IS_IPAD) {
            //19.12.2018 we should show alco a close button
            self.closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(closeButtonPressed:)];
            self.navigationItem.leftBarButtonItem = self.closeButton;
            
        }
    }
    if (self.displayAddButton) {
        NSArray *subViews = [self.view subviews];
        for (UIView *v in subViews) {
            
            if ([v isKindOfClass:[UIToolbar class]]) {
                UIToolbar *toolbar = (UIToolbar*)v;
                NSMutableArray *existingItems = [NSMutableArray arrayWithArray:toolbar.items];
                UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
                [existingItems addObject:flexSpace];
                self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonPressed:)];
                [existingItems addObject:self.addButton];
                [toolbar setItems:existingItems];
                toolbar.barTintColor = [UIColor lightGrayColor];
                // set default
                toolbar.tintColor = nil;
            }
        }
    }
}

#pragma mark - Actions

-(IBAction)closeButtonPressed:(id)sender {
    if ([self.addDelegate respondsToSelector:@selector(didAddObject:forKey:)]) {
        [self.addDelegate didAddObject:nil forKey:self.addDelegateKey];
    }
}

- (void)saveButtonPressed:(UIBarButtonItem*)sender {
    [self.delegatePlus photoBrowser:self saveNewImages:YES];
}

- (void)addButtonPressed:(UIBarButtonItem*)sender {
    UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Options", nil)
                                                                message:nil
                                                         preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             NSLog(@"");
                                                         }];
    
    UIAlertAction* newPhotoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Take new photo", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) {
                                                               [self takePicture];
                                                           }];
    
    UIAlertAction* existingPhotoAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Pick existing image", nil)
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction * action) {
                                                                    [self choosePicture];
                                                                }];

    
    [al addAction:newPhotoAction];
    [al addAction:existingPhotoAction];
    [al addAction:cancelAction];
    
    if (DEVICE_IS_IPAD) {
        [al setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popController = [al popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        popController.delegate = self;
        popController.barButtonItem = sender;
    }
    
    [self presentViewController:al animated:YES completion:nil];
}
    
- (void)actionButtonPressed:(UIBarButtonItem*)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Options" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *buttonMainPhoto = [UIAlertAction actionWithTitle:@"Set As Main Photo"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       //add code to make something happen once tapped
                                                       NSLog(@"");
                                                       [self.delegatePlus photoBrowser:self setPhotoAsContent:self.currentIndex];
                                                   }];

    UIAlertAction *button = [UIAlertAction actionWithTitle:@"Resave current photo"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       //add code to make something happen once tapped
                                                       NSLog(@"");
                                                       [self.delegatePlus photoBrowser:self resaveCurrentPhoto:self.currentIndex];
                                                   }];
    UIAlertAction *button1 = [UIAlertAction actionWithTitle:@"Delete current photo"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action){
                                                        //add code to make something happen once tapped
                                                        NSLog(@"");
                                                        [self.delegatePlus photoBrowser:self deleteCurrentPhoto:self.currentIndex];
                                                    }];
    
    UIAlertAction *button2 = [UIAlertAction actionWithTitle:@"Start full sync"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action){
                                                        //add code to make something happen once tapped
                                                        NSLog(@"");
                                                        [self.delegatePlus photoBrowser:self resaveAllPhotos:YES];
                                                    }];
    
    UIAlertAction *button3 = [UIAlertAction actionWithTitle:@"Cancel"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action){
                                                        //add code to make something happen once tapped
                                                        NSLog(@"");
                                                    }];
    if (/*!_gridController*/self.enableGrid) {
        if (self.displaySetAsMainContent) {
            [alertVC addAction:buttonMainPhoto];
        }
        [alertVC addAction:button];
        [alertVC addAction:button1];
    }
    [alertVC addAction:button2];
    [alertVC addAction:button3];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [alertVC setModalPresentationStyle:UIModalPresentationPopover];
        
        UIPopoverPresentationController *popController = [alertVC popoverPresentationController];
        popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        popController.delegate = self;
        popController.barButtonItem = sender;
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)takePicture {
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentViewController:picker animated:YES completion:nil];
        } else {
            [picker setModalPresentationStyle:UIModalPresentationPopover];
            
            UIPopoverPresentationController *popController = [picker popoverPresentationController];
            popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            popController.delegate = self;
            popController.barButtonItem = self.addButton;
            
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
    else
    {
        UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                    message:NSLocalizedString(@"Camera is not available", @"Camera is not available")
                                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"Close")
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                          }];
        
        [al addAction:closeAction];
        
        [self presentViewController:al animated:YES completion:nil];
    }
}

- (void)choosePicture {
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.navigationBar.barStyle = UIBarStyleBlackOpaque;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self presentViewController:picker animated:YES completion:nil];
        } else {
            [picker setModalPresentationStyle:UIModalPresentationPopover];
            
            UIPopoverPresentationController *popController = [picker popoverPresentationController];
            popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            popController.delegate = self;
            popController.barButtonItem = self.addButton;
            
            [self presentViewController:picker animated:YES completion:nil];
        }
    } else {
        UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                    message:NSLocalizedString(@"Album is not available" , @"Album is not available")
                                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* closeAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Close", @"Close")
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction * action) {
                                                            }];
        
        [al addAction:closeAction];
        
        [self presentViewController:al animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker
        didFinishPickingImage:(UIImage *)image
                  editingInfo:(NSDictionary *)editingInfo {
    NSLog(@"didFinishPickingImage");
    UIImage *img = [editingInfo objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self.delegatePlus photoBrowser:self newImageAdded:img];
    [self hideGrid];
    [self showGrid:NO];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *img = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self.delegatePlus photoBrowser:self newImageAdded:img];
    [self hideGrid];
    [self showGrid:NO];
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
