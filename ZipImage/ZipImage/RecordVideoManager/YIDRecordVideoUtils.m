//
//  YIDRecordVideoUtils.m
//  OneCarDriver
//
//  Created by zhouwei on 2018/8/1.
//  Copyright © 2018年 yirenyiche. All rights reserved.
//

#import "YIDRecordVideoUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <MobileCoreServices/UTCoreTypes.h>

@implementation YIDRecordVideoUtils


#pragma ---
#pragma --- 将mov文件转为MP4文件 ---
+ (void)changeMovToMp4:(NSURL *)mediaURL complete:(void (^)(NSURL *videoUrl,UIImage *movieImage))complete{
    
    NSString *basePath=[self getVideoCachePath];
    NSString *videoPath = [basePath stringByAppendingPathComponent:[self getUploadFileNameWithtype:@"video" fileType:@"mp4"]];
    NSURL *videoUrl = [NSURL fileURLWithPath:videoPath];
    
    AVAsset *video = [AVAsset assetWithURL:mediaURL];
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:video
                                                                            presetName:AVAssetExportPreset1280x720];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.outputURL = videoUrl;
    WeakObj(self)
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        StrongObj(selfWeak);
        [selfWeakStrong movieToImageWithVideoPath:videoPath Handler:^(UIImage *movieImage) {
            if (complete) {
                complete(videoUrl,movieImage);
            }
        }];
    }];
}

#pragma ---
#pragma --- 视频存放的地址 ---
+ (NSString *)getVideoCachePath {
    NSString *videoCache = [NSTemporaryDirectory() stringByAppendingPathComponent:@"videos"] ;
    BOOL isDir = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:videoCache isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {
        [fileManager createDirectoryAtPath:videoCache withIntermediateDirectories:YES attributes:nil error:nil];
    };
    return videoCache;
}

#pragma ---
#pragma --- 重新设置视频名称 ---
+ (NSString *)getUploadFileNameWithtype:(NSString *)type fileType:(NSString *)fileType {
    NSTimeInterval nowTimeInterval = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HHmmss"];
    NSDate *nowDate = [NSDate dateWithTimeIntervalSince1970:nowTimeInterval];
    NSString *timeStr = [formatter stringFromDate:nowDate];
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.%@",type,timeStr,fileType];
    return fileName;
}

#pragma ---
#pragma --- 获取视频的封面 ---
+ (void)movieToImageWithVideoPath:(NSString *)videoPath Handler:(void (^)(UIImage *movieImage))handler {
    NSURL *url = [NSURL fileURLWithPath:videoPath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0, 60);
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    AVAssetImageGeneratorCompletionHandler generatorHandler =
    ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *thumbImg = [UIImage imageWithCGImage:im];
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(thumbImg);
                });
            }
        }
    };
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]]
                                    completionHandler:generatorHandler];
}

#pragma ---
#pragma --- 判断相机权限 denied用户拒绝  sucessful 成功 ---
+ (void)judgeCameraPermissionsWithDenied:(void(^)(void))denied successful:(void(^)(UIImagePickerControllerSourceType sourceType))successful{
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        return;
    }
    // 判断授权状态
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusRestricted:
        {
            NSLog(@"因为系统原因, 无法访问相机");
        }
            break;
        case AVAuthorizationStatusDenied:// 用户拒绝当前应用访问相机
        {
            if (denied) {
                denied();
            }
        }
            break;
        case AVAuthorizationStatusAuthorized:// 用户允许当前应用访问相机
        {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                if (successful) {
                    successful(sourceType);
                }
            }
        }
            break;
        case AVAuthorizationStatusNotDetermined:// 用户还没有做出选择
        {
            // 弹框请求用户授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) { //用户授权接受
                    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
                    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                        if (successful) {
                            successful(sourceType);
                        }
                    }
                }
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma ---
#pragma --- 判断相册权限 ---
+ (void)judgeAlbumPermissionsWithDenied:(void(^)(void))denied successful:(void(^)(UIImagePickerControllerSourceType sourceType))successful{
    // 判断授权状态
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusRestricted:// 此应用程序没有被授权访问的照片数据。可能是家长控制权限。
        {
            NSLog(@"因为系统原因, 无法访问相册");
        }
            break;
        case PHAuthorizationStatusDenied: //用户拒绝访问相册
        {
            if (denied) {
                denied();
            }
        }
            break;
        case PHAuthorizationStatusAuthorized:// 用户允许访问相册
        {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                if (successful) {
                    successful(sourceType);
                }
            }
        }
            break;
        case PHAuthorizationStatusNotDetermined:// 用户还没有做出选择
        {
            // 弹框请求用户授权
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) { //用户点击了同意
                    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                        if (successful) {
                            successful(sourceType);
                        }
                    }
                }
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma ---
#pragma --- 判断麦克风权限 ---
+ (void)determineMicrophonePermissionsWithDenied:(void(^)(void))denied successful:(void(^)(void))successful{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (authStatus) {
        case AVAuthorizationStatusRestricted: //此应用程序没有被授权访问的麦克风。可能是家长控制权限。
        {
            NSLog(@"因为系统原因, 无法访问相册");
        }
            break;
        case AVAuthorizationStatusDenied: //用户拒绝访问
        {
            if (denied) {
                denied();
            }
        }
            break;
        case AVAuthorizationStatusAuthorized: //用户允许访问
        {
            if (successful) {
                successful();
            }
        }
            break;
        case AVAuthorizationStatusNotDetermined: //用户还没有做出选择问麦克风
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted) {//用户授权接受
                    if (successful) {
                        successful();
                    }
                }
            }];
        }
            break;
        default:
            break;
    }
}

@end
