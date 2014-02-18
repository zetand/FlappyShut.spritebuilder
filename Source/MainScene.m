//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Obstacle.h"

//static const CGFloat scrollSpeed = 80.f;
static const CGFloat firstObstaclePosition = 235.f;
//static const CGFloat distanceBetweenObstacles = 120.f;
int i = 0;

@implementation MainScene{
    
    ADBannerView *_bannerView;
    
    CCSprite *_hero;
    CCPhysicsNode *_physicsNode;
    CCPhysicsNode *_physicsNode2;
    
    CCNode *_ground1;
    CCNode *_ground2;
    NSArray *_grounds;
    
    CCSprite *_leg1;
    CCSprite *_leg2;
    CCSprite *_wing;
    
    NSTimeInterval _sinceTouch;
    NSMutableArray *_obstacles;
    CCButton *_restartButton;
    CCButton *_gameCenterButton;
    
    BOOL _gameOver;
    CGFloat _scrollSpeed;
    
    NSArray *_crowds;
    CCNode *_crowd1;
    CCNode *_crowd2;
    
    CCNode *_background1;
    CCNode *_background2;
    NSArray *_backgrounds;
    
    CCNode *_foot_bt1;
    CCNode *_foot_bt2;
    NSArray *_foot_bts;
    
    NSInteger _points;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_hi_score_label;
    CCLabelTTF *_youscore_label;
    CCLabelTTF *_hi_score;
    CCLabelTTF *_your_score,*_game_over_label;
    
    CCNodeColor *_sum_score;
    
    _Bool fast_stage;
    
    BOOL is_highScore_update;
    
    CGFloat _distanceBetweenObstacles;
    
    long long _hi_score_i;
}

- (void)didLoadFromCCB {
    
    //    _bannerView = [[ADBannerView alloc]initWithFrame:CGRectMake(0, 518, 320, 50)];
    //
    //    // Optional to set background color to clear color
    //    [_bannerView setBackgroundColor:[UIColor clearColor]];
    //    [[[CCDirector sharedDirector]view]addSubview:_bannerView];
    
    if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
        _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        
    } else {
        _bannerView = [[ADBannerView alloc] init];
    }
    //_bannerView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
    _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    //[[[CCDirector sharedDirector]view]addSubview:_bannerView];
    [_bannerView setBackgroundColor:[UIColor clearColor]];
    [[[CCDirector sharedDirector]view]addSubview:_bannerView];
    _bannerView.delegate = self;
    
    [self layoutAnimated:YES];
    
    
    if([GKLocalPlayer localPlayer].authenticated == NO)
    {
        [[GKLocalPlayer localPlayer]
         authenticateWithCompletionHandler:^(NSError *error)
         {
             NSLog(@"Game Center Load Error%@",error);
         }];
    }
    
    is_highScore_update = FALSE;
    _hi_score_i = 0;
    _scrollSpeed = 80.f;
    _distanceBetweenObstacles = 120.f;
    
    self.userInteractionEnabled = TRUE;
    _grounds = @[_ground1, _ground2];
    _crowds = @[_crowd1, _crowd2];
    _backgrounds = @[_background1, _background2];
    _foot_bts = @[_foot_bt1, _foot_bt2];
    
    for (CCNode *ground in _grounds) {
        // set collision txpe
        ground.physicsBody.collisionType = @"level";
        ground.zOrder = DrawingOrderGround;
    }
    
    for (CCNode *background in _backgrounds) {
        // set collision txpe
        //ground.physicsBody.collisionType = @"level";
        background.zOrder = DrawingOrderBackground;
    }
    
    for (CCNode *foot_bt in _foot_bts) {
        // set collision txpe
        //ground.physicsBody.collisionType = @"level";
        foot_bt.zOrder = DrawingOrderfoot_bt;
    }
    
    for (CCSprite *crowd in _crowds) {
        // set collision txpe
        crowd.physicsBody.collisionType = @"level";
        crowd.zOrder = DrawingOrderCrowd;
    }
    
    // set this class as delegate
    _physicsNode.collisionDelegate = self;
    // set collision txpe
    _hero.physicsBody.collisionType = @"hero";
    _hero.zOrder = DrawingOrdeHero;
    _obstacles = [NSMutableArray array];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    [self spawnNewObstacle];
    
}


typedef NS_ENUM(NSInteger, DrawingOrder) {
    
    DrawingOrderBackground,
    DrawingOrderGround,
    DrawingOrderPipes,
    DrawingOrderfoot_bt,
    DrawingOrdeHero,
    DrawingOrderCrowd
    
};


- (void)update:(CCTime)delta {
    
    
    // clamp velocity
    float yVelocity = clampf(_hero.physicsBody.velocity.y, -1 * MAXFLOAT, 200.f);
    _hero.physicsBody.velocity = ccp(_scrollSpeed, yVelocity);
    
    _physicsNode.position = ccp(_physicsNode.position.x - (_scrollSpeed*delta), _physicsNode.position.y);
    
    _physicsNode2.position = ccp(_physicsNode2.position.x - (_scrollSpeed*delta)/20, _physicsNode2.position.y);
    
    if (is_highScore_update == FALSE)
    {
        do {
            
            
            if([GKLocalPlayer localPlayer].authenticated) {
                
                [self getCurrentLeaderboardScore:@"L20140216FT"];
                
            }
            
            i++;
            
        } while (i == 10);
        i = 0;
        is_highScore_update = TRUE;
    }
    
    
    // loop the ground
    for (CCNode *ground in _grounds) {
        // get the world position of the ground
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width)) {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
    }
    
    // loop the foot_bt
    for (CCNode *foot_bt in _foot_bts) {
        // get the world position of the ground
        CGPoint foot_btWorldPosition = [_physicsNode convertToWorldSpace:foot_bt.position];
        // get the screen position of the ground
        CGPoint foot_btScreenPosition = [self convertToNodeSpace:foot_btWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (foot_btScreenPosition.x <= (-1 * foot_bt.contentSize.width)) {
            foot_bt.position = ccp(foot_bt.position.x + 2 * foot_bt.contentSize.width, foot_bt.position.y);
        }
    }
    
    
    // loop the crowd
    for (CCNode *crowd in _crowds) {
        // get the world position of the ground
        CGPoint crowdWorldPosition = [_physicsNode convertToWorldSpace:crowd.position];
        // get the screen position of the ground
        CGPoint crowdScreenPosition = [self convertToNodeSpace:crowdWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (crowdScreenPosition.x <= (-1 * crowd.contentSize.width)) {
            crowd.position = ccp(crowd.position.x + 2 * crowd.contentSize.width, crowd.position.y);
        }
    }
    
    // loop the background
    for (CCNode *background in _backgrounds) {
        // get the world position of the ground
        CGPoint backgroundWorldPosition = [_physicsNode2 convertToWorldSpace:background.position];
        // get the screen position of the ground
        CGPoint backgroundScreenPosition = [self convertToNodeSpace:backgroundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (backgroundScreenPosition.x <= (-1 * background.contentSize.width)) {
            background.position = ccp(background.position.x + 2 * background.contentSize.width, background.position.y);
        }
    }
    
    
    // Hero Head Down
    _sinceTouch += delta;
    _hero.rotation = clampf(_hero.rotation, -10.f, 80.f);
    if (_hero.physicsBody.allowsRotation) {
        float angularVelocity = clampf(_hero.physicsBody.angularVelocity, 1.f, 15.f);
        _hero.physicsBody.angularVelocity = angularVelocity;
    }
    if ((_sinceTouch > 0.5f)) {
        [_hero.physicsBody applyAngularImpulse:-20000.f*delta];
    }
    
    
    // Spawn the obstacle
    NSMutableArray *offScreenObstacles = nil;
    for (CCNode *obstacle in _obstacles) {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position];
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if (obstacleScreenPosition.x < -obstacle.contentSize.width) {
            if (!offScreenObstacles) {
                offScreenObstacles = [NSMutableArray array];
            }
            [offScreenObstacles addObject:obstacle];
        }
    }
    for (CCNode *obstacleToRemove in offScreenObstacles) {
        [obstacleToRemove removeFromParent];
        [_obstacles removeObject:obstacleToRemove];
        // for each removed obstacle, add a new one
        [self spawnNewObstacle];
    }
    
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (!_gameOver) {
        [_hero.physicsBody applyImpulse:ccp(0, 400.f)];
        [_hero.physicsBody applyAngularImpulse:10000.f];
        _sinceTouch = 0.f;
    }
    
}

- (void)spawnNewObstacle {
    
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x;
    
    if (!previousObstacle) {
        // this is the first obstacle
        previousObstacleXPosition = firstObstaclePosition;
    }
    Obstacle *obstacle = (Obstacle *)[CCBReader load:@"Obstacle"];
    obstacle.position = ccp(previousObstacleXPosition + _distanceBetweenObstacles, -18);
    [obstacle setupRandomPosition];
    
    
    
    [_physicsNode addChild:obstacle];
    [_obstacles addObject:obstacle];
    
    obstacle.zOrder = DrawingOrderPipes;
    
    
    
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level {
    NSLog(@"Game Over");
    
    // Hero Speed Stop
    _scrollSpeed = 0.f;
    _hero.rotation = 90.f;
    _hero.physicsBody.allowsRotation = FALSE;
    
    
    CCSpriteFrame *frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Sprites/hero_die.png"];
    [_hero removeAllChildren];
    [_hero setSpriteFrame:frame];
    [_hero setRotation:-10.f];
    [_hero setScale:0.5];
    [_hero setFlipX:false];
    
    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"SealExplosion"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the seals position
    explosion.position = hero.position;
    // add the particle effect to the same node the seal is on
    [hero.parent addChild:explosion];
    
    [self gameOver];
    //_restartButton.visible = TRUE;
    
    
    return TRUE;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero goal:(CCNode *)goal {
    
    // Remove Goal
    [goal removeFromParent];
    
    // Add Point
    _points++;
    // Show Point
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
    
    // Point Condition Stage
    if (_points > 5)_scrollSpeed = 100.f;
    if (_points > 10)_scrollSpeed = 120.f;
    if (_points > 15){
        _scrollSpeed = 140.f;
        _distanceBetweenObstacles = 125.f;
        
    }
    if (_points > 20){
        _scrollSpeed = 160.f;
        _distanceBetweenObstacles = 130.f;
        
    }
    
    if (_points > 25){
        _scrollSpeed = 180.f;
        _distanceBetweenObstacles = 135.f;
        
    }
    
    if (_points > 30){
        _scrollSpeed = 200.f;
        _distanceBetweenObstacles = 140.f;
    }
    
    if (_points > 35){
        _scrollSpeed = 220.f;
        _distanceBetweenObstacles = 145.f;
    }
    
    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"heroGoalEffect"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the HERO position
    explosion.position = hero.position;
    // add the particle effect to the same node the seal is on
    [hero.parent addChild:explosion];
    
    explosion = (CCParticleSystem *)[CCBReader load:@"scoreboardEffect"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the Label position
    explosion.position = _scoreLabel.positionInPoints;
    // add the particle effect to the same node the Label is on
    [_scoreLabel.parent addChild:explosion];
    
    
    return TRUE;
}

- (void)restart {
    
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:scene];
    
    
}

- (void)gameOver {
    if (!_gameOver) {
        
        // Hero Properties
        // Hero Speed Stop
        _scrollSpeed = 0.f;
        _hero.rotation = 90.f;
        _hero.physicsBody.allowsRotation = FALSE;
        [_hero stopAllActions];
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.05f position:ccp(-5, 5)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        [self runAction:bounce];
        
        
        if([GKLocalPlayer localPlayer].authenticated) {
            
            // Game Center Score Update
            [self updateScore:_points forLeaderboardID:@"L20140216FT"];
            [self getCurrentLeaderboardScore:@"L20140216FT"];
            
        }else{
            
            // High Score Keeping
            if (_points > _hi_score_i){
                _hi_score_i = _points ;
            }
            
        }
        
        // Vibration When Game Over
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        // High Score Real Time Update Prepare
        is_highScore_update = FALSE;
        
        // Control the Button
        _scoreLabel.visible = FALSE;
        _hi_score_label.visible = TRUE;
        _youscore_label.visible = TRUE;
        _sum_score.visible = TRUE;
        _game_over_label.visible = TRUE;
        _gameCenterButton.visible = TRUE;
        _restartButton.visible = TRUE;
        
        // Show the Score to the Label Object
        _your_score.string = [NSString stringWithFormat:@"%d", _points];
        
        _hi_score.string = [NSString stringWithFormat:@"%lld", _hi_score_i];
        
        // Show to Score to the Screen
        _hi_score.visible = TRUE;
        _your_score.visible = TRUE;
        
        _gameOver = TRUE;
    }
}


- (void) updateScore: (int64_t) score forLeaderboardID: (NSString*) category
{
    GKScore *scoreObj = [[GKScore alloc] initWithCategory:category];
    scoreObj.value = score;
    scoreObj.context = 0;
    [scoreObj reportScoreWithCompletionHandler:^(NSError *error) {
        // Completion code can be added here
        //        UIAlertView *alert = [[UIAlertView alloc]
        //                              initWithTitle:nil message:@"Score Updated Succesfully"
        //                              delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        //        [alert show];
        
    }];
}

-(void) gameCenter_bt{
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = self;
    CCAppDelegate *delegate = (CCAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.navController presentModalViewController:leaderboardViewController animated:YES];
}

#pragma mark - Gamekit delegates
- (void)leaderboardViewControllerDidFinish:
(GKLeaderboardViewController *)viewController{
    CCAppDelegate *delegate = (CCAppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.navController dismissModalViewControllerAnimated:YES];
}

-(void)getCurrentLeaderboardScore:(NSString *)Category
{
    //NSLog(@"find score for category %@ ", Category);
    if([GKLocalPlayer localPlayer].authenticated) {
        NSArray *arr = [[NSArray alloc] initWithObjects:[GKLocalPlayer localPlayer].playerID, nil];
        GKLeaderboard *board = [[GKLeaderboard alloc] initWithPlayerIDs:arr];
        if(board != nil) {
            board.timeScope = GKLeaderboardTimeScopeAllTime;
            board.range = NSMakeRange(1, 1);
            board.category = Category;
            [board loadScoresWithCompletionHandler: ^(NSArray *scores, NSError *error) {
                if (error != nil) {
                    // handle the error.
                    NSLog(@"Error retrieving score.", nil);
                }
                if (scores != nil) {
                    _hi_score_i= ((GKScore*)[scores objectAtIndex:0]).value;
                    NSLog(@"My Score: %lli", _hi_score_i);
                    //                    long long totalScoreToSubmit = myCurrScore+calculatedScore;
                    //                    [[GCHelper sharedInstance] reportScore:totalScoreToSubmit forCategory:Category];
                }
            }];
        }
    }
}

// for Game Center AchievementIdentifier
- (void) reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent
{
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: identifier];
    if (achievement)
    {
        achievement.percentComplete = percent;
        [achievement reportAchievementWithCompletionHandler:^(NSError *error)
         {
             if (error != nil)
             {
                 NSLog(@"Error in reporting achievements: %@", error);
             }
         }];
    }
}

- (void)layoutAnimated:(BOOL)animated
{
    // As of iOS 6.0, the banner will automatically resize itself based on its width.
    // To support iOS 5.0 however, we continue to set the currentContentSizeIdentifier appropriately.
    CGRect contentFrame = [CCDirector sharedDirector].view.bounds;
    if (contentFrame.size.width < contentFrame.size.height) {
        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    } else {
        _bannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierLandscape;
    }
    
    CGRect bannerFrame = _bannerView.frame;
    if (_bannerView.bannerLoaded) {
        contentFrame.size.height -= _bannerView.frame.size.height;
        bannerFrame.origin.y = contentFrame.size.height;
    } else {
        bannerFrame.origin.y = contentFrame.size.height;
    }
    
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        _bannerView.frame = bannerFrame;
    }];
}

#pragma mark - AdViewDelegates

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    [self layoutAnimated:YES];
    NSLog(@"Error loading");
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner{
    [self layoutAnimated:YES];
    NSLog(@"Ad loaded");
}
-(void)bannerViewWillLoadAd:(ADBannerView *)banner{
    NSLog(@"Ad will load");
}
-(void)bannerViewActionDidFinish:(ADBannerView *)banner{
    NSLog(@"Ad did finish");
    
}


@end
