//
//  MTPDF.h
//  MTPDF
//
//  Created by Adam Kirk on 1/3/13.
//  Copyright (c) 2013 Mysterious Trousers. All rights reserved.
//


@interface MTPDF : NSObject


@property (readonly)            CGPDFDocumentRef    reference;
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

- (void)drawInContext:(CGContextRef)context;
- (UIImage *)imageWithPixelsPerPoint:(NSInteger)ppp;

@end

