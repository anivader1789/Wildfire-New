//
//  SearchUserTableCell.m
//  Wildfire
//
//  Created by Animesh Anand on 6/17/14.
//  Copyright (c) 2014 Mobile AUG. All rights reserved.
//

#import "SearchUserTableCell.h"

@implementation SearchUserTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end