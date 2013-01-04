//
//  MTPDF.m
//  MTPDF
//
//  Created by Adam Kirk on 1/3/13.
//  Copyright (c) 2013 Mysterious Trousers. All rights reserved.
//

#import "MTPDF.h"
#import <NSDate+MTDates.h>




@interface MTPDFPage ()
@property (nonatomic)   CGRect  frame;
- (id)initWithReference:(CGPDFPageRef)reference;
@end





@implementation MTPDF


- (id)initWithReference:(CGPDFDocumentRef)reference
{
    self = [super init];
    if (self) {
        _reference = reference;

        // add pages
        NSMutableArray *array = [NSMutableArray array];
        size_t count = CGPDFDocumentGetNumberOfPages(_reference);
        for (NSInteger i = 1; i <= count; i++) {
            MTPDFPage *page = [[MTPDFPage alloc] initWithReference:CGPDFDocumentGetPage(_reference, i)];
            [array addObject:page];
        }
        _pages = array;

        // general properties
        _allowsCopying      = CGPDFDocumentAllowsCopying(_reference);
        _allowsPrinting     = CGPDFDocumentAllowsPrinting(_reference);
        _isEncrypted        = CGPDFDocumentIsEncrypted(_reference);
        _isUnlocked         = CGPDFDocumentIsUnlocked(_reference);

        // version
        int majorVersion = 0;
        int minorVersion = 0;
        CGPDFDocumentGetVersion(_reference, &majorVersion, &minorVersion);
        _version = [NSString stringWithFormat:@"%d.%d", majorVersion, minorVersion];

        // get dictionary info
        CGPDFDictionaryRef dict = CGPDFDocumentGetInfo(_reference);
        if (dict != NULL) {
            _title          = [self getKey:"Title"          from:dict];
            _author         = [self getKey:"Author"         from:dict];
            _creator        = [self getKey:"Creator"        from:dict];
            _subject        = [self getKey:"Subject"        from:dict];

            NSString *creationDateString = [self getKey:"CreationDate" from:dict];
            if (creationDateString)
                _creationDate = [self dateFromPDFDateString:creationDateString];


            NSString *modifiedDateString = [self getKey:"ModDate" from:dict];
            if (modifiedDateString)
                _modifiedDate = [self dateFromPDFDateString:modifiedDateString];
        }
    }
    return self;
}


+ (MTPDF *)PDFWithContentsOfFile:(NSString *)path
{
    return [self PDFWithContentsOfURL:[NSURL fileURLWithPath:path]];
}

+ (MTPDF *)PDFWithContentsOfURL:(NSURL *)aURL
{
    CFURLRef URL = (CFURLRef)CFBridgingRetain(aURL);
    return [[MTPDF alloc] initWithReference:CGPDFDocumentCreateWithURL(URL)];
}


+ (MTPDF *)PDFWithData:(NSData *)data
{
    CFDataRef myPDFData = (__bridge CFDataRef)data;
    CGDataProviderRef provider = CGDataProviderCreateWithCFData(myPDFData);
    return [[MTPDF alloc] initWithReference:CGPDFDocumentCreateWithProvider(provider)];
}


- (BOOL)unlockWithPassword:(NSString *)password
{
    return CGPDFDocumentUnlockWithPassword(_reference, [password UTF8String]);
}

- (void)writeToFile:(NSString *)path
{
    CFMutableDictionaryRef infoDict = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    if (_title)     CFDictionarySetValue(infoDict, kCGPDFContextTitle,      CFBridgingRetain(_title));
    if (_author)    CFDictionarySetValue(infoDict, kCGPDFContextAuthor,     CFBridgingRetain(_author));
    if (_creator)   CFDictionarySetValue(infoDict, kCGPDFContextCreator,    CFBridgingRetain(_creator));
    if (_subject)   CFDictionarySetValue(infoDict, kCGPDFContextSubject,    CFBridgingRetain(_subject));

    MTPDFPage *anyPage = [_pages lastObject];
    CGRect rect = anyPage.frame;
    CGContextRef PDFContext = CGPDFContextCreateWithURL((__bridge CFURLRef)([NSURL fileURLWithPath:path]), &rect, infoDict);

    for (MTPDFPage *page in _pages) {
        [page drawInContext:PDFContext];
    }

    CFRelease(PDFContext);
    CFRelease(infoDict);
}



#pragma mark - Private

-(NSString *)getKey:(char *)key from:(CGPDFDictionaryRef)dict
{
    NSString *value = nil;
    CGPDFStringRef cfValue;
    if (CGPDFDictionaryGetString(dict, key, &cfValue))
        value = CFBridgingRelease(CGPDFStringCopyTextString(cfValue));
    return value;
}

// D:20111103113132+11'00'
// D: 2011 11 03 11 31 32 +11 '00'
- (NSDate *)dateFromPDFDateString:(NSString *)string
{
    NSRange yearRange   = NSMakeRange(2, 4);
    NSRange monthRange  = NSMakeRange(yearRange.location    + yearRange.length,     2);
    NSRange dayRange    = NSMakeRange(monthRange.location   + monthRange.length,    2);
    NSRange hourRange   = NSMakeRange(dayRange.location     + dayRange.length,      2);
    NSRange minRange    = NSMakeRange(hourRange.location    + hourRange.length,     2);
    NSRange secRange    = NSMakeRange(minRange.location     + minRange.length,      2);
    NSRange signRange   = NSMakeRange(secRange.location     + secRange.length,      1);
    NSRange tzRange     = NSMakeRange(signRange.location    + signRange.length,     2);

    NSInteger year      = [[string substringWithRange:yearRange]    integerValue];
    NSInteger month     = [[string substringWithRange:monthRange]   integerValue];
    NSInteger day       = [[string substringWithRange:dayRange]     integerValue];
    NSInteger hour      = [[string substringWithRange:hourRange]    integerValue];
    NSInteger min       = [[string substringWithRange:minRange]     integerValue];
    NSInteger sec       = [[string substringWithRange:secRange]     integerValue];

    NSInteger sign      = 1;
    if (string.length >= signRange.location + signRange.location) {
        sign = [[string substringWithRange:signRange] isEqualToString:@"-"] ? -1 : 1;

    }

    NSInteger tz        = 0;
    if (string.length >= tzRange.location + tzRange.location) {
        tz = [[string substringWithRange:tzRange] integerValue] * sign;
    }

    NSTimeZone *timeZone = [NSTimeZone timeZoneForSecondsFromGMT:(tz * 60 * 60)];
    [NSDate setTimeZone:timeZone];
    NSDate *date = [NSDate dateFromYear:year month:month day:day hour:hour minute:min second:sec];
    [NSDate setTimeZone:[NSTimeZone defaultTimeZone]];
    return date;
}


@end







@implementation MTPDFPage


- (id)initWithReference:(CGPDFPageRef)reference
{
    self = [super init];
    if (self) {
        _reference  = reference;
        _pageNumber = CGPDFPageGetPageNumber(_reference);
        _frame      = CGPDFPageGetBoxRect(_reference, kCGPDFMediaBox);
    }
    return self;
}

- (CGSize)size
{
    return _frame.size;
}

- (void)drawInContext:(CGContextRef)context
{
    CFMutableDictionaryRef pageDict = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDataRef boxData = CFDataCreate(NULL, (const UInt8 *)&_frame, sizeof(CGRect));
    CFDictionarySetValue(pageDict, kCGPDFContextMediaBox, boxData);

    CGPDFContextBeginPage(context, pageDict);
    CGContextDrawPDFPage(context, _reference);
    CGPDFContextEndPage(context);

    CFRelease(pageDict);
    CFRelease(boxData);
}

- (UIImage *)imageWithPixelsPerPoint:(NSInteger)ppp
{
    CGSize size = _frame.size;
    CGRect rect = CGRectMake(0, 0, size.width, size.height) ;
    size.width  *= ppp;
    size.height *= ppp;

    UIGraphicsBeginImageContext(size);

	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextSaveGState(context);
	CGAffineTransform transform = CGPDFPageGetDrawingTransform(_reference, kCGPDFMediaBox, rect, 0, true);
	CGContextConcatCTM(context, transform);

    CGContextTranslateCTM(context, 0, size.height);
    CGContextScaleCTM(context, ppp, -ppp);

    CFMutableDictionaryRef pageDict = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDataRef boxData = CFDataCreate(NULL, (const UInt8 *)&rect, sizeof(CGRect));
    CFDictionarySetValue(pageDict, kCGPDFContextMediaBox, boxData);

	CGContextDrawPDFPage(context, _reference);

	CGContextRestoreGState(context);

	UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return resultingImage;
}


@end