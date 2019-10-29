//
//  iEmdrClientTVC.m
//  iEmdr
//
//  Created by Christoph Krey on 07.09.13.
//  Copyright © 2013-2019 Christoph Krey. All rights reserved.
//

#import "iEmdrClientTVC.h"
#import "iEmdrSessionTVC.h"
#import "IemdrAD.h"
#import "Client+CoreDataClass.h"
#import "Session+CoreDataClass.h"
#import "iEmdrPersonTVC.h"
#import "IemdrVC.h"
#import "CocoaLumberjack.h"
#import <Contacts/Contacts.h>

@interface iEmdrClientTVC ()
@property (nonatomic) BOOL once;
@end

@implementation iEmdrClientTVC
static const DDLogLevel ddLogLevel = DDLogLevelError;

- (void)restrictUI {
    self.navigationItem.rightBarButtonItem = nil;
    self.navigationItem.prompt = @"Start Anonymously";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    IemdrAD *delegate = (IemdrAD *)[UIApplication sharedApplication].delegate;
        
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Client"];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.fetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:delegate.data.managedObjectContext
                                          sectionNameKeyPath:nil
                                                   cacheName:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (self.once) {
        return;
    }

    self.once = TRUE;
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    switch (status) {
        case CNAuthorizationStatusRestricted: {
            DDLogVerbose(@"CNAuthorizationStatus: CNAuthorizationStatusRestricted");
            UIAlertController *ac =
            [UIAlertController alertControllerWithTitle:@"Addressbook Access"
                                                message:@"has been restricted, possibly due to restrictions such as parental controls."
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok =
            [UIAlertAction actionWithTitle:@"Continue"
                                     style:UIAlertActionStyleDefault
                                   handler:nil];
            [ac addAction:ok];
            [self presentViewController:ac animated:TRUE completion:nil];
            break;
        }

        case CNAuthorizationStatusDenied: {
            DDLogVerbose(@"CNAuthorizationStatus: CNAuthorizationStatusDenied");
            UIAlertController *ac =
            [UIAlertController alertControllerWithTitle:@"Addressbook Access"
                                                message:@"has been denied by user. Go to Settings/Privacy/Contacts to change"
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok =
            [UIAlertAction actionWithTitle:@"Continue"
                                     style:UIAlertActionStyleDefault
                                   handler:nil];
            [ac addAction:ok];
            [self presentViewController:ac animated:TRUE completion:^{
                [self restrictUI];
            }];
            break;
        }

        case CNAuthorizationStatusAuthorized:
            DDLogVerbose(@"CNAuthorizationStatus: CNAuthorizationStatusAuthorized");
            break;

        case CNAuthorizationStatusNotDetermined:
        default:
            DDLogVerbose(@"CNAuthorizationStatus: CNAuthorizationStatusNotDetermined");
            CNContactStore *contactStore = [[CNContactStore alloc] init];
            [contactStore requestAccessForEntityType:CNEntityTypeContacts
                                   completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                       if (granted) {
                                           DDLogVerbose(@"requestAccessForEntityType granted");
                                       } else {
                                           DDLogVerbose(@"requestAccessForEntityType denied %@", error);
                                           [self restrictUI];
                                       }
                                   }];
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"client"];
    
    Client *client = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = client.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)[client.hasSessions count]];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DDLogVerbose(@"prepareForSegue %@", segue.identifier);
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"setClient:"]) {
            Client *client = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setClient:)]) {
                [segue.destinationViewController performSelector:@selector(setClient:) withObject:client];
            }
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Client *client = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.fetchedResultsController.managedObjectContext deleteObject:client];
        [self.fetchedResultsController.managedObjectContext save:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Client *client = [self.fetchedResultsController objectAtIndexPath:indexPath];

    if (self.splitViewController.isCollapsed) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        IemdrVC *vc = [sb instantiateViewControllerWithIdentifier:@"detailView"];
        if ([vc respondsToSelector:@selector(setClientToRun:)]) {
            [vc performSelector:@selector(setClientToRun:) withObject:client];
        }
        [self.navigationController pushViewController:vc animated:TRUE];
    } else {
        IemdrVC *vc = self.splitViewController.viewControllers[1];
        if ([vc respondsToSelector:@selector(setClientToRun:)]) {
            [vc performSelector:@selector(setClientToRun:) withObject:client];
        }
    }

}

- (IBAction)fastForwardPressed:(UIBarButtonItem *)sender {
    if (self.splitViewController.isCollapsed) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        IemdrVC *vc = [sb instantiateViewControllerWithIdentifier:@"detailView"];
        if ([vc respondsToSelector:@selector(setClientToRun:)]) {
            [vc performSelector:@selector(setClientToRun:) withObject:nil];
        }
        [self.navigationController pushViewController:vc animated:TRUE];
    } else {
        IemdrVC *vc = self.splitViewController.viewControllers[1];
        if ([vc respondsToSelector:@selector(setClientToRun:)]) {
            [vc performSelector:@selector(setClientToRun:) withObject:nil];
        }
    }
}


- (IBAction)clientSelected:(UIStoryboardSegue *)unwindSegue {
    if ([unwindSegue.sourceViewController respondsToSelector:@selector(selectedPersonName)]) {
        NSString *name = [unwindSegue.sourceViewController performSelector:@selector(selectedPersonName)];
        IemdrAD *delegate = (IemdrAD *)[UIApplication sharedApplication].delegate;
        [Client clientWithName:name inManagedObjectContext:delegate.data.managedObjectContext];
        [delegate.data.managedObjectContext save:nil];
    }
}
@end

