//
//  FourSquareDetailViewController.m
//  TalkinToTheNet
//
//  Created by Mesfin Bekele Mekonnen on 9/21/15.
//  Copyright © 2015 Mike Kavouras. All rights reserved.
//

#import "FourSquareDetailViewController.h"

@interface FourSquareDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@end

@implementation FourSquareDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Location Section from API response
    NSDictionary *location = [self.foursquareData objectForKey:@"location"];
    NSArray *formattedAddress = [location objectForKey:@"formattedAddress"];
    
    NSString *addressOne = [formattedAddress firstObject];
    NSString *addressTwo = formattedAddress[1];
    
    self.locationLabel.text = [addressOne stringByAppendingString:addressTwo];
    
    //Category Section From API response
    NSArray *categoryArray = [self.foursquareData objectForKey:@"categories"];
    NSDictionary *categoryObject = [categoryArray firstObject];
    NSString *category = [categoryObject objectForKey:@"name"];
    
    self.categoryLabel.text = category;
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
