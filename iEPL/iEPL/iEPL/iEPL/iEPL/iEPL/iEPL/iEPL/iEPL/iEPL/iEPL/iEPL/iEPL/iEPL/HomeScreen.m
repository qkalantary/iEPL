//
//  HomeScreen.m
//  iEPL
//
//  Created by Q Kalantary on 2/4/15.
//  Copyright (c) 2015 Q Kalantary. All rights reserved.
//

#import "HomeScreen.h"
#import <NMSSH/NMSSH.h>
@interface HomeScreen ()

@end

@implementation HomeScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    NMSSHSession *session = [NMSSHSession connectToHost:@"@rhino.psych.upenn.edu"
//                                           withUsername:@"qkal"];
//    
//    if (session.isConnected) {
//        [session authenticateByPassword:@"Qpiano!1231"];
//        
//        if (session.isAuthorized) {
//            NSLog(@"Authentication succeeded");
//        }
//    }
//
//    
//    NMSFTP *ftp = [NMSFTP connectWithSession:session];
//    NSArray *arr = [ftp contentsOfDirectoryAtPath:@"/home2/qkal"];
//    NSLog(@"%@", arr);
//    NSString* str = @"teststring2";
//    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
//    [ftp appendContents:data toFileAtPath:@"/home2/qkal/test2.txt"];
//    
//    
//    
//    [session disconnect];
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

@end
