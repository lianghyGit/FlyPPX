//
//  GameScene.m
//  FlyPPX
//
//  Created by liang－pc on 2017/4/20.
//  Copyright © 2017年 apple－pc. All rights reserved.
//

#import "GameScene.h"
#import <AVFoundation/AVFoundation.h>
#import "NewGameScene.h"
#import "Player.h"
#import "Pipe.h"
#import <AVFoundation/AVFoundation.h>

//0001
static const uint32_t kPlayerCategory = 0x1 << 0;
//0010
static const uint32_t kPipeCategory = 0x1 << 1;
//0100
static const uint32_t kGroundCategory = 0x1 << 2;

//重力  正的向上 负的向下
static const CGFloat kGravity = -9.5;
//密度
static const CGFloat kDensity = 1.15;
//速度
static const CGFloat kMaxVelocity = 300;

static const CGFloat kPipeSpeed = 3.5;
//空白
static const CGFloat kPipeGap = 60;
//频率
static const CGFloat kPipeFrequency = kPipeSpeed/2;
//地面高度
static const CGFloat kGroundHeight = 56.0;

static const NSInteger kNumLevels = 20;

static const CGFloat randomFloat(CGFloat Min, CGFloat Max){
    return floor(((rand() % RAND_MAX) / (RAND_MAX * 1.0)) * (Max - Min) + Min);
}

@implementation GameScene {
    Player *_player;
    SKSpriteNode *_ground;
    SKLabelNode *_scoreLabel;
    NSInteger _score;
    NSTimer *_pipeTimer;
    NSTimer *_scoreTimer;
    SKAction *_pipeSound;
    SKAction *_punchSound;
    SKAction *_bgmSound;
    SKAction *_jumpSound;
    
    AVAudioPlayer *_backgroundMusicPlayer;
}

//初始化
- (id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        _score = 0;
        
        srand((time(nil) % kNumLevels)*10000);
        
        [self setBackgroundColor:[SKColor colorWithRed:.69 green:.84 blue:.97 alpha:1]];
        
        //设置重力
        [self.physicsWorld setGravity:CGVectorMake(0, kGravity)];
        //设置代理
        [self.physicsWorld setContactDelegate:self];
        
        //设置云彩
        SKSpriteNode *cloud1 = [SKSpriteNode spriteNodeWithImageNamed:@"Cloud"];
        [cloud1 setPosition:CGPointMake(100, self.size.height - (cloud1.size.height*3))];
        [self addChild:cloud1];
        
        SKSpriteNode *cloud2 = [SKSpriteNode spriteNodeWithImageNamed:@"Cloud"];
        [cloud2 setPosition:CGPointMake(self.size.width - (cloud2.size.width/2) + 50, self.size.height - (cloud2.size.height*5))];
        [self addChild:cloud2];
        
        //设置地面
        _ground = [SKSpriteNode spriteNodeWithImageNamed:@"Ground"];
        [_ground setCenterRect:CGRectMake(26.0/kGroundHeight, 26.0/kGroundHeight, 4.0/kGroundHeight, 4.0/kGroundHeight)];
        [_ground setPosition:CGPointMake(self.size.width/2, _ground.size.height/2)];
        [self addChild:_ground];
        
        //创建物理刚体
        _ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_ground.size];
        //类别掩码 0100
        [_ground.physicsBody setCategoryBitMask:kGroundCategory];
        //碰撞掩码 0001
        [_ground.physicsBody setCollisionBitMask:kPlayerCategory];
        //是否受重力影响
        [_ground.physicsBody setAffectedByGravity:NO];
        //是否有动力效果
        [_ground.physicsBody setDynamic:NO];
        
        //设置地面x的倍数
        [_ground setXScale:self.size.width/kGroundHeight];
        
        //分数
        _scoreLabel = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica"];
        [_scoreLabel setPosition:CGPointMake(self.size.width/2, self.size.height-50)];
        [_scoreLabel setText:[NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:_score]]];
        [self addChild:_scoreLabel];
        
        //添加管子障碍
        _pipeTimer = [NSTimer scheduledTimerWithTimeInterval:kPipeFrequency target:self selector:@selector(addObstacle) userInfo:nil repeats:YES];
        
        //分数
        [NSTimer scheduledTimerWithTimeInterval:kPipeFrequency target:self selector:@selector(startScoreTimer) userInfo:nil repeats:NO];
        
        //音效
        _pipeSound = [SKAction playSoundFileNamed:@"pipe.mp3" waitForCompletion:NO];
        _punchSound = [SKAction playSoundFileNamed:@"die.wav" waitForCompletion:NO];
        
        //点击音效
        _jumpSound = [SKAction playSoundFileNamed:@"jump.wav" waitForCompletion:NO];
        
        //创建皮皮虾
        [self setupPlayer];
        
        //背景音乐
        //        _bgmSound = [SKAction playSoundFileNamed:@"bgm.wav" waitForCompletion:NO];
        //        [self runAction:_bgmSound withKey:@"bgm"];
        //背景音乐
        NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:@"bgm.wav" withExtension:nil];
        _backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:nil];
        _backgroundMusicPlayer.numberOfLoops = -1;
        _backgroundMusicPlayer.volume = 0.8;
        [_backgroundMusicPlayer prepareToPlay];
        [_backgroundMusicPlayer play];
    }
    return self;
}

//创建皮皮虾
- (void)setupPlayer
{
    _player = [Player spriteNodeWithImageNamed:@"ppx"];
    [_player setSize:CGSizeMake(40, 28)];
    [_player setPosition:CGPointMake(self.size.width/2, self.size.height/2)];
    [self addChild:_player];
    
    _player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_player.size];
    [_player.physicsBody setDensity:kDensity];
    [_player.physicsBody setAllowsRotation:NO];
    
    //类别掩码 0001
    [_player.physicsBody setCategoryBitMask:kPlayerCategory];
    //接触测试掩码
    [_player.physicsBody setContactTestBitMask:kPipeCategory | kGroundCategory];
    //碰撞掩码 0110
    [_player.physicsBody setCollisionBitMask:kGroundCategory | kPipeCategory];
}

//添加障碍
- (void)addObstacle
{
    CGFloat centerY = randomFloat(kPipeGap, self.size.height-kPipeGap);
    CGFloat pipeTopHeight = centerY - kPipeGap;
    CGFloat pipeBottomHeight = self.size.height - (centerY + kPipeGap);
    
    // Top Pipe
    Pipe *pipeTop = [Pipe pipeWithHeight:pipeTopHeight withStyle:PipeStyleTop];
    [pipeTop setPipeCategory:kPipeCategory playerCategory:kPlayerCategory];
    [self addChild:pipeTop];
    
    // Bottom Pipe
    Pipe *pipeBottom = [Pipe pipeWithHeight:pipeBottomHeight withStyle:PipeStyleBottom];
    [pipeBottom setPipeCategory:kPipeCategory playerCategory:kPlayerCategory];
    [self addChild:pipeBottom];
    
    // Move top pipe
    SKAction *pipeTopAction = [SKAction moveToX:-(pipeTop.size.width/2) duration:kPipeSpeed];
    SKAction *pipeTopSequence = [SKAction sequence:@[pipeTopAction, [SKAction runBlock:^{
        [pipeTop removeFromParent];
    }]]];
    [pipeTop runAction:[SKAction repeatActionForever:pipeTopSequence]];
    
    // Move bottom pipe
    SKAction *pipeBottomAction = [SKAction moveToX:-(pipeBottom.size.width/2) duration:kPipeSpeed];
    SKAction *pipeBottomSequence = [SKAction sequence:@[pipeBottomAction, [SKAction runBlock:^{
        [pipeBottom removeFromParent];
    }]]];
    [pipeBottom runAction:[SKAction repeatActionForever:pipeBottomSequence]];
}

//开始计分
- (void)startScoreTimer
{
    _scoreTimer = [NSTimer scheduledTimerWithTimeInterval:kPipeFrequency target:self selector:@selector(incrementScore) userInfo:nil repeats:YES];
}

//加分
- (void)incrementScore
{
    _score++;
    [_scoreLabel setText:[NSString stringWithFormat:@"%@", [NSNumber numberWithInteger:_score]]];
    [self runAction:_pipeSound];
}

//点击上移
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_player.physicsBody setVelocity:CGVectorMake(_player.physicsBody.velocity.dx, kMaxVelocity)];
    [self runAction:_jumpSound];
}

//事件监测
- (void)update:(NSTimeInterval)currentTime
{
    if (_player.physicsBody.velocity.dy > kMaxVelocity) {
        [_player.physicsBody setVelocity:CGVectorMake(_player.physicsBody.velocity.dx, kMaxVelocity)];
    }
    
    //设置旋转(低头)
    CGFloat rotation = ((_player.physicsBody.velocity.dy + kMaxVelocity) / (2*kMaxVelocity)) * M_2_PI;
    [_player setZRotation:rotation-M_1_PI/2];
}

#pragma mark - SKPhysicsContactDelegate
//碰撞开始
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKNode *node = contact.bodyA.node;
    if ([node isKindOfClass:[Player class]]) {
        [_pipeTimer invalidate];
        [_scoreTimer invalidate];
        
        //移除背景音乐
        //        [self removeActionForKey:@"bgm"];
        [_backgroundMusicPlayer stop];
        
        [self runAction:_punchSound completion:^{
            SKTransition *transition = [SKTransition doorsCloseHorizontalWithDuration:0.5];
            NewGameScene *newGame = [[NewGameScene alloc] initWithSize:self.size];
            [self.scene.view presentScene:newGame transition:transition];
        }];
    }
}

@end
