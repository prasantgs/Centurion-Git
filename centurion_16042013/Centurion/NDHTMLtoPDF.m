//
//  NDHTMLtoPDF.m
//  Nurves
//
//  Created by Clément Wehrung on 31/10/12.
//  Copyright (c) 2012 QuelleEnergie. All rights reserved.
//
// Sources : http://www.labs.saachitech.com/2012/10/23/pdf-generation-using-uiprintpagerenderer/
// Addons : http://developer.apple.com/library/ios/#samplecode/PrintWebView/Listings/MyPrintPageRenderer_m.html#//apple_ref/doc/uid/DTS40010311-MyPrintPageRenderer_m-DontLinkElementID_7

#import "NDHTMLtoPDF.h"

@interface NDHTMLtoPDF ()

@property (nonatomic, strong) NSURL *URL;
@property (nonatomic, strong) NSString *HTML;
@property (nonatomic, strong) NSString *PDFpath;
@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, assign) UIEdgeInsets pageMargins;

@end

@interface UIPrintPageRenderer (PDF)

- (NSData*) printToPDF;

@end

@implementation NDHTMLtoPDF

@synthesize URL=_URL,webview,delegate=_delegate,PDFpath=_PDFpath,pageSize=_pageSize,pageMargins=_pageMargins;

// Create PDF by passing in the URL to a webpage
+ (id)createPDFWithURL:(NSURL*)URL pathForPDF:(NSString*)PDFpath delegate:(id <NDHTMLtoPDFDelegate>)delegate pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins
{
    NDHTMLtoPDF *creator = [[NDHTMLtoPDF alloc] initWithURL:URL delegate:delegate pathForPDF:PDFpath pageSize:pageSize margins:pageMargins];
    
    return creator;
}

// Create PDF by passing in the HTML as a String
+ (id)createPDFWithHTML:(NSString*)HTML pathForPDF:(NSString*)PDFpath delegate:(id <NDHTMLtoPDFDelegate>)delegate
               pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins
{
    NDHTMLtoPDF *creator = [[NDHTMLtoPDF alloc] initWithHTML:HTML delegate:delegate pathForPDF:PDFpath pageSize:pageSize margins:pageMargins];
    
    return creator;
}

- (id)initWithURL:(NSURL*)URL delegate:(id <NDHTMLtoPDFDelegate>)delegate pathForPDF:(NSString*)PDFpath pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins
{
    self = [super init];
    if (self)
    {
        self.URL = URL;
        self.delegate = delegate;
        self.PDFpath = PDFpath;
                
        self.pageMargins = pageMargins;
        self.pageSize = pageSize;

        [[UIApplication sharedApplication].delegate.window addSubview:self.view];

        self.view.frame = CGRectMake(0, 0, 1, 1);
        self.view.alpha = 0.0;
    }
    return self;
}

- (id)initWithHTML:(NSString*)HTML delegate:(id <NDHTMLtoPDFDelegate>)delegate
        pathForPDF:(NSString*)PDFpath pageSize:(CGSize)pageSize margins:(UIEdgeInsets)pageMargins
{
    self = [super init];
    if (self)
    {
        self.HTML = HTML;
        self.delegate = delegate;
        self.PDFpath = PDFpath;
        
        self.pageMargins = pageMargins;
        self.pageSize = pageSize;
        
        [[UIApplication sharedApplication].delegate.window addSubview:self.view];
        
        self.view.frame = CGRectMake(0, 0, 1, 1);
        self.view.alpha = 0.0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webview = [[UIWebView alloc] initWithFrame:self.view.frame];
    webview.delegate = self;
    
    [self.view addSubview:webview];
    
    if (self.URL != nil) {
        [webview loadRequest:[NSURLRequest requestWithURL:self.URL]];
    }else{
        [webview loadHTMLString:self.HTML baseURL:nil];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView.isLoading) return;
    
    UIPrintPageRenderer *render = [[UIPrintPageRenderer alloc] init];
    
    [render addPrintFormatter:webView.viewPrintFormatter startingAtPageAtIndex:0];
        
    CGRect printableRect = CGRectMake(self.pageMargins.left,
                                  self.pageMargins.top,
                                  self.pageSize.width - self.pageMargins.left - self.pageMargins.right,
                                  self.pageSize.height - self.pageMargins.top - self.pageMargins.bottom);
    
    CGRect paperRect = CGRectMake(0, 0, self.pageSize.width, self.pageSize.height);
    
    [render setValue:[NSValue valueWithCGRect:paperRect] forKey:@"paperRect"];
    [render setValue:[NSValue valueWithCGRect:printableRect] forKey:@"printableRect"];

    NSData *pdfData = [render printToPDF];
        
    [pdfData writeToFile: self.PDFpath  atomically: YES];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(HTMLtoPDFDidSucceed:)])
        [self.delegate HTMLtoPDFDidSucceed:self];
    

    [self terminateWebTask];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (webView.isLoading) return;

    if (self.delegate && [self.delegate respondsToSelector:@selector(HTMLtoPDFDidFail:)])
        [self.delegate HTMLtoPDFDidFail:self];

    [self terminateWebTask];
}

- (void)terminateWebTask
{
    [self.webview stopLoading];
    self.webview.delegate = nil;
    [self.webview removeFromSuperview];
    
    [self.view removeFromSuperview];
    
    self.webview = nil;
}

@end

@implementation UIPrintPageRenderer (PDF)

- (NSData*) printToPDF
{
    NSMutableData *pdfData = [NSMutableData data];
    //595, 842
    UIGraphicsBeginPDFContextToData(pdfData, CGRectMake(0, 20, 595, 842), nil);
        
   // [self prepareForDrawingPages: NSMakeRange(0, self.numberOfPages)];
    
    //CGRect bounds = UIGraphicsGetPDFContextBounds();
        
    for ( int i = 0 ; i < self.numberOfPages ; i++ )
    {
        UIGraphicsBeginPDFPage();
        
        [self drawPageAtIndex: i inRect: CGRectMake(120, 770, 500, 15)]; //bounds];
        CGRect textRect = [self addText:@"Centurion Medical Products | 100 Centurion Way | Williamston MI USA 48895 | 800.248.4058"
                              withFrame:CGRectMake(120, 770, 500, 15) fontSize:8.0f];
        
        UIImage *anImage = [UIImage imageNamed:@"logo.gif"];
        CGRect imageRect = [self addImage:anImage
                                  atPoint:CGPointMake(50, 768)];

    }

    UIGraphicsEndPDFContext();
        
    return pdfData;
}

- (CGRect)addImage:(UIImage*)image atPoint:(CGPoint)point {
    CGRect imageFrame = CGRectMake(point.x, point.y, 70, 10);//CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [image drawInRect:imageFrame];
    
    return imageFrame;
}
- (CGRect)addText:(NSString*)text withFrame:(CGRect)frame fontSize:(float)fontSize {
    UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
    
	CGSize stringSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(500, 15) lineBreakMode:NSLineBreakByWordWrapping];
    
	float textWidth = frame.size.width;
    
    if (textWidth < stringSize.width)
        textWidth = stringSize.width;
    if (textWidth > 500)
        textWidth = 500 - frame.origin.x;
    
    CGRect renderingRect = CGRectMake(frame.origin.x, frame.origin.y, textWidth, stringSize.height);
    
    [text drawInRect:renderingRect withFont:font lineBreakMode:NSLineBreakByWordWrapping alignment:UITextAlignmentCenter];
    
    frame = CGRectMake(frame.origin.x, frame.origin.y, textWidth, stringSize.height);
    
    return frame;
}
@end
