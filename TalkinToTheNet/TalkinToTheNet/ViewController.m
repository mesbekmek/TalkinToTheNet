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
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

NSString const *clientID = @"2Y20530SGQR4IN4DVOMH41P312TZMVKSTFEMQNERGYQ3UW2T";
NSString const *clientSecrect = @"4F3XAJLC01RA5IXLSI20XKOFYJI2ZVKJWEV2235WIV0N4MJG";
NSString const *latitude = @"40.8700250";
NSString const *longitude = @"-73.8837900";
NSString const *rawUrlString = @"https://api.foursquare.com/v2/venues/search?ll=40.8306760,-73.9142540789&client_id=2Y20530SGQR4IN4DVOMH41P312TZMVKSTFEMQNERGYQ3UW2T&client_secret=4F3XAJLC01RA5IXLSI20XKOFYJI2ZVKJWEV2235WIV0N4MJG&v=20150920";

@interface ViewController () <UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate,
MKMapViewDelegate,
CLLocationManagerDelegate>

@property (nonatomic) NSString *urlString;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;

@end

@implementation ViewController{
    CLLocationManager *locationManager;
    UITapGestureRecognizer *tap;
    CLLocationCoordinate2D touchMapCoordinate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

-(void)setup{
    //seting up delegates
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchTextField.delegate = self;
    self.mapView.delegate = self;
    locationManager.delegate = self;
    
    //Foursquare API string
    self.urlString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%@,%@&client_id=%@&client_secret=%@&v=20150920",latitude,longitude,clientID,clientSecrect];
    [self fetchFourSquareData:self.urlString];
    
    //seting up refresh control
    UIRefreshControl *refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    //MapView Setup
    self.mapView.showsUserLocation = YES;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.userInteractionEnabled = YES;
  //  self.searchButton.enabled = NO;
    
    //Ability to drop a pin on the map
    UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    gestureRecognizer.minimumPressDuration = 1.0;
    [self.mapView addGestureRecognizer:gestureRecognizer];
}


#pragma mark UIRefresh Control method
-(void)refreshData:(UIRefreshControl *)refreshControl{
    [self.tableView reloadData];
    [refreshControl endRefreshing];
    
}

#pragma mark - Fetch FourSquare Data method
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

#pragma mark - textField methods
- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    NSString *latitude = [NSString stringWithFormat:@"%f",self.mapView.userLocation.location.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",self.mapView.userLocation.location.coordinate.longitude];
    
    
    NSString *queryString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%@,%@&client_id=2Y20530SGQR4IN4DVOMH41P312TZMVKSTFEMQNERGYQ3UW2T&client_secret=4F3XAJLC01RA5IXLSI20XKOFYJI2ZVKJWEV2235WIV0N4MJG&v=20150920&query=%@",latitude,longitude,textField.text];
    NSString *encodedString = [queryString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    [self fetchFourSquareData:encodedString];
    [textField endEditing:YES];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //Dismiss keyboard when pressing outside textfield
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];   
}


-(void)dismissKeyboard{
    [self.searchTextField resignFirstResponder];
    [self.view removeGestureRecognizer:tap];
    
}

#pragma mark - Map View and Location Manager methods

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(nonnull MKUserLocation *)userLocation{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
    MKPointAnnotation *point = [MKPointAnnotation new];
    point.coordinate = userLocation.coordinate;
    point.title = @"Here!";
    
    [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
    
    [self.mapView addAnnotation:point];
    [locationManager stopUpdatingLocation];
    locationManager = nil;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if(gestureRecognizer.state != UIGestureRecognizerStateBegan){
        return;
    }
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    MKPointAnnotation *annotation = [MKPointAnnotation new];
    annotation.coordinate = touchMapCoordinate;
   // self.mapView.userLocation.coordinate = touchMapCoordinate;
    [self.mapView addAnnotation:annotation];
}

- (IBAction)zoomToCurrentLocation:(UIBarButtonItem *)sender {
    float spanX = 0.00725;
    float spanY = 0.00725;
    MKCoordinateRegion region;
    region.center.latitude = self.mapView.userLocation.coordinate.latitude;
    region.center.longitude = self.mapView.userLocation.coordinate.longitude;
    region.span.latitudeDelta = spanX;
    region.span.longitudeDelta = spanY;
    [self.mapView setRegion:region animated:YES];
}


-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    self.searchButton.enabled = YES;
}

- (IBAction)searchButtonTapped:(UIBarButtonItem *)sender {

    NSString *latitude = [NSString stringWithFormat:@"%f",touchMapCoordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f",touchMapCoordinate.longitude];

    NSString *queryString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%@,%@&client_id=2Y20530SGQR4IN4DVOMH41P312TZMVKSTFEMQNERGYQ3UW2T&client_secret=4F3XAJLC01RA5IXLSI20XKOFYJI2ZVKJWEV2235WIV0N4MJG&v=20150920&query=%@",latitude,longitude,self.searchTextField.text];
    NSString *encodedString = [queryString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSLog(@"%@",self.searchTextField.text);
    [self fetchFourSquareData:encodedString];
}


#pragma mark - Life Cycle
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSDictionary *fourSquareData = self.searchResults[indexPath.row];
    FourSquareDetailViewController *vc = segue.destinationViewController;
    vc.foursquareData = fourSquareData;
    
}


@end
