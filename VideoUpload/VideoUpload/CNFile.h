//
//  CNFile.h
//  VideoUpload
//
//  Created by xiyang on 2017/7/13.
//  Copyright © 2017年 xiyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface CNFile : NSObject

@property (nonatomic,copy)NSString* fileType;//image  or  movie
@property (nonatomic,copy)NSString* filePath;//文件在app中路径
@property (nonatomic,copy,readonly)NSString* fileName;//文件名
@property (nonatomic,assign,readonly)NSInteger fileSize;//文件大小
@property (nonatomic, assign,readonly) NSInteger chunks;//总片数

@property (nonatomic,strong)UIImage* fileImage;//文件缩略图
@property (nonatomic,strong) NSMutableArray* fileArr;//标记每片的上传状态
-(void)uploadData;
@end
