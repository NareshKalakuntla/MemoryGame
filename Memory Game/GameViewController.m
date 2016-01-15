//
//  GameViewController.m
//  Memory Game
//
//  Created by Naresh Kalakuntla on 1/14/16.
//  Copyright © 2016 Naresh Kalakuntla. All rights reserved.
//

#import "GameViewController.h"
#import "PhotoCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "FlickrHelper.h"

#define kTimeToMemorize 15
#define kWaitingTime 1

@interface GameViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (weak, nonatomic) IBOutlet UIImageView *currentImageView;
@property (strong, nonatomic) NSString *currentImageId;
@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;

@property (strong, nonatomic) NSMutableArray *randomArray;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    
    [self.imagesCollectionView registerClass:[PhotoCollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCell"];
    [self.imagesCollectionView setBackgroundColor:[UIColor clearColor]];
    
    self.randomArray = [NSMutableArray array];
    self.currentImageId = [NSString string];
    
    [self prepareToStartGame:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)prepareToStartGame:(id)sender {
    
    [self.messageLabel setText:@"Memorise Images"];
    [self.movesLabel setText:@"0"];
    
    [self.randomArray removeAllObjects];
    // Add numbers to array
    for (int i=0; i < 9; i++) {
        [self.randomArray addObject:[NSNumber numberWithInt:i]];
    }
    
    // randomize the array
    NSUInteger count = [self.randomArray count];
    if (count > 1) {
        for (NSUInteger i = count - 1; i > 0; --i) {
            [self.randomArray exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform((int32_t)(i + 1))];
        }
    }
    
    [self fetchPhotos];
}

- (void)startGame {

    [self.movesLabel setText:@"0"];
    __weak typeof(self) _weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTimeToMemorize * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.messageLabel setText:@"Recognize the correct Image"];
        [_weakSelf flipAllImages];
        [_weakSelf showImageForRecognition];
        
    });
}


- (void)flipAllImages {
    
    NSInteger totalCells = [self.imagesCollectionView numberOfItemsInSection:0];
    
    for (int i=0; i < totalCells; i++) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[self.imagesCollectionView cellForItemAtIndexPath:indexPath];
        [cell flipImage];
        
    }
    
    
}

- (void)showImageForRecognition {
    if (self.randomArray.count > 0) {
        
        NSDictionary *currentPhotoDic = [self.photos objectAtIndex:[self.randomArray[0] integerValue]];
        
        [self.currentImageView setShowActivityIndicatorView:YES];
        [self.currentImageView sd_setImageWithURL:[FlickrHelper URLforPhoto:currentPhotoDic format:FlickrPhotoFormatSquare] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [self.currentImageView setShowActivityIndicatorView:NO];
        }];
        
        self.currentImageId = [NSString stringWithFormat:@"%@",[currentPhotoDic objectForKey:@"id"]];
        
        [self.randomArray removeObjectAtIndex:0];
        
    } else {
        [self showGameCompleted];
    }
}

- (void)showGameCompleted {
    [self.messageLabel setText:@"Congrats!! Game completed!!"];
}

#pragma mark UICollectionView Data Source


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    [cell setUserInteractionEnabled:YES];
    
    NSDictionary *photoDic = [self.photos objectAtIndex:indexPath.row];
    
    PhotoCollectionViewCell *photoCell = (PhotoCollectionViewCell *)cell;
    [photoCell setImageId:[NSString stringWithFormat:@"%@",[photoDic objectForKey:@"id"]]];
    [photoCell.actualImageView setShowActivityIndicatorView:YES];
    [photoCell.actualImageView sd_setImageWithURL:[FlickrHelper URLforPhoto:photoDic format:FlickrPhotoFormatSquare] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [photoCell.actualImageView setShowActivityIndicatorView:NO];
    }];
    
    return cell;
}

#pragma mark UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PhotoCollectionViewCell *cell = (PhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    // Show the actual image now
    [cell flipImage];
    
    // Check if it is correct.
    if ([cell.imageId isEqualToString:self.currentImageId]) {
        // if yes then disable the cell and change the memory image
        
        [cell setBackgroundColor:[UIColor greenColor]];
        [cell setUserInteractionEnabled:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kWaitingTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showImageForRecognition];
        });
        
    } else {
       // else, flip it back
        [cell setBackgroundColor:[UIColor redColor]];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kWaitingTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [cell flipImage];
            [cell setBackgroundColor:[UIColor grayColor]];
        });
        
    }
    
  // Increase the moves number
    [self.movesLabel setText:[NSString stringWithFormat:@"%ld",[self.movesLabel.text integerValue] + 1 ]];
    
    
    
}

#pragma mark UICollectionView Layout Delegates

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat side = collectionView.frame.size.width/3.2;
    return CGSizeMake(side , side);
}


- (void)fetchPhotos {

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSURL *url = [FlickrHelper URLforRecentGeoreferencedPhotos];
    
    
    __weak typeof(self) _weakSelf = self;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:[url absoluteString] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        self.photos = [responseObject valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        [self.imagesCollectionView reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [_weakSelf startGame];
        });
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        
    }];
    
}

@end
