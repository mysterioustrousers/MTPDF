MTPDF
=====

Objective-C PDF objects. Doing my part to help us stay out of the headache that is Core Foundation.

### Installation

In your Podfile, add this line:

    pod "MTPDF"

pod? => https://github.com/CocoaPods/CocoaPods/

NOTE: You may need to add `-all_load` to "Other Linker Flags" in your targets build settings if the pods library only contains categories.

### Example Usage

Read a PDF from a file:

    MTPDF *pdf = [MTPDF PDFWithContentsOfFile:path];
    pdf.pages.count       // => 3
    pdf.isEncrypted       // => NO
    pdf.title             // => @"Forever Young"

Read a PDF from a URL:

    MTPDF *pdf = [MTPDF PDFWithContentsOfURL:url];

Create a PDF from data:

    MTPDF *pdf = [MTPDF PDFWithData:data];

Modify A PDF:

    MTPDF *pdf = [MTPDF PDFWithContentsOfURL:url];
    pdf.title   = @"New Title";
    pdf.author  = @"New Author";
    pdf.creator = @"New Creator";
    pdf.subject = @"New Subject";

Write PDF to file:

    [pdf writeToFile:file];

Iterate through pages:

    for (MTPDFPage *page in pdf.pages) {
      page.size     // => (500, 600)
    }

Draw a page in a view:

    MTPDFPage *page = pdf.pages[0];
    [page drawInContext:UIGraphicsGetCurrentContext()];

Export a page as an UIImage:

    UIImage *img = [page imageWithPixelsPerPoint:4];

This allows you to export the PDF at whatever resolution you need. Keep in mind, whatever the pixels per point is, the 
width and height will grow by that factor from the original size.