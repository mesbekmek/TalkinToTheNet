//
//  ViewController.m
//  TalkinToTheNet
//
//  Created by Michael Kavouras on 9/20/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "ViewController.h"
#import "APIManager.h"
#import "FourSquareDetailViewController.h"


NSString const *clientID = @"2Y20530SGQR4IN4DVOMH41P312TZMVKSTFEMQNERGYQ3UW2T";
NSString const *clientSecrect = @"4F3XAJLC01RA5IXLSI20XKOFYJI2ZVKJWEV2235WIV0N4MJG";
NSString const *latitude = @"40.8306760";
NSString const *longitude = @"-73.9142540";
NSString const *rawUrlString = @"https://api.foursquare.com/v2/venues/search?ll=40.8306760,-73.9142540789&client_id=2Y20530SGQR4IN4DVOMH41P312TZMVKSTFEMQNERGYQ3UW2T&client_secret=4F3XAJLC01RA5IXLSI20XKOFYJI2ZVKJWEV2235WIV0N4MJG&v=20150920";


@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic) NSString *urlString;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *searchResults;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

-(void)setup{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchTextField.delegate = self;
    self.urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%@,%@&client_id=%@&client_secret=%@&v=20150920",latitude,longitude,clientID,clientSecrect];
    [self fetchFourSquareData:self.urlString];
    
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

-(void)refreshData:(UIRefreshControl *)refreshControl{
    [self.tableView reloadData];
    [refreshControl endRefreshing];
    
}

-(void) fetchFourSquareData:(NSString *)urlString{
    NSURL *url = [NSURL URLWithString:urlString];
    
    [APIManager GETRequestWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSDictionary *searchResponse = [results objectForKey:@"response"];
        self.searchResults = [searchResponse objectForKey:@"venues"];
        [self.tableView reloadData];
        
    }];
}

#pragma mark - Table View Delegate and Data Source methods
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.searchResults.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier" forIndexPath:indexPath];
    
    NSDictionary *dict = self.searchResults[indexPath.row];
    NSString *venueName = [dict objectForKey:@"name"];
    cell.textLabel.text = venueName;
    return cell;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField{

    
    NSString *queryString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=40.8306760,-73.9142540789&client_id=2Y20530SGQR4IN4DVOMH41P312TZMVKSTFEMQNERGYQ3UW2T&client_secret=4F3XAJLC01RA5IXLSI20XKOFYJI2ZVKJWEV2235WIV0N4MJG&v=20150920&query=%@",textField.text ];
    NSString *encodedString = [queryString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self fetchFourSquareData:encodedString];
    [textField endEditing:YES];
    return YES;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    NSDictionary *fourSquareData = self.searchResults[indexPath.row];
    FourSquareDetailViewController *vc = segue.destinationViewController;
    vc.foursquareData = fourSquareData;
    
}


@end
