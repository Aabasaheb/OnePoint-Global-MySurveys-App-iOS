// --------------------------------------------------------------------------------------------------------------------
// <copyright file="IPanellistProfileVariable" company="OnePoint Global">
//   Copyright (c) 2012 OnePoint Global Ltd. All rights reserved.
// </copyright>
// <summary>
//   This file was autogenerated and you should not edit it. It will be 
//   regenerated whenever the schema changes.
//   All changes should be made in PanellistProfileVariable.cs and the mode.xml. 
// </summary>
// --------------------------------------------------------------------------------------------------------------------


/// <summary>
/// The IPanellistProfileVariable Interface Data Object Base
/// </summary>
 
#import <Foundation/Foundation.h>   
#import	"IPanellistProfileVariableDataTypeData.h"
#import	"IPanelData.h"

/// <summary>
/// The IPanellistProfileVariableData Interface Data Object Base
/// </summary>
@protocol IPanellistProfileVariableData <NSObject>
    
-(NSNumber *) VariableID;
-(void) setVariableID:(NSNumber *) value;
-(NSString *) NameSpecified;
-(void) setNameSpecified:(NSString *) value;
-(NSNumber *) PanelID;
-(void) setPanelID:(NSNumber *) value;
-(NSNumber *) TypeID;
-(void) setTypeID:(NSNumber *) value;
-(NSNumber *) IsDeleted;
-(void) setIsDeleted:(NSNumber *) value;
-(NSNumber *) IsBasic;
-(void) setIsBasic:(NSNumber *) value;
-(NSDate *) CreatedDate;
-(void) setCreatedDate:(NSDate *) value;
-(NSDate *) LastUpdatedDate;
-(void) setLastUpdatedDate:(NSDate *) value;
-(id<IPanellistProfileVariableDataTypeData>) PanellistProfileVariableDataType;

-(id<IPanelData>) Panel;


@end
   

   
    
