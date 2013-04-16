//
//  ViewPDFViewController.m
//  Centurion
//
//  Created by ankur on 12/20/12.
//
//

#import "ViewPDFViewController.h"

@interface ViewPDFViewController ()

@end

@implementation ViewPDFViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdfPath = [documentsDirectory stringByAppendingPathComponent:@"Centurion.pdf"];
    if([[NSFileManager defaultManager] fileExistsAtPath:pdfPath])
    {
        
//        ReaderDocument *document = [ReaderDocument withDocumentFilePath:pdfPath password:nil];
//        
//        if (document != nil)
//        {
//            ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
//            readerViewController.delegate = self;
//            
//            readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//            readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
//            
//            [self presentModalViewController:readerViewController animated:YES];
//        }
        
      //  NSString *path = [[NSBundle mainBundle] pathForResource:@"Peripheral_IV_Estimate_01" ofType:@"pdf"];
        NSURL *targetURL = [NSURL fileURLWithPath:pdfPath];
        NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
        [webView loadRequest:request];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)DonePressed:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

@end
