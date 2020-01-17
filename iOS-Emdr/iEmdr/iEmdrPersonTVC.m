//
//  iEmdrPersonTVC.m
//  iEmdr
//
//  Created by Christoph Krey on 10.11.14.
//  Copyright © 2014-2020 Christoph Krey. All rights reserved.
//

#import "iEmdrPersonTVC.h"
#import <Contacts/Contacts.h>

@interface iEmdrPersonTVC ()
@property (strong, nonatomic) NSMutableDictionary *sections;
@end

@implementation iEmdrPersonTVC

- (void)viewWillAppear:(BOOL)animated {
    self.sections = [[NSMutableDictionary alloc] init];

    NSArray *keys = @[[CNContactFormatter
                       descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],
                      CNContactThumbnailImageDataKey,
                      CNContactImageDataAvailableKey
    ];
    CNContactFetchRequest *contactFetchRequest = [[CNContactFetchRequest alloc]
                                                  initWithKeysToFetch:keys];
    CNContactStore *contactStore = [[CNContactStore alloc] init];
    [contactStore enumerateContactsWithFetchRequest:contactFetchRequest
                                              error:nil
                                         usingBlock:
     ^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
        NSString *name = [CNContactFormatter
                          stringFromContact:contact
                          style:CNContactFormatterStyleFullName];

        NSLog(@"contact %@: %@",
              contact.identifier,
              name);

        NSString *key = [name substringToIndex:1].uppercaseString;
        if (key) {
            NSMutableArray *array = (self.sections)[key];
            if (!array) {
                array = [[NSMutableArray alloc] init];
            }
            [array addObject:contact];
            (self.sections)[key] = array;
        }

    }];

    for (NSString *key in self.sections.allKeys) {
        NSArray *persons = [(self.sections)[key] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            CNContact *contact1 = obj1;
            CNContact *contact2 = obj2;
            NSString *name1 = [CNContactFormatter
                               stringFromContact:contact1
                               style:CNContactFormatterStyleFullName];
            NSString *name2 = [CNContactFormatter
                               stringFromContact:contact2
                               style:CNContactFormatterStyleFullName];

            return [name1 localizedCaseInsensitiveCompare:name2];
        }];

        (self.sections)[key] = persons;
    }

    self.tableView.sectionIndexMinimumDisplayRowCount = 8;
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.sections count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *keys = [[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)];
    return keys[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *keys = [[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSArray *persons = [self.sections valueForKey:keys[section]];
    return [persons count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"person" forIndexPath:indexPath];
    
    NSArray *persons = [self sortedPersonsInSection: indexPath.section];
    CNContact *contact = persons[indexPath.row];
    cell.textLabel.text =
    [CNContactFormatter stringFromContact:contact
                                    style:CNContactFormatterStyleFullName];
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *persons = [self sortedPersonsInSection: indexPath.section];
    CNContact *contact = persons[indexPath.row];
    self.selectedPersonName =
    [CNContactFormatter stringFromContact:contact
                                    style:CNContactFormatterStyleFullName];
    return indexPath;
}

- (NSArray *)sortedPersonsInSection:(NSInteger)index {
    NSArray *keys = [[self.sections allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSArray *persons = [self.sections valueForKey:keys[index]];
    return persons;
}

@end
