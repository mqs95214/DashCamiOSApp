//
//  AboutPage2ViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "DashcamInitViewController.h"

@interface DashcamInitViewController ()
{
    AppDelegate *delegate;
}

@property(nonatomic,strong)NSBundle *bundle;
@end

@implementation DashcamInitViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    
    
}
-(void)viewWillAppear:(BOOL)animated {
    UILabel *label;
    label = [self getLenghtText];
    UIFont *font;
    font = [self adjFontSize:label];
    CGFloat fontSize = font.pointSize;
    self.info1.font = [font fontWithSize:fontSize];
    self.info2.font = [font fontWithSize:fontSize];
    self.info3.font = [font fontWithSize:fontSize];
    self.info4.font = [font fontWithSize:fontSize];
    self.info5.font = [font fontWithSize:fontSize];
    self.info6.font = [font fontWithSize:fontSize];
    self.info7.font = [font fontWithSize:fontSize];
    self.info1.text = [NSString stringWithFormat:@"%@\n%@\n%@\n%@",[delegate getStringForKey:@"SetDashcamHomePageInfo1_K7" withTable:@""],[delegate getStringForKey:@"SetDashcamHomePageInfo2_K7" withTable:@""],[delegate getStringForKey:@"SetDashcamHomePageInfo3_K7" withTable:@""],[delegate getStringForKey:@"SetDashcamHomePageInfo4_K7" withTable:@""]];
    self.info2.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SelectCountry" withTable:@""]];
    self.info3.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetTimeandDate" withTable:@""]];
    self.info4.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SelectSpeedUnit" withTable:@""]];
    self.info5.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetWirelessLinkPassword" withTable:@""]];
    self.info6.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetSDFormat" withTable:@""]];
    self.info7.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SelectInstallationPosition" withTable:@""]];
    _nextBtn.titleLabel.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetNext" withTable:@""]];
}
- (IBAction)nextBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self performSegueWithIdentifier:@"dashcamHome_show" sender:sender];
    /*UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"dashcamSelectCountry"];
    [self presentViewController:vc animated:YES completion:NULL];*/
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    SelectCountryViewController *vc = [sb instantiateViewControllerWithIdentifier:@"dashcamSelectCountry"];
    [self.navigationController pushViewController:vc animated:YES];
}
-(UILabel*)getLenghtText {
    UILabel *label = [[UILabel alloc] init];
    UIFont *font = [UIFont fontWithName:@"Frutiger LT 55 Roman" size:18];//
    NSMutableArray *arrayText = [[NSMutableArray alloc] init];
    NSMutableArray *arrayLenght = [[NSMutableArray alloc] init];
    NSRange range;
    NSString *str;
    NSString *curStr;
    int selectedIndex = 0;
    int count = 0;
    int maxLenght = 0;
    
    while(count < 7) {
        if(count == 0) {
            str = self.info1.text;
        } else if(count == 1) {
            str = self.info2.text;
        } else if(count == 2) {
            str = self.info3.text;
        } else if(count == 3) {
            str = self.info4.text;
        } else if(count == 4) {
            str = self.info5.text;
        } else if(count == 5) {
            str = self.info6.text;
        } else if(count == 6) {
            str = self.info7.text;
        }
        do {
            range = [str rangeOfString:@"\n"];
            if(range.location == NSNotFound) {
                
            } else {
                curStr = [str substringWithRange:NSMakeRange(0, range.location)];
                [arrayText addObject:curStr];
                [arrayLenght addObject:[NSString stringWithFormat:@"%d",curStr.length]];
                
                str = [str substringWithRange:NSMakeRange(range.location+1, str.length-(range.location+1))];
            }
        } while(range.location != NSNotFound);
        [arrayText addObject:str];
        [arrayLenght addObject:[NSString stringWithFormat:@"%d",str.length]];
        count++;
    }
    
    for(int i=0;i<arrayText.count;i++) {
        if([[arrayLenght objectAtIndex:i] intValue] > maxLenght) {
            maxLenght = [[arrayLenght objectAtIndex:i] intValue];
            selectedIndex = i;
        }
    }
    if(arrayText.count > selectedIndex)
        [label setText:[arrayText objectAtIndex:selectedIndex]];
    else {
        [label setText:@""];
    }
    font = [font fontWithSize:18];
    [label setFont:font];
    return label;
}
-(UIFont*)adjFontSize:(UILabel*)label{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float curFontSize = label.font.pointSize;
    UIFont *font = label.font;
    
    CGRect rect;
    rect = [self.info1 bounds];
    if(rect.size.width == 0.0f || rect.size.height == 0.0f) {
        return 0;
    }
    while(curFontSize > label.minimumScaleFactor && curFontSize > 0.0f) {
        CGSize size = CGSizeZero;
        if(label.numberOfLines == 1) {
            size = [label.text sizeWithFont:font constrainedToSize:CGSizeMake(rect.size.width, 0.0f) lineBreakMode:NSLineBreakByClipping];
        } else {
            size = [label.text sizeWithFont:font constrainedToSize:CGSizeMake(rect.size.width, 0.0f) lineBreakMode:NSLineBreakByWordWrapping];
        }
        
        if(size.width < screenWidth*0.7 && size.height <= rect.size.height) {
            break;
        }
        curFontSize -= 1.0f;
        font = [font fontWithSize:curFontSize];
    }
    if(curFontSize <= label.minimumScaleFactor) {
        curFontSize = label.minimumScaleFactor;
    }
    if(curFontSize < 0.0f) {
        curFontSize = 1.0f;
    }
    font = [font fontWithSize:curFontSize];
    return font;
}
- (NSString*)getStringForKey:(NSString*)key withTable:(NSString*)table {
    if(_bundle) {
        return NSLocalizedStringFromTableInBundle(key, table, _bundle, @"");
    }
    return NSLocalizedStringFromTable(key, table, @"");
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"dashcamHome_show"]) {
        UIViewController *controller = segue.destinationViewController;
        if([controller isKindOfClass:[UINavigationController class]]) {
            NSLog(@"dashcamHome_show->UINavigationController");
        }
    }
}
-(void) performSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    

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
