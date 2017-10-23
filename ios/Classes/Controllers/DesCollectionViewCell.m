//
//  DesCollectionViewCell.m
//  LXFDrawBoard
//
//  Created by 何江伟 on 2017/10/9.
//  Copyright © 2017年 LXF. All rights reserved.
//

#import "DesCollectionViewCell.h"

@implementation DesCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"圆角矩形1"]];
}

    // Configure the view for the selected state
    // Configure the view for the selected state
    // Configure the view for the selected state
    // Configure the view for the selected state
    // Configure the view for the selected state
    // Configure the view for the selected state
    // Configure the view for the selected state
    // Configure the view for the selected state
    // Configure the view for the selected state

    
-(void)cellWithIndexPath:(NSIndexPath *)indexpath
{
//    @"圆角矩形1"
    NSInteger mark = indexpath.row % 5 + 1;
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[NSString stringWithFormat:@"圆角矩形%ld",mark]]];

    
    NSString *title ;
    switch (indexpath.row) {
        case 0:
            title = @"Revocation";
            break;
        case 1:
            title = @"Reverse cancellation";

            break;
        case 2:
            title = @"Pencil";

            break;
        case 3:
            title = @"Arrow";

            break;
        case 4:
            title = @"A straight line";

            break;
        case 5:
            title = @"Text";

            break;
        case 6:
            title = @"Rectangles";

            break;
        case 7:
            title = @"Mosaic";
            
            break;
            
        default:
            break;
            
            
    }
    self.contentLabel.text = title;
    
    
}


// Configure the view for the selected state
// Configure the view for the selected state
// Configure the view for the selected state
// Configure the view for the selected state
// Configure the view for the selected state
// Configure the view for the selected state
// Configure the view for the selected state
// Configure the view for the selected state
// Configure the view for the selected state
// Configure the view for the selected state
// Configure the view for the selected state


@end
