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
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    self.recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    self.recorder.delegate = self;
    self.recorder.meteringEnabled = YES;
    [self.recorder prepareToRecord];
    
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
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(displayWord:)
                                   userInfo:nil
                                    repeats:YES];

}

-(void)startMathDisplay {
    
    [self displayMath];
}

-(void)displayMath {
    static int i;

    
    
    int x = getRandomInteger(1, 9);
    int y = getRandomInteger(1, 9);
    int z = getRandomInteger(1, 9);
    
    self.mathInputAnswer = [@(x + y + z) stringValue];
    
    self.mathProblem.text = [NSString stringWithFormat:@"%i + %i + %i", x,y,z];
    
    self.wordShow.hidden = YES;
    self.mathProblem.hidden = NO;
    self.mathInput.hidden = NO;
    
    
    i++;
    if (i > 20) {
        i = 0;
        [self recordResponse];
        return;
    }
    
    [self.mathInput becomeFirstResponder];

    
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



-(void) displayWord:(NSTimer *)timer {
    static int i;
    NSLog(@"displaying Word");
    //dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", self.keyArray[i]);
        self.wordShow.text =  [self.wordData objectForKey: self.keyArray[i]];
    //});
    i++;
    if (self.keyArray.count == i) {
        i = 0;
        [timer invalidate];
        
        [self startMathDisplay];
    }
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
    
    
    NMSFTP *ftp = [NMSFTP connectWithSession:session];
//    NSString* str = @"teststring2";
//    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [ftp appendContents:audioData toFileAtPath:@"/home2/qkal/test3"];
    
    NSLog(@"contents");
    
    
    
    [session disconnect];
    
    
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
    //                                                    message: @"Finish playing the recording!"
    //                                                   delegate: nil
    //                                          cancelButtonTitle:@"OK"
    //                                          otherButtonTitles:nil];
    //[alert show];
    int i = [self.loopNumber intValue];
    i++;
    self.loopNumber = [NSNumber numberWithInt:i];
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
