//
//  SamplePhotoCell.h
//  SamplePhotoViewer
//
//  Created by Ravi Koluguri on 3/31/15.
//  Copyright (c) 2015 Ravi Koluguri. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SamplePhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoView;

@property (weak, nonatomic) IBOutlet UILabel *photoTitle;

@property (nonatomic,strong) NSString *title;

@property (nonatomic,strong) NSString *date_take;

@property (nonatomic,strong) NSString *tags;

@property (nonatomic,strong) NSString *media;

@end
