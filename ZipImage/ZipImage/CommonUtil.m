//
//  CommonUtil.m
//  ZipImage
//
//  Created by zhouwei on 2018/8/8.
//  Copyright © 2018年 zhouwei. All rights reserved.
//

#import "CommonUtil.h"

@implementation CommonUtil

#pragma mark ---
#pragma mark --- 打开应用设置界面 ---
+ (void)openApplicationSettings{
    [self openApplicationSettingsWithUrlStr:UIApplicationOpenSettingsURLString];
}

+ (void)openApplicationSettingsWithUrlStr:(NSString *)urlStr{
    NSURL *privacyUrl = [NSURL URLWithString:urlStr];
    if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
        [[UIApplication sharedApplication] openURL:privacyUrl];
    }
}

+ (UIImage *)thumbWithImage:(UIImage *)sourceImage{
    //缩略为 宽为162  高为90
    //对图像尺寸进行压缩
    CGSize imageSize = sourceImage.size;//取出要压缩的image尺寸
    CGFloat width = imageSize.width;    //图片宽度
    CGFloat height = imageSize.height;  //图片高度
    
    CGFloat scale = height/width;
    width = 162;
    height = width * scale;
    //进行尺寸重绘
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [sourceImage drawInRect:CGRectMake(0,0,width,height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)zipScaleWithImage:(UIImage *)sourceImage{
    //进行图像尺寸的压缩
    CGSize imageSize = sourceImage.size;//取出要压缩的image尺寸
    CGFloat width = imageSize.width;    //图片宽度
    CGFloat height = imageSize.height;  //图片高度
    //1.宽高大于1280(宽高比不按照2来算，按照1来算)
    if (width > 1280 || height > 1280) {
        if (width > height) {
            CGFloat scale = height/width;
            width = 1280;
            height = width * scale;
        }else{
            CGFloat scale = width/height;
            height = 1280;
            width = height * scale;
        }
        //2.宽大于1280高小于1280
    }else if(width > 1280|| height < 1280){
        CGFloat scale = height/width;
        width = 1280;
        height = width * scale;
        //3.宽小于1280高大于1280
    }else if(width < 1280|| height > 1280){
        CGFloat scale = width/height;
        height = 1280;
        width = height * scale;
        //4.宽高都小于1280
    }
    //进行尺寸重绘
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [sourceImage drawInRect:CGRectMake(0,0,width,height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //进行图像的画面质量压缩
    NSData *data = UIImageJPEGRepresentation(newImage, 0.5);
    if (data.length/1024.f > 512) { //大于1MB
        if (data.length/1024.f > 1024) {//1M以及以上
            data = UIImageJPEGRepresentation(newImage, 0.3);
        }else if (data.length/1024.f > 512) {//0.5M-1M
            data = UIImageJPEGRepresentation(newImage, 0.4);
        }
    }
    
    UIImage *zipImage = [UIImage imageWithData:data];
    return zipImage;
}

@end
