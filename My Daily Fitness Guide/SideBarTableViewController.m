//
//  SideBarTableViewController.m
//  My Daily Fitness Guide
//
//  Created by yogesh on 15/05/2014.
//  Copyright (c) 2014 yogesh. All rights reserved.
//

#import "SideBarTableViewController.h"
#import "SWRevealViewController.h"
#import "FirstTabViewController.h"

@interface SideBarTableViewController () <UIAlertViewDelegate> {
    UIAlertView *alertResetBody;
    FMDatabase *database;
}

@end

@implementation SideBarTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set background color of tableView
    //self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#555555"];
    //self.tableView.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    self.tableView.separatorColor = [UIColor colorWithWhite:0.15f alpha:0.2f];
    
    // Create alertBox for Reset Body Stats
    alertResetBody = [[UIAlertView alloc] initWithTitle:nil message:@"Are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    
    // Initialize database
    database = [FMDatabase databaseWithPath:[DatabaseExtra dbPath]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 14;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 10) {
        NSString *text = @"Hi, I’m using My Daily Fitness Guide iPhone app from Gold’s Gym. Download it now from - ";
        NSURL *url = [NSURL URLWithString:@"http://tinyurl.com/goldsgymindia-ios"];
        UIImage *image = [UIImage imageNamed:@"app_icon_120x120.png"];
        
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[text, url, image] applicationActivities:nil];
        
        controller.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                             UIActivityTypePrint,
                                             UIActivityTypeAssignToContact,
                                             UIActivityTypeSaveToCameraRoll,
                                             UIActivityTypeAddToReadingList,
                                             UIActivityTypePostToFlickr,
                                             UIActivityTypePostToVimeo,
                                             UIActivityTypePostToTencentWeibo,
                                             UIActivityTypeAirDrop];
        
        [self presentViewController:controller animated:YES completion:nil];
        
        [controller setCompletionHandler:^(NSString *activityType, BOOL completed)
         {
             if (completed)
             {
                 UIAlertView *objalert = [[UIAlertView alloc]initWithTitle:nil message:@"Successfully Shared" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                 [objalert show];
                 objalert = nil;
             }
         }];
        [self loadHomePage];
    } else if (indexPath.row == 8) {
        [alertResetBody show];
    } else if(indexPath.row == 11) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:Rate_Us_URL]];
        [self loadHomePage];
    }
}

#pragma mark - UIAlertView Delegate methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == alertResetBody) {
        if (buttonIndex == 0) {
            // Load home page when user pressed Cancel Button
            [self loadHomePage];
            
        } else if (buttonIndex == 1) {
            // Reset all data regarding user's workout
            [database open];
            [database executeUpdate:@"UPDATE fitnessMainData SET value = ? WHERE type = ?", @"Undefined", @"goal"];
            [database executeUpdate:@"UPDATE fitnessMainData SET value = ? WHERE type = ?", @"veg", @"vegNonVeg"];
            [database executeUpdate:@"DELETE FROM dailyTicks"];
            [database executeUpdate:@"UPDATE dietaryRecall SET calcValue = ?", @""];
            [database executeUpdate:@"UPDATE achievementTable SET appear = ?, dateShown = ?", @"false", @""];
            [database executeUpdate:@"UPDATE medicalCondition SET selected = ?", @"false"];
            [database executeUpdate:@"DELETE FROM monthLog"];
            [database close];

            [[NSUserDefaults standardUserDefaults] setObject:NULL forKey:@"energy"];
            [[NSUserDefaults standardUserDefaults] setObject:NULL forKey:@"carbohydrates"];
            [[NSUserDefaults standardUserDefaults] setObject:NULL forKey:@"protiens"];
            [[NSUserDefaults standardUserDefaults] setObject:NULL forKey:@"fats"];
            [[NSUserDefaults standardUserDefaults] setObject:NULL forKey:@"fibre"];

            [[NSUserDefaults standardUserDefaults] setObject:NULL forKey:@"Breakfast"];
            [[NSUserDefaults standardUserDefaults] setObject:NULL forKey:@"Lunch"];
            [[NSUserDefaults standardUserDefaults] setObject:NULL forKey:@"Snacks"];
            [[NSUserDefaults standardUserDefaults] setObject:NULL forKey:@"Dinner"];
            [[NSUserDefaults standardUserDefaults] setObject:NULL forKey:@"Bedtime"];

            [[NSUserDefaults standardUserDefaults] synchronize];
            
            // Cancel all localnotification
            [[UIApplication sharedApplication] cancelAllLocalNotifications];

            // Delete all user's body picks from gallery folder
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectoryPath = [paths objectAtIndex:0];
            NSFileManager *fm = [NSFileManager defaultManager];
            NSString *directory = [documentsDirectoryPath stringByAppendingPathComponent:@"gallery/"];
            NSError *error = nil;
            for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
            BOOL success = [fm removeItemAtPath:[NSString stringWithFormat:@"%@/%@", directory, file] error:&error];
                if (!success || error) {
                    // it failed.
                }
            }
            
            // load home page
            [self loadHomePage];
        }
    }
}

-(void)loadHomePage {
    
    /*
     Function for loading Home Page after Resetting body stats
     */
    
    FirstTabViewController *dvc = (FirstTabViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"firstTab"];
    UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
    [navController setViewControllers: @[dvc] animated: NO ];
    
    SWRevealViewController *revealController = self.revealViewController;
    [revealController setFrontViewController:navController animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        // Open Other linked Pages
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;
        
        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: NO ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
        
    }
}

@end
