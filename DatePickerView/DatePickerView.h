//
//  DatePickerView.h
//
//  Created by Mike on 15/4/10.
//  Copyright © 2016年 Combanc. All rights reserved.
//

#import <UIKit/UIKit.h>

//typedef NS_OPTIONS(NSUInteger, DatePickerViewMode) {
//    
////    kCFCalendarUnitYear = (1UL << 2),
////    kCFCalendarUnitMonth = (1UL << 3),
////    kCFCalendarUnitDay = (1UL << 4),
////    kCFCalendarUnitHour = (1UL << 5),
////    kCFCalendarUnitMinute = (1UL << 6),
////    kCFCalendarUnitSecond = (1UL << 7),
//};

typedef NS_ENUM(NSUInteger, DatePickerViewCombinedMode) {
    DatePickerViewCombinedModeyyyyMMdd       = 0b00011100,
    DatePickerViewCombinedModeyyyyMMddHH     = 0b00111100,
    DatePickerViewCombinedModeyyyyMMddHHmm   = 0b01111100,
    DatePickerViewCombinedModeyyyyMMddHHmmss = 0b11111100,
    DatePickerViewCombinedModeMMdd           = 0b00011000,
    DatePickerViewCombinedModeMMddHH         = 0b00111000,
    DatePickerViewCombinedModeMMddHHmm       = 0b01111000,
    DatePickerViewCombinedModeMMddHHmmss     = 0b11111000,
    DatePickerViewCombinedModeddHH           = 0b00110000,
    DatePickerViewCombinedModeddHHmm         = 0b01110000,
    DatePickerViewCombinedModeddHHmmss       = 0b11110000,
    DatePickerViewCombinedModeHHmm           = 0b01100000,
    DatePickerViewCombinedModeHHmmss         = 0b11100000
};

@protocol DatePickerViewDelegate;

@interface DatePickerView : UIView

@property (nonatomic, weak) id<DatePickerViewDelegate> delegate;
@property (nonatomic, strong) NSDate *startDate; // default 1900-02-1 13:59:00
@property (nonatomic, strong) NSDate *endDate; // default 2100-12-31 13:59:00
@property (nonatomic, strong) NSDate *initialDate; // default [NSDate date]
@property (nonatomic, copy) NSDateFormatter *dateFormatter; // default "yyyy-MM-dd"
@property (nonatomic, weak) UITextField *ownerView;
@property (nonatomic, copy) void (^didClickedDoneItemBlock)(NSDate *date); // use together with toolbar

+ (instancetype)datePickerViewWhetherAttachToolBar:(BOOL)whetherAttachToolBar;

@end

@protocol DatePickerViewDelegate <NSObject>

- (void)datePickerView:(DatePickerView *)datePickerView didClickedDoneItemWithDate:(NSDate *)date; // use together with toolbar

@end