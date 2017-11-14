//
//  OpenCv.m
//  OpenVC-SavePhoto
//
//  Created by Jaeseong on 2017. 11. 14..
//  Copyright © 2017년 Jaeseong. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <UIKit/UIKit.h>
#import "OpenVC-SavePhoto-Bridging-Header.h"


@implementation OpenCv : NSObject

- (id) init {
    if (self = [super init]) {
        self.adaptiveThreshold0 = 2;
        self.adaptiveThreshold1 = 2;
    }
    return self;
}

-(UIImage *)Filter:(UIImage *)image {
    
    // 방향수정
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // UIImage -> Mat
    cv::Mat mat;
    UIImageToMat(image, mat);
    cv::cvtColor(mat,mat,CV_BGR2GRAY);
    
    //Blur 흐림
    if(_useBlur) {
        // kSize 홀수만
        int kSize = _blur0;
        if (kSize % 2 == 0) {
            kSize += 1;
        }
        cv::GaussianBlur(mat, mat, cv::Size(kSize,kSize), _blur1);
    }
    
    // 임계값
    if(_useTreshold) {
        cv::threshold(mat, mat, 0, 255, cv::THRESH_BINARY|cv::THRESH_OTSU);
    }
    
   // 적응임계값
    if(_useAdaptiveTreshold) {
        
        
        int blockSize = _adaptiveThreshold0;
        if(blockSize % 2 == 0) {
            blockSize += 1;
        }
        cv::adaptiveThreshold(mat, mat, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, blockSize, _adaptiveThreshold1);
    }
    
    return MatToUIImage(mat);
}

@end


