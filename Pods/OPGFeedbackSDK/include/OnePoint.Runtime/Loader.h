//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/chinthan/Framework/Logger/ConvertCode/OnePoint/Runtime/RecordLibrary/RecordHelpers/Loader.java
//
//  Created by chinthan on 12/2/13.
//


@class RecordContext;

@interface Loader : NSObject {
 @public
  RecordContext *__Context_;
}

- (RecordContext *)getContext;
- (void)setContextWithRecordContext:(RecordContext *)value;
- (void)loadFromLongStringsWithByteArray:(NSData *)byteStream;
- (void)loadFromByteStreamWithByteArray:(NSData *)byteStream;
- (id)initWithByteArray:(NSData *)byteStream;
- (id)initWithByteArrays:(NSData *)byteStream withLongStrings:(NSData *)longStrings;
- (void)copyAllFieldsTo:(Loader *)other;
@end

