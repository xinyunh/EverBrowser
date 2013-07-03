//
//  sqlite.m
//  SplitFee
//
//  Created by Xinyun on 6/15/13.
//  Copyright (c) 2013 Xinyun. All rights reserved.
//

#import <sqlite3.h>
#import "sqlite.h"
#import "MARCO.h"

#define kDatabaseName @"database.sqlite3"

static NSString *databaseFilePath = @"";
static sqlite3 *db;

@implementation sqlite

+ (void)initializeDB {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    databaseFilePath = [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
}

+ (void)openDB {
    if ([databaseFilePath isEqualToString:@""]) {
        [self initializeDB];
    }
    if (sqlite3_open([databaseFilePath UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(0, @"Fail to open database！");
    }
}

+ (void)closeDB {
    sqlite3_close(db);
}

+ (void)execSql:(NSString *)request {
    [self openDB];
    char *errorMsg;
    if (sqlite3_exec(db, [request UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(0, @"Fail Database Operation: %s", errorMsg);
    }
    [self closeDB];
}

+ (NSMutableArray *)inquireCardInfos {
    [self openDB];
    NSString *sqlQuery = @"SELECT * FROM URL_TABLE";
    sqlite3_stmt *statement;
    
    NSMutableArray *result = [[NSMutableArray alloc] init];

    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            int cardID = sqlite3_column_int(statement, 0);
            id nsIdInt = [NSNumber numberWithInt:cardID];

            char *url = (char*)sqlite3_column_text(statement, 1);
            NSString *nsURLStr = [[NSString alloc]initWithUTF8String:url];
            
//            NSLog(@"id:%d url:%@", cardID, nsURLStr);
            NSDictionary *temp = [[NSDictionary alloc] initWithObjectsAndKeys:nsIdInt, @"ID", nsURLStr, @"URL", nil];
            [result addObject:temp];
        }
        sqlite3_finalize(statement);
    }
    [self closeDB];
    return result;
}

+ (NSInteger)inquireLastCardID{
    [self openDB];
    NSString *sqlQuery = @"SELECT * FROM URL_TABLE ORDER BY ID DESC";
    sqlite3_stmt *statement;
    
    NSInteger result = -1;
    if (sqlite3_prepare_v2(db, [sqlQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            result = sqlite3_column_int(statement, 0);
        }
        sqlite3_finalize(statement);
    }
    [self closeDB];
    return result;
}

@end