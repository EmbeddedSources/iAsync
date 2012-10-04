#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController
{
    NSArray *_imageUrls;
}

- (NSArray *)imageUrls
{
    if (!self->_imageUrls)
    {
        self->_imageUrls = @[
        [@"http://goo.gl/CHhyd" toURL],
        [@"http://goo.gl/yo4cu" toURL],
        [@"http://goo.gl/xpQj0" toURL],
        [@"http://goo.gl/NfbLu" toURL],
        [@"http://goo.gl/0nM5I" toURL],
        [@"http://goo.gl/CvKxv" toURL],
        [@"http://goo.gl/RbhVj" toURL],
        [@"http://goo.gl/1WgcK" toURL],
        [@"http://goo.gl/5DQt7" toURL],
        [@"http://goo.gl/oqeS7" toURL],
        [@"http://goo.gl/dYzp1" toURL],
        [@"http://goo.gl/SDz7k" toURL],
        [@"http://goo.gl/dRgZr" toURL],
        [@"http://goo.gl/S9FpG" toURL],
        [@"http://goo.gl/DmwJR" toURL],
        [@"http://goo.gl/0O8cX" toURL],
        ];
    }
    return self->_imageUrls;
}

- (void)reloadImages
{
    UIImage *placeholder = [UIImage imageNamed:@"loading.png"];
    
    NSArray *imageUrls = [self imageUrls];
    
    [self->_imagesContainer.subviews enumerateObjectsUsingBlock:^(UIImageView *imageView,
                                                                  NSUInteger idx, BOOL *stop) {
        [imageView setImageWithURL:imageUrls[idx]
                    andPlaceholder:placeholder];
    }];
}

- (IBAction)reloadAllImages
{
    [self reloadImages];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self reloadImages];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

@end
