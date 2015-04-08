//
//  SampleCollectionViewController.h
//  SamplePhotoViewer
//
//  Created by Ravi Koluguri on 3/30/15.
//  Copyright (c) 2015 Ravi Koluguri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface SampleCollectionViewController : UICollectionViewController<NSURLConnectionDataDelegate,MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end
