//
//  NewGameScene.m
//  FlyPPX
//
//  Created by liang－pc on 2017/4/20.
//  Copyright © 2017年 apple－pc. All rights reserved.
//

#import "NewGameScene.h"
#import "GameScene.h"

@implementation NewGameScene {
    SKSpriteNode *_ppx;
}

- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        [self setBackgroundColor:[SKColor colorWithRed:.61 green:.74 blue:.86 alpha:1]];
        
        //    _button = [SKSpriteNode spriteNodeWithColor:[SKColor colorWithWhite:1 alpha:1] size:CGSizeMake(128, 32)];
        
        _ppx = [SKSpriteNode spriteNodeWithImageNamed:@"ppx"];
        
        [_ppx setPosition:CGPointMake(self.size.width/2, self.size.height/2)];
        [self addChild:_ppx];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //开门效果
    SKTransition *transition = [SKTransition doorwayWithDuration:.5];
    
    //跳转场景
    GameScene *game = [[GameScene alloc] initWithSize:self.size];
    [self.scene.view presentScene:game transition:transition];
}

@end

