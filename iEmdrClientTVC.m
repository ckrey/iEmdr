//
//  iEmdrClientTVC.m
//  iEmdr
//
//  Created by Christoph Krey on 07.09.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "iEmdrClientTVC.h"
#import "iEmdrSessionTVC.h"
#import "iEmdrAD.h"
#import "Client+Create.h"
#import "Session+Create.h"
#import "IemdrPersonTVC.h"
#import "IemdrVC.h"

@interface iEmdrClientTVC()
@property (strong, nonatomic) UIAlertView *alertview;
@end

@implementation iEmdrClientTVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    IemdrAD *delegate = [UIApplication sharedApplication].delegate;
        
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
    NSLog(@"prepareForSegue %@ %@ %@ %@", segue, segue.identifier, segue.sourceViewController, segue.destinationViewController);
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
    }
}

- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
    NSArray *vcs = self.splitViewController.viewControllers;
    UIViewController *detailVC = vcs[1];
    if ([detailVC respondsToSelector:@selector(setClientToRun:)]) {
        Client *client = [self.fetchedResultsController objectAtIndexPath:newIndexPath];
        [detailVC performSelector:@selector(setClientToRun:) withObject:client];
    }
    [self.splitViewController showDetailViewController:detailVC sender:nil];
}

- (IBAction)withoutClient:(UIBarButtonItem *)sender {
    NSArray *vcs = self.splitViewController.viewControllers;
    [self.splitViewController showDetailViewController:vcs[1] sender:sender];
}


- (IBAction)clientSelected:(UIStoryboardSegue *)unwindSegue {
    if ([unwindSegue.sourceViewController respondsToSelector:@selector(selectedPersonName)]) {
        NSString *name = [unwindSegue.sourceViewController performSelector:@selector(selectedPersonName)];
        IemdrAD *delegate = [UIApplication sharedApplication].delegate;
        [Client clientWithName:name inManagedObjectContext:delegate.data.managedObjectContext];
    }
}
@end

