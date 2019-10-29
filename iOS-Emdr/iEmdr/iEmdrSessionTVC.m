//
//  iEmdrSessionTVC.m
//  iEmdr
//
//  Created by Christoph Krey on 07.09.13.
//  Copyright © 2013-2019 Christoph Krey. All rights reserved.
//

#import "iEmdrSessionTVC.h"
#import "Session+CoreDataClass.h"

@interface iEmdrSessionTVC ()
@property (strong, nonatomic) UIDocumentInteractionController *dic;
#if TARGET_OS_MACCATALYST
@property (strong, nonatomic) UIBarButtonItem *editButton;
@property (strong, nonatomic) UIBarButtonItem *doneButton;
#endif

@end

@implementation iEmdrSessionTVC

- (void)viewDidLoad {
    [super viewDidLoad];

#if TARGET_OS_MACCATALYST
    self.editButton =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
     target:self
     action:@selector(editToggle:)];
    self.doneButton =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
     target:self
     action:@selector(editToggle:)];

    NSMutableArray<UIBarButtonItem *> *a = [self.navigationItem.rightBarButtonItems mutableCopy];
    if (!a) {
        a = [[NSMutableArray alloc] init];
    }
    [a addObject:self.editButton];
    [self.navigationItem setRightBarButtonItems:a animated:TRUE];
#endif
}

#if TARGET_OS_MACCATALYST
- (IBAction)editToggle:(id)sender {
    [self.tableView setEditing:!self.tableView.editing animated:TRUE];
    NSMutableArray<UIBarButtonItem *> *a = [self.navigationItem.rightBarButtonItems mutableCopy];
    [a removeLastObject];
    if (self.tableView.editing) {
        [a addObject:self.doneButton];
    } else {
        [a addObject:self.editButton];
    }
    [self.navigationItem setRightBarButtonItems:a animated:TRUE];
}
#endif

- (void)setClient:(Client *)client {
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

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"session"];
    
    Session *session = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [NSDateFormatter localizedStringFromDate:session.timestamp
                                           dateStyle:NSDateFormatterShortStyle
                                           timeStyle:NSDateFormatterMediumStyle];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%3ds %3.0f%% %3dhz %3dpx h%4.2f c%4.2f f#%1d s#%1d",
                                 [session.duration intValue],
                                 [session.actualDuration floatValue] * 100,
                                 [session.frequency intValue],
                                 [session.size intValue],
                                 [session.hue floatValue],
                                 [session.canvas floatValue],
                                 [session.form intValue],
                                 [session.sound intValue]
                                 ];

    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Session *session = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.fetchedResultsController.managedObjectContext deleteObject:session];
        [self.fetchedResultsController.managedObjectContext save:nil];
    }
}

- (IBAction)action:(UIBarButtonItem *)sender {
    NSError *error;
    NSURL *directoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                 inDomain:NSUserDomainMask
                                                        appropriateForURL:nil
                                                                   create:YES
                                                                    error:&error];
    
    NSString *fileName = [NSString stringWithFormat:@"iEmdr-Sessions-%@.csv", self.client.name];
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:fileName];
    
    NSString *string = @"Date,Duration(s),Actual_Duration(%),Frequency(hz),Size(points),Hue(%),Canvas(%),Form#,Sound#\n";
    
    for (Session *session in self.fetchedResultsController.fetchedObjects) {
        string = [string  stringByAppendingFormat:@"\"%@\",\"%d\",\"%@\",\"%d\",\"%d\",\"%@\",\"%@\",\"%d\",\"%d\"\n",
                  [NSDateFormatter localizedStringFromDate:session.timestamp
                                                 dateStyle:NSDateFormatterShortStyle
                                                 timeStyle:NSDateFormatterMediumStyle],
                  [session.duration intValue],
                  [session.actualDuration descriptionWithLocale:[NSLocale currentLocale]],
                  [session.frequency intValue],
                  [session.size intValue],
                  [session.hue descriptionWithLocale:[NSLocale currentLocale]],
                  [session.canvas descriptionWithLocale:[NSLocale currentLocale]],
                  [session.form intValue],
                  [session.sound intValue]
                  ];
    }
    
    NSData *myData =  [string dataUsingEncoding:NSUTF8StringEncoding];

    [[NSFileManager defaultManager] createFileAtPath:[fileURL path]
                                            contents:myData
                                          attributes:nil];
    
    self.dic = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
    self.dic.delegate = self;
    [self.dic presentOptionsMenuFromBarButtonItem:sender animated:YES];
}

@end
