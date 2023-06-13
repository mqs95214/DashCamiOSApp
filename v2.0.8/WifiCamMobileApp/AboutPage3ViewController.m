//
//  AboutPage3ViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2019/5/2.
//  Copyright © 2019年 Cansonic. All rights reserved.
//

#import "AboutPage3ViewController.h"
#import "AppSettingTableViewCell.h"

long selectData_layer1;
@interface AboutPage3ViewController ()
{
    sqlite3 *db;
    NSString *databaseName;
    NSString *tableName;
    AppDelegate *delegate;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property(nonatomic,strong)NSBundle *bundle;
@end

@implementation AboutPage3ViewController


- (void)initContentList {
    _contentList = [[NSMutableArray alloc] init];
    if([[delegate getTimeFormat]  isEqual: @"12H"]) {
        [_contentList addObject:[delegate getStringForKey:@"AboutTimeFormatContent1" withTable:@""]];
    } else if([[delegate getTimeFormat]  isEqual: @"24H"]) {
        [_contentList addObject:[delegate getStringForKey:@"AboutTimeFormatContent2" withTable:@""]];
    }
    
    if([[delegate getDateFormat]  isEqual: @"DDMMYYYY"]) {
        [_contentList addObject:[delegate getStringForKey:@"AboutDateStyleContent1" withTable:@""]];
    } else if([[delegate getDateFormat]  isEqual: @"MMDDYYYY"]) {
        [_contentList addObject:[delegate getStringForKey:@"AboutDateStyleContent2" withTable:@""]];
    } else if([[delegate getDateFormat]  isEqual: @"YYYYMMDD"]) {
        [_contentList addObject:[delegate getStringForKey:@"AboutDateStyleContent3" withTable:@""]];
    }
    
    if([[delegate getSpeedUnit]  isEqual: @"Imperial Unit"]) {
        [_contentList addObject:[delegate getStringForKey:@"AboutUnitContent1" withTable:@""]];
    } else if([[delegate getSpeedUnit]  isEqual: @"Metric Unit"]) {
        [_contentList addObject:[delegate getStringForKey:@"AboutUnitContent2" withTable:@""]];
    }
    
    if([[delegate getLanguage]  isEqual: @"English"]) {
        [_contentList addObject:[delegate getStringForKey:@"SetLanguageEnglish" withTable:@""]];
    } else if([[delegate getLanguage]  isEqual: @"German"]) {
        [_contentList addObject:[delegate getStringForKey:@"SetLanguageGerman" withTable:@""]];
    } else if([[delegate getLanguage]  isEqual: @"French"]) {
        [_contentList addObject:[delegate getStringForKey:@"SetLanguageFrench" withTable:@""]];
    } else if([[delegate getLanguage]  isEqual: @"Dutch"]) {
        [_contentList addObject:[delegate getStringForKey:@"SetLanguageDutch" withTable:@""]];
    } else if([[delegate getLanguage]  isEqual: @"Italian"]) {
        [_contentList addObject:[delegate getStringForKey:@"SetLanguageItalian" withTable:@""]];
    } else if([[delegate getLanguage]  isEqual: @"Spanish"]) {
        [_contentList addObject:[delegate getStringForKey:@"SetLanguageSpanish" withTable:@""]];
    } else if([[delegate getLanguage]  isEqual: @"Portuguese"]) {
        [_contentList addObject:[delegate getStringForKey:@"SetLanguagePortuguese" withTable:@""]];
    } else if([[delegate getLanguage]  isEqual: @"Russia"]) {
        [_contentList addObject:[delegate getStringForKey:@"SetLanguageRussia" withTable:@""]];
    } else if([[delegate getLanguage]  isEqual: @"Polish"]) {
        [_contentList addObject:[delegate getStringForKey:@"SetLanguagePolish" withTable:@""]];
    } else if([[delegate getLanguage]  isEqual: @"Czech"]) {
        [_contentList addObject:[delegate getStringForKey:@"SetLanguageCzech" withTable:@""]];
    } else if([[delegate getLanguage]  isEqual: @"Romanian"]) {
        [_contentList addObject:[delegate getStringForKey:@"SetLanguageRomanian" withTable:@""]];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate initLanguage];
    _bundle = [delegate getBundleLanguage];
    
    databaseName = @"info";
    tableName = @"appsetting";
    
    self.appSettingTitle.text = [delegate getStringForKey:@"SetAppSettingTitle" withTable:@""];
    //[self initContentList];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    _tableview.backgroundColor = UIColor.clearColor;
    
    _tableview.separatorColor=UIColor.clearColor;
    
    //進入第一層
    _curLayer = 1;
    _list = [[NSMutableArray alloc] init];
    //init database
    [self initDB:databaseName database:db tableName:tableName];
    
    [self initContentList];
    if([_contentList count] > 3) {
        
        [_list addObject:[NSArray arrayWithObjects:[delegate getStringForKey:@"AboutTimeFormat" withTable:@""],@"",[_contentList objectAtIndex:0], nil]];
        [_list addObject:[NSArray arrayWithObjects:[delegate getStringForKey:@"AboutDateStyle" withTable:@""],@"",[_contentList objectAtIndex:1], nil]];
        [_list addObject:[NSArray arrayWithObjects:[delegate getStringForKey:@"AboutUnit" withTable:@""],@"",[_contentList objectAtIndex:2], nil]];
        [_list addObject:[NSArray arrayWithObjects:[delegate getStringForKey:@"AboutLanguage" withTable:@""],@"",[_contentList objectAtIndex:3], nil]];
    }
    //[_list addObject:[NSArray arrayWithObjects:NSLocalizedString(@"AboutLanguage",nil),@"",[_contentList objectAtIndex:3], nil]];
}
- (IBAction)Back:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    if(_curLayer == 2) {
        self.appSettingTitle.text = [delegate getStringForKey:@"SetAppSettingTitle" withTable:@""];
        _curLayer = 1;
        _list = [[NSMutableArray alloc] init];
        [_list addObject:[NSArray arrayWithObjects:[delegate getStringForKey:@"AboutTimeFormat" withTable:@""],@"",[_contentList objectAtIndex:0], nil]];
        [_list addObject:[NSArray arrayWithObjects:[delegate getStringForKey:@"AboutDateStyle" withTable:@""],@"",[_contentList objectAtIndex:1], nil]];
        [_list addObject:[NSArray arrayWithObjects:[delegate getStringForKey:@"AboutUnit" withTable:@""],@"",[_contentList objectAtIndex:2], nil]];
        [_list addObject:[NSArray arrayWithObjects:[delegate getStringForKey:@"AboutLanguage" withTable:@""],@"",[_contentList objectAtIndex:3], nil]];
        [self.tableview reloadData];
    } else {//第一層才返回
        [self.navigationController popViewControllerAnimated:YES];
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
//UITableViewDataSource上的方法，
//用以表示有多少筆資料，
//在此回傳_contacts陣列的個數
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_list count];
}
//UITableViewDataSource上的方法，
//回傳TableView顯示每列資料用的UITableViewCell
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //建立UITableViewCell物件
    AppSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"appSettingCell"];//[[UITableViewCell alloc] init];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //UITableViewCell有個屬性為textLabel,
    //其是⼀一個UILabel物件,
    //透過setText可設定其顯示的字樣
    [cell.leftText setText:[[_list objectAtIndex:indexPath.row] objectAtIndex:0]];
    [cell.centerText setText:[[_list objectAtIndex:indexPath.row] objectAtIndex:1]];
    [cell.rightText setText:[[_list objectAtIndex:indexPath.row] objectAtIndex:2]];
    
    [cell.leftText setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    if(indexPath.row == 0) {
        if((selectData_layer1 == 0 && [[delegate getTimeFormat]  isEqual: @"12H"]) ||
           (selectData_layer1 == 1 && [[delegate getDateFormat]  isEqual: @"DDMMYYYY"]) ||
           (selectData_layer1 == 2 && [[delegate getSpeedUnit]  isEqual: @"Imperial Unit"]) ||
           (selectData_layer1 == 3 && [[delegate getLanguage]  isEqual: @"English"])) {
            [cell.centerText setTextColor:[UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1]];
        } else {
            [cell.centerText setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        }
    } else if(indexPath.row == 1) {
        if((selectData_layer1 == 0 && [[delegate getTimeFormat]  isEqual: @"24H"]) ||
           (selectData_layer1 == 1 && [[delegate getDateFormat]  isEqual: @"MMDDYYYY"]) ||
           (selectData_layer1 == 2 && [[delegate getSpeedUnit]  isEqual: @"Metric Unit"]) ||
           (selectData_layer1 == 3 && [[delegate getLanguage]  isEqual: @"German"])) {
            [cell.centerText setTextColor:[UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1]];
        } else {
            [cell.centerText setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        }
    } else if(indexPath.row == 2) {
        if((selectData_layer1 == 1 && [[delegate getDateFormat]  isEqual: @"YYYYMMDD"]) ||
           (selectData_layer1 == 3 && [[delegate getLanguage]  isEqual: @"French"])) {
            [cell.centerText setTextColor:[UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1]];
        } else {
            [cell.centerText setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        }
    } else if(indexPath.row == 3) {
        if((selectData_layer1 == 3 && [[delegate getLanguage]  isEqual: @"Dutch"])) {
            [cell.centerText setTextColor:[UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1]];
        } else {
            [cell.centerText setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        }
    } else if(indexPath.row == 4) {
        if((selectData_layer1 == 3 && [[delegate getLanguage]  isEqual: @"Italian"])) {
            [cell.centerText setTextColor:[UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1]];
        } else {
            [cell.centerText setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        }
    } else if(indexPath.row == 5) {
        if((selectData_layer1 == 3 && [[delegate getLanguage]  isEqual: @"Spanish"])) {
            [cell.centerText setTextColor:[UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1]];
        } else {
            [cell.centerText setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        }
    } else if(indexPath.row == 6) {
        if((selectData_layer1 == 3 && [[delegate getLanguage]  isEqual: @"Portuguese"])) {
            [cell.centerText setTextColor:[UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1]];
        } else {
            [cell.centerText setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        }
    } else if(indexPath.row == 7) {
        if((selectData_layer1 == 3 && [[delegate getLanguage]  isEqual: @"Russia"])) {
            [cell.centerText setTextColor:[UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1]];
        } else {
            [cell.centerText setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        }
    } else if(indexPath.row == 8) {
        if((selectData_layer1 == 3 && [[delegate getLanguage]  isEqual: @"Polish"])) {
            [cell.centerText setTextColor:[UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1]];
        } else {
            [cell.centerText setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        }
    } else if(indexPath.row == 9) {
        if((selectData_layer1 == 3 && [[delegate getLanguage]  isEqual: @"Czech"])) {
            [cell.centerText setTextColor:[UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1]];
        } else {
            [cell.centerText setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        }
    } else if(indexPath.row == 10) {
        if((selectData_layer1 == 3 && [[delegate getLanguage]  isEqual: @"Romanian"])) {
            [cell.centerText setTextColor:[UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1]];
        } else {
            [cell.centerText setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
        }
    } else {
        [cell.centerText setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    }
    //[cell.centerText setTextColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1]];
    [cell.rightText setTextColor:[UIColor colorWithRed:53/255.0 green:61/255.0 blue:244/255.0 alpha:1]];
    [cell.leftText setFont:[UIFont fontWithName:@"Frutiger LT 55 Roman" size:15]];
    [cell.centerText setFont:[UIFont fontWithName:@"Frutiger LT 55 Roman" size:15]];
    [cell.rightText setFont:[UIFont fontWithName:@"Frutiger LT 55 Roman" size:15]];
    cell.backView.hidden = YES;
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //回傳cell物件,以供UITableView顯示在畫面上
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *content;
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    AppSettingTableViewCell *cell = (AppSettingTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(cell.backView.isHidden)
        cell.backView.hidden = NO;
    else
        cell.backView.hidden = YES;
    if(_curLayer == 1) {
        selectData_layer1 = indexPath.row;
        //進入第二層
        _curLayer = 2;
        switch (indexPath.row) {
                //NSLocalizedString(@"AboutTimeFormatContent1", nil),NSLocalizedString(@"AboutDateStyleContent1", nil),NSLocalizedString(@"AboutUnitContent1", nil),NSLocalizedString(@"SetLanguageEnglish", nil)
            case TimeFormat_e:
                _list = [[NSMutableArray alloc] init];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"AboutTimeFormatContent1" withTable:@""],@"", nil]];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"AboutTimeFormatContent2" withTable:@""],@"", nil]];
                [self.tableview reloadData];
                break;
            case DateStyle_e:
                _list = [[NSMutableArray alloc] init];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"AboutDateStyleContent1" withTable:@""],@"", nil]];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"AboutDateStyleContent2" withTable:@""],@"", nil]];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"AboutDateStyleContent3" withTable:@""],@"", nil]];
                [self.tableview reloadData];
                break;
            case Unit_e:
                _list = [[NSMutableArray alloc] init];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"AboutUnitContent1" withTable:@""],@"", nil]];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"AboutUnitContent2" withTable:@""],@"", nil]];
                [self.tableview reloadData];
                break;
            case Language_e:
                _list = [[NSMutableArray alloc] init];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"SetLanguageEnglish" withTable:@""],@"", nil]];
                //[self.tableview reloadData];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"SetLanguageGerman" withTable:@""],@"", nil]];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"SetLanguageFrench" withTable:@""],@"", nil]];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"SetLanguageDutch" withTable:@""],@"", nil]];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"SetLanguageItalian" withTable:@""],@"", nil]];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"SetLanguageSpanish" withTable:@""],@"", nil]];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"SetLanguagePortuguese" withTable:@""],@"", nil]];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"SetLanguageRussia" withTable:@""],@"", nil]];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"SetLanguagePolish" withTable:@""],@"", nil]];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"SetLanguageCzech" withTable:@""],@"", nil]];
                [_list addObject:[NSArray arrayWithObjects:@"",[delegate getStringForKey:@"SetLanguageRomanian" withTable:@""],@"", nil]];
                [self.tableview reloadData];
                break;
                
            default:
                break;
        }
    } else if(_curLayer == 2) {
        _list_database = [[NSMutableArray alloc] init];
        content = @"";
#if 1
        NSArray *languages;
        NSString *currentLanguage;
        switch (selectData_layer1) {
            case TimeFormat_e:
                if(indexPath.row == 0) {
                    content = @"12H";
                } else if(indexPath.row == 1) {
                    content = @"24H";
                }
                if([delegate getTimeFormat]) {
                    [delegate modifyData:db tableName:tableName columnName1:@"content" cur:content columnName2:@"name" modify:@"TimeFormat"];
                    _bundle = [delegate getBundleLanguage];
                } else {
                    [_list_database addObject:[NSString stringWithFormat:@"%d",[delegate inquiryDataCount:db tableName:tableName]]];
                    [_list_database addObject:@"TimeFormat"];
                    switch (indexPath.row) {
                        case 0:
                            [_list_database addObject:content];
                            break;
                        case 1:
                            [_list_database addObject:content];
                            break;
                        default:
                            break;
                    }
                    
                    [delegate addData:db tableName:tableName list:_list_database];
                    _bundle = [delegate getBundleLanguage];
                }
            
                break;
            case DateStyle_e:
                if(indexPath.row == 0) {
                    content = @"DDMMYYYY";
                } else if(indexPath.row == 1) {
                    content = @"MMDDYYYY";
                } else if(indexPath.row == 2) {
                    content = @"YYYYMMDD";
                }
                if([delegate getDateFormat]) {
                    [delegate modifyData:db tableName:tableName columnName1:@"content" cur:content columnName2:@"name" modify:@"DateStyle"];
                    _bundle = [delegate getBundleLanguage];
                } else {
                    [_list_database addObject:[NSString stringWithFormat:@"%d",[delegate inquiryDataCount:db tableName:tableName]]];
                    [_list_database addObject:@"DateStyle"];
                    switch (indexPath.row) {
                        case 0:
                            [_list_database addObject:content];
                            break;
                        case 1:
                            [_list_database addObject:content];
                            break;
                        case 2:
                            [_list_database addObject:content];
                            break;
                        default:
                            break;
                    }
                    
                    [delegate addData:db tableName:tableName list:_list_database];
                    _bundle = [delegate getBundleLanguage];
                }
                
                break;
            case Unit_e:
                if(indexPath.row == 0) {
                    content = @"Imperial Unit";
                } else if(indexPath.row == 1) {
                    content = @"Metric Unit";
                }
                if([delegate getSpeedUnit]) {
                    [delegate modifyData:db tableName:tableName columnName1:@"content" cur:content columnName2:@"name" modify:@"Unit"];
                    _bundle = [delegate getBundleLanguage];
                } else {
                    [_list_database addObject:[NSString stringWithFormat:@"%d",[delegate inquiryDataCount:db tableName:tableName]]];
                    [_list_database addObject:@"Unit"];
                    switch (indexPath.row) {
                        case 0:
                            [_list_database addObject:content];
                            break;
                        case 1:
                            [_list_database addObject:content];
                            break;
                        default:
                            break;
                    }
                    
                    [delegate addData:db tableName:tableName list:_list_database];
                    _bundle = [delegate getBundleLanguage];
                }
                break;
            case Language_e:
                languages = [[NSUserDefaults standardUserDefaults] valueForKey:@"AppleLanguages"];
                currentLanguage = languages.firstObject;
                NSLog(@"language = %@",currentLanguage);
                if(indexPath.row == 0) {
                    content = @"English";
                } else if(indexPath.row == 1) {
                    content = @"German";
                } else if(indexPath.row == 2) {
                    content = @"French";
                } else if(indexPath.row == 3) {
                    content = @"Dutch";
                } else if(indexPath.row == 4) {
                    content = @"Italian";
                } else if(indexPath.row == 5) {
                    content = @"Spanish";
                } else if(indexPath.row == 6) {
                    content = @"Portuguese";
                } else if(indexPath.row == 7) {
                    content = @"Russia";
                } else if(indexPath.row == 8) {
                    content = @"Polish";
                } else if(indexPath.row == 9) {
                    content = @"Czech";
                } else if(indexPath.row == 10) {
                    content = @"Romanian";
                }
                if([delegate getLanguage]) {
                    [delegate modifyData:db tableName:tableName columnName1:@"content" cur:content columnName2:@"name" modify:@"Language"];
                    _bundle = [delegate getBundleLanguage];
                } else {
                    [_list_database addObject:[NSString stringWithFormat:@"%d",[delegate inquiryDataCount:db tableName:tableName]]];
                    [_list_database addObject:@"Language"];
                    switch (indexPath.row) {
                        case 0:
                            [_list_database addObject:content];
                            break;
                        default:
                            break;
                    }
                    
                    [delegate addData:db tableName:tableName list:_list_database];
                    _bundle = [delegate getBundleLanguage];
                }
                
                [delegate initLanguage];
                _bundle = [delegate getBundleLanguage];
                break;
            default:
                break;
        }
#endif
        [self initContentList];
        //設定並返回第一層
        self.appSettingTitle.text = [delegate getStringForKey:@"SetAppSettingTitle" withTable:@""];
        _curLayer = 1;
        _list = [[NSMutableArray alloc] init];
        [_list addObject:[NSArray arrayWithObjects:[delegate getStringForKey:@"AboutTimeFormat" withTable:@""],@"",[_contentList objectAtIndex:0], nil]];
        [_list addObject:[NSArray arrayWithObjects:[delegate getStringForKey:@"AboutDateStyle" withTable:@""],@"",[_contentList objectAtIndex:1], nil]];
        [_list addObject:[NSArray arrayWithObjects:[delegate getStringForKey:@"AboutUnit" withTable:@""],@"",[_contentList objectAtIndex:2], nil]];
        [_list addObject:[NSArray arrayWithObjects:[delegate getStringForKey:@"AboutLanguage" withTable:@""],@"",[_contentList objectAtIndex:3], nil]];
        [self.tableview reloadData];
    }
}
#if 1
- (void) setListConten {
    
}
- (bool) initDB:(NSString*)dbName database:(sqlite3*) db tableName:(NSString*)tableName {
    NSString *docsDir;
    NSArray *dirPath;
    
    // Get the documents directory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPath objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: dbName]];
    //file check
    NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    
    
    //if ([filemgr fileExistsAtPath: databasePath ] == NO) {//不存在
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK) {//開啟database
            char *errMsg;
            //資料庫樣式
            NSString *str = [[NSString alloc] initWithFormat:@"CREATE TABLE %@ (_id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, content TEXT)",tableName];
            NSLog(@"strRR = %@",str);
            //const char *sql = "CREATE TABLE appsetting (_id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, address TEXT, phone TEXT)";
            /*const char *sql = "CREATE TABLE data3 (_id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, address TEXT, phone TEXT)";*/
            const char *sql = [str UTF8String];
            if (sqlite3_exec(db, sql, NULL, NULL, &errMsg) != SQLITE_OK) {
                NSLog( @"Failed to create table");
                return NO;
            }
            
            sqlite3_close(db);
            _list_database = [[NSMutableArray alloc] init];
            [_list_database addObject:[NSString stringWithFormat:@"%d",[delegate inquiryDataCount:db tableName:tableName]]];
            [_list_database addObject:@"TimeFormat"];
            [_list_database addObject:@"12H"];
            [delegate addData:db tableName:tableName list:_list_database];
            _bundle = [delegate getBundleLanguage];
            
            _list_database = [[NSMutableArray alloc] init];
            [_list_database addObject:[NSString stringWithFormat:@"%d",[delegate inquiryDataCount:db tableName:tableName]]];
            [_list_database addObject:@"DateStyle"];
            [_list_database addObject:@"DDMMYYYY"];
            [delegate addData:db tableName:tableName list:_list_database];
            _bundle = [delegate getBundleLanguage];
            
            _list_database = [[NSMutableArray alloc] init];
            [_list_database addObject:[NSString stringWithFormat:@"%d",[delegate inquiryDataCount:db tableName:tableName]]];
            [_list_database addObject:@"Unit"];
            [_list_database addObject:@"Imperial Unit"];
            [delegate addData:db tableName:tableName list:_list_database];
            _bundle = [delegate getBundleLanguage];
            
            _list_database = [[NSMutableArray alloc] init];
            [_list_database addObject:[NSString stringWithFormat:@"%d",[delegate inquiryDataCount:db tableName:tableName]]];
            [_list_database addObject:@"Language"];
            [_list_database addObject:@"English"];
            [delegate addData:db tableName:tableName list:_list_database];
            _bundle = [delegate getBundleLanguage];
            return YES;
        } else {//不能開啟database
            NSLog( @"Failed to open/create database");
            return NO;
        }
    //} else {//存在
    //    return YES;
    //}
}
#endif
@end
