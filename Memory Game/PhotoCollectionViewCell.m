//
//  PhotoCollectionViewCell.m
//  Memory Game
//
//  Created by Naresh Kalakuntla on 1/14/16.
//  Copyright © 2016 Naresh Kalakuntla. All rights reserved.
//

#import "PhotoCollectionViewCell.h"

@implementation PhotoCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.actualImageView = [[UIImageView alloc] init];
        self.defaultImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"defaultImage"]];
        [self.contentView addSubview:self.actualImageView];
        self.isShowingActualImage = YES;
        
        self.backgroundColor = [UIColor grayColor];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.actualImageView.image = nil;
    self.imageId = nil;
    
}

- (void)layoutSubviews {
    
    CGRect imgRect = CGRectMake(0,0,self.frame.size.width * 0.8, self.frame.size.height * 0.8);
    
    self.actualImageView.frame = imgRect;
    self.defaultImageView.frame = imgRect;
    
    self.actualImageView.center = self.contentView.center;
    self.defaultImageView.center = self.contentView.center;
    
}

- (void) flipImage {
    
    UIImageView *showingImgView = self.isShowingActualImage ? self.actualImageView : self.defaultImageView;
    UIImageView *hidingImageView = !self.isShowingActualImage ?self.actualImageView : self.defaultImageView;
    
    [UIView transitionFromView:showingImgView
                        toView:hidingImageView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:^(BOOL finished) {
        // completion code
    }];
   
    self.isShowingActualImage = !self.isShowingActualImage;
    
}

@end
