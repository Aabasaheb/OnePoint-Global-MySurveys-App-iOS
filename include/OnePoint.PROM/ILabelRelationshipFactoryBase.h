// --------------------------------------------------------------------------------------------------------------------
// <copyright file="ILabelRelationship" company="OnePoint Global">
//   Copyright (c) 2012 OnePoint Global Ltd. All rights reserved.
// </copyright>
// <summary>
//   This file was autogenerated and you should not edit it. It will be 
//   regenerated whenever the schema changes.
//   All changes should be made in LabelRelationship.cs and the mode.xml. 
// </summary>
// --------------------------------------------------------------------------------------------------------------------


/// <summary>
/// The ILabelRelationship Interface Data Object Base
/// </summary>

#import <Foundation/Foundation.h>


/// <summary>
/// The ILabelRelationshipFactoryBase Interface Data Object Base
/// </summary>
	
@protocol ILabelRelationshipFactoryBase <NSObject>
   
-(NSString *) SelectAllStatement;
-(NSString *)TableName;
-(NSString *)ByPkClause;
-(NSString *)InsertStatement;
-(NSString *)UpdateStatement;
-(NSString *)DeleteStatement;
-(NSString *)DeleteByPk;


-(void) AddLabelRelationshipIDParameter:(DataHandler *) dataHandler withLabelRelationshipID:(NSNumber*) LabelRelationshipID;     
-(void) AddLabelIDParameter:(DataHandler *) dataHandler withLabelID:(NSNumber*) LabelID;     
-(void) AddIdentfierIDParameter:(DataHandler *) dataHandler withIdentfierID:(NSNumber*) IdentfierID;     
-(void) AddCreatedDateParameter:(DataHandler *) dataHandler withCreatedDate:(NSDate *) CreatedDate; 
-(void) AddLastUpdatedDateParameter:(DataHandler *) dataHandler withLastUpdatedDate:(NSDate *) LastUpdatedDate; 
-(id<ILabelRelationshipData>) FindByLabelRelationshipID:(NSNumber *) fieldValue;
        
-(id<ILabelRelationshipData>) FindByLabelID:(NSNumber *) fieldValue;
        
-(id<ILabelRelationshipData>) FindByIdentfierID:(NSNumber *) fieldValue;
        
-(id<ILabelRelationshipData>) FindByCreatedDate:(NSDate *) fieldValue;
        
-(id<ILabelRelationshipData>) FindByLastUpdatedDate:(NSDate *) fieldValue;
        
-(id<ILabelRelationshipData>) CreateLabelRelationship:(id<IDataReader>)reader;

@end
    

   
    

