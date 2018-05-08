//
//  ListCropSizesCollectionViewCell.m
//  VideoEditor
//
//  Created by Mohammed Aslam on 03/05/18.
//  Copyright © 2018 Oottru. All rights reserved.
//

#import "ListCropSizesCollectionViewCell.h"

@implementation ListCropSizesCollectionViewCell
@synthesize _imageView,ratioSizeLabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, self.contentView.frame.size.width-12, 50)];
        [_imageView setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:_imageView];
        UILabel *fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(6, 58, self.contentView.frame.size.width-12, 20)];
        //fromLabel.text = @"text";
       // fromLabel.numberOfLines = 1;
        fromLabel.baselineAdjustment = UIBaselineAdjustmentAlignBaselines; // or UIBaselineAdjustmentAlignCenters, or UIBaselineAdjustmentNone
        fromLabel.adjustsFontSizeToFitWidth = YES;
        fromLabel.clipsToBounds = YES;
        fromLabel.backgroundColor = [UIColor brownColor];
        fromLabel.textColor = [UIColor blackColor];
        fromLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:fromLabel];
    }
    return self;
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    // reset image property of imageView for reuse
    _imageView.image = nil;
    // update frame position of subviews
    _imageView.frame = self.contentView.bounds;
}
@end
