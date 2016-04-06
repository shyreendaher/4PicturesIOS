//
//  ScoreboardCell.h
//  What's the movie
//
//  Created by eurisko on 4/9/13.
//  Copyright (c) 2013 eurisko. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreboardCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *numberLabel1, *numberLabel2, *numberLabel3, *numberLabel4;
@property (nonatomic, retain) IBOutlet UIImageView *fbImage1, *fbImage2, *fbImage3, *fbImage4;
@property (nonatomic, retain) IBOutlet UIButton *fbButton1, *fbButton2, *fbButton3, *fbButton4;

@end
