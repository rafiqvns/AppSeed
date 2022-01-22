//
//  TestDataHeader+CoreDataClass.h
//  Quality
//
//  Created by .D. .D. on 1/28/19.
//  Copyright © 2019 RCO. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import "RCOObject.h"

#define TestSignatureDriver @"Signature Driver"
#define TestSignatureEvaluator @"Signature Evaluator"
#define TestSignatureCompanyRep @"Signature Company Rep"

#define TestBTW @"01"
#define TestPreTrip @"02"
#define TestBusEval @"03"
#define TestSWP @"04"
#define TestProd @"05"
#define TestVRT @"06"

#define TestValueYes @"5"
#define TestValueNo @"2"

#define KeySignatureDriver @"driverSignature"
#define KeySignatureEvaluator @"evaluatorSignature"
#define KeySignatureCompanyRepresentative @"compRepSignature"


NS_ASSUME_NONNULL_BEGIN

@interface TestDataHeader : RCOObject
-(NSString*)CSVFormat;
-(NSString*)employee;
-(NSString*)driverName;
-(NSString*)pointsPercentage;
-(BOOL)isPaused;
-(void)addPauseDateTime:(NSDate*)dateTime;
-(NSString*)calculateElaspsedTime;
-(NSDate*)getPauseDate;
-(NSString*)evaluationLocation;
+(NSString*)encodeText:(NSString*)text;
+(NSString*)decodeText:(NSString*)text;
@end

NS_ASSUME_NONNULL_END

#import "TestDataHeader+CoreDataProperties.h"
