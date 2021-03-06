// --------------------------------------------------------------------------------------------------------------------
// <copyright file="model.cs" company="OnePoint Global">
//   Copyright (c) 2012 OnePoint Global Ltd. All rights reserved.
// </copyright>
// <summary>
//   This file was autogenerated and you should not edit it. It will be 
//   regenerated whenever the schema changes.
//   All changes should be made in PanellistProfileVariableResponse.cs and the mode.xml. 
// </summary>
// --------------------------------------------------------------------------------------------------------------------


#import <Foundation/Foundation.h>
#import <OnePointFramework/DataObjectFactory.h>
#import "IPanellistProfileVariableResponseData.h"
#import "IPanellistProfileVariableResponseFactoryBase.h"

//package OnePoint.POM.Model; 
  

/// <summary>
/// Creates and finds PanellistProfileVariableResponse objects
/// </summary>



@interface  PanellistProfileVariableResponseFactoryBase : DataObjectFactory<IPanellistProfileVariableResponseData,IPanellistProfileVariableResponseFactoryBase>
{
}

+(NSString*)  FIELD_NAME_PANELLISTPROFILEVARIABLERESPONSEID;
+(NSString*)  FIELD_NAME_PANELID;
+(NSString*)  FIELD_NAME_PANELLISTID;
+(NSString*)  FIELD_NAME_VARIABLEID;
+(NSString*)  FIELD_NAME_TYPEID;
+(NSString*)  FIELD_NAME_TEXTVAL;
+(NSString*)  FIELD_NAME_REALVAL;
+(NSString*)  FIELD_NAME_DATEVAL;
+(NSString*)  FIELD_NAME_OBJECTVAL;
+(NSString*)  FIELD_NAME_ISDELETED;
+(NSString*)  FIELD_NAME_CREATEDDATE;
+(NSString*)  FIELD_NAME_LASTUPDATEDDATE;
+(NSString*) PARAMETER_NAME_PANELLISTPROFILEVARIABLERESPONSEID;
+(NSString*) PARAMETER_NAME_PANELID;
+(NSString*) PARAMETER_NAME_PANELLISTID;
+(NSString*) PARAMETER_NAME_VARIABLEID;
+(NSString*) PARAMETER_NAME_TYPEID;
+(NSString*) PARAMETER_NAME_TEXTVAL;
+(NSString*) PARAMETER_NAME_REALVAL;
+(NSString*) PARAMETER_NAME_DATEVAL;
+(NSString*) PARAMETER_NAME_OBJECTVAL;
+(NSString*) PARAMETER_NAME_ISDELETED;
+(NSString*) PARAMETER_NAME_CREATEDDATE;
+(NSString*) PARAMETER_NAME_LASTUPDATEDDATE;

/// <summary>
/// The Microsoft SQL statement to join one table to another and perform it.
/// </summary>
-(BOOL) DeleteByPk :(NSNumber *) keyPanellistProfileVariableResponseID ;
//-(BOOL) DeleteByPk:(NSNumber *) keyPanellistProfileVariableResponseID;
// Define input parameters once only so they can be reused by other methods
-(void) AddPanellistProfileVariableResponseIDParameter:(DataHandler *) dataHandler valPanellistProfileVariableResponseID:(NSNumber *) valPanellistProfileVariableResponseID;	

-(void) AddPanelIDParameter:(DataHandler *) dataHandler valPanelID:(NSNumber *) valPanelID;	

-(void) AddPanellistIDParameter:(DataHandler *) dataHandler valPanellistID:(NSNumber *) valPanellistID;	

-(void) AddVariableIDParameter:(DataHandler *) dataHandler valVariableID:(NSNumber *) valVariableID;	

-(void) AddTypeIDParameter:(DataHandler *) dataHandler valTypeID:(NSNumber *) valTypeID;	

-(void) AddTextValParameter:(DataHandler *) dataHandler valTextVal:(NSString *) valTextVal;	

-(void) AddRealValParameter:(DataHandler *) dataHandler valRealVal:(NSNumber *) valRealVal;	

-(void) AddDateValParameter:(DataHandler *) dataHandler valDateVal: (NSDate *) valDateVal;	

-(void) AddObjectValParameter:(DataHandler *) dataHandler valObjectVal: (NSMutableData *) valObjectVal;	

-(void) AddIsDeletedParameter:(DataHandler *) dataHandler valIsDeleted:(NSNumber *) valIsDeleted;	

-(void) AddCreatedDateParameter:(DataHandler *) dataHandler valCreatedDate: (NSDate *) valCreatedDate;	

-(void) AddLastUpdatedDateParameter:(DataHandler *) dataHandler valLastUpdatedDate: (NSDate *) valLastUpdatedDate;	

-(BOOL) ProcessPkStatement :(NSNumber *) keyPanellistProfileVariableResponseID   query:(NSString *) query;
//-(BOOL) ProcessPkStatement:(NSNumber *) keyPanellistProfileVariableResponseID query:(NSString *) query;

-(id<IPanellistProfileVariableResponseData>) Find:(NSString *) attributeName attributeValue:(id) attributeValue;

-(id<IPanellistProfileVariableResponseData>) FindByPanellistProfileVariableResponseID:(NSNumber *) fieldValue;
-(id<IPanellistProfileVariableResponseData>) FindByPanelID:(NSNumber *) fieldValue;
-(id<IPanellistProfileVariableResponseData>) FindByPanellistID:(NSNumber *) fieldValue;
-(id<IPanellistProfileVariableResponseData>) FindByVariableID:(NSNumber *) fieldValue;
-(id<IPanellistProfileVariableResponseData>) FindByTypeID:(NSNumber *) fieldValue;
-(id<IPanellistProfileVariableResponseData>) FindByTextVal:(NSString *) fieldValue; 
-(id<IPanellistProfileVariableResponseData>) FindByRealVal:(NSNumber *) fieldValue;
-(id<IPanellistProfileVariableResponseData>) FindByDateVal:(NSDate *) fieldValue;  
-(id<IPanellistProfileVariableResponseData>) FindByObjectVal:(NSMutableData *) fieldValue; 
-(id<IPanellistProfileVariableResponseData>) FindByIsDeleted:(NSNumber *) fieldValue;
-(id<IPanellistProfileVariableResponseData>) FindByCreatedDate:(NSDate *) fieldValue;  
-(id<IPanellistProfileVariableResponseData>) FindByLastUpdatedDate:(NSDate *) fieldValue;  
-(void) AppendSqlParameters:(DataHandler *) dataHandler dataObject:(DataObject *)dataObject mode:(DataMode *) mode;      
-(id<IPanellistProfileVariableResponseData>) FindObject :(NSNumber *) keyPanellistProfileVariableResponseID ;
        
-(id<IPanellistProfileVariableResponseData>) Find:(DataHandler *) dataHandler;
        
-(id<IPanellistProfileVariableResponseData>) FindAllObjects;

-(id<IPanellistProfileVariableResponseData>) FindAllObjects:(NSString *) orderByField;

-(id<IPanellistProfileVariableResponseData>) FindAllObjects:(NSString *) orderByField resultLimit:(int)resultLimit;	

-(id<IPanellistProfileVariableResponseData>) CreatePanellistProfileVariableResponse:(id<IDataReader>) reader;
		
-(id<IPanellistProfileVariableResponseData>) createObjectFromDataReader:(id<IDataReader>) reader withPopulate:(BOOL)populateRelatedObject;

-(id<IPanellistProfileVariableResponseData>) Build:(DataHandler *) currentDataHandler closeConnection:(BOOL)closeConnection;
       
@end