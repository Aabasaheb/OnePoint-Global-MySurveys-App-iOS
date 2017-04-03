// --------------------------------------------------------------------------------------------------------------------
// <copyright file="ISamplePanellist" company="OnePoint Global">
//   Copyright (c) 2012 OnePoint Global Ltd. All rights reserved.
// </copyright>
// <summary>
//   This file was autogenerated and you should not edit it. It will be 
//   regenerated whenever the schema changes.
//   All changes should be made in SamplePanellist.cs and the mode.xml. 
// </summary>
// --------------------------------------------------------------------------------------------------------------------


/// <summary>
/// The ISamplePanellist Interface Data Object Base
/// </summary>

#import <Foundation/Foundation.h>


/// <summary>
/// The ISamplePanellistFactoryBase Interface Data Object Base
/// </summary>
	
@protocol ISamplePanellistFactoryBase <NSObject>
   
-(NSString *) SelectAllStatement;
-(NSString *)TableName;
-(NSString *)ByPkClause;
-(NSString *)InsertStatement;
-(NSString *)UpdateStatement;
-(NSString *)DeleteStatement;
-(NSString *)DeleteByPk;


-(void) AddSamplePanellistIDParameter:(DataHandler *) dataHandler withSamplePanellistID:(NSNumber*) SamplePanellistID;     
-(void) AddSampleIDParameter:(DataHandler *) dataHandler withSampleID:(NSNumber*) SampleID;     
-(void) AddPanellistIDParameter:(DataHandler *) dataHandler withPanellistID:(NSNumber*) PanellistID;     
-(void) AddPanelIDParameter:(DataHandler *) dataHandler withPanelID:(NSNumber*) PanelID;     
-(void) AddExcludedParameter:(DataHandler *) dataHandler withExcluded:(NSNumber*) Excluded;     
-(void) AddIsDeletedParameter:(DataHandler *) dataHandler withIsDeleted:(NSNumber*) IsDeleted;     
-(void) AddCreatedDateParameter:(DataHandler *) dataHandler withCreatedDate:(NSDate *) CreatedDate; 
-(void) AddLastUpdatedDateParameter:(DataHandler *) dataHandler withLastUpdatedDate:(NSDate *) LastUpdatedDate; 
-(id<ISamplePanellistData>) FindBySamplePanellistID:(NSNumber *) fieldValue;
        
-(id<ISamplePanellistData>) FindBySampleID:(NSNumber *) fieldValue;
        
-(id<ISamplePanellistData>) FindByPanellistID:(NSNumber *) fieldValue;
        
-(id<ISamplePanellistData>) FindByPanelID:(NSNumber *) fieldValue;
        
-(id<ISamplePanellistData>) FindByExcluded:(NSNumber *) fieldValue;
        
-(id<ISamplePanellistData>) FindByIsDeleted:(NSNumber *) fieldValue;
        
-(id<ISamplePanellistData>) FindByCreatedDate:(NSDate *) fieldValue;
        
-(id<ISamplePanellistData>) FindByLastUpdatedDate:(NSDate *) fieldValue;
        
-(id<ISamplePanellistData>) CreateSamplePanellist:(id<IDataReader>)reader;

@end
    

   
    
