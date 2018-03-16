//
//  FormTableViewController.m
//  iEmdr
//
//  Created by Christoph Krey on 29.09.15.
//  Copyright © 2015-2018 Christoph Krey. All rights reserved.
//

#import "FormTableViewController.h"

@interface FormTableViewController ()

@end

@implementation FormTableViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self show];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self performSegueWithIdentifier:@"unwindFromForm" sender:self];
    [super viewWillDisappear:animated];
}


- (void)show {
    for (int i = 0; i < 6; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[NSUserDefaults standardUserDefaults] integerForKey:@"FormVal"]
                                                inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[NSUserDefaults standardUserDefaults] setObject:@(indexPath.row) forKey:@"FormVal"];
    [self show];
}

@end
