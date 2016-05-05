//
//  BBGridView.m
//  BubbleArtboard
//
//  Created by Arman Markosyan on 04.05.16.
//  Copyright © 2016 Arman Markosyan. All rights reserved.
//

#import "BBGridView.h"

@implementation BBGridView

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set line Color
    UIColor *lineColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    CGContextSetStrokeColorWithColor(context, lineColor.CGColor);
    CGContextSetLineWidth(context, 1.0);
    
    CGFloat gridSize = kGRID_SIZE;
    
    // draw horizontal lines
    CGFloat linePosition = 0.0;
    while (linePosition < rect.size.height) {
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, 0, linePosition);
        CGContextAddLineToPoint(context, rect.size.width, linePosition);
        CGContextStrokePath(context);
        linePosition += gridSize;
    }
    
    // draw vertical lines
    linePosition = 0.0f;
    while (linePosition < rect.size.width) {
        
        CGContextBeginPath(context);
        CGContextMoveToPoint(context, linePosition, 0);
        CGContextAddLineToPoint(context, linePosition, rect.size.height);
        CGContextStrokePath(context);
        linePosition += gridSize;
    }
}

@end
