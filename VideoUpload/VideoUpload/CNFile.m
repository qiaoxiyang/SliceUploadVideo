//
//  CNFile.m
//  VideoUpload
//
//  Created by xiyang on 2017/7/13.
//  Copyright © 2017年 xiyang. All rights reserved.
//

#import "CNFile.h"
#import "XYNetworking.h"
#import <AVFoundation/AVFoundation.h>
static int offset =1024*1024;//（每一片的大小是1M）

@interface CNFile ()

@property (nonatomic, copy) NSString *randomStr;

@property (nonatomic,copy)NSString* mp4FilePath;//视频转换格式路径

@end

@implementation CNFile

-(void)setFilePath:(NSString *)filePath{
    _filePath = filePath;
    
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    [self movFileTransformToMP4WithSourceUrl:fileURL completion:^(NSString *Mp4FilePath) {
        self.mp4FilePath = Mp4FilePath;
        [self uploadData];
        
    }];
}

-(void)setMp4FilePath:(NSString *)mp4FilePath{
    _mp4FilePath = mp4FilePath;
    NSURL *fileURL = [NSURL fileURLWithPath:_mp4FilePath];
    _fileSize = [NSData dataWithContentsOfURL:fileURL].length;
    //    总片数的获取方法：
    _chunks = (_fileSize%1024==0)?((int)(_fileSize/1024*1024)):((int)(_fileSize/(1024*1024) + 1));
    NSLog(@"chunks = %ld",(long)_chunks);
    
    for (int i=0; i<_chunks; i++) {
        [self.fileArr addObject:[self readDataWithChunk:i]];
    }
    
    _randomStr = [NSString stringWithFormat:@"%i",arc4random()];
    _fileName = [_mp4FilePath lastPathComponent];
}



-(NSData *)readDataWithChunk:(NSInteger)chunk{

//    将文件分片，读取每一片的数据：
    NSData* data;
    NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:_mp4FilePath];
    [readHandle seekToFileOffset:offset * chunk];
    data = [readHandle readDataOfLength:offset];
    return data;
}

-(void)uploadData{
    
    dispatch_group_t group = dispatch_group_create();
    NSInteger chunk = 0;
    for (NSData *data in self.fileArr) {
        if ([self.fileArr[chunk] isKindOfClass:[NSData class]]) {
            dispatch_group_enter(group);
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:_randomStr forKey:@"r"];
            [params setObject:@(_chunks) forKey:@"chunks"];
            [params setObject:@(chunk) forKey:@"chunk"];
            NSLog(@"参数为：%@",params);
            [XYNetworking uploadWithURL:@"oUpload.php" params:params fileData:data name:@"file" fileName:_fileName mimeType:@"video/*" success:^(id responseObject) {
                dispatch_group_leave(group);
                NSLog(@"返回数据：%@",responseObject);
                [self.fileArr replaceObjectAtIndex:chunk withObject:@"finish"];
                
            } failure:^(NSError *error) {
                dispatch_group_leave(group);
                NSLog(@"第%zd片上传失败",chunk);
            }];
        }
        chunk++;
    }
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"上传成功!");
        
    });

}

-(void)uploadVideo{
    
    NSData *data = [NSData dataWithContentsOfFile:self.mp4FilePath];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:_randomStr forKey:@"r"];
    [XYNetworking uploadWithURL:@"oUpload.php" params:params fileData:data name:@"file" fileName:_fileName mimeType:@"video/*" success:^(id responseObject) {
        
        NSLog(@"返回数据：%@",responseObject);
        
        
    } failure:^(NSError *error) {
        
        NSLog(@"上传失败");
    }];
}


-(void)movFileTransformToMP4WithSourceUrl:(NSURL *)sourceUrl completion:(void(^)(NSString *Mp4FilePath))comepleteBlock
{
    /**
     *  mov格式转mp4格式
     */
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceUrl options:nil];
    
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    NSLog(@"%@",compatiblePresets);
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        
        
        NSDate *date = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *uniqueName = [NSString stringWithFormat:@"%@.mp4",[formatter stringFromDate:date]];
        NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        NSString * resultPath = [document stringByAppendingPathComponent:uniqueName];//PATH_OF_DOCUMENT为documents路径
        
        NSLog(@"output File Path : %@",resultPath);
        
        exportSession.outputURL = [NSURL fileURLWithPath:resultPath];
        
        exportSession.outputFileType = AVFileTypeMPEG4;//可以配置多种输出文件格式
        
        exportSession.shouldOptimizeForNetworkUse = YES;
        
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         
         {
             //             dispatch_async(dispatch_get_main_queue(), ^{
             //                 [hud hideAnimated:YES];
             //             });
             
             switch (exportSession.status) {
                     
                 case AVAssetExportSessionStatusUnknown:
                     
                     //                     NSLog(@"AVAssetExportSessionStatusUnknown");
//                     [XHToast showCenterWithText:@"视频格式转换出错Unknown"];
                     //                     CLOUDMESSAGETIPS(@"视频格式转换出错Unknown", 0.8); //自定义错误提示信息
                     break;
                     
                 case AVAssetExportSessionStatusWaiting:
                     
                     //                     NSLog(@"AVAssetExportSessionStatusWaiting");
//                     [XHToast showCenterWithText:@"视频格式转换出错Waiting"];
                     //                     CLOUDMESSAGETIPS(@"视频格式转换出错Waiting", 0.8);
                     break;
                     
                 case AVAssetExportSessionStatusExporting:
                     
                     //                     NSLog(@"AVAssetExportSessionStatusExporting");
                     //                     CLOUDMESSAGETIPS(@"视频格式转换出错Exporting", 0.8);
//                     [XHToast showCenterWithText:@"视频格式转换出错Exporting"];
                     break;
                     
                 case AVAssetExportSessionStatusCompleted:
                 {
                     
                     //                     NSLog(@"AVAssetExportSessionStatusCompleted");
                     NSLog(@"mp4 file size:%lf MB",[NSData dataWithContentsOfURL:exportSession.outputURL].length/1024.f/1024.f);
                     comepleteBlock(resultPath);
                     
                 }
                     break;
                     
                 case AVAssetExportSessionStatusFailed:
                     
                     //                     NSLog(@"AVAssetExportSessionStatusFailed");
                     //                     CLOUDMESSAGETIPS(@"视频格式转换出错Unknown", 0.8);
//                     [XHToast showCenterWithText:@"视频格式转换出错Unknown"];
                     break;
                     
                 case AVAssetExportSessionStatusCancelled:
                     
                     //                     NSLog(@"AVAssetExportSessionStatusFailed");
                     //                     CLOUDMESSAGETIPS(@"视频格式转换出错Cancelled", 0.8);
//                     [XHToast showCenterWithText:@"视频格式转换出错Cancelled"];
                     break;
                     
             }
             
         }];
        
    }
}
/**
 获取视频缩略图
 */

+ (UIImage *)get_videoThumbImage:(NSURL *)videoURL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:opts];
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    CMTime actualTime;
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime:CMTimeMake(0, 600) actualTime:&actualTime error:&error];
    if (error) {
        return nil;
    }
    return [UIImage imageWithCGImage:img];
}


- (NSMutableArray *)fileArr
{
   if (!_fileArr) {
        _fileArr = [[NSMutableArray alloc] init];
    }
   return _fileArr;
}
@end
