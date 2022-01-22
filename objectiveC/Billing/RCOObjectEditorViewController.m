//
//  RCOObjectEditorViewController.m
//  MobileOffice
//
//  Created by .R.H. on 11/18/11.
//  Copyright (c) 2011 RCO All rights reserved.
//

#import "DataRepository.h"

#import "RCOObjectEditorViewController.h"
#import "RCOObject+RCOObject_Imp.h"
#import "UIColor+TKCategory.h"

@implementation RCOObjectEditorViewController

@synthesize obj=m_obj;
@synthesize objDict=m_objDict;
@synthesize linkedControls=m_linkedControls;
@synthesize isEditingObject=m_isEditingObject;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_linkedControls = [[NSMutableDictionary alloc] init ];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    NSLog(@"didReceiveMemoryWarning: %@-%@", self.class, self);
    //[aggregate unRegisterForCallback:self];
    
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    if (self.fieldEditingDelegate == nil) {
        self.fieldEditingDelegate = self;
    } else {
        //we have set the delegate already
    }
    self.obj=nil;
    self.objDict=nil;
    
    self.isEditingObject = false;
    
    [super viewDidLoad];
    [self.bottomToolbar setBarTintColor:[UIColor toolBarColor]];
}

- (void)viewDidUnload
{
    self.obj = nil;
    self.objDict = nil;
    self.linkedControls = nil;
    
    // overlay array for each object:
    // RCO_OBJECT_KEY: this contains class, id, etc, it's a pointer to the actual object
    // RCO_CONTENT_KEY: content: image file
    // other keys contain edited information
    // asking for a key returns the information from the edit set if it exists, otherwise from the object
    // setting a key sets the edit object.
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void) dealloc
{
    if ([self.alertView isVisible]) {
        [self.alertView dismissWithClickedButtonIndex:0 animated:NO];
    }
}

#pragma mark - Field Editor Delegate

// update the dictionary AND the linked controls
- (void) setObjectValue:  (NSObject *) theValue forKey: (NSString *) theKey
{
    [self.objDict setValue:theValue forKey:theKey];
    
    // propagate to linked controls
    [self refreshedLinkedControl: theKey];
    
    if( [theKey hasSuffix:KEY_CONTENT] )
    {
        RCOObject *theObj = [self getObjFromKey:theKey];
        
        NSURL * fp = [[theObj aggregate] getFilePathForObjectImage:theObj.rcoObjectId size: @"-1"];
        
        NSError *deleteError;
        [[NSFileManager defaultManager] removeItemAtURL:fp error:&deleteError];
        
        NSLog(@" Deleting content: %@ %@", theObj.rcoObjectId, fp);
    }
}

- (void) setObjectValue:  (NSObject *) theValue forKey: (NSString *) theKey fromControl:(UIControl *)aControl
{
    [self.objDict setValue:theValue forKey:theKey];
    
    // propagate to linked controls
    UITextField * tf =  (UITextField *)[self.linkedControls objectForKey:theKey];
    if (aControl != tf)
    {
        [self refreshedLinkedControl: theKey];
    } /*else {
        if ([theKey hasSuffix:@"*quantity"]) {
            [self refreshedLinkedControl: theKey];
        }
        
    }
       */
}


#pragma mark - Object editing

- (void) setObj:(RCOObject *)anObj
{
    [self setObj:anObj withDetails:true];
}

- (void) setObj:(RCOObject *)anObj withDetails: (Boolean) includeDetails
{
    m_obj = anObj;
    
    // a leak?
    self.objDict=nil;
    
    // now initialize the dictionary and the controls
    self.objDict = [[NSMutableDictionary alloc] init];
    for (NSAttributeDescription *prop in anObj.entity.properties)
    {
        [self setObjectValue:[anObj valueForKey:prop.name] forKey:prop.name];
        //NSLog(@"%@, %@", prop.name, [anObj valueForKey:prop.name]);
    }
    
    // and add details
    if( anObj != nil && includeDetails )
    {
        NSArray *details = [self.aggregate getObjectDetails:anObj.rcoObjectId];
        for (RCOObject *detail in details )
        {
            [self setDetailObj: detail];
        }
    }
    
    
    [self updateLinkedControlsEditingEnabledState: self.isEditingObject];
}

- (RCOObject *) getObjFromKey: (NSString *) theKey
{
    RCOObject *theObj=nil;
    NSString *propName;
    NSArray *comps = [theKey componentsSeparatedByString:@"*"];
    if( [comps count] > 1 )
    {
        NSString *objClass = [comps objectAtIndex:0];
        NSString *objId = [comps objectAtIndex:1];
        propName = [comps objectAtIndex:2];
        theObj = [self.aggregate getObjectDetailWithId: objId andClass: objClass];
    }
    else
    {
        propName = theKey;
        theObj = self.obj;
    }
    return theObj;
}

- (void) startObjectEditing
{
    self.isEditingObject = true;
    [self updateLinkedControlsEditingEnabledState: self.isEditingObject];
}

-(NSString*)getObjectIdFromKey:(NSString*)key {
    
    NSArray *comps = [key componentsSeparatedByString:@"*"];
    NSString *objId = nil;
    if( [comps count] > 1 ) {
        objId = [comps objectAtIndex:1];
    }
    return objId;
}

- (Boolean) saveObjectEdits
{
    Boolean isDirty = false;
    Boolean bUploaded = true;
    
    // save values out from dictionary
    NSArray *theKeys = [self.objDict allKeys];
    //NSLog(@"saveObjectEdits %@", self.objDict);
    
    // we have aproblem when loading items, we are query too many times the DB
    NSMutableDictionary *detailsTmp = [NSMutableDictionary dictionary];
    
    for (NSString *aKey in theKeys)
    {   
        NSString *objectId = [self getObjectIdFromKey:aKey];
        
        RCOObject *theObj = nil;
        if ([objectId length]) {
            theObj = [detailsTmp objectForKey:objectId];
        }
        
        if (!theObj) {
            theObj = [self getObjFromKey:aKey];
        }         
        if (theObj) {
            // we should use a local caching, there is no point in query the same object multiple times, for each property
            [detailsTmp setObject:theObj forKey:theObj.rcoObjectId];
        }
        
        NSString *propName = aKey;
        NSArray *comps = [aKey componentsSeparatedByString:@"*"];
        
        if( [comps count] > 1) {
            if (comps.count > 2) {
                propName = [comps objectAtIndex:2];
            }
        }
            
        id theValue = [self.objDict valueForKey:aKey];
        
        SEL aSelector = NSSelectorFromString(propName);
        
        if( theObj == nil ) {
            NSString *rcoClass = nil;
            
            if (comps.count > 0) {
                rcoClass = [comps objectAtIndex:0];
                Aggregate * detailAggregate = [[DataRepository sharedInstance] getAggregateForClass:rcoClass];
                theObj = [detailAggregate createNewObject];
                
                if (comps.count > 1) {
                    theObj.rcoObjectId = [comps objectAtIndex:1];
                }
            }
        }
        
        if( [propName hasPrefix:@"rcoObject"] )
        {
            
        }
        else if( [theObj respondsToSelector:aSelector] )
        {
            if (! [theValue isEqual: [theObj valueForKey:propName]])
            {
                isDirty = true;
                NSLog(@"saveObjectEdits %@ %@ is dirty", aKey, theValue);
                NSError *anError=nil;
                if( [theObj validateValue:&theValue forKey:propName error:&anError] )
                {
                    /*
                    if ([[theObj valueForKey:propName] isKindOfClass:[theValue class]]) {
                        [theObj setValue:theValue forKey:propName];
                    } else {
                        */
                        [theObj setValue:theValue forKey:propName];
                    ///}
                    //NSLog(@"saveObjectEdits %@ %@", aKey, theValue);
                }
                else
                {
                    NSLog(@"Invalid data for %@: %@", aKey, [anError localizedDescription]);
                    NSArray* detailedErrors = [[anError userInfo] objectForKey:NSDetailedErrorsKey];
                    if(detailedErrors != nil && [detailedErrors count] > 0) 
                    {
                        for(NSError* detailedError in detailedErrors) 
                        {
                            NSLog(@"  DetailedError: %@", [detailedError userInfo]);
                        }
                    }
                    else {
                        NSLog(@"  %@", [anError userInfo]);
                    }
                }
            }
        }
        else if( [propName isEqualToString:KEY_CONTENT] )
        {
            for (Aggregate *detailAggregate in self.aggregate.detailAggregates)
            {
                if ([detailAggregate.rcoObjectClass isEqualToString:theObj.rcoObjectClass])
                {
                    //NSString * fp = [detailAggregate getFilePathForObjectImage:theObj.rcoObjectId size: @"-1"];
                    NSURL * url = [detailAggregate getFilePathForObjectImage:theObj.rcoObjectId size: kImageSizeForUpload];
                    NSString *fp = [url path];
                    BOOL isDir;
                    if( theValue == nil )
                    {
                        NSLog(@" Deleting content: %@ %@", theObj.rcoObjectId, fp);
                    }
                    else if( ![[NSFileManager defaultManager] fileExistsAtPath:fp isDirectory:&isDir] )
                    {
                        NSLog(@" Uploading content: %@ %@", theObj.rcoObjectId, fp);
                        [(NSData *) theValue writeToFile:fp atomically:YES];
                        if( [theObj existsOnServer] ) {
                            //[detailAggregate uploadObjectContent:theObj size:@"-1"];
                            [detailAggregate uploadObjectContent:theObj size:kImageSizeForUpload];
                        }
                    }
                }
            }
        }
    }
    
    // upload details to the server and save
    for (Aggregate *detailAggregate in self.aggregate.detailAggregates)
    {
        NSArray *details = [detailAggregate getObjectsWithParentId:self.obj.rcoObjectId];
        for (RCOObject *detail in details )
        {
            if( [detail needsDeleting] )
            {
                [detailAggregate destroyObj:detail];
            }
            else
            {
            }
        }
    }
    
    // upload obj to the server and save
        
    [self.aggregate save];
    bUploaded = [self.aggregate uploadObject:self.obj];
    [self endObjectEditing];

    return bUploaded;
}

- (void) cancelObjectEdits
{
    NSLog(@"RCOObjectEditor cancelObjectEdits");
    /*
    if ([super respondsToSelector:@selector(cancelObjectEdits)]) {
        [super cancelObjectEdits];
    }
    */
}

- (void) endObjectEditing
{
    self.isEditingObject = false;
    
    [self updateLinkedControlsEditingEnabledState: self.isEditingObject];
}

// have the editing fields changed?
- (Boolean) dirty
{
    if (self.obj == nil)
        return false;
    
    Boolean dirty=false;
    
    
    for (NSAttributeDescription *prop in self.obj.entity.properties){
        dirty = dirty || ![[self.objDict valueForKey:prop.name ] isEqual:[self.obj valueForKey:prop.name]];
        if (dirty)
            break;
    }
    
    return dirty;
}


#pragma mark - Detail editing
- (void) setDetailObj: (RCOObject *) detailObj
{
    for (NSAttributeDescription *prop in detailObj.entity.properties)
    {
        NSString *flatKey = [self buildKeyForDetailObj: detailObj andKey: prop.name];
        [self setObjectValue:[detailObj valueForKey:prop.name] forKey:flatKey];          
        //NSLog(@"%@, %@", flatKey, [detailObj valueForKey:prop.name]);
    }
}

- (void) removeDetailObj: (RCOObject *) detailObj
{
    for (NSAttributeDescription *prop in detailObj.entity.properties)
    {
        NSString *flatKey = [self buildKeyForDetailObj: detailObj andKey: prop.name];
        [self.objDict removeObjectForKey:flatKey];
    }
}

- (void) addDetail:(RCOObject *)detailObj
{
    [self setDetailObj:detailObj];
}

- (void) deleteDetail: (RCOObject *) detailObj
{
    NSString *theKey = [self buildKeyForDetailObj:detailObj andKey:RCOOBJECT_NEEDSDELETING];
    
    [self setObjectValue:[NSNumber numberWithBool:TRUE] forKey:theKey];
    
}

- (NSString *) buildKeyForDetailObj: (RCOObject *) theObj andKey: (NSString *) theKey
{
    return [NSString stringWithFormat:@"%@*%@*%@", theObj.rcoObjectClass, theObj.rcoObjectId, theKey];
}

- (NSString *) parseObjIdFromKey: (NSString *) theKey
{
    NSString *objId =nil;
    NSArray *comps = [theKey componentsSeparatedByString:@"*"];
    if( [comps count] > 1 )
    {
        objId = [comps objectAtIndex:1];
    }
    else
    {
        objId = [self.objDict valueForKey:@"rcoObjectId"];
    }
    
    return objId;

}

- (void) updateLinkedControlsEditingEnabledState: (Boolean) enabled
{
    for (NSString *aKey in [self.linkedControls allKeys])
    {
        UITextField* tf = [self.linkedControls objectForKey:aKey];
        if( [[tf class] isSubclassOfClass:[UITextField class]] )
        {
            NSSet *targets = [tf allTargets];
            if ([targets containsObject:self] )
            {
                tf.userInteractionEnabled = enabled;
                //NSLog(@"updateEditingEnabledState for %@ %@ %i", aKey, tf, enabled);
            }
        }
    }
    
}

// link a textfield to an object field for automatic updating
- (void) linkControl: (UIColor *) aControl toKey: (NSString *) theKey
{
    [self.linkedControls setObject:aControl forKey:theKey];
}

// linked textfield has changed: update object with new value
- (IBAction)textFieldChanged:(id)sender
{
    NSArray *array = [self.linkedControls allKeysForObject:sender];
    
    for (NSString *aKey in array)      
    {
        UITextField * tf = (UITextField *) sender;
        NSLog(@"textFieldChanged %@ %@", aKey, tf.text);
        NSObject *curVal = [self.objDict objectForKey:aKey];
        
        if( curVal==nil || [[curVal class] isSubclassOfClass:[NSString class]] )    
            [self setObjectValue:tf.text forKey:aKey fromControl:tf];
        else if( [[curVal class] isSubclassOfClass:[NSNumber class]] )
            [self setObjectValue:[NSNumber numberWithFloat: [tf.text floatValue]] forKey:aKey fromControl:tf];
                
    }    
}

// value in object dict has been set or changed: refresh display control
- (void) refreshedLinkedControl: (NSString *) theKey
{
    UITextField * tf =  (UITextField *)[self.linkedControls objectForKey:theKey];
    if ([[tf class] isSubclassOfClass: [UITextField class]])
    {
        NSString *theValue = [self.objDict valueForKey:theKey];
        if( [[theValue class] isSubclassOfClass:[NSString class]] )
        {
            if ([theValue isEqualToString:@"(null)"]) {
                [tf setText:@""];
            } else {
                [tf setText:theValue];
            }
        }
        else if (theValue == nil )
        {
            [tf setText:@""];
            
        }        
    }
}

#pragma mark - RCO Data Delegate
- (void) objectIdIsUpdated: (NSString *) localId toServerId: (NSString *) assignedId fromAggregate:(Aggregate *)fromAggregate
{
    // change the key if it's a detail obj
    /* Removing this functionality - 03282014
     NSArray *theKeys = [self.objDict allKeys];
    
    //NSLog(@"saveObjectEdits %@", self.objDict);
    for (NSString *aKey in theKeys)
    {
    }
     */
    
}

- (void) objectSyncComplete: (Aggregate *) fromAggregate
{
    
}
- (void) contentDownloadComplete:(NSString *) objectId fromAggregate: (Aggregate *) aggregate

{
    
}


- (void) objectsChanged: (Aggregate *) fromAggregate
{
    self.obj = nil;
}



@end
