//
//  ViewController.m
//  ZipImage
//
//  Created by zhouwei on 2018/8/8.
//  Copyright © 2018年 zhouwei. All rights reserved.
//

#import "ViewController.h"
#import "YIDTakePhotoAndRecordVideo.h"

@interface ViewController ()

@property (nonatomic, strong) YIDTakePhotoAndRecordVideo *takePhotoAndRecordVideo;
@property (nonatomic, strong) UIImageView *imgV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *imgV = [UIImageView new];
    imgV.center = self.view.center;
    imgV.bounds = CGRectMake(0, 0, 200, 200);

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor blueColor];
    [btn setTitle:@"拍照" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    btn.frame = CGRectMake(20, imgV.frame.origin.y + 200, self.view.bounds.size.width - 40, 50);
    
    [self.view addSubview:imgV];
    [self.view addSubview:btn];
    self.imgV = imgV;
    
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnClick:(UIButton *)btn{
    WeakObj(self);
    [self.takePhotoAndRecordVideo openCameraAndComplete:^(UIImage *image, UIImage *thumbImage) {
        StrongObj(selfWeak)
        NSData *data = UIImageJPEGRepresentation(thumbImage, 0.5);
        selfWeakStrong.imgV.image = thumbImage;
        NSLog(@"-----image-bity:%@------",@(data.length/1024.f));
    }];
    
}

- (YIDTakePhotoAndRecordVideo *)takePhotoAndRecordVideo{
    if (!_takePhotoAndRecordVideo) {
        _takePhotoAndRecordVideo = [[YIDTakePhotoAndRecordVideo alloc]initWithUIViewController:self];
    }
    return _takePhotoAndRecordVideo;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
