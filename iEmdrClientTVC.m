//
//  iEmdrClientTVC.m
//  iEmdr
//
//  Created by Christoph Krey on 07.09.13.
//  Copyright (c) 2013 Christoph Krey. All rights reserved.
//

#import "iEmdrClientTVC.h"
#import "iEmdrSessionTVC.h"
#import "iEmdrAppDelegate.h"
#import "Client+Create.h"
#import "Session+Create.h"

@interface iEmdrClientTVC()
@property (nonatomic) BOOL started;
@end

@implementation iEmdrClientTVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    IEMDRAppDelegate *delegate = [UIApplication sharedApplication].delegate;
        
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Client"];
    
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:delegate.data.managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                    cacheName:nil];
    if (!self.started) {
        self.started = TRUE;
        if (!self.splitViewController) {
        }
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
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"setClientToRun:"]) {
            Client *client = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setClientToRun:)]) {
                [segue.destinationViewController performSelector:@selector(setClientToRun:) withObject:client];
            }
            [self transferSplitViewBarButtonItemToViewController:segue.destinationViewController];
        }
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
    
    [theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
    UITableViewCell *cell = [theTableView cellForRowAtIndexPath:newIndexPath];
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        // Reflect selection in data model
    } else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        // Reflect deselection in data model
    }
}

- (IBAction)newClient:(UIBarButtonItem *)sender {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    picker.addressBook = [Client theABRef];
    [self presentViewController:picker animated:YES completion:nil];    
}

- (IBAction)withoutClient:(UIBarButtonItem *)sender {
    [self performSegueWithIdentifier:@"setClientToRun:" sender:nil];
}


#pragma ABPeoplePickerNavigationControllerDelegate
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    IEMDRAppDelegate *delegate = [UIApplication sharedApplication].delegate;

    NSString *name = CFBridgingRelease(ABRecordCopyCompositeName(person));
    (void)[Client clientWithName:name inManagedObjectContext:delegate.data.managedObjectContext];
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:NULL];
    return NO;
}

-(BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}

-(void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma SplitViewDelegate

- (void)awakeFromNib
{
    if (self.splitViewController) {
        self.splitViewController.delegate = self;
    }
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    id detailViewController = [self.splitViewController.viewControllers lastObject];
    [detailViewController setSplitViewBarButtonItem:nil];
}

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Clients";
    id detailViewController = [self.splitViewController.viewControllers lastObject];
    [detailViewController setSplitViewBarButtonItem:barButtonItem];
}

- (id)splitViewDetailWithBarButtonItem
{
    id detail = [self.splitViewController.viewControllers lastObject];
    if (![detail respondsToSelector:@selector(setSplitViewBarButtonItem:)] ||
        ![detail respondsToSelector:@selector(splitViewBarButtonItem)]) detail = nil;
    return detail;
}

- (id)splitViewDetailWithBig
{
    id detail = [self.splitViewController.viewControllers lastObject];
    if (![detail respondsToSelector:@selector(setBig:)] ||
        ![detail respondsToSelector:@selector(big)]) detail = nil;
    return detail;
}


- (void)transferSplitViewBarButtonItemToViewController:(id)destinationViewController
{
    UIBarButtonItem *splitViewBarButtonItem = [[self splitViewDetailWithBarButtonItem] performSelector:@selector(splitViewBarButtonItem)];
    [[self splitViewDetailWithBarButtonItem] setSplitViewBarButtonItem:nil];
    if (splitViewBarButtonItem) [destinationViewController setSplitViewBarButtonItem:splitViewBarButtonItem];
    
    id big = [[self splitViewDetailWithBig] performSelector:@selector(big)];
    [[self splitViewDetailWithBig] setBig:nil];
    if (big) [destinationViewController setBig:big];
}

@end

