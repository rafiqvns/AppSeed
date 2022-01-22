//
//  PSPDFDocument.h
//  PSPDFKit
//
//  Copyright 2011-2012 Peter Steinberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSPDFKitGlobal.h"
#import "PSPDFCache.h"

@class PSPDFDocumentSearcher, PSPDFOutlineParser, PSPDFPageInfo, PSPDFAnnotationParser, PSPDFViewController;

/// Represents a single, logical, pdf document. (one or many pdf files)
/// Can be overriden to support custom collections.
@interface PSPDFDocument : NSObject <NSCopying, NSCoding> {
    NSUInteger pageCount_;
}

/// @name Initialization

/// initialize empty PSPDFDocument 
+ (PSPDFDocument *)PDFDocument;

/// initialize PSPDFDocument with data
+ (PSPDFDocument *)PDFDocumentWithData:(NSData *)data;

/// initialize PSPDFDocument with distinct path and an array of files.
+ (PSPDFDocument *)PDFDocumentWithBaseUrl:(NSURL *)baseUrl files:(NSArray *)files;

/// initializes PSPDFDocument with a single file
+ (PSPDFDocument *)PDFDocumentWithUrl:(NSURL *)url;

- (id)init;
- (id)initWithData:(NSData *)data;
- (id)initWithUrl:(NSURL *)url;
- (id)initWithBaseUrl:(NSURL *)basePath files:(NSArray *)files;


/// @name File Access / Modification

/// appends a file to the current document. No PDF gets modified, just displayed together. Can be a name or partial path (full path if basePath is nil)
/// Note: As of PSPDFKit 1.9.7, adding the same file multiple times is allowed.
- (void)appendFile:(NSString *)file;

/// returns path for a single page (in case pages are split up). Page starts at 0.
/// Note: uses fileIndexForPage and URLForFileIndex internally. Override those instead of pathForPage.
- (NSURL *)pathForPage:(NSUInteger)page;

/// Returns position of the internal file array.
- (NSInteger)fileIndexForPage:(NSUInteger)page;

/// Returns the URL corresponding to the fileIndex
- (NSURL *)URLForFileIndex:(NSInteger)fileIndex;

/// return plain thumbnail path, if thumbnail already exists. override if you pre-provide thumbnails. Returns nil on default.
- (NSURL *)thumbnailPathForPage:(NSUInteger)page;

/// Returs a files array with the base path already added (if there is one)
- (NSArray *)filesWithBasePath;

/// common base path for pdf files. Set to nil to use absolute paths for files.
@property(nonatomic, strong) NSURL *basePath;

/// array of NSString pdf files. If basePath is set, this will be combined with the file name.
/// If basePath is not set, add the full path (as NSString) to the files.
/// Note: it's currently not possible to add the file multiple times, this will fail to display correctly.`
@property(nonatomic, copy) NSArray *files;

/// usually, you have one single file url representing the pdf. This is a shortcut setter for basePath* files. Overrides all current settings if set.
/// nil if the document was initialized with initWithData:
@property(nonatomic, strong) NSURL *fileUrl;

/// PDF data when initialized with initWithData: otherwise nil
@property(nonatomic, copy, readonly) NSData *data;

/// document title as shown in the controller
@property(nonatomic, copy) NSString *title;

/// For caching, provide a *UNIQUE* uid here. (Or clear cache after content changes for same uid. Appending content is no problem)
@property(nonatomic, copy) NSString *uid;


/// @name Page Info Data

/// return pdf page count
- (NSUInteger)pageCount;

/// return pdf page number. this may be different if a collection of pdfs is used a one big document. Page starts at 0.
- (NSUInteger)pageNumberForPage:(NSUInteger)page;

/// Returns YES of pageInfo for page is available
- (BOOL)hasPageInfoForPage:(NSUInteger)page;

/// cached rotation and aspect ratio data for specific page. Page starts at 0.
- (PSPDFPageInfo *)pageInfoForPage:(NSUInteger)page;

/// cached rotation and aspect ratio data for specific page. Page starts at 0.
/// You can override this if you need to manually change the rotation value of a page.
- (PSPDFPageInfo *)pageInfoForPage:(NSUInteger)page pageRef:(CGPDFPageRef)pageRef;

/// Makes a search beginning from page 0 for the nearest pageInfo. Does not calculate/block the thread.
- (PSPDFPageInfo *)nearestPageInfoForPage:(NSUInteger)page;

/// aspect ratio is automatically cached and analyzed per page. Page starts at 0.
/// maybe needs a pdf lock if not already cached.
- (CGRect)rectBoxForPage:(NSUInteger)page;

/// rotation for specified page. cached. Page starts at 0.
- (int)rotationForPage:(NSUInteger)page;

/// Scan the whole document and analyzes if the aspect ratio is equal or not.
/// If this returns 0 or a very small value, it's perfectly suitable for pageCurl.
/// Note: this might take a second on larger documents, as the page structure needs to be parsed.
- (CGFloat)aspectRatioVariance;


/// @name Caching

/// if you change internal properties (like file count), cache needs to be cleared. Forced clears *everything* and even if doc is currently displayed.
- (void)clearCacheForced:(BOOL)forced;

/// shortcut to clearCacheForced:NO
- (void)clearCache;

/// creates internal cache for faster display. override to provide custom caching. usually called in a thread.
- (void)fillCache;


/// @name PDF Drawing

/// return true if you want drawOverlayRect to be called.
- (BOOL)shouldDrawOverlayRectForSize:(PSPDFSize)size;

/// can be overridden to draw an overlay on the pdf - will be called from drawing threads.
/// Note: most of the time you might be better off using custom UIViews and adding them on PSPDFPageView via the delegates.
- (void)drawOverlayRect:(CGRect)rect inContext:(CGContextRef)context forPage:(NSUInteger)page zoomScale:(CGFloat)zoomScale size:(PSPDFSize)size;


/// @name PDF Search

/// defaults to nil. can be overridden to provide custom text.
/// if this returns nil for a site, we'll try to extract text ourselves.
/// Note: If you return text here, text highlighting cannot be used for this page.
- (NSString *)pageContentForPage:(NSUInteger)page;


/// @name Design and hints for PSPDFViewController

/// override if you want custom *page* background colors. Only displayed while loading, and when no thumbnail is yet available. Defaults to white.
- (UIColor *)backgroundColorForPage:(NSUInteger)page;

/// if aspect ratio is equal on all pages, you can enable this for even better performance. Defaults to NO.
@property(nonatomic, assign, getter=isAspectRatioEqual) BOOL aspectRatioEqual;

/// annotation link extraction. Defaults to YES.
@property(nonatomic, assign, getter=isAnnotationsEnabled) BOOL annotationsEnabled;

/// enables two-step rendering. First use cache image, then re-render original pdf. Slightly improves text quality in landscape mode,
/// or when displayed embedded. Two-Step rendering is slower. Defaults to NO.
/// This might be a good idea to turn on when using JPG for caching.
@property(nonatomic, assign, getter=isTwoStepRenderingEnabled) BOOL twoStepRenderingEnabled;

/// if document is displayed, returns currently active pdfController. Don't set this yourself. Optimizes caching. 
// note: doesn't use weak as this could lead to background deallocation of the controller.
@property(nonatomic, unsafe_unretained) PSPDFViewController *displayingPdfController;

/// Text extraction class for current document.
@property(nonatomic, strong) PSPDFDocumentSearcher *documentSearcher;


/// @name Password Protection and Security

/// Passes a password to unlock encrypted documents.
/// If the password is correct, this method returns YES. Once unlocked, you cannot use this function to relock the document.
/// If you attempt to unlock an already unlocked document, one of the following occurs:
/// If the document is unlocked with full owner permissions, unlockWithPassword: does nothing and returns YES. The password string is ignored.
/// If the document is unlocked with only user permissions, unlockWithPassword attempts to obtain full owner permissions with the password
/// string. If the string fails, the document maintains its user permissions. In either case, this method returns YES.
- (BOOL)unlockWithPassword:(NSString*)password;

/// set a base password to be used for all files in this document (if the document is PDF encrypted).
@property(nonatomic, copy) NSString* password;

/// Returns YES if the document is valid (if it has at least one page)
@property(nonatomic, assign, readonly, getter=isValid) BOOL valid;

/// Do the PDF digital right allow for printing?
@property(nonatomic, assign, readonly) BOOL allowsPrinting;

/// Was the PDF file encryted at file creation time?
@property(nonatomic, assign, readonly) BOOL isEncrypted;

/// Has the PDF file been unlocked? (is it still locked?).
@property(nonatomic, assign, readonly) BOOL isLocked;


/// @name Attached Parser for Outline, Annotations

/// Outline extraction class for current document.
@property(nonatomic, strong) PSPDFOutlineParser *outlineParser;

/// Link annotation parser class for current document.
/// Can be overridden to use a subclassed annotation parser.
@property(nonatomic, strong) PSPDFAnnotationParser *annotationParser;

/// Page labels (NSString) for the current document.
@property(nonatomic, readonly) NSArray *pageLabels;

@end
