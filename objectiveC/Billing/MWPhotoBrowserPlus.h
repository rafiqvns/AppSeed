//
//  MWPhotoBrowserPlus.h
//  MobileOffice
//
//  Created by .D. .D. on 9/12/18.
//  Copyright © 2018 RCO. All rights reserved.
//

#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import "AddObject.h"

@protocol MWPhotoBrowserDelegatePlus <NSObject>

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser;
- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;

@optional

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index;
- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index;
- (NSString *)photoBrowser:(MWPhotoBrowser *)photoBrowser titleForPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser actionButtonPressedForPhotoAtIndex:(NSUInteger)index;
- (BOOL)photoBrowser:(MWPhotoBrowser *)photoBrowser isPhotoSelectedAtIndex:(NSUInteger)index;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index selectedChanged:(BOOL)selected;
- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser;


- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser resaveAllPhotos:(BOOL)save;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser saveNewImages:(BOOL)save;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser deleteCurrentPhoto:(NSInteger)photoIndex;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser resaveCurrentPhoto:(NSInteger)photoIndex;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser newImageAdded:(UIImage*)image;
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser setPhotoAsContent:(NSInteger)photoIndex;

@end

@interface MWPhotoBrowserPlus : MWPhotoBrowser

@property (nonatomic, weak) IBOutlet id<MWPhotoBrowserDelegatePlus> delegatePlus;
@property (nonatomic, weak) id<AddObject> addDelegate;
@property (nonatomic, strong) NSString *addDelegateKey;

@property (nonatomic) BOOL displayActionButtonAllTheTime;
@property (nonatomic) BOOL displaySaveButton;
@property (nonatomic) BOOL displayAddButton;
@property (nonatomic) BOOL displaySetAsMainContent;


@end
