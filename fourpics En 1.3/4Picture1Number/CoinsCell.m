//
//  CoinsCell.m
//  What's the movie
//
//  Created by eurisko on 4/13/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import "CoinsCell.h"

@implementation CoinsCell
@synthesize titleLabel, priceLabel;

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
