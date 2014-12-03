//
//  MTPDF.h
//  MTPDF
//
//  Created by Adam Kirk on 1/3/13.
//  Copyright (c) 2013 Mysterious Trousers. All rights reserved.
//


@interface MTPDF : NSObject


@property (readonly)            CGPDFDocumentRef    reference;
@property (readonly)            NSData              *data;
@property (readonly)            NSArray             *pages;
@property (readonly)            BOOL                allowsCopying;
@property (readonly)            BOOL                allowsPrinting;
@property (readonly)            BOOL                isEncrypted;
@property (readonly)            BOOL                isUnlocked;
@property (readonly)            NSString            *version;
@property (strong, nonatomic)   NSString            *title;
@property (strong, nonatomic)   NSString            *author;
@property (strong, nonatomic)   NSString            *creator;
@property (strong, nonatomic)   NSString            *subject;
@property (readonly)            NSDate              *creationDate;
@property (readonly)            NSDate              *modifiedDate;


+ (MTPDF *)PDFWithContentsOfFile:(NSString *)path;
+ (MTPDF *)PDFWithContentsOfURL:(NSURL *)aURL;
+ (MTPDF *)PDFWithData:(NSData *)data;

- (BOOL)unlockWithPassword:(NSString *)password;
- (void)writeToFile:(NSString *)path;


@end




@interface MTPDFPage : NSObject

@property (readonly) CGPDFPageRef   reference;
@property (readonly) NSInteger      pageNumber;
@property (readonly) CGSize         size;

// This is the old method, and has gone away. Please use drawInContext:atSize: instead.
//- (void)drawInContext:(CGContextRef)context;

// New draw methods. Use drawInPDFContext: to draw in a specifically created CGPDFContext.
- (void)drawInPDFContext:(CGContextRef)context;
// Use drawInContext:atSize: as a replacement for the old drawInContext: method. Size will specify the dimensions at which to draw in the context.
- (void)drawInContext:(CGContextRef)context atSize:(CGSize)drawSize;

- (UIImage *)imageWithPixelsPerPoint:(NSInteger)ppp;

@end

