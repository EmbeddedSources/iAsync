#import "SecondViewController.h"

@implementation SecondViewController

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

// Override to allow orientations other than the default portrait orientation.
-(BOOL)shouldAutorotateToInterfaceOrientation:( UIInterfaceOrientation )interface_orientation_
{
   return YES;
}

-(void)didReceiveMemoryWarning
{
   // Releases the view if it doesn't have a superview.
   [ super didReceiveMemoryWarning ];

   // Release any cached data, images, etc that aren't in use.
}

-(void)viewDidUnload
{
   // Release any retained subviews of the main view.
   // e.g. self.myOutlet = nil;
}

-(void)dealloc
{
   [ super dealloc ];
}

@end
