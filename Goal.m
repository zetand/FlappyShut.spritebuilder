//
//  Goal.m
//  FlappyShut
//
//  Created by Veeraphat Philaskhanapong on 2/12/2557 BE.
//  Copyright (c) 2557 Apportable. All rights reserved.
//

#import "Goal.h"

@implementation Goal

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"goal";
    self.physicsBody.sensor = TRUE;
}

@end
