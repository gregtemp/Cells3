//
//  TimedShape.m
//  timedAnimations
//
//  Created by Travis Kirton on 12-05-10.
//  Copyright (c) 2012 POSTFL. All rights reserved.
//

#import "TimedShape.h"
#import "MySample.h"
#import "SampleRecorder.h"

@interface TimedShape ()
-(void)start;
-(void)startDying;
-(void)newSize;
-(void)startRecord;
-(void)stopRecord;
-(void)startPlay;
-(void)stopPlay;
-(void)fade;
-(void)printMeters;

@property (readwrite, assign) C4Sample *audioSample;
@property (readwrite, strong) SampleRecorder *sampleRecorder;
@end

@implementation TimedShape {
    BOOL isDying;
    BOOL fadeOn;
    BOOL fadeUp;
    CGFloat myVol;
    NSInteger sampleId;
    UIColor *tcolor;
}
@synthesize audioSample, sampleRecorder;

-(id)init {
    
    self = [super init];
    if(self) {
        [self ellipse:CGRectMake(284,412,30,30)];
        isDying = NO;
        self.animationDuration = 0.0f;
        tcolor = [UIColor colorWithWhite:0 alpha:0.2];
        self.fillColor = tcolor;
        self.strokeColor = [UIColor colorWithWhite:0 alpha:0.7];
        self.lineWidth = 2.0f;
        [self newSize];
        [self performSelector:@selector(start) withObject:nil afterDelay:0.5f];
    }
    return self;
}

-(id)initWithTimedShape:(TimedShape *)ts {
    
    self = [super initWithFrame:ts.frame];
    if(self) {
        isDying = NO;
        self.animationDuration = 0.0f;
        [self ellipse: self.frame];
        tcolor = [UIColor colorWithWhite:0 alpha:0.2];
        self.fillColor = tcolor;
        self.strokeColor = [UIColor colorWithWhite:0 alpha:0.7];
        self.lineWidth = 2.0f;
        sampleRecorder = [SampleRecorder new];
        
        [self performSelector:@selector(start) withObject:nil afterDelay:0.5f];
        
    }
    return self;
}

-(void)start {
    [self performSelector:@selector(changePosition) withObject:nil afterDelay:0.5];
    
    CGFloat lifeSpan = ((CGFloat)[C4Math randomInt:100])/5.0f+5.0f;
    [self performSelector:@selector(startDying) withObject:self afterDelay:lifeSpan];
    
    [self startRecord];
}

-(void) newSize {
    int s = (int)[C4Math randomIntBetweenA:10 andB:50];
    [self ellipse:CGRectMake(self.frame.origin.x, self.frame.origin.y, s, s)];
}

-(void)changePosition {
    if([C4Math randomInt:15] < 5 && isDying == NO) {
        [self postNotification:@"timedShapeShouldDivide"];
    }
    
    
    CGFloat time = ((CGFloat) [C4Math randomIntBetweenA:100 andB:400]/100);
    self.animationDuration = time;
    
    NSInteger r = [C4Math randomIntBetweenA:-300 andB:300];
    CGFloat theta = DegreesToRadians([C4Math randomInt:360]);
    self.center = CGPointMake(r*[C4Math cos:theta] + 384, r*[C4Math sin:theta] + 512);
    
    
    [self performSelector:@selector(changePosition) withObject:self afterDelay:time];
}

-(id)copyWithZone:(NSZone *)zone {
   return [[TimedShape alloc] initWithTimedShape:self];
}

-(void)startDying {
    [self postNotification:@"imDying"];
    isDying = YES;
    self.animationDuration = ((CGFloat)[C4Math randomInt:70])/10.0f + 2.0f;
    
    self.fillColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.0f];
    self.strokeColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.0f];
    [self performSelector:@selector(removeFromSuperview) 
               withObject:nil 
               afterDelay:self.animationDuration];
    [self performSelector:@selector(stopPlay)];
}

-(void) startRecord {
    C4Log(@"start record");
    sampleId++;
    fadeOn = NO;
    self.sampleRecorder = [SampleRecorder new];
    [self.sampleRecorder recordSampleWithId:sampleId];
    [self performSelector:@selector(stopRecord) 
               withObject:nil 
               afterDelay:self.frame.size.width/10.0f];

}
-(void) stopRecord {
    C4Log(@"stop record");
    fadeOn = NO;
    [self.sampleRecorder stopRecording];
    [self startPlay];
}
-(void) startPlay {
    C4Log(@"start play");
    self.audioSample = nil;
//    self.audioSample = [C4Sample new];
    self.audioSample = self.sampleRecorder.sample;
    if(self.audioSample != nil)
        [self.audioSample play];
    self.audioSample.loops = YES;
    self.audioSample.meteringEnabled = YES;

    myVol = 0;
    fadeOn = YES;
    fadeUp = YES;
    [self fade];
    
    NSTimer *t = [NSTimer timerWithTimeInterval:0.1f target:self selector:@selector(printMeters) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:t forMode:NSDefaultRunLoopMode];
}

-(void) stopPlay {
    fadeOn = YES;
    fadeUp = NO;
    [self fade];
}

-(void) fade {
    
    if (fadeOn == YES){
        if (fadeUp == YES){
            if (myVol < 1.0f){
                myVol = myVol + 0.01f;
                [self performSelector:@selector(fade) withObject:nil afterDelay:0.05f];
                //C4Log(@"%f", myVol);
            }
            self.audioSample.volume = myVol;
        }
        if (fadeUp == NO){
            if (myVol > 0.01f){
                myVol = myVol - 0.01f;
                [self performSelector:@selector(fade) withObject:nil afterDelay:0.05f];
                //C4Log(@"%f", myVol);
            }
            self.audioSample.volume = myVol;
            if (myVol <= 0.0f){
                [self.audioSample stop];
                C4Log(@"stop");
            }
        }
    }
    if (fadeOn == NO){
        fadeUp = YES;
        myVol = 0;
    }
}


-(void)printMeters {
    [self.audioSample.player updateMeters];
    //CGFloat oldDur = self.animationDuration;
    
    self.animationDuration = 0.0f;
    CGFloat alpha = (pow (10, (0.05 *[self.audioSample.player averagePowerForChannel:0]))) * 10;
//    
    @try {
        self.fillColor = [tcolor colorWithAlphaComponent:alpha];
    } @catch (NSException *e) {
    }
    
    //self.animationDuration = oldDur;
    //C4Log(@"%f", alpha);

}

-(void)removeFromSuperview {
    self.audioSample = nil;
    self.sampleRecorder = nil;
    [super removeFromSuperview];
}

@end
