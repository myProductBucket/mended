#import "RequestProcessor.h"
#import "SBJson.h"
#import "ConvenientPopups.h"


#define REQUEST_TIMEOUT 30
#define METERS_TO_MI 0.000621371192f
#define DEFAULT_LOCATION [[CLLocation alloc] initWithLatitude:40.714623 longitude: -74.006605] // New York
#define DEFAULT_ANIMATION_INTERVAL 0.5

/*
 3rd party stuff
 */

#define FOURSQUARE_CLIENT_ID @"3B4IOAGZ55X3TOWXSFJIEQEH5GZTHL55MF32VZJRKUYA5F3L"
#define FOURSQUARE_SECRET @"H2Y1UDPYLCZDFW3BSIZR3OFVTJQH41OJI2JGONPNNOY0J2OO"



@implementation RequestProcessor

@synthesize urlString;
@synthesize delegate;
@synthesize processedJSON;

@synthesize successCallback;
@synthesize failCallback;

static NSMutableArray *__processors = nil;

+ (NSString *)urlEncode:(id) unencodedString
{
	if(unencodedString == nil)
		return @"";
    
    
	NSString *stringToEncode;
	
	if(![unencodedString isKindOfClass:[NSString class]])
	{
		stringToEncode = [NSString stringWithFormat:@"%@", unencodedString];
	}
	else
	{
		stringToEncode = unencodedString;
	}
	
	NSString * encodedString;
	
	if([stringToEncode length] == 0)
	{
		return @"";
	}
	else
	{
		encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                     kCFAllocatorDefault,
                                                                                     (CFStringRef)stringToEncode,
                                                                                     NULL,
                                                                                     (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                     kCFStringEncodingUTF8 );
        
	}
	
	return encodedString;
}

+ (void)cancelAllRequestsFromDelegate:(id)delegate
{
    for(RequestProcessor *rp in __processors)
    {
        if(rp.delegate == delegate)
        {
            rp.delegate = nil;
            [rp cancelRequest];
        }
    }
}

- (id)init
{
	self = [super init];
	if(self)
	{
		self.delegate = nil;
		self.processedJSON = nil;

        _offset = 0;
        _limit = 25;
        
        _request = nil;
        _formRequest = nil;
        
        successCallback = nil;
        failCallback = nil;
        
        _parameterAdded = NO;
        
        [ASIHTTPRequest setDefaultTimeOutSeconds:REQUEST_TIMEOUT];
        
        if (!__processors)
        {
            __processors = [[NSMutableArray alloc] init];
        }
	}
	
	return self;
}

- (void)dealloc
{
    self.delegate = nil;
	self.processedJSON = nil;
	self.urlString = nil;
    
    if(_request)
    {
        [_request clearDelegatesAndCancel];
        _request = nil;
    }
    
    if(_formRequest)
    {
        [_formRequest clearDelegatesAndCancel];
        _formRequest = nil;
    }
    [__processors release];
    __processors = nil;
    [super dealloc];
}

- (void)startRequest
{
	
	NSURL *url = [NSURL URLWithString: urlString];	
	
	_request = [ASIHTTPRequest requestWithURL:url];	
    
	[_request setValidatesSecureCertificate:NO]; 
	[_request setDelegate:self];
	[_request startAsynchronous];
}

- (void)cancelRequest
{
    if(_request)
    {
        [_request clearDelegatesAndCancel];
        _request = nil;
    }
    
    if(_formRequest)
    {
        [_formRequest  clearDelegatesAndCancel];
        _formRequest = nil;
    }
    
    if([__processors indexOfObject:self] != NSNotFound)
    {
        [__processors removeObject:self];
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    _request = nil;
    _formRequest = nil;

	NSString *responseString = [request responseString];	
	
    [self performSelectorInBackground:@selector(process:) withObject:responseString];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    _request = nil;
    _formRequest = nil;
    
    [ConvenientPopups showToastLikeMessage:@"Beep, beep! " 
     @"We can't connect to the internet right now! Check your network or try again in a minute!"
                                    onView:[[UIApplication sharedApplication] keyWindow]];
	
    
	if(self.delegate)
    {
        if(self.failCallback != nil)
        {
            if([self.delegate respondsToSelector:self.failCallback])
            {
                [self.delegate performSelector:self.failCallback withObject:self];
            }
        }
        else
            [self.delegate requestProcessorFailedCallback:self];
    }
	
    if(_formRequest != nil)
        _formRequest = nil;
    
    if(_request != nil)
        _request = nil;
    
	if([__processors indexOfObject:self] != NSNotFound)
    {
        [__processors removeObject:self];
    }
}

- (void)addParameter:(NSString *)parameter value:(id)value
{
    if(_parameterAdded)
    {
        self.urlString = [urlString stringByAppendingFormat:@"&%@=%@", [RequestProcessor urlEncode:parameter],
                     [RequestProcessor urlEncode:value]];
    }
    else
    {
        self.urlString = [urlString stringByAppendingFormat:@"?%@=%@", [RequestProcessor urlEncode:parameter],
                     [RequestProcessor urlEncode:value]];
        
        _parameterAdded = YES;
    }
}

- (void)process:(NSString *) stringToProcess
{
    
	SBJsonParser *jsonParser = [SBJsonParser new];
	
	self.processedJSON = [jsonParser objectWithString: stringToProcess];
    jsonParser = nil;
	
	id returnValue = nil;

    if(![self.processedJSON isKindOfClass:[NSDictionary class]])
    {
        [ConvenientPopups showToastLikeMessage:@"Beep, beep! " 
         @"Error processing server response! Please try again later!"
                                        onView:[[UIApplication sharedApplication] keyWindow]];
    }
    else
    if(_requestType == kRequestTypeNonInternal)
    {
        returnValue = self.processedJSON;
    }
    else
	if([self.processedJSON  objectForKey: @"error"] == nil)
	{
        [ConvenientPopups showToastLikeMessage:[NSString stringWithFormat:@"Beep, beep! %@", stringToProcess]
                                        onView:[[UIApplication sharedApplication] keyWindow]];

	}
    else
    if([[self.processedJSON objectForKey: @"error"] isKindOfClass:[NSDictionary class]])
    {
        if([[self.processedJSON objectForKey: @"error"] objectForKey: @"code"] == [NSNull null] ||
           [[[self.processedJSON objectForKey: @"error"] objectForKey: @"code"] intValue] == 0
           )
        {
            returnValue = self.processedJSON;
        }
        else
        if([[self.processedJSON objectForKey: @"error"] objectForKey:@"code"] != nil)
        {
            if([[self.processedJSON objectForKey: @"error"] objectForKey:@"description"])
            [ConvenientPopups showAlertWithTitle:@"Error" 
                                      andMessage:[[self.processedJSON objectForKey: @"error"] objectForKey:@"description"]];
        }
    }
    else
    {
        [ConvenientPopups showToastLikeMessage:@"Beep, beep! " @"Error processing server response! Please try again later!"
                                        onView:[[UIApplication sharedApplication] keyWindow]];
    }
    
    if(returnValue != nil)
	{
		if(self.delegate)
        {
            if(self.successCallback != nil)
            {
                if([self.delegate respondsToSelector:self.successCallback])
                {
                    [self.delegate performSelectorOnMainThread:self.successCallback withObject:self waitUntilDone:NO];
                }
            }
            else
                [self.delegate performSelectorOnMainThread:@selector(requestProcessorSuccessCallback:) withObject:self waitUntilDone:NO];
        }
	}
	else
    {
        if(self.delegate)
        {
            if(self.failCallback != nil)
            {
                if([self.delegate respondsToSelector:self.failCallback])
                {
                    [self.delegate performSelectorOnMainThread:self.failCallback withObject:self waitUntilDone:NO];
                }
            }
            else
                [self.delegate performSelectorOnMainThread:@selector(requestProcessorFailedCallback:) withObject:self waitUntilDone:NO];
        }
    }

    
    if(_formRequest != nil)
        _formRequest = nil;
    
    if(_request != nil)
        _request = nil;
    
	if([__processors indexOfObject:self] != NSNotFound)
    {
        [__processors removeObject:self];
    }

}

#pragma mark - Request methods

- (void)getFoursquareVenuesForLocation:(CLLocation *)location
                                radius:(NSString *)radius
                                 query:(NSString *)query
                           limitToFood:(BOOL)limitToFood
{
    [__processors addObject:self];
    
    _requestType = kRequestTypeNonInternal;
    
    self.urlString = @"https://api.foursquare.com/v2/venues/explore";
    
    [self addParameter:@"client_id" value:FOURSQUARE_CLIENT_ID];
    [self addParameter:@"client_secret" value:FOURSQUARE_SECRET];

    //if(limitToFood)
    //    [self addParameter:@"section" value:@"food"];
    
    if(location != nil)
    {
        CLLocationCoordinate2D coordinate = location.coordinate;
        self.urlString = [urlString stringByAppendingFormat:@"&ll=%f,%f", coordinate.latitude, coordinate.longitude];
    }
    
    self.urlString = [urlString stringByAppendingFormat:@"&limit=100"];
    
    NSInteger foursquareRadius = MIN((int) ([radius floatValue] / METERS_TO_MI), 30000);
    
    
    self.urlString = [urlString stringByAppendingFormat:@"&radius=%li", (long)foursquareRadius];
    
    self.urlString = [urlString stringByAppendingFormat:@"&query=%@", [RequestProcessor urlEncode:query]];
    
    self.urlString = [urlString stringByAppendingFormat:@"&v=20130815"];
    
    [self startRequest];
}

@end