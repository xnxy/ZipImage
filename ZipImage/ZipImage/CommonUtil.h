//
//  CommonUtil.h
//  ZipImage
//
//  Created by zhouwei on 2018/8/8.
//  Copyright © 2018年 zhouwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtil : NSObject

+ (void)openApplicationSettings;
+ (void)openApplicationSettingsWithUrlStr:(NSString *)urlStr;

//缩略图
+ (UIImage *)thumbWithImage:(UIImage *)sourceImage;
//压缩后的图片
+ (UIImage *)zipScaleWithImage:(UIImage *)sourceImage;

@end
