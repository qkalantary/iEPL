//
//  FreeRecall0.m
//  iEPL
//
//  Created by Q Kalantary on 2/4/15.
//  Copyright (c) 2015 Q Kalantary. All rights reserved.
//

#import "FreeRecall0.h"
#import <AVFoundation/AVFoundation.h>
#import "FreeRecallWordShow.h"
#import <MediaPlayer/MediaPlayer.h>

#define RECORD_LENGTH 5

@interface FreeRecall0 () <AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *affirmButton;
@property (weak, nonatomic) IBOutlet UITextView *instructionText;
@property (strong, nonatomic) NSArray *keyArray;
@property (strong, nonatomic) NSDictionary *wordList;

@property (strong,nonatomic) NSString *instructString;
@property (strong,nonatomic) NSString *micString;
@property (strong,nonatomic) NSString *micTestString;
@property (strong,nonatomic) NSString *movieString;
@property (strong,nonatomic) NSString *experimentString;

@property AVAudioRecorder *recorder;
@property AVAudioPlayer *player;



@end

@implementation FreeRecall0

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.instructString = @"Click This After You Read Above Info";
    self.micString = @"Allow Mic Access";
    self.movieString = @"Watch Movie";
    self.experimentString = @"Continue to Demo";
    self.micTestString = @"";
    
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
    
    
    
    
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.wav",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithFloat:44100],AVSampleRateKey,
                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
                                   [NSNumber numberWithInt: 1],AVNumberOfChannelsKey,
                                   [NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,nil];
    
    
    // Initiate and prepare the recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:audioSettings error:NULL];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    
}
- (IBAction)clickButton:(id)sender {

    //intro sequence of instructions
    if ([self.affirmButton.currentTitle  isEqual: self.instructString]) {
        
//        CGRect frame = self.instructionText.frame;
//        frame.size = self.instructionText.contentSize;
//        self.instructionText.frame = frame;
        
        self.instructionText.font = [UIFont boldSystemFontOfSize:20.0];
        self.instructionText.textAlignment = NSTextAlignmentCenter;
        
        self.instructionText.text = @"Please allow the Mic. It is necessary to run the Free Recall Experiment";
        
        self.instructionText.font = [UIFont boldSystemFontOfSize:20.0];
        self.instructionText.textAlignment = NSTextAlignmentCenter;
        
        
        [self.affirmButton setTitle:self.micString forState:UIControlStateNormal];

        
        
    } else if ([self.affirmButton.currentTitle  isEqual:self.micString]) {
        NSLog(@"mic access allow pressed");
        
        PermissionBlock permissionBlock = ^(BOOL granted) {
            if (granted)
            {
                //[self doActualRecording];
                self.instructionText.text = @"Now watch this instructional video";
                [self.affirmButton setTitle:self.movieString forState:UIControlStateNormal];
                
                self.instructionText.font = [UIFont boldSystemFontOfSize:20.0];
                self.instructionText.textAlignment = NSTextAlignmentCenter;
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
            NSLog(@"lower than ios 7 you've got to be kidding me");
        }
    } else if ([self.affirmButton.currentTitle isEqualToString:self.movieString]) {

        NSString *path = [NSString stringWithFormat:@"%@/%@",
                          [[NSBundle mainBundle] resourcePath], @"instructions.mov"];
        NSLog(@"Path of video file: %@", path);
        
        NSURL *url = [NSURL fileURLWithPath:path];
        
        MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        vc.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        
        [self presentMoviePlayerViewControllerAnimated:vc];
        [vc.moviePlayer prepareToPlay];
        [vc.moviePlayer play];
        
        self.instructionText.text = @"We are now going to test the Microphone. Press the button below to start recording and say anything into the mic.";
        self.instructionText.font = [UIFont boldSystemFontOfSize:20.0];
        self.instructionText.textAlignment = NSTextAlignmentCenter;
        
        [self.affirmButton setTitle:@"Start Mic Test" forState:UIControlStateNormal];
        
       
    } else if ([self.affirmButton.currentTitle isEqualToString:@"Start Mic Test"]) {
        self.instructionText.text = @"Recording... Talk now";
        self.instructionText.font = [UIFont boldSystemFontOfSize:20.0];
        self.instructionText.textAlignment = NSTextAlignmentCenter;
        
        //time to record
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        NSLog(@"before recording");
        // Start recording
        [self.recorder recordForDuration:RECORD_LENGTH];
        
        NSLog(@"after recording");
        
        self.affirmButton.hidden = YES;

    } else if ([self.affirmButton.currentTitle isEqualToString:@"I heard something"]) {
        
        self.instructionText.text = @"Great! Please talk to the proctor if you have any questions. You will now go through a short demo session of the experiment.";
        self.instructionText.font = [UIFont boldSystemFontOfSize:20.0];
        self.instructionText.textAlignment = NSTextAlignmentCenter;
        
        [self.affirmButton setTitle:self.experimentString forState:UIControlStateNormal];

    } else if ([self.affirmButton.currentTitle isEqualToString:self.experimentString]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"list" sender:self];
        });

    }
}


- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    self.instructionText.text = @"Playing";
    self.instructionText.font = [UIFont boldSystemFontOfSize:20.0];
    self.instructionText.textAlignment = NSTextAlignmentCenter;
    
    //play responses
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
    [self.player setDelegate:self];
    [self.player play];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{

    self.instructionText.text = @"Tell the proctor if you didn't hear anything";
    self.instructionText.font = [UIFont boldSystemFontOfSize:20.0];
    self.instructionText.textAlignment = NSTextAlignmentCenter;
    self.affirmButton.hidden = NO;
    [self.affirmButton setTitle:@"I heard something" forState:UIControlStateNormal];
    
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
