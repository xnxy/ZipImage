//
//  YIDTakePhotoAndRecordVideo.h
//  OneCarDriver
//
//  Created by zhouwei on 2018/8/1.
//  Copyright © 2018年 yirenyiche. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface YIDTakePhotoAndRecordVideo : NSObject

- (instancetype)initWithUIViewController:(UIViewController *)viewController;

//录像
- (void)recordVideoAndComplete:(void(^)(NSURL *videoUrl, UIImage *movieImage))complete;
//拍照
- (void)openCameraAndComplete:(void(^)(UIImage *image, UIImage *thumbImage))complete;

@end
