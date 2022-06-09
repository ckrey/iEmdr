//
//  IEMDRScene.h
//  iEmdr
//
//  Created by Christoph Krey on 19.11.13.
//  Copyright © 2013-2022 Christoph Krey. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface IemdrScene : SKScene

+ (void)resetNode:(SKView *)spriteView
             form:(NSInteger)form
           offset:(double)offset
           canvas:(double)canvas
           radius:(NSInteger)radius
              hue:(double)hue
              bpm:(double)bpm;

+ (void)setNode:(SKView *)spriteView
           form:(NSInteger)form
         offset:(double)offset
          sound:(NSInteger)sound;

@end
