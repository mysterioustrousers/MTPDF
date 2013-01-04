//
//  MTPDFTests.m
//  MTPDFTests
//
//  Created by Adam Kirk on 1/3/13.
//  Copyright (c) 2013 Mysterious Trousers. All rights reserved.
//

#import "MTPDFTests.h"
#import "MTPDF.h"


@interface MTPDFTests ()
@property (strong, nonatomic) NSString *inputPDFPath;
@property (strong, nonatomic) NSString *outputPDFPath;
@end

@implementation MTPDFTests

- (void)setUp
{
    [super setUp];

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	_inputPDFPath = [bundle pathForResource:@"sample" ofType:@"pdf"];
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:_inputPDFPath], nil);

    _outputPDFPath= [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.pdf"];
}



- (void)testCreateFromPath
{
    MTPDF *pdf = [MTPDF PDFWithContentsOfFile:_inputPDFPath];
    STAssertNotNil(pdf, nil);
    STAssertTrue(pdf.reference != NULL, nil);
    STAssertNotNil(pdf.pages, nil);
    STAssertTrue(pdf.pages.count == 1, nil);
    STAssertTrue(pdf.allowsCopying, nil);
    STAssertTrue(pdf.allowsPrinting, nil);
    STAssertFalse(pdf.isEncrypted, nil);
    STAssertTrue(pdf.isUnlocked, nil);
    STAssertNotNil(pdf.version, nil);
    STAssertNotNil(pdf.title, nil);
    STAssertNotNil(pdf.author, nil);
    STAssertNotNil(pdf.creator, nil);
    STAssertNotNil(pdf.subject, nil);
}

- (void)testCreateFromURL
{
    MTPDF *pdf = [MTPDF PDFWithContentsOfURL:[NSURL fileURLWithPath:_inputPDFPath]];
    STAssertNotNil(pdf, nil);
    STAssertTrue(pdf.reference != NULL, nil);
    STAssertNotNil(pdf.pages, nil);
    STAssertTrue(pdf.pages.count == 1, nil);
    STAssertTrue(pdf.allowsCopying, nil);
    STAssertTrue(pdf.allowsPrinting, nil);
    STAssertFalse(pdf.isEncrypted, nil);
    STAssertTrue(pdf.isUnlocked, nil);
    STAssertNotNil(pdf.version, nil);
    STAssertNotNil(pdf.title, nil);
    STAssertNotNil(pdf.author, nil);
    STAssertNotNil(pdf.creator, nil);
    STAssertNotNil(pdf.subject, nil);
}

- (void)testWriteToFile
{
    MTPDF *pdf = [MTPDF PDFWithContentsOfURL:[NSURL fileURLWithPath:_inputPDFPath]];
    pdf.title   = @"modified";
    pdf.author  = @"modified";
    pdf.creator = @"modified";
    pdf.subject = @"modified";

    [pdf writeToFile:_outputPDFPath];
    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:_outputPDFPath], nil);

    pdf = [MTPDF PDFWithContentsOfURL:[NSURL fileURLWithPath:_outputPDFPath]];
    STAssertNotNil(pdf, nil);
    STAssertTrue(pdf.reference != NULL, nil);
    STAssertNotNil(pdf.pages, nil);
    STAssertTrue(pdf.pages.count == 1, nil);
    STAssertTrue(pdf.allowsCopying, nil);
    STAssertTrue(pdf.allowsPrinting, nil);
    STAssertFalse(pdf.isEncrypted, nil);
    STAssertTrue(pdf.isUnlocked, nil);
    STAssertNotNil(pdf.version, nil);
    STAssertNotNil(pdf.title, nil);
    STAssertNotNil(pdf.author, nil);
    STAssertNotNil(pdf.creator, nil);
    STAssertNotNil(pdf.subject, nil);
}

- (void)testToImage
{
    MTPDF *pdf = [MTPDF PDFWithContentsOfURL:[NSURL fileURLWithPath:_inputPDFPath]];
    MTPDFPage *page = [pdf.pages lastObject];
    UIImage *img = [page imageWithPixelsPerPoint:4];

    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.png"];
    [UIImageJPEGRepresentation(img, 1) writeToFile:path atomically:YES];

    STAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:path], nil);

    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfFile:path]];
    STAssertTrue(image.size.width == page.size.width * 4, nil);
    STAssertTrue(image.size.height == page.size.height * 4, nil);
}

@end
