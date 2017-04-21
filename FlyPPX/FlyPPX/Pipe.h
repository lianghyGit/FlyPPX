//
//  Pipe.h
//  FlyPPX
//
//  Created by liang－pc on 2017/4/20.
//  Copyright © 2017年 apple－pc. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSInteger, PipeStyle) {
    PipeStyleTop,
    PipeStyleBottom,
};

@interface Pipe : SKSpriteNode

+ (Pipe *)pipeWithHeight:(CGFloat)height withStyle:(PipeStyle)style;

- (void)setPipeCategory:(uint32_t)pipe playerCategory:(uint32_t)player;

@end
