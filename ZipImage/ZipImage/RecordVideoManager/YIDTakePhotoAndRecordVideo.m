//
//  YIDTakePhotoAndRecordVideo.m
//  OneCarDriver
//
//  Created by zhouwei on 2018/8/1.
//  Copyright © 2018年 yirenyiche. All rights reserved.
//

#import "YIDTakePhotoAndRecordVideo.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import "YIDRecordVideoUtils.h"

typedef void(^TakePhotoComplete)(UIImage *image, UIImage *thumbImage);
typedef void(^RecordVideoComplete)(NSURL *videoUrl, UIImage *movieImage);

@interface YIDTakePhotoAndRecordVideo()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIViewController *vc;

@property (nonatomic, copy) TakePhotoComplete takePhotoComplete;
@property (nonatomic, copy) RecordVideoComplete recordVideoComplete;

@end

@implementation YIDTakePhotoAndRecordVideo

- (instancetype)initWithUIViewController:(UIViewController *)viewController{
    self = [super init];
    if (self) {
        self.vc = viewController;
    }
    return self;
}

#pragma ---
#pragma --- 录像 ---
- (void)recordVideoAndComplete:(void(^)(NSURL *videoUrl, UIImage *movieImage))complete{
    WeakObj(self);
    self.recordVideoComplete = complete;
    [YIDRecordVideoUtils determineMicrophonePermissionsWithDenied:^
     {
         StrongObj(selfWeak);
         [AlertViewUtils alertViewpresentViewController:selfWeakStrong.vc
                                         title:@"提示"
                                       message:@"麦克风授权未开启\n请在系统设置中开启麦克风权限"
                                     cancleStr:@"暂不"
                                         okStr:@"去设置"
                                   cancleBlock:^{
                                       
                                   } okBlock:^{
                                       [CommonUtil openApplicationSettings];
                                   }];
     } successful:^{
         [YIDRecordVideoUtils judgeCameraPermissionsWithDenied:^{
             StrongObj(selfWeak);
             [AlertViewUtils alertViewpresentViewController:selfWeakStrong.vc
                                             title:@"提示"
                                           message:@"相机授权未开启\n请在系统设置中开启相机权限"
                                         cancleStr:@"暂不"
                                             okStr:@"去设置"
                                       cancleBlock:^{
                                           
                                       } okBlock:^{
                                           [CommonUtil openApplicationSettings];
                                       }];
         } successful:^(UIImagePickerControllerSourceType sourceType) {
             StrongObj(selfWeak)
             UIImagePickerController *picker = [[UIImagePickerController alloc] init];
             picker.delegate = selfWeakStrong;
             picker.sourceType = sourceType;
             // 设置图像选取控制器的类型为动态图像
             picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
             // 设置摄像图像品质
             picker.videoQuality = UIImagePickerControllerQualityTypeLow;
             // 设置最长摄像时间
             picker.videoMaximumDuration = 60; //暂时不限制
             // 允许用户进行编辑
             picker.allowsEditing = YES;
             [selfWeakStrong.vc presentViewController:picker animated:YES completion:nil];
         }];
     }];
}

#pragma mark ---
#pragma mark --- 打开相机 ---
- (void)openCameraAndComplete:(void(^)(UIImage *image, UIImage *thumbImage))complete{
    self.takePhotoComplete = complete;
    //获取摄像设备
    WeakObj(self)
    [YIDRecordVideoUtils judgeCameraPermissionsWithDenied:^{
        StrongObj(selfWeak)
        [AlertViewUtils alertViewpresentViewController:selfWeakStrong.vc
                                        title:@"提示"
                                      message:@"相机授权未开启\n请在系统设置中开启相机权限"
                                    cancleStr:@"暂不"
                                        okStr:@"去设置"
                                  cancleBlock:^{
                                      
                                  } okBlock:^{
                                      [CommonUtil openApplicationSettings];
                                  }];
    } successful:^(UIImagePickerControllerSourceType sourceType) {
        StrongObj(selfWeak)
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = selfWeakStrong;
        picker.sourceType = sourceType;
        [selfWeakStrong.vc presentViewController:picker animated:YES completion:nil];
    }];
}

#pragma mark ---
#pragma mark --- 打开相册 ---
- (void)openPhotoLibrary{
    // 判断授权状态
    WeakObj(self)
    [YIDRecordVideoUtils judgeAlbumPermissionsWithDenied:^{
        StrongObj(selfWeak)
        [AlertViewUtils alertViewpresentViewController:selfWeakStrong.vc
                                        title:@"提示"
                                      message:@"相册授权未开启\n请在系统设置中开启相册权限"
                                    cancleStr:@"暂不"
                                        okStr:@"去设置"
                                  cancleBlock:^
         {
             
         } okBlock:^{
             [CommonUtil openApplicationSettings];
         }];
    } successful:^(UIImagePickerControllerSourceType sourceType) {
        StrongObj(selfWeak)
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = selfWeakStrong;
        picker.sourceType = sourceType;
        [selfWeakStrong.vc presentViewController:picker animated:YES completion:nil];
    }];
}


#pragma mark- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    WeakObj(self)
    [self.vc dismissViewControllerAnimated:YES completion:^{
        StrongObj(selfWeak)
        //获取媒体类型
        NSLog(@"-----info:%@-----",info);
        NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) { //图片
            UIImage * originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
            originalImage = [CommonUtil zipScaleWithImage:originalImage];
            UIImage *thumbImage = [CommonUtil thumbWithImage:originalImage];
            NSLog(@"-----originalImage:%@-----",originalImage);
            if (self.takePhotoComplete) {
                self.takePhotoComplete(originalImage,thumbImage);
            }
        }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){ //视频
            // 获取视频文件的url
            NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
            NSLog(@"-----videoUrl:%@-----",videoUrl);
            AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
            double duration = urlAsset.duration.value / urlAsset.duration.timescale;
            [selfWeakStrong changeMovToMp4WithDurantion:duration videoUrl:videoUrl pickerController:picker];
        }
    }];
}

- (void)changeMovToMp4WithDurantion:(double)duration videoUrl:(NSURL *)url pickerController:(UIImagePickerController *)picker{
    WeakObj(self)
    if (duration > 5) { //判断时间是否大于5秒
        [YIDRecordVideoUtils changeMovToMp4:url complete:^(NSURL *videoUrl, UIImage *movieImage) {
            StrongObj(selfWeak)
            if (selfWeakStrong.recordVideoComplete) {
                selfWeakStrong.recordVideoComplete(videoUrl, movieImage);
                NSLog(@"----mp4:%@-----movieImage:%@-----",videoUrl,movieImage);
            }
        }];
    } else {
//        [YICProgressHUD showInfoWithStatus:@"视频太短，请重新录制"];
        [self.vc presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.vc dismissViewControllerAnimated:YES completion:nil];
}

@end
