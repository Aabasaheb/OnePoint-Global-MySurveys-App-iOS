
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/ashchauhan/Desktop/SampleApp/OnePoint/Runtime/Common/IOM/IStyle.java
//
//  Created by ashchauhan on 6/20/14.
//

//#ifndef _IStyle_H_
//#define _IStyle_H_

#import <Foundation/Foundation.h>
@protocol IAudioStyle;
@protocol ICellStyle;
@protocol IControlStyle;
@protocol IFontStyle;
@protocol IMediaStyle;
@protocol ISliderStyle;
#import "CursorTypes.h"
#import "ElementAlignments.h"
#import "ImagePositions.h"
#import "Orientations.h"
#import "Alignments.h"
#import "VerticalAlignments.h"


@protocol IStyle < NSObject>

- (id<IAudioStyle>)getAudio;
- (void)setAudio:(id<IAudioStyle>)value;
-(id<IMediaStyle>) getMedia ;
-(void)setMedia:(id<IMediaStyle>) value ;
- (id<ICellStyle>)getCell;
- (void)setCell:(id<ICellStyle>)value;
- (id<IControlStyle>)getControl;
- (void)setControl:(id<IControlStyle>)value;
- (id<IFontStyle>)getFont;
- (void)setFont:(id<IFontStyle>)value;
- (BOOL)getIsEmpty;
- (void)setIsEmpty:(BOOL)value;
- (id<IStyle>)getParent;
- (AlignmentsEnm )getAlign;
- (void)setAlign:(AlignmentsEnm)value;
- (NSString *)getBgcolor;
- (void)setBgcolor:(NSString *)value;
- (NSString *)getColor;
- (void)setColor:(NSString *)value;
- (long)getColumns;
- (void)setColumns:(long)value;
- (CursorTypes)getCursor;
- (void)setCursor:(CursorTypes)value;
- (ElementAlignments)getElementAlign;
- (void)setElementAlign:(ElementAlignments)value;
- (NSString *)getHeight;
- (void)setHeight:(NSString *)value;
- (BOOL)getHidden;
- (void)setHidden:(BOOL)value;
- (NSString *)getImage;
- (void)setImage:(NSString *)value;
- (ImagePositions)getImagePosition;
- (void)setImagePosition:(ImagePositions)value;
- (long)getIndent;
- (void)setIndent:(long)value;
- (Orientations)getOrientation;
- (void)setOrientation:(Orientations)value;
- (long)getRows;
- (void)setRows:(long)value;
- (BOOL)getUseCascadeStyles;
- (void)setUseCascadeStyles:(BOOL)value;
- (VerticalAlignmentsEnm)getVerticalAlign;
- (void)setVerticalAlign:(VerticalAlignmentsEnm)value;
- (NSString *)getWidth;
- (void)setWidth:(NSString *)value;
- (long)getZIndex;
- (void)setZIndex:(long)value;
- (void)copyTo:(id<IStyle>)destination;
- (void)copyTo:(id<IStyle>)destination withBoolean:(BOOL)allCasecadedStyles;
- (void)processProperties:(id)json;
-(id<ISliderStyle>) getSlider;
-(void)setSlider:(id<ISliderStyle>)value;
-(NSString*) getMask;
-(void)setMask:(NSString*) value;
-(NSString*)getPlaceholder;
-(void)setPlaceholder:(NSString*)value;
@end
