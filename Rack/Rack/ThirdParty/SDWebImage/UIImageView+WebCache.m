/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIImageView+WebCache.h"

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSURL *)url withIndicator:(BOOL)showIndicator
{
    [self setImageWithURL:url placeholderImage:nil];
    
    if (showIndicator && self.image==nil) {
        UIActivityIndicatorView *indicator = [self viewWithTag:100];
        if (indicator == nil) {
            indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            double delayInSeconds = 0.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
               indicator.frame = CGRectMake((self.frame.size.width-20)/2, (self.frame.size.height-20)/2, 20, 20);
            });
            indicator.tag = 100;
            [self addSubview:indicator];
        }
        [indicator startAnimating];
    }
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder options:0];
}

- (UIImage *)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url placeholderImage:nil];
    return self.image;
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options{
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];
    self.image = placeholder;
    if (url)
    {
        [manager downloadWithURL:url delegate:self options:options];
    }
}
- (void)cancelCurrentImageLoad
{
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}
- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    self.image = image;
        for (UIActivityIndicatorView *indicatorView in self.subviews) {
        if([indicatorView isKindOfClass:[UIActivityIndicatorView class]]){
            [indicatorView stopAnimating];
            [indicatorView removeFromSuperview];
        }
    }
}

@end
