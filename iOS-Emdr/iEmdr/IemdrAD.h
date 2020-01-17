//
//  IEMDRAppDelegate.h
//  iEmdr
//
//  Created by Christoph Krey on 25.10.13.
//  Copyright © 2013-2020 Christoph Krey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IemdrVC.h"
#import "iEmdrCoreData.h"

@interface IemdrAD : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) iEmdrCoreData *data;

@end
