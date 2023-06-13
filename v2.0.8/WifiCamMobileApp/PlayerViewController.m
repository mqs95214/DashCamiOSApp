//
//  PlayerViewController.m
//  WifiCamMobileApp
//
//  Created by Rex Chih on 2018/5/18.
//  Copyright © 2018年 iCatchTech. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVKit/AVKit.h>

@interface PlayerViewController ()
@property (weak, nonatomic) IBOutlet UIView *player_displayView;
@end

@implementation PlayerViewController{
    AVPlayer *_player;
    AVPlayerLayer *_playerLayer;
    AVPlayerViewController *avPlayerViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status != PHAuthorizationStatusAuthorized )
    {
        NSLog(@"PlaymediaVC ask for request");
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    PHVideoRequestOptions *options = [PHVideoRequestOptions new];
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:_mediaAsset options:options resultHandler:^(AVAsset* avasset, AVAudioMix* audioMix, NSDictionary* info){
        
        AVURLAsset *videoAsset = (AVURLAsset*)avasset;
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:videoAsset];
        
        self.avPlayer = [AVPlayer playerWithPlayerItem:item];
        self.avPlayerViewController = [[AVPlayerViewController alloc] init];
        self.avPlayerViewController.player = self.avPlayer;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self addChildViewController:self.avPlayerViewController];
            [self.view addSubview:self.avPlayerViewController.view];
            self.avPlayerViewController.view.frame=self.view.frame;
            [self.avPlayerViewController.player play];
        });
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
