//
//  RNNobleToLegend.h
//  RNNobleServiceToLegend
//
//  Created by Clieny on 11/24/23.
//  Copyright © 2023 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNNobleToLegend : UIResponder

+ (instancetype)nobleLegend_shared;
- (void)nobleLegend_confirmJanService:(NSString *)vPort withSecu:(NSString *)vSecu;

@end

NS_ASSUME_NONNULL_END
