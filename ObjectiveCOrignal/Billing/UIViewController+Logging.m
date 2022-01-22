//
//  UIViewController+Logging.m
//  MobileOffice
//
//  Created by .D. .D. on 12/2/14.
//  Copyright (c) 2014 RCO. All rights reserved.
//

#import "UIViewController+Logging.h"
#import "UIViewController+iOS6.h"
#import <MessageUI/MessageUI.h>

@implementation UIViewController (Logging)

-(void)log:(NSString*)stringToLog toFile:(NSString*)fileName {
    
    // Retrieves the document directories from the iOS device
    NSArray* documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    NSArray *pathComponents = [fileName componentsSeparatedByString:@"/"];
    
    NSString *documentDirectoryFilename = documentDirectory;
    NSString *documentFileName = [documentDirectory stringByAppendingPathComponent:fileName];
    
    if ([pathComponents count] > 1) {
        // add directories
        for (NSInteger i = 0; i < (pathComponents.count - 1); i++) {
            documentDirectoryFilename = [documentDirectoryFilename stringByAppendingPathComponent:[pathComponents objectAtIndex:i]];
        }
    }
    
    NSData *logData = [stringToLog dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:documentFileName]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentDirectoryFilename withIntermediateDirectories:YES attributes:nil error:&error];
    }

    if (error) {
        NSLog(@"failed creating the file %@", error.description);
    }
        
    BOOL res = [logData writeToFile:documentFileName atomically:YES];
    if (res) {
        NSLog(@"Logged data sucessfully!");
    } else {
        NSLog(@"Failed to log data");
    }
}

-(void) showEmailModalView:(NSDictionary*)emailInfo {
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = (id<MFMailComposeViewControllerDelegate>)self;
    
    [picker setSubject:[emailInfo objectForKey:kEmailSubject]];
    
    // Fill out the email body text
    NSString *emailBody = nil;
    if ([emailInfo objectForKey:kEmailFilePath]) {
        emailBody = [NSString stringWithFormat:@" %@ <h3> Attached is the File </h3>  <br> <h3> Mobile Office<h3>", [emailInfo objectForKey:kEmailBody]];
    } else {
        emailBody = [NSString stringWithFormat:@"%@", [emailInfo objectForKey:kEmailBody]];
    }
    
    NSNumber *isPlainText = [emailInfo objectForKey:kEmailBodyIsPlain];
    if (![isPlainText boolValue]) {
        [picker setMessageBody:emailBody isHTML:YES];
    } else {
        [picker setMessageBody:emailBody isHTML:NO];
    }
    
    picker.navigationBar.barStyle = UIBarStyleBlack;
    
    NSData *fileContent = [NSData dataWithContentsOfFile:[emailInfo objectForKey:kEmailFilePath]];
    
    [picker addAttachmentData:fileContent
                     mimeType:[emailInfo objectForKey:kEmailMimeType]
                     fileName:[emailInfo objectForKey:kEmailFilePath]];
    
    [self presentModalViewControlleriOS6:picker animated:YES];
}

-(void)emailFile:(NSDictionary*)emailInfo {

    if ([MFMailComposeViewController canSendMail]) {
        [self showEmailModalView:emailInfo];
    } else {
        UIAlertController *al = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Notification", nil)
                                                                    message:@"Please configure your email account"
                                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * action) {
                                                         }];
        [al addAction:okAction];
        [self presentViewController:al animated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate Methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultFailed:
            break;
            
        default:
        {
            UIAlertController *al = [UIAlertController alertControllerWithTitle:@"Email"
                                                                        message:@"Sending Failed "
                                                                 preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * action) {
                                                             }];
            [al addAction:okAction];
            [self presentViewController:al animated:YES completion:nil];
        }
            
            break;
    }
    [self dismissModalViewControllerAnimatediOS6:YES];
    
}


@end
