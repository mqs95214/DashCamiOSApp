//
//  TestHttpViewController.m
//  WifiCamMobileApp
//
//  Created by MAC on 2018/6/25.
//  Copyright © 2018年 iCatchTech. All rights reserved.
//


#import "TestHttpViewController.h"
#import <AVFoundation/AVFoundation.h>


//NSString *databaseName = @"info";
//NSString *tableName = @"appsetting";

@interface TestHttpViewController ()
{
#if 0
    //播放器
    AVPlayer *_player;
    AVPlayerItem *item;
    //显示画面的Layer
    AVPlayerLayer *imageLayer;
#endif
    //sqlite3 *db;
}
@property (nonatomic) NSMutableArray *list;
@property (weak, nonatomic) IBOutlet UIImageView *PlayerView;

@end

@implementation TestHttpViewController
#if 0
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
    
    
    if ([filemgr fileExistsAtPath: databasePath ] == NO) {//不存在
        
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
            return YES;
        } else {//不能開啟database
            NSLog( @"Failed to open/create database");
            return NO;
        }
    } else {//存在
        return YES;
    }
}
- (bool) addData:(sqlite3*) db tableName:(NSString*)tableName list:(NSMutableArray*) dataList {
    
    NSString *docsDir;
    NSArray *dirPath;
    
    // Get the documents directory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPath objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: databaseName]];
    //file check
    //NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        char *errorMsg;
        NSString *str = [[NSString alloc] initWithFormat:@"insert into %@(_id,name,content) values(%@,'%@','%@')",tableName,[dataList objectAtIndex:0],[dataList objectAtIndex:1],[dataList objectAtIndex:2]];
        NSLog(@"strAA = %@",str);
        const char *insertSql=[str UTF8String];//"insert into appsetting(_id,name,content) values(0,'Orange','iOTEC Systems')";
        //const char *insertSql="insert into appsetting(_id,name,address) values(0,'Orange','iOTEC Systems')";
        if (sqlite3_exec(db, insertSql, NULL, NULL, &errorMsg)==SQLITE_OK) {
            sqlite3_close(db);
            NSLog(@"INSERT OK");
            return YES;
        }else{
            sqlite3_close(db);
            NSLog(@"Insert error: %s",errorMsg);
            return NO;
        }
    } else {
        return NO;
    }
   
}
- (void) inquiryData:(sqlite3*) db tableName:(NSString*)tableName {
    NSString *docsDir;
    NSArray *dirPath;
    
    // Get the documents directory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPath objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: databaseName]];
    //file check
    //NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        NSString *str = [[NSString alloc] initWithFormat:@"select * from %@",tableName];
        NSLog(@"strBB = %@",str);
        const char *sql = [str UTF8String];//"select * from data3";
        sqlite3_stmt *statement =nil;
        if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                NSString *_id,*name, *content;
                
                _id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                content = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                
                NSLog(@"Record: %@> %@ , %@",_id, name, content);
            }
            
            sqlite3_finalize(statement);
        }
        sqlite3_close(db);
    }
}
- (bool) modifyData:(sqlite3*) db tableName:(NSString*)tableName columnName1:(NSString*)columnName1 cur:(NSString*)data1 columnName2:(NSString*)columnName2 modify:(NSString*)data2 {
    NSString *docsDir;
    NSArray *dirPath;
    
    // Get the documents directory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPath objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: databaseName]];
    //file check
    //NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        char *errorMsg;
        NSString *str = [[NSString alloc] initWithFormat:@"UPDATE %@ SET %@='%@' WHERE %@='%@'",tableName,columnName1,data2,columnName2,data1];
        NSLog(@"strYY = %@",str);
        const char *sql = [str UTF8String];//"UPDATE member SET name='Apple' WHERE name='Orange'";
        
        if (sqlite3_exec(db, sql, NULL, NULL, &errorMsg)==SQLITE_OK) {
            NSLog(@"UPDATE OK");
            sqlite3_close(db);
            return YES;
        }else{
            NSLog(@"UPDATE error: %s",errorMsg);
            sqlite3_close(db);
            return NO;
        }
    } else {
        return NO;
    }
}
- (bool) deleteData:(sqlite3*) db tableName:(NSString*)tableName columnName:(NSString*)columnName cur:(NSString*)data1 {
    NSString *docsDir;
    NSArray *dirPath;
    
    // Get the documents directory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPath objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: databaseName]];
    //file check
    //NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
        char *errorMsg;
        NSString *str = [[NSString alloc] initWithFormat:@"DELETE FROM %@ WHERE %@='%@'",tableName,columnName,data1];
        const char *sql = [str UTF8String];//"DELETE FROM member WHERE name='Apple'";
        
        if (sqlite3_exec(db, sql, NULL, NULL, &errorMsg)==SQLITE_OK) {
            NSLog(@"DELETE OK");
            return YES;
        }else{
            NSLog(@"DELETE error: %s",errorMsg);
            return NO;
        }
    } else {
        return NO;
    }
}
#endif
- (IBAction)SendHttp:(id)sender {
#if 0
    [self initDB:databaseName database:db tableName:tableName];
    
    _list = [[NSMutableArray alloc] init];
    [_list addObject:@"1"];
    [_list addObject:@"Language"];
    [_list addObject:@"English"];
    [self addData:db tableName:tableName list:_list];
    [self inquiryData:db tableName:tableName];
    [self modifyData:db tableName:tableName columnName1:@"name" cur:@"Chinese" columnName2:@"name" modify:@"Language"];
    [self inquiryData:db tableName:tableName];
    [self modifyData:db tableName:tableName columnName1:@"name" cur:@"Language" columnName2:@"name" modify:@"Chinese"];
    [self inquiryData:db tableName:tableName];
    [self deleteData:db tableName:tableName columnName:@"name" cur:@"Language"];
    NSLog(@"Record: delete");
    [self inquiryData:db tableName:tableName];
#endif
    
#if 0  //建立資料庫
    NSString *databaseName = @"data3";
    
    NSString *docsDir;
    NSArray *dirPath;
    sqlite3 *db;
    
    // Get the documents directory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPath objectAtIndex:0];
    
    // Build the path to the database file
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent: databaseName]];
    NSFileManager *filemgr = [NSFileManager defaultManager];
    const char *dbpath = [databasePath UTF8String];
    if ([filemgr fileExistsAtPath: databasePath ] == NO) {
        
        
        if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
            char *errMsg;
            // create SQL statements
            //const char *sql = "CREATE TABLE IF NOT EXISTS MEMBER (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, address TEXT, phone TEXT)";
            const char *sql = "CREATE TABLE data3 (_id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, address TEXT, phone TEXT)";
            /*
             CREATE_TABLE =
             "CREATE TABLE " + TABLE_NAME + " (" +
             KEY_ID + " INTEGER PRIMARY KEY AUTOINCREMENT, " +
             NAME_COLUMN + " TEXT NOT NULL, " +
             LOCK_STATE + " INTEGER NOT NULL, "+
             LOCATION_COLUMN + "  INTEGER NOT NULL, " +
             CONTENT_COLUMN2 + " TEXT)" ;*/
            if (sqlite3_exec(db, sql, NULL, NULL, &errMsg) != SQLITE_OK) {
                NSLog( @"Failed to create table");
                //return NO;
            }
            NSLog( @"aaaa successed");
            char *errorMsg;
            const char *insertSql="insert into data3(_id,name,address) values(0,'Orange','iOTEC Systems')";
            if (sqlite3_exec(db, insertSql, NULL, NULL, &errorMsg)==SQLITE_OK) {
                NSLog(@"INSERT OK");
            }else{
                NSLog(@"Insert error: %s",errorMsg);
            }
            sqlite3_close(db);
            //return YES;
        }
        else {
            NSLog( @"Failed to open/create database");
            //return NO;
        }
    }else{
        if (sqlite3_open(dbpath, &db) == SQLITE_OK) {
            NSLog(@"Database already created.");
            const char *sql = "select * from data3";
            sqlite3_stmt *statement =nil;
            if (sqlite3_prepare_v2(db, sql, -1, &statement, NULL) == SQLITE_OK) {
                while (sqlite3_step(statement) == SQLITE_ROW) {
                    
                    NSString *_id,*name, *company;
                    
                    _id = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 0)];
                    name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 1)];
                    company = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, 2)];
                    
                    NSLog(@"Record: %@> %@ , %@",_id, name, company);
                }
                
                sqlite3_finalize(statement);
            }
            sqlite3_close(db);
        }
        //return YES;
    }
#endif
#if 0
    [self NVTSendHttpCmd:@"3001" Par2:@"2"];
    
    NSString *Head = @"http://192.168.1.254/VIDEO/2019_0715_161359_001.MOV";
    
    NSURL *videoURL = [NSURL fileURLWithPath:Head];
    
    item = [AVPlayerItem playerItemWithURL:videoURL];
    _player = [AVPlayer playerWithPlayerItem:item];
    imageLayer   = [AVPlayerLayer playerLayerWithPlayer:_player];
    imageLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    //2.设置frame
    imageLayer.frame = self.PlayerView.frame;
    //3.添加到界面上
    //==================显示图像========================
    [self.PlayerView.layer addSublayer:imageLayer];
    
    
    [_player play];
#endif
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    

    // Do any additional setup after loading the view.
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
- (void)NVTSendHttpCmd:(NSString *)cmd Par2:(NSString *)par{
    // 1.URL
    NSString *tempcmd = @"";
    NSString *fullcmd = @"";
    fullcmd = [tempcmd stringByAppendingFormat:@"%s%@%s%@","http://192.168.1.254/?custom=1&cmd=",cmd,"&par=",par];
    NSURL *httpurl = [NSURL URLWithString:fullcmd];
    // 2.封装请求
    NSURLRequest *request = [NSURLRequest requestWithURL:httpurl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:60];
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
@end
