//
//  FreeRecall0.m
//  iEPL
//
//  Created by Q Kalantary on 2/4/15.
//  Copyright (c) 2015 Q Kalantary. All rights reserved.
//

#import "FreeRecall0.h"
#import <AVFoundation/AVAudioSession.h>
#import "FreeRecallWordShow.h"

@interface FreeRecall0 ()
@property (weak, nonatomic) IBOutlet UIButton *affirmButton;
@property (weak, nonatomic) IBOutlet UITextView *instructionText;
@property (strong, nonatomic) NSArray *keyArray;
@property (strong, nonatomic) NSDictionary *wordList;

@end

@implementation FreeRecall0

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDictionary *wordList = [NSDictionary dictionaryWithObjectsAndKeys:
                      @"11111", @"word1",
                      @"22222", @"word2",
                      @"3333", @"word3",
                      @"4444", @"word4",
                      @"5555", @"word5",
                      @"6666", @"word6",
                      @"7777", @"word7",
                      @"8888", @"word8",
                      @"9999", @"word9",
                      @"10 10 10", @"word10",
                      @"11 11 11", @"word11",
                      @"12 12 12", @"word12",
                      @"********", @"word13",
                        nil];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:wordList
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got a JSON error: %@", error);
    } else {
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", jsonString);

    }
    
    NSArray *arr =  [[wordList allKeys] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
    
    NSLog(@"%@", arr);
    
    
    self.keyArray = arr;
    self.wordList = wordList;
    
}
- (IBAction)clickButton:(id)sender {

    //intro sequence of instructions
    if ([self.affirmButton.currentTitle  isEqual: @"Click This After You Read Above Info"]) {
        self.instructionText.text = @"Please allow the Mic. It's going to be used for important recording purposes. Just trust us. We're scientists.";
        CGRect frame = self.instructionText.frame;
        frame.size = self.instructionText.contentSize;
        self.instructionText.frame = frame;
        
        [self.affirmButton setTitle:@"Allow Mic Access" forState:UIControlStateNormal];

    } else if ([self.affirmButton.currentTitle  isEqual: @""]) {
        
        
        
        
        [self.affirmButton setTitle:@"Allow Mic Access" forState:UIControlStateNormal];
    } else if ([self.affirmButton.currentTitle  isEqual: @"Allow Mic Access"]) {
        NSLog(@"mic access allow pressed");
        
        PermissionBlock permissionBlock = ^(BOOL granted) {
            if (granted)
            {
                //[self doActualRecording];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"list" sender:self];
                });
            }
            else
            {
                // Warn no access to microphone
                NSLog(@"Microphone permission denied");
                self.instructionText.text = @"Microphone permission has been denied. Please accept the microphone as it is essential for this experiment.";
            }
        };
        
        // iOS7+ request microphone permission with permissionBlock
        if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)])
        {
            NSLog(@"microphone permission accepted");
            
            [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:)
                                                  withObject:permissionBlock];
            
        }
        else
        {
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    FreeRecallWordShow *dest = [segue destinationViewController];
    dest.keyArray = self.keyArray;
    dest.wordData = self.wordList;
}


@end
