//
//  Pipe.m
//  FlyPPX
//
//  Created by liang－pc on 2017/4/20.
//  Copyright © 2017年 apple－pc. All rights reserved.
//

#import "Pipe.h"

static const CGFloat kPipeWidth = 56.0;

@implementation Pipe

+ (Pipe *)pipeWithHeight:(CGFloat)height withStyle:(PipeStyle)style
{
    NSString *pipeImageName;
    CGFloat offset;
    
    if (style == PipeStyleTop) {
        pipeImageName = @"PipeTop";
        offset = -([UIScreen mainScreen].bounds.size.height-2);
    } else {
        pipeImageName = @"PipeBottom";
        offset = -2;
    }
    
    Pipe *pipe = [[Pipe alloc] initWithImageNamed:pipeImageName];
    
    pipe.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:pipe.size];
    [pipe.physicsBody setAffectedByGravity:NO];
    [pipe.physicsBody setDynamic:NO];
    
    [pipe setCenterRect:CGRectMake(26.0/kPipeWidth, 26.0/kPipeWidth, 4.0/kPipeWidth, 4.0/kPipeWidth)];
    [pipe setYScale:height/(pipe.size.height)];
    [pipe setPosition:CGPointMake(320+(pipe.size.width/2), fabs(offset+(pipe.size.height/2)))];
    
    return pipe;
}

- (void)setPipeCategory:(uint32_t)pipe playerCategory:(uint32_t)player
{
    [self.physicsBody setCategoryBitMask:pipe];
    [self.physicsBody setCollisionBitMask:player];
}

@end

