//
//  ElfinsArray.m
//  Test
//
//  Created by 胡杨 on 2017/5/5.
//  Copyright © 2017年 net.fitcome.www. All rights reserved.
//

#import "ElfinsArray.h"

@implementation ElfinsArray

- (NSUInteger)countOfElfins {
    NSLog(@" ----");
    return self.count;
}

- (id)objectInElfinsAtIndex:(NSUInteger)index {
    NSLog(@" ***");
    return [NSString stringWithFormat:@"小精灵%lu", (unsigned long)index];
}

@end
