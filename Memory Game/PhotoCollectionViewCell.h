//
//  PhotoCollectionViewCell.h
//  Memory Game
//
//  Created by Naresh Kalakuntla on 1/14/16.
//  Copyright © 2016 Naresh Kalakuntla. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *actualImageView;
@property (nonatomic, strong) UIImageView *defaultImageView;
@property (nonatomic, strong) NSString *imageId;
@property (nonatomic, assign) BOOL isShowingActualImage;

- (void) flipImage;

@end
