//
//  TrainingEquipment+CoreDataClass.m
//  CSD
//
//  Created by .D. .D. on 11/4/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import "TrainingEquipment+CoreDataClass.h"
#import "Settings.h"
#import "DataRepository.h"

@implementation TrainingEquipment
-(NSString*)CSVFormat {
    NSMutableArray *result = [NSMutableArray array];
    
    if ([self existsOnServer]) {
        [result addObject:@"U"];
        [result addObject:@"H"];
        [result addObject:self.rcoObjectId];
        [result addObject:self.rcoObjectType];
    } else {
        [result addObject:@"O"];
        [result addObject:@"H"];
        [result addObject:@""];
        [result addObject:@""];
    }
    
    //5 MobileRecordId
    [result addObject:[self getUploadCodingFieldFomValue:self.rcoMobileRecordId]];
    
    //6 functionalGroupName
    [result addObject:@""];
    
    NSString *organizationName = [Settings getSetting:CLIENT_ORGANIZATION_NAME];
    NSString *organizationId = [Settings getSetting:CLIENT_ORGANIZATION_ID];
    
    // 7 organisation name
    [result addObject:organizationName];
    
    //8 organisation number
    [result addObject:organizationId];
    
    //9 Date
    if (self.dateTime) {
        [result addObject:[self rcoDateTimeString:self.dateTime]];
    } else {
        [result addObject:@""];
    }
    
    //16 Company
    [result addObject:[self getUploadCodingFieldFomValue:self.company]];

    // 11 Student first name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentFirstName]];

    //12 Student Last name
    [result addObject:[self getUploadCodingFieldFomValue:self.studentLastName]];

    //13 Student driver license number
    [result addObject:[self getUploadCodingFieldFomValue:self.studentDriverLicenseNumber]];
    
    //14 student driver license state
    [result addObject:[self getUploadCodingFieldFomValue:self.studentDriverLicenseState]];

    //15 Instructor first name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorFirstName]];

    //16 instructor last name
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorLastName]];
    
    //17 instructor employee id
    [result addObject:[self getUploadCodingFieldFomValue:self.instructorEmployeeId]];
    
    //18 vehicleTransmissionType
    [result addObject:[self getUploadCodingFieldFomValue:self.transmissionType]];
    
    //19 vehicleTransmissionTypeOther
    [result addObject:[self getUploadCodingFieldFomValue:self.transmissionTypeOther]];

    //20 vehicleType
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleType]];

    //21 vehicleTypeOther
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleTypeOther]];

    //22 vehicleManufacturer
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleManufacturer]];

    //23 vehicleManufacturerOther
    [result addObject:[self getUploadCodingFieldFomValue:self.vehicleManufacturerOther]];

    //24 singleTrailerLength
    [result addObject:[self getUploadCodingFieldFomValue:self.singleTrailerLength]];

    //25 singleTrailerLengthOther
    [result addObject:[self getUploadCodingFieldFomValue:self.singleTrailerLengthOther]];

    //26 lvc
    [result addObject:[self getUploadCodingFieldFomValue:self.lVCType]];

    //27 lvcLenght
    [result addObject:[self getUploadCodingFieldFomValue:self.lVCLength]];

    //28 lvcOther
    [result addObject:[self getUploadCodingFieldFomValue:self.lVCTypeOther]];
    
    //29 lvcLenghtOther
    [result addObject:[self getUploadCodingFieldFomValue:self.lVCLengthOther]];

    //30 dollyGearType
    [result addObject:[self getUploadCodingFieldFomValue:self.dollyGearType]];

    //31 dollyGearTypeOther
    [result addObject:[self getUploadCodingFieldFomValue:self.dollyGearTypeOther]];

    //32 powerUnit
    [result addObject:[self getUploadCodingFieldFomValue:self.powerUnit]];
    
    //33 Trailer 1 number
    [result addObject:[self getUploadCodingFieldFomValue:self.trailer1Number]];
    
    //34 Trailer 2 number
    [result addObject:[self getUploadCodingFieldFomValue:self.trailer2Number]];

    //35 Trailer 3 number
    [result addObject:[self getUploadCodingFieldFomValue:self.trailer3Number]];

    //36 dolly 1 number
    [result addObject:[self getUploadCodingFieldFomValue:self.dolly1Number]];
    
    //37 Dolly 2 number
    [result addObject:[self getUploadCodingFieldFomValue:self.dolly2Number]];

    //38 Parent mobile record id
    [result addObject:[self getUploadCodingFieldFomValue:self.parentMobileRecordId]];

    NSString *res = [result componentsJoinedByString:@"\",\""];
    res = [NSString stringWithFormat:@"\"%@\"", res];
    
    return res;
}

-(NSString*)Trailer {
    // this is used for loading info in the HTML
    NSMutableArray *arr = [NSMutableArray array];
    if (self.powerUnit.length) {
        [arr addObject:[NSString stringWithFormat:@"%@", self.powerUnit]];
    }
    if (self.trailer1Number.length) {
        [arr addObject:self.trailer1Number];
    }
    if (self.dolly1Number.length) {
        [arr addObject:self.dolly1Number];
    }
    if (self.trailer2Number.length) {
        [arr addObject:self.trailer2Number];
    }
    if (self.dolly2Number.length) {
        [arr addObject:self.dolly2Number];
    }
    if (self.trailer3Number.length) {
        [arr addObject:self.trailer3Number];
    }
    if (arr.count) {
        return [arr componentsJoinedByString:@","];
    }
    return @" ";
}

-(NSString*)trailerNumber {
    
    NSMutableArray *arr = [NSMutableArray array];
    if (self.powerUnit.length) {
        [arr addObject:[NSString stringWithFormat:@"%@", self.powerUnit]];
    }
    if (self.trailer1Number.length) {
        [arr addObject:self.trailer1Number];
    }
    if (self.dolly1Number.length) {
        [arr addObject:self.dolly1Number];
    }
    if (self.trailer2Number.length) {
        [arr addObject:self.trailer2Number];
    }
    if (self.dolly2Number.length) {
        [arr addObject:self.dolly2Number];
    }
    if (self.trailer3Number.length) {
        [arr addObject:self.trailer3Number];
    }
    
    if (!arr.count) {
        // 17.12.2019 we should add the rest of the coding fiels
        if (self.transmissionType.length) {
            [arr addObject:self.transmissionType];
        }
        if (self.transmissionTypeOther.length) {
            [arr addObject:self.transmissionTypeOther];
        }
        if (self.vehicleType.length) {
            [arr addObject:self.vehicleType];
        }
        if (self.vehicleTypeOther.length) {
            [arr addObject:self.vehicleTypeOther];
        }
        if (self.vehicleManufacturer.length) {
            [arr addObject:self.vehicleManufacturer];
        }
        if (self.vehicleManufacturerOther.length) {
            [arr addObject:self.vehicleManufacturerOther];
        }
        if (self.singleTrailerLength.length) {
            [arr addObject:self.singleTrailerLength];
        }
        if (self.singleTrailerLengthOther.length) {
            [arr addObject:self.singleTrailerLengthOther];
        }
        if (self.lVCType.length) {
            [arr addObject:self.lVCType];
        }
        if (self.lVCTypeOther.length) {
            [arr addObject:self.lVCTypeOther];
        }
        if (self.lVCLength.length) {
            [arr addObject:self.lVCLength];
        }
        if (self.lVCLengthOther.length) {
            [arr addObject:self.lVCLengthOther];
        }
        if (self.dollyGearType.length) {
            [arr addObject:self.dollyGearType];
        }
        if (self.dollyGearTypeOther.length) {
            [arr addObject:self.dollyGearTypeOther];
        }
    }
    
    return [arr componentsJoinedByString:@","];
}

-(NSString*)TransmissionType {
    if (self.transmissionType.length) {
        return self.transmissionType;
    }
    if (self.transmissionTypeOther.length) {
        return self.transmissionTypeOther;
    }
    return nil;
}

-(NSString*)VehicleType {
    if (self.vehicleType.length) {
        return self.vehicleType;
    }
    if (self.vehicleTypeOther.length) {
        return self.vehicleTypeOther;
    }
    return nil;
}
-(NSString*)VehicleManufacturer {
    if (self.vehicleManufacturer.length) {
        return self.vehicleManufacturer;
    }
    if (self.vehicleManufacturerOther.length) {
        return self.vehicleManufacturerOther;
    }
    return nil;
}
-(NSString*)SingleTrailerLenght {
    if (self.singleTrailerLength.length) {
        return self.singleTrailerLength;
    }
    if (self.singleTrailerLengthOther.length) {
        return self.singleTrailerLengthOther;
    }
    return nil;
}
-(NSString*)LVC {
    if (self.lVCType.length) {
        return self.lVCType;
    }
    if (self.lVCTypeOther.length) {
        return self.lVCTypeOther;
    }
    return nil;
}

-(NSString*)LVCLength {
    if (self.lVCLength.length) {
        return self.lVCLength;
    }
    if (self.lVCLengthOther.length) {
        return self.lVCLengthOther;
    }
    return nil;
}
-(NSString*)DollyGearType {
    if (self.dollyGearType.length) {
        return self.dollyGearType;
    }
    if (self.dollyGearTypeOther.length) {
        return self.dollyGearTypeOther;
    }
    return nil;
}

@end

