//
//  FreeRecallWordShow.m
//  iEPL
//
//  Created by Q Kalantary on 2/11/15.
//  Copyright (c) 2015 Q Kalantary. All rights reserved.
//

#import "FreeRecallWordShow.h"
#import <AVFoundation/AVFoundation.h>
#import <NMSSH/NMSSH.h>



@interface FreeRecallWordShow () <UITextFieldDelegate, AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *mathProblem;
@property (weak, nonatomic) IBOutlet UITextField *mathInput;
@property (weak, nonatomic) IBOutlet UILabel *wordShow;


@property (weak, nonatomic) IBOutlet UITextView *textOut;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;

@property NSNumber *loopNumber;

@property NSString* mathInputAnswer;
@property int sessionPlace;


@property AVAudioRecorder *recorder;
@property AVAudioPlayer *player;



@end

@implementation FreeRecallWordShow

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mathInput.delegate = self;
    
    self.mathProblem.hidden = YES;
    self.mathInput.hidden = YES;
    self.agreeButton.hidden = YES;
    self.textOut.hidden = YES;
   
    self.playButton.hidden = YES;
    self.stopButton.hidden = YES;
    self.recordPauseButton.hidden = YES;

    self.loopNumber = [[NSNumber alloc] initWithInt:1];
    
    
    // Disable Stop/Play button when application launches
    [self.stopButton setEnabled:NO];
    [self.playButton setEnabled:NO];
    
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
    
    
    //set dummy userName
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int userName = (int)[defaults integerForKey:@"userName"];
    userName++;
    [defaults setInteger:userName forKey:@"userName"];
    
    [defaults synchronize];
    
    
}


//Audio Recording Setup

//NSURL *audioFileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingString:@"audioRecording.m4a"]];
//
//NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                               [NSNumber numberWithFloat:44100],AVSampleRateKey,
//                               [NSNumber numberWithInt: kAudioFormatAppleLossless],AVFormatIDKey,
//                               [NSNumber numberWithInt: 1],AVNumberOfChannelsKey,
//                               [NSNumber numberWithInt:AVAudioQualityMedium],AVEncoderAudioQualityKey,nil];
//
//self.audioRecorder = [[AVAudioRecorder alloc]
//                      initWithURL:audioFileURL
//                      settings:audioSettings
//                      error:nil];

-(void)wordShuffle {
    NSString *fileName = [self.loopNumber stringValue];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName
                                                     ofType:@"txt"];
    
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    
    //NSLog(@"%@", content);
    
    // NSArray *wordList = [content componentsSeparatedByString:@"\t"];
    //NSLog(@"%@", wordList);
    
    NSString *sep = @"\t\n";
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:sep];
    NSArray *temp=[content componentsSeparatedByCharactersInSet:set];
    NSLog(@"temp=%@",temp);
    
    int x = getRandomInteger(1, (int)temp.count);
    NSMutableArray *mut = [[NSMutableArray alloc] init];
    for (int i = 0; i < 12; i++) {
        x = getRandomInteger(1, (int)temp.count - 1);
        if ([self doesContain:temp[x] withArr:mut]) {
            i--;
        } else {
            [mut addObject:temp[x]];
        }
    }
    NSArray *final = mut;
    self.keyArray = final;
}

-(BOOL)doesContain:(NSString*)string withArr:(NSMutableArray*)arr {
    for (int i = 0; i < arr.count; i++) {
        if ([arr[i] isEqualToString:string]) {
            return true;
        }
    }
    return false;
}

- (void)viewDidAppear:(BOOL)animated {
    
    
    [self startWordDisplay];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

int getRandomInteger(int minimum, int maximum) {
    return arc4random_uniform((maximum - minimum) + 1) + minimum;
}



-(void)startWordDisplay {
    
    
    //shuffle words
    [self wordShuffle];
    
    
    //start timer and call displayWord
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(displayWord:)
                                   userInfo:nil
                                    repeats:YES];

}

-(void) displayWord:(NSTimer *)timer {
    static int i;
    NSLog(@"displaying Word");
    //dispatch_async(dispatch_get_main_queue(), ^{
    NSLog(@"%@", self.keyArray[i]);
    self.wordShow.text =  self.keyArray[i];
    //});
    i++;
    if (self.keyArray.count == i) {
        i = 0;
        [timer invalidate];
        
        [self startMathDisplay];
    }
}

-(void)startMathDisplay {
    
    [self displayMath];
    
    //configure timing for mathDisplay
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(endMathDisplay:)
                                   userInfo:nil
                                    repeats:YES];

}

-(void)displayMath {
    //static int i;
    
    int x = getRandomInteger(1, 9);
    int y = getRandomInteger(1, 9);
    int z = getRandomInteger(1, 9);
    
    self.mathInputAnswer = [@(x + y + z) stringValue];
    
    self.mathProblem.text = [NSString stringWithFormat:@"%i + %i + %i", x,y,z];
    
    self.wordShow.hidden = YES;
    self.mathProblem.hidden = NO;
    self.mathInput.hidden = NO;
    
    
    //i++;
    //if (i > 20) {
    //  i = 0;
    //}
    
    [self.mathInput becomeFirstResponder];
}

-(void)endMathDisplay:(NSTimer *) timer {
    NSLog(@"Math Display Ended");
    
    [timer invalidate];
    [self recordResponse];
}



- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //input math question
    if ([self.mathInput.text  isEqual: self.mathInputAnswer]) {
        NSLog(@"correct");
    } else {
        NSLog(@"incorrect");
    }
    
    self.mathInput.text = @"";
    [self startMathDisplay];
    return NO;
}

-(void)recordResponse {
    NSLog(@"response");
    self.mathProblem.hidden = YES;
    self.mathInput.hidden = YES;
    [self.mathInput resignFirstResponder];
    
    self.wordShow.hidden = NO;
    self.wordShow.text = @"*****************";
    
    //time to record
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    
    NSLog(@"before recording");
    // Start recording
    [self.recorder recordForDuration:10.0];
    
    NSLog(@"after recording");
    
    
//    self.recordPauseButton.hidden = NO;
//    self.playButton.hidden = NO;
//    self.stopButton.hidden = NO;
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    [self.recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
    [self.player setDelegate:self];
    [self.player play];
    
    NSData *audioData = [[NSData alloc] initWithContentsOfFile:self.recorder.url.path];
    
    NMSSHSession *session = [NMSSHSession connectToHost:@"@rhino.psych.upenn.edu"
                                           withUsername:@"qkal"];
    
    if (session.isConnected) {
        [session authenticateByPassword:@"Qpiano!1231"];
        
        if (session.isAuthorized) {
            NSLog(@"Authentication succeeded");
        }
    }
    
    NSString *listContents = @"";
    for (NSString *string in self.keyArray) {
        NSString *tmp = [NSString stringWithFormat:@"%@\n",string];
        listContents = [listContents stringByAppendingString:tmp];
    }
    NSData* listData = [listContents dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NMSFTP *ftp = [NMSFTP connectWithSession:session];
    
    
    //userName:
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int loopInt = (int)[self.loopNumber integerValue];
    int userName = (int)[defaults integerForKey:@"userName"];
    NSString *newDirectoryA = [NSString stringWithFormat:@"/home2/qkal/LTP%i",userName];
    NSString *newDirectoryB = [NSString stringWithFormat:@"/home2/qkal/LTP%i/session%i",userName,loopInt];
    NSString *audioString = [NSString stringWithFormat:@"/home2/qkal/LTP%i/session%i/audio.data",userName,loopInt];
    NSString *listString = [NSString stringWithFormat:@"/home2/qkal/LTP%i/session%i/listString.lst",userName,loopInt];
    
    //create new directory for user
    [ftp createDirectoryAtPath:newDirectoryA];
    
    //creates directory for each session
    [ftp createDirectoryAtPath:newDirectoryB];

    
    //append audio data to the file
    [ftp appendContents:audioData toFileAtPath:audioString];
    
    //append list to file
    [ftp appendContents:listData toFileAtPath:listString];

    [session disconnect];
    
    
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
    //                                                    message: @"Finish playing the recording!"
    //                                                   delegate: nil
    //                                          cancelButtonTitle:@"OK"
    //                                          otherButtonTitles:nil];
    //[alert show];
//    int i = [self.loopNumber intValue];
//    i++;
//    self.loopNumber = [NSNumber numberWithInt:i];
    
    //increment loop
    self.loopNumber = [NSNumber numberWithInt:[self.loopNumber intValue] + 1];
    
    self.wordShow.text = [NSString stringWithFormat:@"Are you ready for part %@",self.loopNumber];
    self.agreeButton.hidden = NO;
}

- (IBAction)agreeButton:(id)sender {
    self.mathProblem.hidden = YES;
    self.mathInput.hidden = YES;
    self.agreeButton.hidden = YES;
    self.textOut.hidden = YES;
    
    self.playButton.hidden = YES;
    self.stopButton.hidden = YES;
    self.recordPauseButton.hidden = YES;
    
    [self startWordDisplay];
}



















- (IBAction)stopTapped:(id)sender {
    [self.recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (IBAction)recordPauseTapped:(id)sender {
    // Stop the audio player before recording
    if (self.player.playing) {
        [self.player stop];
    }
    
    if (!self.recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [self.recorder record];
        [self.recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else {
        
        // Pause recording
        [self.recorder pause];
        [self.recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    
    [self.stopButton setEnabled:YES];
    [self.playButton setEnabled:NO];
}

- (IBAction)playTapped:(id)sender {
    if (!self.recorder.recording){
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
        [self.player setDelegate:self];
        [self.player play];
    }
}




-(void)readyForNextSession {
    
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
