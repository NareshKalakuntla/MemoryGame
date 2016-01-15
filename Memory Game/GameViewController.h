//
//  GameViewController.h
//  Memory Game
//
//  Created by Naresh Kalakuntla on 1/14/16.
//  Copyright © 2016 Naresh Kalakuntla. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameViewController : UIViewController 

@property (nonatomic, strong) NSArray *photos; // of Flickr photo NSDictionary
@property (weak, nonatomic) IBOutlet UILabel *movesLabel;

- (void)startGame;

@end
