//
//  ViewController.m
//  VideoUpload
//
//  Created by xiyang on 2017/7/13.
//  Copyright © 2017年 xiyang. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CNFile.h"
#import <AVFoundation/AVFoundation.h>

#import "XYNetworking.h"
@interface ViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initSubViews];
    [self requestData];
}
-(void)initSubViews{
    
}
-(void)requestData{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    
    
    
}

- (IBAction)btnClick {
    [self takeVideo];
}

-(void)takeVideo{
    
    UIImagePickerController *imagePickerVc = [[UIImagePickerController alloc] init];
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVc.sourceType = sourceType;
        imagePickerVc.mediaTypes =  [[NSArray alloc] initWithObjects:(NSString*)kUTTypeMovie,nil];
        imagePickerVc.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        
        imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        
        imagePickerVc.delegate = self;
        [self presentViewController:imagePickerVc animated:YES completion:nil];
    } else {
        
    }
}
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    // 视频处理
    NSURL *videoUrl = info[UIImagePickerControllerMediaURL];//视频路径
    
    //        UIImage *image = [self get_videoThumbImage:videoUrl];
    //        self.videoImageView.image = image;
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([videoUrl path])) {
            UISaveVideoAtPathToSavedPhotosAlbum([videoUrl path], self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
        }
    }
}
//视频保存到相册之后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        // 保存失败
//        [XHToast showCenterWithText:@"视频保存失败!"];
    }else {
        // 处理视频
        NSURL *videoUrl = [NSURL fileURLWithPath:videoPath];
//        UIImage *image = [XYUploadImageManager get_videoThumbImage:videoUrl];
//        [self configureLocalVideoPath:videoPath image:image];
        dispatch_async(dispatch_get_main_queue(), ^{
            CNFile *file = [[CNFile alloc] init];
            file.filePath = videoPath;
//            [self movFileTransformToMP4WithSourceUrl:videoUrl completion:^(NSString *Mp4FilePath) {
//                NSData *data = [NSData dataWithContentsOfFile:Mp4FilePath];
//                NSString *randomStr = [NSString stringWithFormat:@"%i",arc4random()];
//                
//                NSString *lastComponent = [Mp4FilePath lastPathComponent];
//                [XYNetworking uploadWithURL:@"oUpload.php" params:@{@"r":randomStr} fileData:data name:@"file" fileName:lastComponent mimeType:@"video/*" success:^(id responseObject) {
//                   
//                } failure:^(NSError *error) {
//                    
//                    
//                }];
//            }];
            
 
        });
       
        
    }
    
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
