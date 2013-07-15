#import "UIImage+JpegPackImage.h"

#include <libturbojpeg/jpeglib.h>

#include <sys/mman.h>

//1. TODO - Move to separate library

//based on example: https://code.google.com/p/sumatrapdf/source/browse/trunk/ext/libjpeg-turbo/example.c?r=2397

/*
 * Sample routine for JPEG compression.  We assume that the target file name
 * and a compression quality factor are passed in.
 */

typedef struct
{
    const char *filename;
    int quality;
    JSAMPLE * imageBuffer;
    int imageWidth;
    int imageHeight;
    int bytesPerRow;
    J_COLOR_SPACE colorSpace;
    NSUInteger inputComponents;
    
} JpegCompressInfoArg;

LOCAL(void)
write_JPEG_file(JpegCompressInfoArg *args)
{
    /* This struct contains the JPEG compression parameters and pointers to
     * working space (which is allocated as needed by the JPEG library).
     * It is possible to have several such structures, representing multiple
     * compression/decompression processes, in existence at once.  We refer
     * to any one struct (and its associated working data) as a "JPEG object".
     */
    struct jpeg_compress_struct cinfo;
    /* This struct represents a JPEG error handler.  It is declared separately
     * because applications often want to supply a specialized error handler
     * (see the second half of this file for an example).  But here we just
     * take the easy way out and use the standard error handler, which will
     * print a message on stderr and call exit() if compression fails.
     * Note that this struct must live as long as the main JPEG parameter
     * struct, to avoid dangling-pointer problems.
     */
    struct jpeg_error_mgr jerr;
    /* More stuff */
    FILE * outfile;               /* target file */
    JSAMPROW row_pointer[1];      /* pointer to JSAMPLE row[s] */
    int row_stride;               /* physical row width in image buffer */
    
    /* Step 1: allocate and initialize JPEG compression object */
    
    /* We have to set up the error handler first, in case the initialization
     * step fails.  (Unlikely, but it could happen if you are out of memory.)
     * This routine fills in the contents of struct jerr, and returns jerr's
     * address which we place into the link field in cinfo.
     */
    cinfo.err = jpeg_std_error(&jerr);
    /* Now we can initialize the JPEG compression object. */
    jpeg_create_compress(&cinfo);
    
    /* Step 2: specify data destination (eg, a file) */
    /* Note: steps 2 and 3 can be done in either order. */
    
    /* Here we use the library-supplied code to send compressed data to a
     * stdio stream.  You can also write your own code to do something else.
     * VERY IMPORTANT: use "b" option to fopen() if you are on a machine that
     * requires it in order to write binary files.
     */
    if ((outfile = fopen(args->filename, "wb")) == NULL) {
        fprintf(stderr, "can't open %s\n", args->filename);
        exit(1);//TODO create outError when error
    }
    jpeg_stdio_dest(&cinfo, outfile);
    
    /* Step 3: set parameters for compression */
    
    /* First we supply a description of the input image.
     * Four fields of the cinfo struct must be filled in:
     */
    cinfo.image_width  = args->imageWidth;      /* image width and height, in pixels */
    cinfo.image_height = args->imageHeight;
    cinfo.input_components = args->inputComponents;  /* # of color components per pixel */
    cinfo.in_color_space   = args->colorSpace;       /* colorspace of input image */
    /* Now use the library's routine to set default compression parameters.
     * (You must set at least cinfo.in_color_space before calling this,
     * since the defaults depend on the source color space.)
     */
    jpeg_set_defaults(&cinfo);
    /* Now you can set any non-default parameters you wish to.
     * Here we just illustrate the use of quality (quantization table) scaling:
     */
    jpeg_set_quality(&cinfo, args->quality, TRUE /* limit to baseline-JPEG values */);
    
    /* Step 4: Start compressor */
    
    /* TRUE ensures that we will write a complete interchange-JPEG file.
     * Pass TRUE unless you are very sure of what you're doing.
     */
    jpeg_start_compress(&cinfo, TRUE);
    
    /* Step 5: while (scan lines remain to be written) */
    /*           jpeg_write_scanlines(...); */
    
    /* Here we use the library's state variable cinfo.next_scanline as the
     * loop counter, so that we don't have to keep track ourselves.
     * To keep things simple, we pass one scanline per call; you can pass
     * more if you wish, though.
     */
    row_stride = args->bytesPerRow; /* JSAMPLEs per row in image_buffer */
    
    while (cinfo.next_scanline < cinfo.image_height) {
        /* jpeg_write_scanlines expects an array of pointers to scanlines.
         * Here the array is only one element long, but you could pass
         * more than one scanline at a time if that's more convenient.
         */
        row_pointer[0] = & args->imageBuffer[cinfo.next_scanline * row_stride];
        (void) jpeg_write_scanlines(&cinfo, row_pointer, 1);
    }
    
    /* Step 6: Finish compression */
    
    jpeg_finish_compress(&cinfo);
    /* After finish_compress, we can close the output file. */
    fclose(outfile);
    
    /* Step 7: release JPEG compression object */
    
    /* This is an important step since it will release a good deal of memory. */
    jpeg_destroy_compress(&cinfo);
    
    /* And we're done! */
}

static inline J_COLOR_SPACE glibColorspace(CGImageRef imageRef,
                                           CGColorSpaceRef colorSpace,
                                           NSUInteger *numberOfComponents)
{
    CGColorSpaceModel model = CGColorSpaceGetModel(colorSpace);
    
    assert(model == kCGColorSpaceModelRGB);
    
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
    
#ifdef DEBUG
    {
        static CGImageAlphaInfo supportedAlphaInfo[] =
        {
            kCGImageAlphaPremultipliedLast,
            kCGImageAlphaPremultipliedFirst,
            kCGImageAlphaNoneSkipLast,
            kCGImageAlphaNoneSkipFirst,
        };
        
        const size_t size = sizeof(supportedAlphaInfo)/sizeof(supportedAlphaInfo[0]);
        size_t index = 0;
        
        for (; index < size; ++index) {
            
            if (supportedAlphaInfo[index] == alphaInfo)
                break;
        }
        assert(index != size && "unsupported alpha type");
    }
#endif //DEBUG
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    BOOL isLittle = (bitmapInfo & kCGBitmapByteOrder16Little) || (bitmapInfo & kCGBitmapByteOrder32Little);
    BOOL isBig    = (bitmapInfo & kCGBitmapByteOrder16Big   ) || (bitmapInfo & kCGBitmapByteOrder32Big   );
    BOOL reverseOrder = (isLittle || isBig);
    
    //table -          alpha             | order   | result
    //        kCGImageAlphaPremultipliedLast  | normal  | RGBA
    //        kCGImageAlphaPremultipliedLast  | reverse | ABGR
    //        kCGImageAlphaPremultipliedFirst | normal  | ARGB
    //        kCGImageAlphaPremultipliedFirst | reverse | BGRA
    //        kCGImageAlphaNoneSkipLast       | normal  | RGBX
    //        kCGImageAlphaNoneSkipLast       | reverse | XBGR
    //        kCGImageAlphaNoneSkipFirst      | normal  | XRGB
    //        kCGImageAlphaNoneSkipFirst      | reverse | BGRX
    
    static J_COLOR_SPACE alphaInfoToJCS[][2] =
    {
        //normal | reverse
        {JCS_UNKNOWN , JCS_UNKNOWN },//- kCGImageAlphaNone
        {JCS_EXT_RGBA, JCS_EXT_ABGR},//+ kCGImageAlphaPremultipliedLast
        {JCS_EXT_ARGB, JCS_EXT_BGRA},//+ kCGImageAlphaPremultipliedFirst
        {JCS_UNKNOWN , JCS_UNKNOWN },//- kCGImageAlphaLast
        {JCS_UNKNOWN , JCS_UNKNOWN },//- kCGImageAlphaFirst
        {JCS_EXT_RGBX, JCS_EXT_XBGR},//+ kCGImageAlphaNoneSkipLast
        {JCS_EXT_XRGB, JCS_EXT_BGRX},//+ kCGImageAlphaNoneSkipFirst
        {JCS_UNKNOWN , JCS_UNKNOWN },//- kCGImageAlphaOnly
    };
    
    J_COLOR_SPACE result = alphaInfoToJCS[alphaInfo][reverseOrder?1:0];
    
    assert(result != JCS_UNKNOWN && "unsupported colorspace -> todo implement");
    
    *numberOfComponents = 4;
    
    return result;
}

static NSString *filePathToRGBAImage(CGImageRef imageRef,
                                     size_t *rawDataLength,
                                     void **rawData)
{
    size_t width  = CGImageGetWidth (imageRef);
    size_t height = CGImageGetHeight(imageRef);
    
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    
    *rawDataLength = bytesPerRow*CGImageGetHeight(imageRef);
    
    NSString *filePath = [NSString createUuid];
    filePath = [NSString cachesPathByAppendingPathComponent:filePath];
    const char *filePathPtr = [filePath cStringUsingEncoding:NSUTF8StringEncoding];
    
    FILE *file = fopen(filePathPtr, "w+");
    
    if (file == NULL) {
        
        printf("Error opening file %s!\n\n" , filePathPtr);
        exit(1);
        return nil;
    }
    
    fseek(file, (*rawDataLength)-1, SEEK_SET);
    fprintf(file, "%c", 0x00);
    fseek(file, 0, SEEK_SET);
    
    int fd = fileno(file);
    *rawData = mmap(NULL, (*rawDataLength), PROT_WRITE, MAP_SHARED, fd, 0);
    
    if (*rawData == MAP_FAILED) {
        
        int code = errno;
        printf("Error opening mmap file %i!\n\n" , code);
        fclose(file);
        exit(1);
        return nil;
    }
    
    fclose(file);
    
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    
    CGColorSpaceRef colorspace = CGImageGetColorSpace(imageRef);
    
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    CGContextRef contextRef = CGBitmapContextCreate(*rawData,
                                                    width,
                                                    height,
                                                    bitsPerComponent,
                                                    bytesPerRow,
                                                    colorspace,
                                                    bitmapInfo);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, width, height), imageRef);
    
    CGContextRelease(contextRef);
    
    return filePath;
}

static void UIImageJPEGRepresentationFilePath(UIImage *image, CGFloat compressionQuality, NSString *resultFilePath)
{
    JpegCompressInfoArg args;
    
    args.filename = [resultFilePath cStringUsingEncoding:NSUTF8StringEncoding];
    
    CGImageRef imageRef = image.CGImage;
    
    args.imageWidth  = CGImageGetWidth (imageRef);
    args.imageHeight = CGImageGetHeight(imageRef);
    
    NSString *bitmapFile;
    void *rawData;
    size_t rawDataLength;
    {
        bitmapFile = filePathToRGBAImage(imageRef, &rawDataLength, &rawData);
        args.imageBuffer = (JSAMPLE *)rawData;
    }
    
    CGColorSpaceRef colorSpaceRef = CGImageGetColorSpace(imageRef);
    
    args.colorSpace = glibColorspace(imageRef, colorSpaceRef, &args.inputComponents);
    
    args.quality     = (int)compressionQuality*100.f;
    args.bytesPerRow = CGImageGetBytesPerRow(imageRef);
    
    write_JPEG_file(&args);
    
    [[NSFileManager defaultManager] removeItemAtPath:bitmapFile error:NULL];
    munmap(rawData, rawDataLength);
}

@implementation UIImage (JpegPackImage)

- (void)jffJpegPackImageToDataFilePath:(NSString *)filePath
                           compression:(CGFloat)compression
{
    UIImageJPEGRepresentationFilePath(self, compression, filePath);
}

@end
