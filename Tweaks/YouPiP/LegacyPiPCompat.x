#import "Header.h"
#import <version.h>
#import "../YouTubeHeader/MLAVPlayer.h"
#import "../YouTubeHeader/MLHAMQueuePlayer.h"
#import "../YouTubeHeader/MLPIPController.h"
#import "../YouTubeHeader/MLPlayerPool.h"
#import "../YouTubeHeader/MLPlayerPoolImpl.h"
#import "../YouTubeHeader/MLVideoDecoderFactory.h"
#import "../YouTubeHeader/MLDefaultPlayerViewFactory.h"
#import "../YouTubeHeader/YTHotConfig.h"
#import "../YouTubeHeader/YTPlayerPIPController.h"
#import "../YouTubeHeader/YTBackgroundabilityPolicy.h"
#import "../YouTubeHeader/YTPlayerViewControllerConfig.h"
#import "../YouTubeHeader/YTSystemNotifications.h"
#import "../YouTubeHeader/YTAutonavEndscreenController.h"

extern BOOL TweakEnabled();
extern BOOL isPictureInPictureActive(MLPIPController *);

BOOL hasSampleBufferPiP;
BOOL isLegacyVersion;

BOOL LegacyPiP() {
    return isLegacyVersion ? YES : [[NSUserDefaults standardUserDefaults] boolForKey:CompatibilityModeKey];
}

static void forceRenderViewTypeBase(YTIHamplayerConfig *hamplayerConfig) {
    if (!LegacyPiP()) return;
    hamplayerConfig.renderViewType = 2;
}

static void forceRenderViewTypeHot(YTIHamplayerHotConfig *hamplayerHotConfig) {
    if (!LegacyPiP()) return;
    hamplayerHotConfig.renderViewType = 2;
}

static void forceRenderViewType(YTHotConfig *hotConfig) {
    YTIHamplayerHotConfig *hamplayerHotConfig = [hotConfig hamplayerHotConfig];
    forceRenderViewTypeHot(hamplayerHotConfig);
}

static MLPIPController *(*InjectMLPIPController)(void);
static YTSystemNotifications *(*InjectYTSystemNotifications)(void);
static YTBackgroundabilityPolicy *(*InjectYTBackgroundabilityPolicy)(void);
static YTPlayerViewControllerConfig *(*InjectYTPlayerViewControllerConfig)(void);
YTHotConfig *(*InjectYTHotConfig)(void);

%group WithInjection

YTPlayerPIPController *initPlayerPiPControllerIfNeeded(YTPlayerPIPController *controller, id delegate, id parentResponder) {
    if (controller) return controller;
    controller = [[%c(YTPlayerPIPController) alloc] init];
    MLPIPController *pip = InjectMLPIPController();
    YTSystemNotifications *systemNotifications = InjectYTSystemNotifications();
    YTBackgroundabilityPolicy *bgPolicy = InjectYTBackgroundabilityPolicy();
    YTPlayerViewControllerConfig *playerConfig = InjectYTPlayerViewControllerConfig();
    [controller setValue:pip forKey:@"_pipController"];
    [controller setValue:bgPolicy forKey:@"_backgroundabilityPolicy"];
    [controller setValue:playerConfig forKey:@"_config"];
    @try {
        YTHotConfig *config = InjectYTHotConfig();
        [controller setValue:config forKey:@"_hotConfig"];
    } @catch (id ex) {}
    if (parentResponder) {
        @try {
            [controller setValue:parentResponder forKey:@"_parentResponder"];
        } @catch (id ex) {}
    }
    [controller setValue:delegate forKey:@"_delegate"];
    [bgPolicy addBackgroundabilityPolicyObserver:controller];
    [pip addPIPControllerObserver:controller];
    [systemNotifications addSystemNotificationsObserver:controller];
    return controller;
}

%hook YTPlayerPIPController

- (instancetype)initWithDelegate:(id)delegate {
    return initPlayerPiPControllerIfNeeded(%orig, delegate, nil);
}

- (instancetype)initWithDelegate:(id)delegate parentResponder:(id)parentResponder {
    return initPlayerPiPControllerIfNeeded(%orig, delegate, parentResponder);
}

%end

%hook YTAutonavEndscreenController

- (instancetype)initWithParentResponder:(id)arg1 config:(id)arg2 imageService:(id)arg3 lastActionController:(id)arg4 reachabilityController:(id)arg5 endscreenDelegate:(id)arg6 {
    self = %orig;
    if ([self valueForKey:@"_pipController"] == nil)
        [self setValue:InjectMLPIPController() forKey:@"_pipController"];
    return self;
}

%end

%hook MLHAMQueuePlayer

- (instancetype)initWithStickySettings:(MLPlayerStickySettings *)stickySettings playerViewProvider:(MLPlayerPoolImpl *)playerViewProvider playerConfiguration:(void *)playerConfiguration {
    self = %orig;
    if ([self valueForKey:@"_pipController"] == nil)
        [self setValue:InjectMLPIPController() forKey:@"_pipController"];
    return self;
}

%end

%hook MLAVPlayer

- (bool)isPictureInPictureActive {
    return isPictureInPictureActive(InjectMLPIPController());
}

%end

%hook MLPlayerPoolImpl

- (instancetype)init {
    self = %orig;
    if (self)
        [self setValue:InjectMLPIPController() forKey:@"_pipController"];
    return self;
}

%end

%hook MLAVPIPPlayerLayerView

- (id)initWithPlaceholderPlayerItem:(AVPlayerItem *)playerItem {
    self = %orig;
    if ([self valueForKey:@"_pipController"] == nil)
        [self setValue:InjectMLPIPController() forKey:@"_pipController"];
    return self;
}

%end

%end

%group Legacy

static MLAVPlayer *makeAVPlayer(id self, MLVideo *video, MLInnerTubePlayerConfig *playerConfig, MLPlayerStickySettings *stickySettings, BOOL gimmeAlloc) {
    BOOL externalPlaybackActive = [(MLAVPlayer *)[self valueForKey:@"_activePlayer"] externalPlaybackActive];
    MLAVPlayer *player = gimmeAlloc ? [((MLPlayerPool *)self).gimme allocOf:%c(MLAVPlayer)] : [%c(MLAVPlayer) alloc];
    player = [player initWithVideo:video playerConfig:playerConfig stickySettings:stickySettings externalPlaybackActive:externalPlaybackActive];
    if (stickySettings)
        player.rate = stickySettings.rate;
    return player;
}

%hook MLPIPController

- (void)activatePiPController {
    if (!isPictureInPictureActive(self)) {
        AVPictureInPictureController *pip = [self valueForKey:@"_pictureInPictureController"];
        if (!pip) {
            MLAVPIPPlayerLayerView *avpip = [self valueForKey:@"_AVPlayerView"];
            if (avpip) {
                AVPlayerLayer *playerLayer = [avpip playerLayer];
                pip = [[AVPictureInPictureController alloc] initWithPlayerLayer:playerLayer];
                [self setValue:pip forKey:@"_pictureInPictureController"];
                pip.delegate = self;
            }
        }
    }
}

- (void)deactivatePiPController {
    AVPictureInPictureController *pip = [self valueForKey:@"_pictureInPictureController"];
    [pip stopPictureInPicture];
}

%end

%hook MLPlayerPoolImpl

- (id)acquirePlayerForVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig stickySettings:(MLPlayerStickySettings *)stickySettings {
    return makeAVPlayer(self, video, playerConfig, stickySettings, NO);
}

- (id)acquirePlayerForVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig stickySettings:(MLPlayerStickySettings *)stickySettings latencyLogger:(id)latencyLogger {
    return makeAVPlayer(self, video, playerConfig, stickySettings, NO);
}

- (id)acquirePlayerForVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig stickySettings:(MLPlayerStickySettings *)stickySettings latencyLogger:(id)latencyLogger reloadContext:(id)reloadContext {
    return makeAVPlayer(self, video, playerConfig, stickySettings, NO);
}

- (MLAVPlayerLayerView *)playerViewForVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig {
    MLDefaultPlayerViewFactory *factory = [self valueForKey:@"_playerViewFactory"];
    return [factory AVPlayerViewForVideo:video playerConfig:playerConfig];
}

- (BOOL)canQueuePlayerPlayVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig {
    return NO;
}

%end

%hook MLPlayerPool

- (id)acquirePlayerForVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig stickySettings:(MLPlayerStickySettings *)stickySettings {
    return makeAVPlayer(self, video, playerConfig, stickySettings, YES);
}

- (id)acquirePlayerForVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig stickySettings:(MLPlayerStickySettings *)stickySettings latencyLogger:(id)latencyLogger {
    return makeAVPlayer(self, video, playerConfig, stickySettings, YES);
}

- (MLAVPlayerLayerView *)playerViewForVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig {
    MLDefaultPlayerViewFactory *factory = [self valueForKey:@"_playerViewFactory"];
    return [factory AVPlayerViewForVideo:video playerConfig:playerConfig];
}

- (BOOL)canUsePlayerView:(id)playerView forVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig {
    forceRenderViewTypeBase([playerConfig hamplayerConfig]);
    return %orig;
}

- (BOOL)canQueuePlayerPlayVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig {
    return NO;
}

%end

%hook MLDefaultPlayerViewFactory

- (id)hamPlayerViewForVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig {
    forceRenderViewType([self valueForKey:@"_hotConfig"]);
    forceRenderViewTypeBase([playerConfig hamplayerConfig]);
    return %orig;
}

- (BOOL)canUsePlayerView:(id)playerView forVideo:(MLVideo *)video playerConfig:(MLInnerTubePlayerConfig *)playerConfig {
    forceRenderViewTypeBase([playerConfig hamplayerConfig]);
    return %orig;
}

%end

%hook MLVideoDecoderFactory

- (void)prepareDecoderForFormatDescription:(id)formatDescription delegateQueue:(id)delegateQueue {
    forceRenderViewTypeHot([self valueForKey:@"_hotConfig"]);
    %orig;
}

%end

%end

%group Compat

%hook AVPictureInPictureController

%new(v@:)
- (void)invalidatePlaybackState {}

%new(v@:)
- (void)sampleBufferDisplayLayerDidDisappear {}

%new(v@:)
- (void)sampleBufferDisplayLayerDidAppear {}

%new
- (void)sampleBufferDisplayLayerRenderSizeDidChangeToSize:(CGSize)size {}

%new
- (void)setRequiresLinearPlayback:(BOOL)linear {}

%new(v@:)
- (void)reloadPrerollAttributes {}

%end

%end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability-new"

%group AVKit_iOS14_2_Up

%hook AVPictureInPictureControllerContentSource

%property (assign) bool hasInitialRenderSize;

- (id)initWithSampleBufferDisplayLayer:(AVSampleBufferDisplayLayer *)sampleBufferDisplayLayer initialRenderSize:(CGSize)initialRenderSize playbackDelegate:(id)playbackDelegate {
    self = %orig;
    if (self)
        self.hasInitialRenderSize = true;
    return self;
}

%end

%end

%group AVKit_preiOS14_2

%hook AVPictureInPictureControllerContentSource

%property (assign) bool hasInitialRenderSize;

%new
- (instancetype)initWithSampleBufferDisplayLayer:(AVSampleBufferDisplayLayer *)sampleBufferDisplayLayer initialRenderSize:(CGSize)initialRenderSize playbackDelegate:(id <AVPictureInPictureSampleBufferPlaybackDelegate>)playbackDelegate {
    return [self initWithSampleBufferDisplayLayer:sampleBufferDisplayLayer playbackDelegate:playbackDelegate];
}

%end

%hook AVPictureInPictureController

%new
- (void)setCanStartPictureInPictureAutomaticallyFromInline:(BOOL)canStartFromInline {}

%end

%end

#pragma clang diagnostic pop

%ctor {
    if (!TweakEnabled()) return;
    NSString *frameworkPath = [NSString stringWithFormat:@"%@/Frameworks/Module_Framework.framework/Module_Framework", NSBundle.mainBundle.bundlePath];
    NSBundle *bundle = [NSBundle bundleWithPath:frameworkPath];
    if (!bundle.loaded) [bundle load];
    MSImageRef ref = MSGetImageByName([frameworkPath UTF8String]);
    InjectMLPIPController = MSFindSymbol(ref, "_InjectMLPIPController");
    if (InjectMLPIPController) {
        InjectYTSystemNotifications = MSFindSymbol(ref, "_InjectYTSystemNotifications");
        InjectYTBackgroundabilityPolicy = MSFindSymbol(ref, "_InjectYTBackgroundabilityPolicy");
        InjectYTPlayerViewControllerConfig = MSFindSymbol(ref, "_InjectYTPlayerViewControllerConfig");
        InjectYTHotConfig = MSFindSymbol(ref, "_InjectYTHotConfig");
        %init(WithInjection);
    } else {
        NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey];
        hasSampleBufferPiP = isLegacyVersion = [currentVersion compare:@"15.33.4" options:NSNumericSearch] == NSOrderedDescending;
        hasSampleBufferPiP &= IS_IOS_OR_NEWER(iOS_13_0);
    }
    if (!IS_IOS_OR_NEWER(iOS_14_0)) {
        %init(Compat);
        if (!IS_IOS_OR_NEWER(iOS_13_0))
            isLegacyVersion = YES;
    }
    if (LegacyPiP()) {
        %init(Legacy);
    }
    if (!IS_IOS_OR_NEWER(iOS_14_0) || IS_IOS_OR_NEWER(iOS_15_0))
        return;
    if (IS_IOS_OR_NEWER(iOS_14_2)) {
        %init(AVKit_iOS14_2_Up);
    } else {
        %init(AVKit_preiOS14_2);
    }
}