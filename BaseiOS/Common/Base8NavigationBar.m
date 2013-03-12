//
//  Base8NavigationBar.m
//  BaseiOS
//
//  Created by Stojce Slavkovski on 3/11/13.
//  Copyright (c) 2013 HighFidelity.io. All rights reserved.
//

#import "Base8NavigationBar.h"

@implementation Base8NavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	UIImage *image = [UIImage imageNamed:@"twitter.png"];
	[image drawInRect:CGRectMake(5, 7, image.size.width, image.size.height)];
}

@end
