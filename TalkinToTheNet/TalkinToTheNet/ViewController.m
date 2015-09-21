//
//  ViewController.m
//  TalkinToTheNet
//
//  Created by Michael Kavouras on 9/20/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "ViewController.h"


NSString const *clientID = @"2Y20530SGQR4IN4DVOMH41P312TZMVKSTFEMQNERGYQ3UW2T";
NSString const *clientSecrect = @"4F3XAJLC01RA5IXLSI20XKOFYJI2ZVKJWEV2235WIV0N4MJG";

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic) NSString *urlString;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchTextField.delegate = self;
    self.urlString = @"https://api.foursquare.com/v2/venues/search?ll=40.7,-74&client_id=2Y20530SGQR4IN4DVOMH41P312TZMVKSTFEMQNERGYQ3UW2T&client_secret=4F3XAJLC01RA5IXLSI20XKOFYJI2ZVKJWEV2235WIV0N4MJG&v=20150920";
}


@end
