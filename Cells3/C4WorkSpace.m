#import "C4WorkSpace.h"
#import "TimedShape.h"
#import "MySample.h"
#import "SampleRecorder.h"

@interface C4WorkSpace ()
-(void)divideTimedShape:(NSNotification *)notification;
-(void)death;
@end

@implementation C4WorkSpace {
    NSInteger guys;
}

-(void)setup {
    TimedShape *t = [TimedShape new];
    [self.canvas addShape:t];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(divideTimedShape:) 
                                                 name:@"timedShapeShouldDivide"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(death) 
                                                 name:@"imDying"
                                               object:nil];
    t = nil;
}

-(void) death {
    guys--;
}

-(void)divideTimedShape:(NSNotification *)notification {
    TimedShape *ts = [((TimedShape *)[notification object]) copy];
    [self.canvas addShape:ts];
    guys++;
    C4Log(@"%i", guys);
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    t = [TimedShape new];
//    t.fillColor = [UIColor colorWithWhite:0 alpha:0.2];
//    t.strokeColor = [UIColor colorWithWhite:0 alpha:0.7];
//    t.lineWidth = 2.0f;
//    [t ellipse:CGRectMake(self.canvas.frame.size.width/2, self.canvas.frame.size.height/2, 30, 30)];
//    [self.canvas addShape:t];
//    [t changePosition];
}

@end
