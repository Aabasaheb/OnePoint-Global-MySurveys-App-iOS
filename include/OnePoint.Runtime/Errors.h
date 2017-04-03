//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/chinthan/Framework/Logger/ConvertCode/OnePoint/Runtime/Expressions/Parser/Errors.java
//
//  Created by chinthan on 1/15/14.
//

#ifndef _Errors_H_
#define _Errors_H_

#import "ErrorList.h"

@interface Errors : NSMutableArray {
 @public
  int count_;
  ErrorList *errorList_;
}

- (ErrorList *)getErrorList;
- (void)synErrWithInt:(int)line
              withInt:(int)col
              withInt:(int)n;
- (void)semErrWithInt:(int)line
              withInt:(int)col
         withNSString:(NSString *)s;
- (void)semErrWithInt:(int)line
              withInt:(int)col
         withNSString:(NSString *)s
         withNSString:(NSString *)fileName;
- (void)semErrWithNSString:(NSString *)s;
- (void)warningWithInt:(int)line
               withInt:(int)col
          withNSString:(NSString *)s;
- (void)warningWithInt:(int)line
               withInt:(int)col
          withNSString:(NSString *)s
          withNSString:(NSString *)fileName;
- (void)warningWithNSString:(NSString *)s;
- (id)init;
@end


#endif // _Errors_H_