#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

extern UIViewController *UnityGetGLViewController();

@interface VideoViewPlugin : NSObject
{
	UIView *videoViewContainer;
    UIView *topBackground;
    UIView *bottomBackground;
    UILabel *videoTitleLabel;
    UILabel *videoTimeLabel;
    UIButton *closeButton;
	MPMoviePlayerController *videoView;
	NSString *gameObjectName;
    NSTimer *durationUpdateTimer;
    BOOL closeClicked;
}
@end

@implementation VideoViewPlugin

- (id)initWithGameObjectName:(const char *)gameObjectName_ withTitle:(const char *)title_ withURL:(const char *)videoURL_
{
	self = [super init];
    
    closeClicked = NO;
	UIView *view = UnityGetGLViewController().view;
	videoViewContainer = [[UIView alloc] initWithFrame:view.frame];
	videoViewContainer.hidden = NO;
	[view addSubview:videoViewContainer];
	NSString *title = [[NSString stringWithUTF8String:title_] retain];
	NSString *videoURL = [[NSString stringWithUTF8String:videoURL_] retain];
	videoView = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:videoURL]];
	[videoViewContainer addSubview:[videoView view]];
	videoView.controlStyle = MPMovieControlStyleNone;
	videoView.repeatMode = MPMovieRepeatModeNone;
	videoView.shouldAutoplay=YES;
    [videoView play];
	
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:videoView];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    durationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                           target:self
                                                         selector:@selector(currentTimeUpdate:)
                                                         userInfo:nil
                                                          repeats:YES];
    
    topBackground = [[UIView alloc] init];
    topBackground.backgroundColor = [UIColor colorWithRed:200/255 green:200/255 blue:200/255 alpha:0.8];
	[view addSubview:topBackground];
    
    bottomBackground = [[UIView alloc] init];
    bottomBackground.backgroundColor = [UIColor colorWithRed:200/255 green:200/255 blue:200/255 alpha:0.8];
	[view addSubview:bottomBackground];
    
    videoTitleLabel = [[UILabel alloc] init];
    [videoTitleLabel setText:title];
    videoTitleLabel.textColor = [UIColor whiteColor];
	[view addSubview:videoTitleLabel];
    
    videoTimeLabel = [[UILabel alloc] init];
    [videoTimeLabel setText:@""];
    videoTimeLabel.textColor = [UIColor whiteColor];
    videoTimeLabel.textAlignment =  NSTextAlignmentRight;
	[view addSubview:videoTimeLabel];
    
    closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    closeButton.backgroundColor = [UIColor whiteColor];
    closeButton.layer.borderColor = [UIColor grayColor].CGColor;
    closeButton.layer.borderWidth = 0.5f;
    closeButton.layer.cornerRadius = 5.0f;
    [closeButton addTarget:self
                    action:@selector(closeButtonTouched:)
          forControlEvents:UIControlEventTouchUpInside];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
	[view addSubview:closeButton];
    
    [self setupScreen];
	gameObjectName = [[NSString stringWithUTF8String:gameObjectName_] retain];
	return self;
}

- (void)dealloc
{
    
	[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:videoView];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
    
    [topBackground removeFromSuperview];
    [topBackground release];
    [bottomBackground removeFromSuperview];
    [bottomBackground release];
    [videoTitleLabel removeFromSuperview];
    [videoTitleLabel release];
    [videoTimeLabel removeFromSuperview];
    [videoTimeLabel release];
    [closeButton removeFromSuperview];
    [closeButton release];
    
	[videoView stop];
	[videoView.view removeFromSuperview];
    
	[videoViewContainer removeFromSuperview];
	[videoViewContainer release];
	[gameObjectName release];
	[super dealloc];
}

-(NSString *)secondsToMMSS:(double)seconds
{
    NSInteger time = floor(seconds);
    NSInteger hh = time / 3600;
    NSInteger mm = (time / 60) % 60;
    NSInteger ss = time % 60;
    if(hh > 0)
        return  [NSString stringWithFormat:@"%d:%02i:%02i",hh,mm,ss];
    else
        return  [NSString stringWithFormat:@"%02i:%02i",mm,ss];
    
}

-(void)currentTimeUpdate:(NSTimer *)sender
{
    NSString *currentTimeText = [self secondsToMMSS:videoView.currentPlaybackTime];
    NSString *videoDurationText = [self secondsToMMSS:videoView.duration];
    videoTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",currentTimeText,videoDurationText];
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    if (!closeClicked) {
        UnitySendMessage( [gameObjectName UTF8String], "onVideoFinish", "");
    } else {
        UnitySendMessage( [gameObjectName UTF8String], "onVideoClose", "");
    }
    NSLog(@"Video ended");
    [self dealloc];
}

-(void) closeButtonTouched:(UIButton *) sender {
    closeClicked = YES;
    NSLog(@"Close button touched");
    [videoView stop];
}

-(void) didRotate:(NSNotification*)notification {
    NSLog(@"rotation changed");
    [self setupScreen];
}

- (void)setupScreen
{
	UIView *view = UnityGetGLViewController().view;
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
	CGRect frame = view.frame;
	int width = frame.size.width;
	int height = frame.size.height;
    int x = frame.origin.x;
    int y = frame.origin.y;
    
	CGRect labelFrame = view.frame;
    CGRect buttonFrame = view.frame;
    CGRect topBGFrame = view.frame;
    CGRect bottomBGFrame = view.frame;
    CGRect timeLabelFrame = view.frame;
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        frame.size.width = width;
        frame.size.height = height;
        frame.origin.x = x;
        frame.origin.y = y;
        
        labelFrame.origin.x = 5;
        labelFrame.origin.y = 0;
        labelFrame.size.width = width - 70;
        labelFrame.size.height = 40;
        
        buttonFrame.origin.x = width - 65;
        buttonFrame.origin.y = 5;
        buttonFrame.size.width = 60;
        buttonFrame.size.height = 25;
        
        topBGFrame.size.width = width;
        topBGFrame.size.height = 40;
        topBGFrame.origin.x = 0;
        topBGFrame.origin.y = 0;
        
        bottomBGFrame.size.width = width;
        bottomBGFrame.size.height = 40;
        bottomBGFrame.origin.x = 0;
        bottomBGFrame.origin.y = height - 40;
        
        timeLabelFrame.size.width = width - 5;
        timeLabelFrame.size.height = 40;
        timeLabelFrame.origin.x = 0;
        timeLabelFrame.origin.y = height - 45;
    } else {
        frame.size.width = height;
        frame.size.height = width;
        frame.origin.x = y;
        frame.origin.y = x;
        
        labelFrame.origin.x = 5;
        labelFrame.origin.y = 0;
        labelFrame.size.width = height - 70;
        labelFrame.size.height = 40;
        
        buttonFrame.origin.x = height - 65;
        buttonFrame.origin.y = 5;
        buttonFrame.size.width = 60;
        buttonFrame.size.height = 25;
        
        topBGFrame.size.width = height;
        topBGFrame.size.height = 40;
        topBGFrame.origin.x = 0;
        topBGFrame.origin.y = 0;
        
        bottomBGFrame.size.width = height;
        bottomBGFrame.size.height = 40;
        bottomBGFrame.origin.x = 0;
        bottomBGFrame.origin.y = width - 40;
        
        timeLabelFrame.size.width = height - 5;
        timeLabelFrame.size.height = 40;
        timeLabelFrame.origin.x = 0;
        timeLabelFrame.origin.y = width - 45;
    }
    
    videoTitleLabel.frame = labelFrame;
    closeButton.frame = buttonFrame;
    topBackground.frame = topBGFrame;
    bottomBackground.frame = bottomBGFrame;
    videoTimeLabel.frame = timeLabelFrame;
    
	videoViewContainer.frame = frame;
	[[videoView view] setFrame:[videoViewContainer bounds]];
	[videoViewContainer addSubview:[videoView view]];
}
@end

extern "C" {
	void *_VideoViewPlugin_Init(const char *gameObjectName, const char *title, const char *videoURL);
	void _VideoViewPlugin_Destroy(void *instance);
}

void *_VideoViewPlugin_Init(const char *gameObjectName, const char *title, const char *videoURL)
{
	id instance = [[VideoViewPlugin alloc] initWithGameObjectName:gameObjectName withTitle:title withURL:videoURL];
	return (void *)instance;
}

void _VideoViewPlugin_Destroy(void *instance)
{
	VideoViewPlugin *videoViewPlugin = (VideoViewPlugin *)instance;
	[videoViewPlugin release];
}