//
//  AboutPage2ViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "SelectCountryViewController.h"

@interface SelectCountryViewController ()
{
    AppDelegate *delegate;
}

@property(nonatomic,strong)NSBundle *bundle;
@end

@implementation SelectCountryViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    
    
    _backBtn.titleLabel.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetBack" withTable:@""]];
    _nextBtn.titleLabel.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetNext" withTable:@""]];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self initData];
    self.NVTGetHttpValueDict = [[NSMutableDictionary alloc] init];
    [self NVTGetHttpCmd:@"3014"];
    //time zones 3109   speed units 3111
    curCountry = [[self.NVTGetHttpValueDict objectForKey:@"3110"] intValue];
    if(curCountry == country_others) {
        curCountry = country_others + 1 + [[self.NVTGetHttpValueDict objectForKey:@"3109"] intValue];;
    }
    //curCountry = 34;
    
}
- (IBAction)backBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if(curDisplayMode != countryMode) {
        [self initCountryList];
        [_tableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        curDisplayMode = countryMode;
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}
- (IBAction)nextBtn_TouchUp:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    NSString *str;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    SetTimeDateViewController *vc = [sb instantiateViewControllerWithIdentifier:@"dashcamSetTimeDate"];
    if(curCountry < country_others) {
        str = [NSString stringWithFormat:@"%d",curCountry];
        [self NVTSendHttpCmd:@"3110" Par2:str];
    } else {
        str = [NSString stringWithFormat:@"%d",country_others];
        [self NVTSendHttpCmd:@"3110" Par2:str];
        str = [NSString stringWithFormat:@"%d",curCountry - country_others - 1];
        [self NVTSendHttpCmd:@"3109" Par2:str];
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}
-(void) initData {
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self initCountryList];
    
}
-(void) initCountryList {
    _titleText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SelectCountry" withTable:@""]];
    curDisplayMode = countryMode;
    list = [[NSMutableArray alloc] init];
    DashcamListItem *item;
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_UnitedState" withTable:@""]] ImageName:@"Flag_United_State" DisplayType:0];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_Canada" withTable:@""]] ImageName:@"Flag_Canada" DisplayType:0];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_Russia" withTable:@""]] ImageName:@"Flag_Russia" DisplayType:0];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_Spain" withTable:@""]] ImageName:@"Flag_Spain" DisplayType:0];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_Germany" withTable:@""]] ImageName:@"Flag_Germany" DisplayType:0];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_France" withTable:@""]] ImageName:@"Flag_France" DisplayType:0];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_Italy" withTable:@""]] ImageName:@"Flag_Italy" DisplayType:0];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_Netherlands" withTable:@""]] ImageName:@"Flag_Netherlands" DisplayType:0];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_Belgium" withTable:@""]] ImageName:@"Flag_Belgium" DisplayType:0];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_Poland" withTable:@""]] ImageName:@"Flag_Poland" DisplayType:0];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_Czech" withTable:@""]] ImageName:@"Flag_Czech" DisplayType:0];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_Romania" withTable:@""]] ImageName:@"Flag_Romania" DisplayType:0];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_UnitedKingdom" withTable:@""]] ImageName:@"Flag_United_Kingdom" DisplayType:0];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_Other" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
}

-(void) initUnitedStatesCountryList {
    _titleText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SelectCountry" withTable:@""]];
    curDisplayMode = countryUnitedStatesMode;
    list = [[NSMutableArray alloc] init];
    DashcamListItem *item;
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(EST)",[delegate getStringForKey:@"SetCountry_UnitedState" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(CST)",[delegate getStringForKey:@"SetCountry_UnitedState" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(MST)",[delegate getStringForKey:@"SetCountry_UnitedState" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(PST)",[delegate getStringForKey:@"SetCountry_UnitedState" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(AKST)",[delegate getStringForKey:@"SetCountry_UnitedState" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(HST)",[delegate getStringForKey:@"SetCountry_UnitedState" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
}

-(void) initCanadaCountryList {
    _titleText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SelectCountry" withTable:@""]];
    curDisplayMode = countryCanadaMode;
    list = [[NSMutableArray alloc] init];
    DashcamListItem *item;
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(NST)",[delegate getStringForKey:@"SetCountry_Canada" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(AST)",[delegate getStringForKey:@"SetCountry_Canada" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(EST)",[delegate getStringForKey:@"SetCountry_Canada" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(CST)",[delegate getStringForKey:@"SetCountry_Canada" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(MST)",[delegate getStringForKey:@"SetCountry_Canada" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(PST)",[delegate getStringForKey:@"SetCountry_Canada" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
}

-(void) initRussiaCountryList {
    _titleText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SelectCountry" withTable:@""]];
    curDisplayMode = countryRussiaMode;
    list = [[NSMutableArray alloc] init];
    DashcamListItem *item;
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(KALT)",[delegate getStringForKey:@"SetCountry_Russia" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(MSK)",[delegate getStringForKey:@"SetCountry_Russia" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(SAMT)",[delegate getStringForKey:@"SetCountry_Russia" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(YEKT)",[delegate getStringForKey:@"SetCountry_Russia" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(OMST)",[delegate getStringForKey:@"SetCountry_Russia" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(KRAT)",[delegate getStringForKey:@"SetCountry_Russia" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(IRKT)",[delegate getStringForKey:@"SetCountry_Russia" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(YAKT)",[delegate getStringForKey:@"SetCountry_Russia" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(VLAT)",[delegate getStringForKey:@"SetCountry_Russia" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(MAGT)",[delegate getStringForKey:@"SetCountry_Russia" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:[NSString stringWithFormat:@"%@(PETT)",[delegate getStringForKey:@"SetCountry_Russia" withTable:@""]] ImageName:@"" DisplayType:1];
    [list addObject:item];
}
-(void) initTimeZones {
    _titleText.text = [NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SelectTimeZone" withTable:@""]];
    curDisplayMode = dstMode;
    list = [[NSMutableArray alloc] init];
    DashcamListItem *item;
    item = [[DashcamListItem alloc] initWithData:@"-12" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"-11" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"-10" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"-9" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"-8" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"-7" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"-6" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"-5" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"-4" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"-3.5" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"-3" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"-2.5" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"-2" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"-1" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"GMT" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"+1" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"+2" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"+3" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"+4" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"+5" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"+6" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"+7" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"+8" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"+9" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"+10" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"+11" ImageName:@"" DisplayType:1];
    [list addObject:item];
    item = [[DashcamListItem alloc] initWithData:@"+12" ImageName:@"" DisplayType:1];
    [list addObject:item];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    int index = unknown_country;
    DashcamInitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DashcamInit" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSeparatorStyleNone;
    
    DashcamListItem *item =[list objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageNamed:item.imageName];
    if(item.type == 0) {
        [cell.text setHidden:NO];
        [cell.iconImage setHidden:NO];
        [cell.centerText setHidden:YES];
        [cell.text setText:item.text];
        [cell.iconImage setImage:image];
    } else {
        
        [cell.text setHidden:YES];
        [cell.iconImage setHidden:YES];
        [cell.centerText setHidden:NO];
        [cell.centerText setText:item.text];
    }
    if(curDisplayMode == countryMode) {
        if(curCountry >= country_UnitedStates_EST && curCountry <= country_UnitedStates_HST) {
            index = 0;
        } else if(curCountry >= country_Canada_NST && curCountry <= country_Canada_PST) {
            index = 1;
        } else if(curCountry >= country_Russia_KALT && curCountry <= country_Russia_PETT) {
            index = 2;
        } else if(curCountry >= country_Spain && curCountry < country_others) {
            index = curCountry - 20;
        } else if(curCountry >= country_others) {
            index = country_others - 20;
        } else if(curCountry == unknown_country) {
            index = unknown_country;
        }
        if(index != unknown_country && index == indexPath.row) {
            cell.backgroundImage.highlighted = YES;
        } else {
            cell.backgroundImage.highlighted = NO;
        }
    } else if(curDisplayMode == countryUnitedStatesMode) {
        if(curCountry >= country_UnitedStates_EST && curCountry <= country_UnitedStates_HST) {
            index = curCountry;
        } else {
            index = unknown_country;
        }
        if(index != unknown_country && index == indexPath.row) {
            cell.backgroundImage.highlighted = YES;
        } else {
            cell.backgroundImage.highlighted = NO;
        }
    } else if(curDisplayMode == countryCanadaMode) {
        if(curCountry >= country_Canada_NST && curCountry <= country_Canada_PST) {
            index = curCountry - country_Canada_NST;
        } else {
            index = unknown_country;
        }
        if(index != unknown_country && index == indexPath.row) {
            cell.backgroundImage.highlighted = YES;
        } else {
            cell.backgroundImage.highlighted = NO;
        }
    } else if(curDisplayMode == countryRussiaMode) {
        if(curCountry >= country_Russia_KALT && curCountry <= country_Russia_PETT) {
            index = curCountry - country_Russia_KALT;
        } else {
            index = unknown_country;
        }
        if(index != unknown_country && index == indexPath.row) {
            cell.backgroundImage.highlighted = YES;
        } else {
            cell.backgroundImage.highlighted = NO;
        }
    } else if(curDisplayMode == dstMode) {
        if(curCountry >= country_others) {
            index = curCountry - country_others - 1;
        } else {
            index = unknown_country;
        }
        if(index != unknown_country && index == indexPath.row) {
            cell.backgroundImage.highlighted = YES;
        } else {
            cell.backgroundImage.highlighted = NO;
        }
    }
    //UIView *view = [[UIView alloc] init];
    //view.backgroundColor = [UIColor clearColor];
    //cell.backgroundView = view;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    int index = 0;
    NSIndexPath *indexPath_top = [NSIndexPath indexPathForRow:0 inSection:0];
    DashcamInitTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DashcamInit" forIndexPath:indexPath];
    DashcamListItem *item =[list objectAtIndex:indexPath.row];
    if([item.text isEqualToString:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_Other" withTable:@""]]]) {
        [self initTimeZones];
        [tableView reloadData];
        [tableView scrollToRowAtIndexPath:indexPath_top atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } else if([item.text isEqualToString:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_UnitedState" withTable:@""]]]) {
        [self initUnitedStatesCountryList];
        [tableView reloadData];
        [tableView scrollToRowAtIndexPath:indexPath_top atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } else if([item.text isEqualToString:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_Canada" withTable:@""]]]) {
        [self initCanadaCountryList];
        [tableView reloadData];
        [tableView scrollToRowAtIndexPath:indexPath_top atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } else if([item.text isEqualToString:[NSString stringWithFormat:@"%@",[delegate getStringForKey:@"SetCountry_Russia" withTable:@""]]]) {
        [self initRussiaCountryList];
        [tableView reloadData];
        [tableView scrollToRowAtIndexPath:indexPath_top atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } else {
        if(curDisplayMode == countryMode) {
            if(indexPath.row > 2 && indexPath.row < 13) {
                curCountry = indexPath.row + 20;
            }
        } else if(curDisplayMode == countryUnitedStatesMode) {
            curCountry = indexPath.row;
        } else if(curDisplayMode == countryCanadaMode) {
            curCountry = indexPath.row + country_Canada_NST;
        } else if(curDisplayMode == countryRussiaMode) {
            curCountry = indexPath.row + country_Russia_KALT;
        } else if(curDisplayMode == dstMode) {
            curCountry = (country_others + 1) + indexPath.row;
        }
        [tableView reloadData];
    }
    
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section { 
    return [list count];
}
- (void)NVTSendHttpCmd:(NSString *)cmd Par2:(NSString *)par{
    // 1.URL
    NSString *tempcmd = @"";
    NSString *fullcmd = @"";
    fullcmd = [tempcmd stringByAppendingFormat:@"%s%@%s%@","http://192.168.1.254/?custom=1&cmd=",cmd,"&par=",par];
    NSURL *httpurl = [NSURL URLWithString:fullcmd];
    // 2.封装请求
    NSURLRequest *request = [NSURLRequest requestWithURL:httpurl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:5];
    // 3.发送请求
    NSURLResponse *response = nil;
    NSError *error = nil;
    // 该方法在iOS9.0之后被废弃
    // 下面的方法有3个参数，参数分别为NSURLRequest，NSURLResponse**，NSError**，后面两个参数之所以传地址进来是为了在执行该方法的时候在方法的内部修改参数的值。这种方法相当于让一个方法有了多个返回值
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    //NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"NAVATAKE STRING = %@",str);
    
    
    // 错误信息
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
        // 此处需要解决iOS9.0之后，HTTP不能正常使用的问题，若不做任何处理，会打印“The resource could not be loaded because the App Transport Security policy requires the use of a secure connection” 错误信息。
    }
    else{
        
    }
    
    
    /*
     NSError *newError = nil;
     NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&newError];
     // 获取对应的数据信息
     
     NSArray *array = dictionary[@"news"];
     NSDictionary *dic = array[0];
     
     NSLog(@"%@", dic[@"title"]);
     */
    
}
- (NSString *)NVTGetHttpCmd:(NSString *)cmd{
    // 1.URL
    NSString *tempcmd = @"";
    NSString *fullcmd = @"";
    fullcmd = [tempcmd stringByAppendingFormat:@"%s%@","http://192.168.1.254/?custom=1&cmd=",cmd];
    NSURL *url = [NSURL URLWithString:fullcmd];
    // 2.封装请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10];
    // 3.发送请求
    NSURLResponse *response = nil;
    NSError *error = nil;
    // 该方法在iOS9.0之后被废弃
    // 下面的方法有3个参数，参数分别为NSURLRequest，NSURLResponse**，NSError**，后面两个参数之所以传地址进来是为了在执行该方法的时候在方法的内部修改参数的值。这种方法相当于让一个方法有了多个返回值
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"NAVATAKE STRING = %@",str);
    NSXMLParser *m_parser = [[NSXMLParser alloc] initWithData:data];
    
    [m_parser setDelegate:self];
    
    BOOL flag = [m_parser parse]; //开始解析
    if(flag) {
        NSLog(@"解析指定路径的xml文件成功");
    }
    else {
        NSLog(@"解析指定路径的xml文件失败");
    }
    // NSLog(@"NVT ALL COMMAND = @%@",[self.NVTGetHttpValueDict allKeys]);
    //for(NSString *key in self.NVTGetHttpValueDict){
    //NSLog(@"command value = %@",[self.NVTGetHttpValueDict objectForKey:cmd]);
    // }
    
    
    // 错误信息
    if(error)
    {
        NSLog(@"%@", [error localizedDescription]);
        // 此处需要解决iOS9.0之后，HTTP不能正常使用的问题，若不做任何处理，会打印“The resource could not be loaded because the App Transport Security policy requires the use of a secure connection” 错误信息。
    }
    else{
        
    }
    NSLog(@"GetValue = %@",[self.NVTGetHttpValueDict objectForKey:cmd]);
    return [self.NVTGetHttpValueDict objectForKey:cmd];
    /*
     NSError *newError = nil;
     NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&newError];
     // 获取对应的数据信息
     
     NSArray *array = dictionary[@"news"];
     NSDictionary *dic = array[0];
     NSLog(@"%@", dic[@"title"]);
     */
    
}
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    
}
//step 2：准备解析节点
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if([elementName isEqualToString:@"Cmd"]){
        storingFlag = TRUE;
        CmdFlag = YES;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        MovieLiveFlag = NO;
    }
    else if([elementName isEqualToString:@"Value"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = YES;
        StringFlag = NO;
        MovieLiveFlag = NO;
    }
    else if([elementName isEqualToString:@"Status"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = YES;
        ValueFlag = NO;
        StringFlag = NO;
        MovieLiveFlag = NO;
    }
    else if([elementName isEqualToString:@"String"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = YES;
        MovieLiveFlag = NO;
    }
    else if([elementName isEqualToString:@"MovieLiveViewLink"]){
        storingFlag = TRUE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        MovieLiveFlag = YES;
    }
    else{
        storingFlag = FALSE;
        CmdFlag = NO;
        StatusFlag = NO;
        ValueFlag = NO;
        StringFlag = NO;
        MovieLiveFlag = NO;
    }
    
}
//step 3:获取首尾节点间内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (storingFlag) {
        storingFlag = FALSE;
        if(CmdFlag)
        {
            CmdFlag = NO;
            currentElementCommand = [[NSString alloc] initWithString:string];
        }
        else if(StatusFlag){
            StatusFlag = NO;
            currentElementStatus = [[NSMutableString alloc] initWithString:string];
            [self.NVTGetHttpValueDict setValue:currentElementStatus forKey:currentElementCommand];
        }
        else if(ValueFlag){
            ValueFlag = NO;
            currentElementValue = [[NSMutableString alloc] initWithString:string];
            [self.NVTGetHttpValueDict setValue:currentElementValue forKey:currentElementCommand];
        }
        else if(StringFlag){
            StringFlag = NO;
            currentElementValue = [[NSMutableString alloc] initWithString:string];
            
            [self.NVTGetHttpValueDict setValue:currentElementValue forKey:currentElementCommand];
        }
        else if(MovieLiveFlag){
            MovieLiveFlag = NO;
            currentElementValue = [[NSMutableString alloc] initWithString:string];
            
            [self.NVTGetHttpValueDict setValue:currentElementValue forKey:@"2019"];
        }
    }
}

//step 4 ：解析完当前节点
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
}

//step 5：解析结束
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    
}
//step 6：获取cdata块数据
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
    
}

@end
