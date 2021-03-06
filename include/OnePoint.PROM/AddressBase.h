// --------------------------------------------------------------------------------------------------------------------
// <copyright file="AddressBase.java" company="OnePoint Global">
//   Copyright (c) 2012 OnePoint Global Ltd. All rights reserved.
// </copyright>
// <summary>
//   This file was autogenerated and you should not edit it. It will be 
//   regenerated whenever the schema changes.
//   All changes should be made in Address.cs and the mode.xml. 
// </summary>
// --------------------------------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import <OnePointFramework/DataObject.h>
#import "IAddressData.h"



#import "IAddressListData.h";
#import "AddressListFactory.h";

//package OnePoint.PROM.Model 
    
	

    
@interface  AddressBase : DataObject<DataObject, IAddressData>
{
@private NSNumber *AddressID;
        
@private NSNumber *AddressListID;
        
@private NSNumber *SurveyID;
        
@private NSString *Address;
        
@private NSNumber *Latitude;
        
@private NSNumber *Longitude;
        
@private NSString *GeoCode;
        
@private NSString *Status;
        
@private NSNumber *IsDeleted;
        
@private NSString *UserDef1;
        
@private NSString *UserDef2;
        
@private NSString *UserDef3;
        
@private NSString *UserDef4;
        
@private NSString *UserDef5;
        
@private NSString *UserDef6;
        
@private NSString *UserDef7;
        
@private NSString *UserDef8;
        
@private NSString *UserDef9;
        
@private NSDate *CreatedDate;
        
@private NSDate *LastUpdatedDate;
        
@private id<IAddressListData> relAddressList; 
}


	  

	@property(nonatomic,retain) NSNumber *AddressID;

	
	@property(nonatomic,retain) NSNumber *AddressListID;

	
	@property(nonatomic,retain) NSNumber *SurveyID;

	
	@property(readwrite,strong) NSString *Address;

	
	@property(nonatomic,retain) NSNumber *Latitude;

	
	@property(nonatomic,retain) NSNumber *Longitude;

	
	@property(readwrite,strong) NSString *GeoCode;

	
	@property(readwrite,strong) NSString *Status;

	
	@property(nonatomic,retain) NSNumber *IsDeleted;

	
	@property(readwrite,strong) NSString *UserDef1;

	
	@property(readwrite,strong) NSString *UserDef2;

	
	@property(readwrite,strong) NSString *UserDef3;

	
	@property(readwrite,strong) NSString *UserDef4;

	
	@property(readwrite,strong) NSString *UserDef5;

	
	@property(readwrite,strong) NSString *UserDef6;

	
	@property(readwrite,strong) NSString *UserDef7;

	
	@property(readwrite,strong) NSString *UserDef8;

	
	@property(readwrite,strong) NSString *UserDef9;

	
	@property(readwrite,strong) NSDate *CreatedDate;

	
	@property(readwrite,strong) NSDate *LastUpdatedDate;

	@property(readwrite,strong) id<IAddressListData> RelAddressList; 
@end
         

    

    