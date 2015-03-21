//
//  LogIn.m
//  iEPL
//
//  Created by Q Kalantary on 2/16/15.
//  Copyright (c) 2015 Q Kalantary. All rights reserved.
//

#import "LogIn.h"

@interface LogIn ()
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation LogIn

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)logIn:(id)sender {
    [self performSegueWithIdentifier:@"correct" sender:sender];
}

- (IBAction)signUp:(id)sender {
    [self performSegueWithIdentifier:@"signUp" sender:sender];
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
