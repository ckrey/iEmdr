//
//  iEmdrSessionTVC.m
//  iEmdr
//
//  Created by Christoph Krey on 07.09.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "iEmdrSessionTVC.h"
#import "Session.h"

@interface iEmdrSessionTVC ()

@end

@implementation iEmdrSessionTVC

- (void)setClient:(Client *)client
{
    _client = client;
    
    if (client.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Session"];
        
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
        request.predicate = [NSPredicate predicateWithFormat:@"hasClient = %@", client];
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:client.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
        self.title = client.name;

    } else {
        self.fetchedResultsController = nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"session"];
    
    Session *session = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSDateFormatter localizedStringFromDate:session.timestamp
                                           dateStyle:NSDateFormatterShortStyle
                                           timeStyle:NSDateFormatterMediumStyle];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%3ds %3.0f%% %3dhz %3d %4.2f %4.2f",
                                                  [session.duration intValue],
                                                  [session.actualDuration floatValue] * 100,
                                                  [session.frequency intValue],
                                                  [session.size intValue],
                                                  [session.hue floatValue],
                                                  [session.canvas floatValue]
                                                  ];

    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Session *session = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.fetchedResultsController.managedObjectContext deleteObject:session];
    }
}

- (IBAction)action:(UIBarButtonItem *)sender
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:[NSString stringWithFormat:@"iEmdr Sessions %@", self.client.name]];
    
    NSString *string = @"Date,Duration(s),Actual_Duration(%),Frequency(hz),Size(points),Hue(%),Canvas(%)\n";
    
    for (Session *session in self.fetchedResultsController.fetchedObjects) {
        string = [string  stringByAppendingFormat:@"\"%@\",\"%d\",\"%@\",\"%d\",\"%d\",\"%@\",\"%@\"\n",
                  [NSDateFormatter localizedStringFromDate:session.timestamp
                                                 dateStyle:NSDateFormatterShortStyle
                                                 timeStyle:NSDateFormatterMediumStyle],
                  [session.duration intValue],
                  [session.actualDuration descriptionWithLocale:[NSLocale currentLocale]],
                  [session.frequency intValue],
                  [session.size intValue],
                  [session.hue descriptionWithLocale:[NSLocale currentLocale]],
                  [session.canvas descriptionWithLocale:[NSLocale currentLocale]]
                  ];
    }
    
    NSData *myData =  [string dataUsingEncoding:NSUTF8StringEncoding];
    [picker addAttachmentData:myData mimeType:@"text/csv"
                     fileName:[NSString stringWithFormat:@"iEmdr-Sessions-%@.csv", self.client.name]];
    
    NSString *emailBody = @"see attached file";
    [picker setMessageBody:emailBody isHTML:NO];
        
    [self presentViewController:picker animated:YES completion:^{
        // done
    }];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:^{
        // done
    }];
}



@end
