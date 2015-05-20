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
#import "NSMutableArray+shuffle.h"
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEEventsObserver.h>

#define RECORD_LENGTH 10.0
#define MATH_LENGTH 10.0
#define WORD_INTERVAL 1.3




@interface FreeRecallWordShow () <UITextFieldDelegate, AVAudioSessionDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate,OEEventsObserverDelegate>
@property (weak, nonatomic) IBOutlet UILabel *mathProblem;
@property (weak, nonatomic) IBOutlet UITextField *mathInput;
@property (weak, nonatomic) IBOutlet UILabel *wordShow;


@property (weak, nonatomic) IBOutlet UITextView *textOut;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *recordPauseButton;

@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;

@property NSNumber *loopNumber;

@property NSString* mathInputAnswer;
@property int sessionPlace;

@property int countDownNumber;



@property AVAudioRecorder *recorder;
@property AVAudioPlayer *player;



@end

@implementation FreeRecallWordShow

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.countDownNumber = 3;
    
    self.mathInput.delegate = self;
    
    self.mathProblem.hidden = YES;
    self.mathInput.hidden = YES;
    self.agreeButton.hidden = YES;
    self.textOut.hidden = YES;
    self.wordShow.hidden = YES;
   
    self.playButton.hidden = YES;
    self.stopButton.hidden = YES;
    self.recordPauseButton.hidden = YES;

    self.loopNumber = [[NSNumber alloc] initWithInt:0];
    
    
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
    NSLog(@"USERNAME: %i", userName);
    [defaults setInteger:userName forKey:@"userName"];
    
    [defaults synchronize];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [NSTimer scheduledTimerWithTimeInterval:WORD_INTERVAL
                                     target:self
                                   selector:@selector(countDown:)
                                   userInfo:nil
                                    repeats:YES];
}

-(void)wordShuffle {
    int fileNumber;
    if ([self.loopNumber integerValue] == 0) {
        fileNumber = 0;
        self.keyArray =
  @[@"+", @"ATTIC",@"BEAM",@"CAMEL",@"CHEST",@"COTTON",@"FLOOD",@"IRON",@"RHINO",@"RING",@"TONGUE",@"WAGON",@"WATCH"];
        return;
    }
    
    fileNumber = getRandomInteger(1, 18);
    
    NSString *fileName = [NSString stringWithFormat:@"%i",fileNumber];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName
                                                     ofType:@"txt"];
    
    NSString* content = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    

    
    NSString *sepLine = @"\n";
    NSCharacterSet *setLine = [NSCharacterSet characterSetWithCharactersInString:sepLine];
    NSArray *lineArray=[content componentsSeparatedByCharactersInSet:setLine];
    NSLog(@"lineArray=%@",lineArray);
    int lineArrayRandomNumber = getRandomInteger(0, 24);
    
    NSString *wordString = lineArray[lineArrayRandomNumber];
    
    NSString *sepWord = @"\t";
    NSCharacterSet *setWord = [NSCharacterSet characterSetWithCharactersInString:sepWord];
    NSArray *wordArray=[wordString componentsSeparatedByCharactersInSet:setWord];
    NSLog(@"before shuffle=%@", wordArray);
    
    NSMutableArray *mut = [[NSMutableArray alloc] init];
    for (int i = 0; i < 12; i++) {
            [mut addObject:wordArray[i]];
    }
    
    [mut shuffle];
    
    [mut insertObject:@"+" atIndex:0];
    
    NSLog(@"after shuffle=%@", mut);
    
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
        [NSTimer scheduledTimerWithTimeInterval:WORD_INTERVAL
                                     target:self
                                   selector:@selector(displayWord:)
                                   userInfo:nil
                                    repeats:YES];

}

-(void) displayWord:(NSTimer *)timer {
    self.textOut.hidden = YES;

    
    static int i;
    NSLog(@"displaying Word");
    NSLog(@"%@", self.keyArray[i]);
    self.wordShow.text =  self.keyArray[i];
    i++;
    if (self.keyArray.count == i) {
        i = 0;
        [timer invalidate];
        
        [self startMathDisplay];
    }
}

-(void) countDown:(NSTimer *)timer {
    self.textOut.hidden = NO;
    self.wordShow.hidden = NO;
    self.textOut.text = @"Countdown";
    self.textOut.font = [UIFont boldSystemFontOfSize:25.0];
    self.textOut.textAlignment = NSTextAlignmentCenter;
    
    self.wordShow.text = [NSString stringWithFormat:@"%i", self.countDownNumber];
    
    
    self.countDownNumber--;

    if (self.countDownNumber == -1) {
        [timer invalidate];
        self.countDownNumber = 3;
        [self startWordDisplay];
    }
}

-(void)startMathDisplay {
    
    [self displayMath];
    
    //configure timing for mathDisplay
    [NSTimer scheduledTimerWithTimeInterval:MATH_LENGTH
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

    
    
    //Language model
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    
    NSArray *words = [NSArray arrayWithObjects:@"Attic", @"Beam", @"Camel", @"Chest", @"Cotton", @"Iron", @"Rhino", @"Flood", @"Ring", nil];
    NSString *name = @"NameIWantForMyLanguageModelFiles";
    NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
    
    NSString *lmPath = nil;
    NSString *dicPath = nil;
    
    if(err == nil) {
        
        lmPath = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"NameIWantForMyLanguageModelFiles"];
        dicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"NameIWantForMyLanguageModelFiles"];
        
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
    
    //
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
    [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
    
    
    //
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];
    
    
    
    
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
    [self.recorder recordForDuration:RECORD_LENGTH];
    
    NSLog(@"after recording");
    
    
    //    self.recordPauseButton.hidden = NO;
    //    self.playButton.hidden = NO;
    //    self.stopButton.hidden = NO;
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    //[self.recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    
    //play responses
    //self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.recorder.url error:nil];
    //[self.player setDelegate:self];
    //[self.player play];
    
    NSData *audioData = [[NSData alloc] initWithContentsOfFile:self.recorder.url.path];
    
    NMSSHSession *session = [NMSSHSession connectToHost:@"@rhino.psych.upenn.edu"
                                           withUsername:@"qkal"];
    
    if (session.isConnected) {
        [session authenticateByPassword:@"Qpiano!1231"];
        
        if (session.isAuthorized) {
            NSLog(@"Authentication succeeded");
        }
    }
    
    //lst file
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
    NSString *newDirectoryA = [NSString stringWithFormat:@"/home2/qkal/iEPL/LTP%i",userName];
    NSString *newDirectoryB = [NSString stringWithFormat:@"/home2/qkal/iEPL/LTP%i/session%i",userName,loopInt];
    NSString *audioString = [NSString stringWithFormat:@"/home2/qkal/iEPL/LTP%i/session%i/audio.wav",userName,loopInt];
    NSString *listString = [NSString stringWithFormat:@"/home2/qkal/iEPL/LTP%i/session%i/listString.lst",userName,loopInt];
    
    //create new directory for user
    [ftp createDirectoryAtPath:newDirectoryA];
    
    //creates directory for each session
    [ftp createDirectoryAtPath:newDirectoryB];

    
    //append audio data to the file
    [ftp appendContents:audioData toFileAtPath:audioString];
    
    //append list to file
    [ftp appendContents:listData toFileAtPath:listString];

    [session disconnect];
    
    
    
    //increment loop
    self.loopNumber = [NSNumber numberWithInt:[self.loopNumber intValue] + 1];
    
    if ([self.loopNumber integerValue] == 1) {
        NSLog(@"loop");
        self.wordShow.text = [NSString stringWithFormat:@"Are you ready for part 1?"];
        self.agreeButton.hidden = NO;
        
    } else if ([self.loopNumber integerValue] == 22) {
        self.wordShow.text = [NSString stringWithFormat:@"You Are Done! Inform your Proctor"];
        self.agreeButton.hidden = YES;
    } else {
        self.wordShow.text = [NSString stringWithFormat:@"Are you ready for part %@",self.loopNumber];
        self.agreeButton.hidden = NO;
        
    }
    
    
}

- (IBAction)agreeButton:(id)sender {
    self.mathProblem.hidden = YES;
    self.mathInput.hidden = YES;
    self.agreeButton.hidden = YES;
    self.textOut.hidden = YES;
    
    self.playButton.hidden = YES;
    self.stopButton.hidden = YES;
    self.recordPauseButton.hidden = YES;
    
    
    [NSTimer scheduledTimerWithTimeInterval:1.2
                                     target:self
                                   selector:@selector(countDown:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{

//    
//    //increment loop
//    self.loopNumber = [NSNumber numberWithInt:[self.loopNumber intValue] + 1];
//    
//    if ([self.loopNumber integerValue] == 1) {
//        NSLog(@"loop");
//        self.wordShow.text = [NSString stringWithFormat:@"Are you ready for part 1 (if not, please tell the proctor)"];
//        self.agreeButton.hidden = NO;
//
//    } else if ([self.loopNumber integerValue] == 22) {
//        self.wordShow.text = [NSString stringWithFormat:@"You Are Done! Inform your Proctor"];
//        self.agreeButton.hidden = YES;
//    } else {
//        self.wordShow.text = [NSString stringWithFormat:@"Are you ready for part %@",self.loopNumber];
//        self.agreeButton.hidden = NO;
//
//    }
}
//

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
}

- (void) pocketsphinxDidStartListening {
    NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
    NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
    NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
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
