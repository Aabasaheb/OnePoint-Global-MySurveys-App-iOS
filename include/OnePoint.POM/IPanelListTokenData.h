// --------------------------------------------------------------------------------------------------------------------
// <copyright file="IPanelListToken" company="OnePoint Global">
//   Copyright (c) 2012 OnePoint Global Ltd. All rights reserved.
// </copyright>
// <summary>
//   This file was autogenerated and you should not edit it. It will be 
//   regenerated whenever the schema changes.
//   All changes should be made in PanelListToken.cs and the mode.xml. 
// </summary>
// --------------------------------------------------------------------------------------------------------------------


/// <summary>
/// The IPanelListToken Interface Data Object Base
/// </summary>
 
#import <Foundation/Foundation.h>   

/// <summary>
/// The IPanelListTokenData Interface Data Object Base
/// </summary>
@protocol IPanelListTokenData <NSObject>
    
-(NSNumber *) PanellistTokenID;
-(void) setPanellistTokenID:(NSNumber *) value;
-(NSNumber *) PanellistID;
-(void) setPanellistID:(NSNumber *) value;
-(NSString *) TokenTextSpecified;
-(void) setTokenTextSpecified:(NSString *) value;
-(NSDate *) CreatedDate;
-(void) setCreatedDate:(NSDate *) value;
-(NSDate *) LastUpdatedDate;
-(void) setLastUpdatedDate:(NSDate *) value;

@end
   

   
    
