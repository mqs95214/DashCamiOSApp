//
//  AboutPage4ViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "AboutPage4ViewController.h"
#import "InstructionContentViewController.h"

@interface AboutPage4ViewController ()
{
    AppDelegate *delegate;
}
@property(nonatomic,strong)NSBundle *bundle;
@end

@implementation AboutPage4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    
    self.instructionTitle.text = [delegate getStringForKey:@"SetInstructionTitle" withTable:@""];
    self.mainScreenText.text = [delegate getStringForKey:@"SetMainScreen" withTable:@""];
    self.previewText.text = [delegate getStringForKey:@"SetPreview" withTable:@""];
    self.filesonDashCamText.text = [delegate getStringForKey:@"SetFileOnDashCam" withTable:@""];
    self.filesonMobileText.text = [delegate getStringForKey:@"SetFileOnMobile" withTable:@""];
    self.dashCamMenuText.text = [delegate getStringForKey:@"SetMenu" withTable:@""];
    NSLog(@"AboutPage4ViewController");
    // Do any additional setup after loading the view.
}
- (IBAction)Back:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)MainScreenTouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    _sendData = 0;
    [self performSegueWithIdentifier:@"instruction_push" sender:sender];
}
- (IBAction)PreviewTouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    _sendData = 1;
    [self performSegueWithIdentifier:@"instruction_push" sender:sender];
}
- (IBAction)FilesonDashcamTouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    _sendData = 2;
    [self performSegueWithIdentifier:@"instruction_push" sender:sender];
}

- (IBAction)FilesonMobileTouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    _sendData = 3;
    [self performSegueWithIdentifier:@"instruction_push" sender:sender];
}
- (IBAction)DashcamMenuTouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    _sendData = 4;
    [self performSegueWithIdentifier:@"instruction_push" sender:sender];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"instruction_push"]) {
        InstructionContentViewController *vc = segue.destinationViewController;
        vc.receiver = _sendData;
        
    }

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
