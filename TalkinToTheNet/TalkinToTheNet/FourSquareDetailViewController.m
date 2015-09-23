//
//  FourSquareDetailViewController.m
//  TalkinToTheNet
//
//  Created by Mesfin Bekele Mekonnen on 9/21/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "FourSquareDetailViewController.h"
#import "STTwitter.h"

@interface FourSquareDetailViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UITableView *tweetsTableView;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel2;

@property (nonatomic) NSMutableArray *twitterFeed;
@property (nonatomic) NSString *twitterHandle;
@end

@implementation FourSquareDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup{
    
    //Tableview setup
    self.tweetsTableView.dataSource = self;
    self.tweetsTableView.delegate = self;
    
    //Location Section from API response
    NSDictionary *location = [self.foursquareData objectForKey:@"location"];
    NSArray *formattedAddress = [location objectForKey:@"formattedAddress"];
    
    NSString *addressOne = [formattedAddress firstObject];
    self.locationLabel.text = addressOne ;

    
    if(formattedAddress.count >1){
        NSString *addressTwo = formattedAddress[1];
        self.locationLabel2.text = addressTwo;
    }
    else{
        self.locationLabel2.text = @" ";
    }
    
    
    //Category Section From API response
    NSArray *categoryArray = [self.foursquareData objectForKey:@"categories"];
    NSDictionary *categoryObject = [categoryArray firstObject];
    NSString *category = [categoryObject objectForKey:@"name"];
    
    self.categoryLabel.text = category;
    
    //Quest to find thy twitter handle
    NSDictionary *contacts = [self.foursquareData objectForKey:@"contact"];
    NSArray *allKeys = [contacts allKeys];
    if([allKeys containsObject:@"twitter"]){
        self.twitterHandle = [contacts objectForKey:@"twitter"];
    }
    else{
        self.twitterHandle = @"Doesn't have twitter account";
    }
    
    //Refreshing capabilities
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refreshTweets:) forControlEvents:UIControlEventValueChanged];
    [self.tweetsTableView addSubview:refreshControl];
    
}

#pragma mark Refreshing method

-(void)refreshTweets:(UIRefreshControl *)rc{
    [self.tweetsTableView reloadData];
    [rc endRefreshing];
}

#pragma mark Table View Data source and Delegate Methods

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.twitterFeed.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID" forIndexPath:indexPath];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
    }
   
   
    NSDictionary *tweets = self.twitterFeed[indexPath.row];
    cell.textLabel.text = tweets[@"text"];
        cell.imageView.image = tweets[@"image"];

        return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0;
}

#pragma mark Alert Controller method
-(void) noTweetsFoundAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"No Twitter Account Found" message:@"Sorry" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Ok Action");
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancel Action");
    }];
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)twitterButtonTapped:(UIButton *)sender {
    STTwitterAPI *twitter = [STTwitterAPI twitterAPIAppOnlyWithConsumerKey:@"JNSvKZtVsPN6UEgFZSuZsbFJn" consumerSecret:@"sFk4RbyK83Mo7S7aRwCfENS2KHa1zi5CkQ0LNHmJ5vBlpqfjaJ"];
    [twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        [twitter getUserTimelineWithScreenName:self.twitterHandle successBlock:^(NSArray *statuses) {
            
            self.twitterFeed = [NSMutableArray arrayWithArray:statuses];
            [self.tweetsTableView reloadData];
            
            
        } errorBlock:^(NSError *error) {
            if(self.twitterFeed.count == 0){
                [self noTweetsFoundAlert];
            }
            NSLog(@"%@",error.debugDescription);

        }];
        
    } errorBlock:^(NSError *error) {
        if(self.twitterFeed.count == 0){
            [self noTweetsFoundAlert];
        }
        
        NSLog(@"%@",error.debugDescription);
    }];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
