//
//  MpbSegmentViewController.h
//  WifiCamMobileApp
//
//  Created by ZJ on 2016/11/18.
//  Copyright © 2016年 iCatchTech. All rights reserved.
//

#import <UIKit/UIKit.h>

enum MpbState{
    MpbStateNor = 0,
    MpbStateEdit,
};

enum MpbMediaType{
    MpbMediaTypePhoto = 0,
    MpbMediaTypeVideo,
};

enum MpbShowState {
    MpbShowStateNor = 0,
    MpbShowStateInfo,
};

enum EditSelect_e1 {
    PBEditNone = 0,
    PBEditLockAction,
    PBEditUnLockAction,
    PBEditDeleteAction,
    PBEditDownloadAction
};

@class MpbSegmentViewController;

@protocol MpbSegmentViewControllerDelegate <NSObject>

- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController goHome:(id)sender;
- (MpbState)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController edit:(id)sender;
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController delete:(id)sender;
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController action:(id)sender;
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController play:(id)sender;

- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController OKAction:(int)ActionType;
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController CancelAction:(id)sender;

- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController LockAction:(id)sender;
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController UnLockAction:(id)sender;
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController SeekToSecond:(double)value;
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController sliderTouchDown:(BOOL)isSeek;
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController playback_fullscreenBT_clicked:(id)sender;
- (void)mpbSegmentViewController:(MpbSegmentViewController *)mpbSegmentViewController cancelDownload:(id)sender;
@end

@interface MpbSegmentViewController : UIViewController <UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    int pageIndex;
    NSMutableArray *viewControllers;
    long long downloadTotal;
    int downloadWait;
    int downloadFailed;
    int downloadDone;
    int downloadCurIndex;
}

@property(weak, nonatomic) IBOutlet UIBarButtonItem *actionButton;
@property(nonatomic) NSUInteger videoIndex;
@property(nonatomic) NSInteger fileType;
@property(nonatomic) UIImage* thumbImage;
@property(nonatomic) NSString *HttpFileNamePath;
@property (nonatomic, weak) IBOutlet id<MpbSegmentViewControllerDelegate> delegate;


@property(nonatomic) double BufferValue;
@property(nonatomic) double seekvalue;
@property(nonatomic) double SliderMaxValue;
@property(nonatomic) NSString *PlayerPath;
@property(nonatomic) BOOL NodePlayerIsPlaying;
@property(nonatomic) BOOL NodePlayerFirstFramePic;
@property(nonatomic) BOOL EditState;
@property(nonatomic) int ActionType;
@property(nonatomic) int SelectNum;
@property(nonatomic) BOOL isVideo;
@property(nonatomic) NSMutableArray *list;
@property(nonatomic) NSMutableArray *downloadStateList;
@property(nonatomic) NSArray *contentList;
@property (weak, nonatomic) IBOutlet UIView *downloadManagerView;
@property (weak, nonatomic) IBOutlet UITableView *downloadTableView;
@property (weak, nonatomic) IBOutlet UILabel *downloadCurrentResult;
@property (weak, nonatomic) IBOutlet UIView *downloadManagerCompletedView;
@property (weak, nonatomic) IBOutlet UILabel *downloadSuccess_Completed;
@property (weak, nonatomic) IBOutlet UILabel *downloadFailed_Completed;
@property (weak, nonatomic) IBOutlet UILabel *downloadCompletedText;
@property (weak, nonatomic) IBOutlet UILabel *downloadManagerTitle;
@property (weak, nonatomic) IBOutlet UILabel *downloadManagerCompletedTitle;
@property (weak, nonatomic) IBOutlet UIButton *downloadManagerOKBtn;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIView *pleaseWaitView;
-(void) updatePreview;
-(void) updateEditCount:(int)count;
-(void) UpdateActionIcon;
-(void) UpdateEditBar;
-(void) updateSeekBarValue;
-(void) updateSliderMaxValue;
-(void) updateBufferSliderValue;
-(void) updatePlayerStatus;
-(void) updatePlayerStatusSetFalse;
-(void) updatePlayerStatusSetTrue;
-(void) hideFullBackView:(bool)hide;
-(void)setPleaseWaitViewVisibility:(BOOL)on;

-(double) getBufferValue;
-(double) getNodePlayerPosition;
-(void) setNodePlayerPositionZero;
-(void) NovatekSliderMaxValue;
-(void) NovatekSetPlayPath;
-(void) NovatekPlayerStart;
-(void) NovatekPlayerPause;
-(void) NovatekPlayerStop;
-(void) NovatekPlayerInit;
-(void) NodePlayerClearView;
-(void) NodePlayerSeekToZero;
-(BOOL) NovatekPlayerStatus;

-(void) downloadCompletedNotice;
-(void)initDownloadManager;
-(void)addDownloadManager:(NSString *)fileName fileSize:(float)fileSize;
-(void) updateDownloadCell;
-(void) downloadFailed;
-(void) downloadSuccess;
-(void) downloadProcessingNumber:(int)currentIndex total:(long long)total;
-(void) setDownloadProgress:(unsigned long)number Progress:(unsigned long)progress ProgressStorage:(float)progressStorage;
-(bool)needDownloadFile:(int)selectedFile;
-(bool)needUpdateProgress:(int)index;

-(UIFont*)adjFontSize:(UILabel*)label;
@end
