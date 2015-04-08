//
//  SampleCollectionViewController.m
//  SamplePhotoViewer
//
//  Created by Ravi Koluguri on 3/30/15.
//  Copyright (c) 2015 Ravi Koluguri. All rights reserved.
//

#import "SampleCollectionViewController.h"
#import "SamplePhotoCell.h"

@interface SampleCollectionViewController ()

@property (nonatomic,strong) NSMutableArray *result;
@property (nonatomic) BOOL isSearching;
@property (nonatomic,strong) NSMutableArray *filteredList;
@property (nonatomic,strong) NSMutableArray *list;
@property (nonatomic,strong) MFMailComposeViewController *mc;

@end

@implementation SampleCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSData* data = [NSData dataWithContentsOfURL:
                    [NSURL URLWithString:@"https://api.flickr.com/services/feeds/photos_public.gne?format=json"]];
    
    [self performSelectorOnMainThread:@selector(fetchedData:)
                           withObject:data waitUntilDone:YES];
    
    self.mc = [[MFMailComposeViewController alloc] init];
    
    self.mc.mailComposeDelegate = self;
    
    UINib *cellNib = [UINib nibWithNibName:@"SamplePhotoCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"PhotoCell"];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(100, 100)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.collectionView setCollectionViewLayout:flowLayout];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
#warning Incomplete method implementation -- Return the number of sections
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
#warning Incomplete method implementation -- Return the number of items in the section
    return [self.result count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"PhotoCell";
    
    SamplePhotoCell *cell = (SamplePhotoCell *) [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    SamplePhotoCell *photoCell = ((SamplePhotoCell *)self.result[indexPath.row]);
    
    cell.media = photoCell.media;
    
    cell.photoTitle.text = photoCell.title;
    
    cell.photoView.image = [UIImage imageNamed:@"placeHolder.jpg"];
    
    NSURL *photoURL = [NSURL URLWithString:photoCell.media];
    
    [self downloadImageWithURL:photoURL completionBlock:^(BOOL succeeded, UIImage *image) {
        if (succeeded) {
            cell.photoView.image = image;
        }
    }];
    
    return cell;
}

/* This Method is Used to parse the JSON file downloaded from URL
 * the parsing is done with NSJSONSerialization
 */
-(void) fetchedData:(NSData *)responseData{
    NSError *e = nil;
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:responseData];
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *subString = [responseString substringWithRange:NSMakeRange(15, [responseString length]-16)];
    NSData *jsonData;
    if ([subString containsString:@"'"])
    {
        NSString *replacedString = [subString stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        jsonData = [replacedString dataUsingEncoding:NSUTF8StringEncoding];
    }
    else
    {
        jsonData = [subString dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSDictionary *cast = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&e];
    self.result = [[NSMutableArray alloc]init];
    NSArray *castArray = [cast objectForKey:@"items"];
    for (NSDictionary *dictionary in castArray) {
        SamplePhotoCell *object = [[SamplePhotoCell alloc]init];
        object.title = [dictionary objectForKey:@"title"];
        object.date_take = [dictionary objectForKey:@"date_taken"];
        object.tags= [dictionary objectForKey:@"tags"];
        NSDictionary *tempDictionary = [dictionary objectForKey:@"media"];
        object.media = [tempDictionary objectForKey:@"m"];
        [self.result addObject:object];
    }
}

- (void)downloadImageWithURL:(NSURL *)url completionBlock:(void (^)(BOOL succeeded, UIImage *image))completionBlock
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if ( !error )
                               {
                                   UIImage *image = [[UIImage alloc] initWithData:data];
                                   completionBlock(YES,image);
                               } else{
                                   completionBlock(NO,nil);
                               }
                           }];
}
#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/


// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SamplePhotoCell *cell = (SamplePhotoCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    NSString *emailTitle = cell.photoTitle.text;
    // Email Content
    UIImage *image = cell.photoView.image;
    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    NSString *messageBody = @"Photo";
    
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"raviteja.3927@gmail.com"];
    
    [self.mc addAttachmentData:imageData mimeType:@"image/png" fileName:@"ImagenFinal"];
    
    [self.mc setSubject:emailTitle];
    [self.mc setMessageBody:messageBody isHTML:NO];
    [self.mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:self.mc animated:YES completion:NULL];
    return YES;
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
