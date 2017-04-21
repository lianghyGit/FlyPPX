//
//  ViewController.m
//  FlyPPX
//
//  Created by liang－pc on 2017/4/20.
//  Copyright © 2017年 apple－pc. All rights reserved.
//

#import "ViewController.h"
#import <SpriteKit/SpriteKit.h>
#import "NewGameScene.h"

@implementation ViewController

- (void)loadView
{
    self.view  = [[SKView alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    SKView *view = (SKView *)[self view];
    [view setShowsFPS:YES];
    [view setShowsNodeCount:YES];
    
    SKScene *scene = [NewGameScene sceneWithSize:view.bounds.size];
    [scene setScaleMode:SKSceneScaleModeAspectFill];
    
    [view presentScene:scene];
}

@end
