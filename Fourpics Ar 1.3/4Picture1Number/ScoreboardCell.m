//
//  ScoreboardCell.m
//  What's the movie
//
//  Created by eurisko on 4/9/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "ScoreboardCell.h"

@implementation ScoreboardCell
@synthesize numberLabel1, numberLabel2, numberLabel3, numberLabel4;
@synthesize fbImage1, fbImage2, fbImage3, fbImage4;
@synthesize fbButton1, fbButton2, fbButton3, fbButton4;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
