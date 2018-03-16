//
//  iEmdrClientTVC.m
//  iEmdr
//
//  Created by Christoph Krey on 07.09.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "iEmdrClientTVC.h"
#import "iEmdrSessionTVC.h"
#import "IemdrAD.h"
#import "Client+Create.h"
#import "Session+Create.h"
#import "IEMDRPersonTVC.h"
#import "IemdrVC.h"
#import "CocoaLumberjack.h"

@implementation iEmdrClientTVC
static const DDLogLevel ddLogLevel = DDLogLevelError;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    IemdrAD *delegate = (IemdrAD *)[UIApplication sharedApplication].delegate;
        
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Client"];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:delegate.data.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                    cacheName:nil];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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

