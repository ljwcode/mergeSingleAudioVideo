//
//  ViewController.m
//  mergeSingleAudioVideo
//
//  Created by 1 on 2020/11/11.
//

#import "ViewController.h"
#import <MBProgressHUD_Add/UIViewController+MBPHUD.h>
#import <AVFoundation/AVFoundation.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showHUDMessage:@"loading..."];
    
    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSURL *videoURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"minemine" ofType:@"mp4"]];
    NSURL *audioURL = [NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"mine" ofType:@"mp3"]];
    
    //设置输出路径
    NSURL *outPutURL = [NSURL fileURLWithPath:[documents stringByAppendingPathComponent:@"AVMeger.mp4"]];
    CMTime starTime = kCMTimeZero; //设置起止时间
    AVMutableComposition *compostion = [AVMutableComposition composition];//设置可变音视频轨道集合
    
    //设置音频采集
    AVURLAsset *audioURLAsset = [[AVURLAsset alloc]initWithURL:audioURL options:nil];
    CMTimeRange audioTime = CMTimeRangeMake(kCMTimeZero, audioURLAsset.duration);
    AVMutableCompositionTrack *audioTrack = [compostion addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *audioAssetTrack = [[audioURLAsset tracksWithMediaType:AVMediaTypeAudio]firstObject];
    [audioTrack insertTimeRange:audioTime ofTrack:audioAssetTrack atTime:starTime error:nil];
    
    //设置视频采集
    AVURLAsset *videoURLAsset = [[AVURLAsset alloc]initWithURL:videoURL options:nil];
    CMTimeRange videoTime = CMTimeRangeMake(starTime, videoURLAsset.duration);
    AVMutableCompositionTrack *videoTrack = [compostion addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAssetTrack *videoAssetTrack = [[videoURLAsset tracksWithMediaType:AVMediaTypeVideo]firstObject];
    [videoTrack insertTimeRange:videoTime ofTrack:videoAssetTrack atTime:starTime error:nil];
    
    
    //设置音视频输出
    AVAssetExportSession *assetExportSession = [[AVAssetExportSession alloc]initWithAsset:compostion presetName:AVAssetExportPresetHighestQuality];
    assetExportSession.outputFileType = AVFileTypeQuickTimeMovie;
    assetExportSession.outputURL = outPutURL;
    assetExportSession.shouldOptimizeForNetworkUse = YES;
    [assetExportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self assetPlayerURL:outPutURL];
        });
    }];
    
    // Do any additional setup after loading the view.
}

-(void)assetPlayerURL:(NSURL *)url{
    AVPlayerItem *playerItem = [[AVPlayerItem alloc]initWithURL:url];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [playerLayer setFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenWidth)];
    [imageView setImage:[UIImage imageNamed:@"applelogo.png"]];
    [self.view addSubview:imageView];
    [imageView.layer addSublayer:playerLayer];
    [self hideHUD];
    [self showHUDMessage:@"合并完成"];
    [player play];
}


@end
