//
//  AwesomeFloatingToolbar.m
//  Browser
//
//  Created by Alessandro Musto on 6/8/16.
//  Copyright © 2016 Lmusto. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"


@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *pressGesture;
@property (nonatomic, strong) NSMutableArray *differentColors;


@end

@implementation AwesomeFloatingToolbar


- (instancetype) initWithFourTitles:(NSArray *)titles {
    
    self = [super init];
    
    if(self) {
      self.translatesAutoresizingMaskIntoConstraints = NO;

        self.currentTitles = titles;
        self.colors =@[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                       [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                       [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                       [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *labelsArray = [[NSMutableArray alloc]init];
        
        for (NSString *currentTitle in self.currentTitles) {
            UILabel *label = [[UILabel alloc] init];
            label.userInteractionEnabled = NO;
            label.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:10];
            label.text = titleForThisLabel;
            label.backgroundColor = colorForThisLabel;
            label.textColor = [UIColor whiteColor];
            
            [labelsArray addObject:label];
            
        }
        
        self.labels = labelsArray;
        
        for (UILabel *thisLabel in self.labels) {
            [self addSubview:thisLabel];
        }
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        [self addGestureRecognizer:self.tapGesture];
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        self.pressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressFired:)];
        [self addGestureRecognizer:self.pressGesture];
        _pressGesture.minimumPressDuration = 1.0;
        [_tapGesture requireGestureRecognizerToFail:_pressGesture];
        
        
    }
        
    return self;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//
//    return YES;
//}

-(void) tapFired:(UITapGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateRecognized){
        CGPoint location = [recognizer locationInView:self];
        UIView *tappedView = [self hitTest:location withEvent:nil];
        
        if ([self.labels containsObject:tappedView]) {
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]){
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UILabel *)tappedView).text];
            }
        }
    }
}

-(void) panFired:(UIPanGestureRecognizer *)recognizer {
    
    if(recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New Translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

-(void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if(recognizer.state == UIGestureRecognizerStateChanged){
        
        CGFloat scale = recognizer.scale;
        
        NSLog(@"Pinch scale: %f", scale);
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryAndPinchWithScale:)]){
        [self.delegate floatingToolbar:self didTryAndPinchWithScale:scale];
        }
    }
}

//- (NSArray *) colorChange {
//    if (_pressGesture) {
//        NSMutableArray *differentColors = [self.colors mutableCopy];
//        for (NSUInteger i = 0; i < ([differentColors count]-1); i++) {
//            [differentColors exchangeObjectAtIndex:i withObjectAtIndex:([differentColors count]-1)];
//        }
//    }
//    return _differentColors;
//}

- (void) pressFired:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        NSMutableArray *differentColors = [self.colors mutableCopy];
        for (NSUInteger i = 0; i < ([differentColors count]-1); i++) {
            [differentColors exchangeObjectAtIndex:i withObjectAtIndex:([differentColors count]-1)];
        }
        
        for (UILabel *label in self.labels) {
            NSUInteger currentLabelIndex = [self.labels indexOfObject:label];
            UIColor *colorForThisLabel = [differentColors objectAtIndex:currentLabelIndex];
           
            label.backgroundColor = colorForThisLabel;
        }
        
        NSLog(@"Long Press Detected");
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        NSLog(@"Long Press Ended");
    }
    
    
}

-(void) floatingToolbar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset {
    CGPoint startingPoint = toolbar.frame.origin;
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
        
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));
    
    if (CGRectContainsRect(self.bounds, potentialNewFrame)) {
        toolbar.frame = potentialNewFrame;
    }
}

- (void) layoutSubviews {

  [super layoutSubviews];

    for (UILabel *thisLabel in self.labels) {
        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
        
        CGFloat labelHieght = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        
        
        if (currentLabelIndex < 2) {
            labelY =0;
        } else {
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentLabelIndex % 2 ==0) {
            labelX = 0;
        } else {
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHieght);
    }
}



# pragma mark - Touch Handeling

- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *) event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView *subview = [self hitTest:location withEvent:event];
    
    if ([subview isKindOfClass:[UILabel class]]) {
        return (UILabel *)subview;
    } else {
        return nil;
    }
    
}

/*- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    self.currentLabel = label;
    self.currentLabel.alpha = 0.5;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    if(self.currentLabel != label){
        self.currentLabel.alpha = 1;
    } else {
        self.currentLabel.alpha = 0.5;
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UILabel *label = [self labelFromTouches:touches withEvent:event];
    
    if (self.currentLabel == label) {
        NSLog(@"Label tapped: %@", self.currentLabel.text);
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
            [self.delegate floatingToolbar:self didSelectButtonWithTitle:self.currentLabel.text];
        }
    }
    
    self.currentLabel.alpha = 1;
    self.currentLabel = nil;
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.currentLabel.alpha = 1;
    self.currentLabel = nil;
}
*/

#pragma mark - Button Enabling

-(void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if(index != NSNotFound){
        UILabel *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 :0.25;
        
    }
}


@end
