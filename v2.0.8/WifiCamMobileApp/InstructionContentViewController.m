//
//  InstructionContentViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/13.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "InstructionContentViewController.h"

@interface InstructionContentViewController ()<UIScrollViewDelegate> {
    UIView *view;
    AppDelegate *delegate;
}
@property (weak, nonatomic) IBOutlet UILabel *instructionTitle;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;
@property(nonatomic,strong)NSBundle *bundle;
@end

@implementation InstructionContentViewController

-(void)initScrollView
{
    _scrollview.showsVerticalScrollIndicator = false;
    _scrollview.showsHorizontalScrollIndicator = false;
    
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return view;
}
-(void)setupImageView:(int)data
{
    CGFloat height = 0;
    NSMutableArray * imageArray = [[NSMutableArray alloc] init];
    switch (data) {
        case mainScreen_e:
            if([[delegate getLanguage]  isEqual: @"English"]) {
                [imageArray addObject:[UIImage imageNamed:@"mainscreen_english"]];
            } else if([[delegate getLanguage]  isEqual: @"German"]) {
                [imageArray addObject:[UIImage imageNamed:@"mainscreen_german"]];
            } else if([[delegate getLanguage]  isEqual: @"French"]) {
                [imageArray addObject:[UIImage imageNamed:@"mainscreen_french"]];
            } else if([[delegate getLanguage]  isEqual: @"Dutch"]) {
                [imageArray addObject:[UIImage imageNamed:@"mainscreen_dutch"]];
            } else if([[delegate getLanguage]  isEqual: @"Italian"]) {
                [imageArray addObject:[UIImage imageNamed:@"mainscreen_italian"]];
            } else if([[delegate getLanguage]  isEqual: @"Spanish"]) {
                [imageArray addObject:[UIImage imageNamed:@"mainscreen_spanish"]];
            } else if([[delegate getLanguage]  isEqual: @"Portuguese"]) {
                [imageArray addObject:[UIImage imageNamed:@"mainscreen_portuguese"]];
            } else if([[delegate getLanguage]  isEqual: @"Russia"]) {
                [imageArray addObject:[UIImage imageNamed:@"mainscreen_russian"]];
            } else if([[delegate getLanguage]  isEqual: @"Polish"]) {
                [imageArray addObject:[UIImage imageNamed:@"mainscreen_polish"]];
            } else if([[delegate getLanguage]  isEqual: @"Czech"]) {
                [imageArray addObject:[UIImage imageNamed:@"mainscreen_czech"]];
            } else if([[delegate getLanguage]  isEqual: @"Romanian"]) {
                [imageArray addObject:[UIImage imageNamed:@"mainscreen_romanian"]];
            }
            
            break;
        case preview_e:
            if([[delegate getLanguage]  isEqual: @"English"]) {
                [imageArray addObject:[UIImage imageNamed:@"preview_english"]];
                [imageArray addObject:[UIImage imageNamed:@"preview02_english"]];
            } else if([[delegate getLanguage]  isEqual: @"German"]) {
                [imageArray addObject:[UIImage imageNamed:@"preview_german"]];
                [imageArray addObject:[UIImage imageNamed:@"preview02_german"]];
            } else if([[delegate getLanguage]  isEqual: @"French"]) {
                [imageArray addObject:[UIImage imageNamed:@"preview_french"]];
                [imageArray addObject:[UIImage imageNamed:@"preview02_french"]];
            } else if([[delegate getLanguage]  isEqual: @"Dutch"]) {
                [imageArray addObject:[UIImage imageNamed:@"preview_dutch"]];
                [imageArray addObject:[UIImage imageNamed:@"preview02_dutch"]];
            } else if([[delegate getLanguage]  isEqual: @"Italian"]) {
                [imageArray addObject:[UIImage imageNamed:@"preview_italian"]];
                [imageArray addObject:[UIImage imageNamed:@"preview02_italian"]];
            } else if([[delegate getLanguage]  isEqual: @"Spanish"]) {
                [imageArray addObject:[UIImage imageNamed:@"preview_spanish"]];
                [imageArray addObject:[UIImage imageNamed:@"preview02_spanish"]];
            } else if([[delegate getLanguage]  isEqual: @"Portuguese"]) {
                [imageArray addObject:[UIImage imageNamed:@"preview_portuguese"]];
                [imageArray addObject:[UIImage imageNamed:@"preview02_portuguese"]];
            } else if([[delegate getLanguage]  isEqual: @"Russia"]) {
                [imageArray addObject:[UIImage imageNamed:@"preview_russian"]];
                [imageArray addObject:[UIImage imageNamed:@"preview02_russian"]];
            } else if([[delegate getLanguage]  isEqual: @"Polish"]) {
                [imageArray addObject:[UIImage imageNamed:@"preview_polish"]];
                [imageArray addObject:[UIImage imageNamed:@"preview02_polish"]];
            } else if([[delegate getLanguage]  isEqual: @"Czech"]) {
                [imageArray addObject:[UIImage imageNamed:@"preview_czech"]];
                [imageArray addObject:[UIImage imageNamed:@"preview02_czech"]];
            } else if([[delegate getLanguage]  isEqual: @"Romanian"]) {
                [imageArray addObject:[UIImage imageNamed:@"preview_romanian"]];
                [imageArray addObject:[UIImage imageNamed:@"preview02_romanian"]];
            }
            break;
        case filesonDashcam_e:
            if([[delegate getLanguage]  isEqual: @"English"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam_english"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam02_english"]];
            } else if([[delegate getLanguage]  isEqual: @"German"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam_german"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam02_german"]];
            } else if([[delegate getLanguage]  isEqual: @"French"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam_french"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam02_french"]];
            } else if([[delegate getLanguage]  isEqual: @"Dutch"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam_dutch"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam02_dutch"]];
            } else if([[delegate getLanguage]  isEqual: @"Italian"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam_italian"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam02_italian"]];
            } else if([[delegate getLanguage]  isEqual: @"Spanish"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam_spanish"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam02_spanish"]];
            } else if([[delegate getLanguage]  isEqual: @"Portuguese"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam_portuguese"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam02_portuguese"]];
            } else if([[delegate getLanguage]  isEqual: @"Russia"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam_russian"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam02_russian"]];
            } else if([[delegate getLanguage]  isEqual: @"Polish"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam_polish"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam02_polish"]];
            } else if([[delegate getLanguage]  isEqual: @"Czech"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam_czech"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam02_czech"]];
            } else if([[delegate getLanguage]  isEqual: @"Romanian"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam_romanian"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_dashcam02_romanian"]];
            }
            break;
        case filesonMobile_e:
            if([[delegate getLanguage]  isEqual: @"English"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile_english"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile02_english"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile03_english"]];
            } else if([[delegate getLanguage]  isEqual: @"German"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile_german"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile02_german"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile03_german"]];
            } else if([[delegate getLanguage]  isEqual: @"French"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile_french"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile02_french"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile03_french"]];
            } else if([[delegate getLanguage]  isEqual: @"Dutch"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile_dutch"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile02_dutch"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile03_dutch"]];
            } else if([[delegate getLanguage]  isEqual: @"Italian"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile_italian"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile02_italian"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile03_italian"]];
            } else if([[delegate getLanguage]  isEqual: @"Spanish"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile_spanish"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile02_spanish"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile03_spanish"]];
            } else if([[delegate getLanguage]  isEqual: @"Portuguese"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile_portuguese"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile02_portuguese"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile03_portuguese"]];
            } else if([[delegate getLanguage]  isEqual: @"Russia"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile_russian"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile02_russian"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile03_russian"]];
            } else if([[delegate getLanguage]  isEqual: @"Polish"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile_polish"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile02_polish"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile03_polish"]];
            } else if([[delegate getLanguage]  isEqual: @"Czech"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile_czech"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile02_czech"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile03_czech"]];
            } else if([[delegate getLanguage]  isEqual: @"Romanian"]) {
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile_romanian"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile02_romanian"]];
                [imageArray addObject:[UIImage imageNamed:@"files_on_mobile03_romanian"]];;
            }
            break;
        case dashcamMenu_e:
            if([[delegate getLanguage]  isEqual: @"English"]) {
                [imageArray addObject:[UIImage imageNamed:@"dashcam_menu_english"]];
            } else if([[delegate getLanguage]  isEqual: @"German"]) {
                [imageArray addObject:[UIImage imageNamed:@"dashcam_menu_german"]];
            } else if([[delegate getLanguage]  isEqual: @"French"]) {
                [imageArray addObject:[UIImage imageNamed:@"dashcam_menu_french"]];
            } else if([[delegate getLanguage]  isEqual: @"Dutch"]) {
                [imageArray addObject:[UIImage imageNamed:@"dashcam_menu_dutch"]];
            } else if([[delegate getLanguage]  isEqual: @"Italian"]) {
                [imageArray addObject:[UIImage imageNamed:@"dashcam_menu_italian"]];
            } else if([[delegate getLanguage]  isEqual: @"Spanish"]) {
                [imageArray addObject:[UIImage imageNamed:@"dashcam_menu_spanish"]];
            } else if([[delegate getLanguage]  isEqual: @"Portuguese"]) {
                [imageArray addObject:[UIImage imageNamed:@"dashcam_menu_portuguese"]];
            } else if([[delegate getLanguage]  isEqual: @"Russia"]) {
                [imageArray addObject:[UIImage imageNamed:@"dashcam_menu_russian"]];
            } else if([[delegate getLanguage]  isEqual: @"Polish"]) {
                [imageArray addObject:[UIImage imageNamed:@"dashcam_menu_polish"]];
            } else if([[delegate getLanguage]  isEqual: @"Czech"]) {
                [imageArray addObject:[UIImage imageNamed:@"dashcam_menu_czech"]];
            } else if([[delegate getLanguage]  isEqual: @"Romanian"]) {
                [imageArray addObject:[UIImage imageNamed:@"dashcam_menu_romanian"]];
            }
            break;
        default:
            break;
    }
    //[imageArray removeAllObjects];
    view = [[UIView alloc] init];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat scale = 1.0;
    for(int i = 0;i<imageArray.count;i++) {
        UIImageView *someImageView = [[UIImageView alloc] initWithImage:imageArray[i]];
        scale = screenWidth/someImageView.frame.size.width;
        someImageView.frame = CGRectMake(0, height, someImageView.frame.size.width*scale, someImageView.frame.size.height*scale);
        someImageView.contentMode = UIViewContentModeScaleAspectFit;
        height = height+someImageView.frame.size.height;
        [view addSubview:someImageView];
    }
    [self.scrollview addSubview:view];
    _scrollview.contentSize = CGSizeMake(screenWidth,height);
    
    
    //CGFloat widthScale = _scrollview.bounds.size.width / imageWidth;
    //CGFloat heightScale = _scrollview.bounds.size.height / height;
    //_scrollview.minimumZoomScale = min(widthScale, heightScale);
    //_scrollview.minimumZoomScale = 0.5;
    //_scrollview.maximumZoomScale = 0.5;
    //_scrollview.zoomScale = 0.5;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    self.instructionTitle.text = [delegate getStringForKey:@"SetInstructionTitle" withTable:@""];
    [self initScrollView];
    [self setupImageView:_receiver];
    _scrollview.delegate = self;
    // Do any additional setup after loading the view.
}
- (IBAction)Back:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self.navigationController popViewControllerAnimated:YES];
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
