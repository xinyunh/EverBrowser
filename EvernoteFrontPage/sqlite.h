//
//  sqlite.h
//  SplitFee
//
//  Created by Xinyun on 6/15/13.
//  Copyright (c) 2013 Xinyun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sqlite : NSObject

+ (void)execSql:(NSString *)request;

+ (NSMutableArray *)inquireCardInfos;
+ (NSInteger)inquireLastCardID;
@end
