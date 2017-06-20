//
//  DatePickerView.m
//
//  Created by Mike on 15/4/10.
//  Copyright © 2016年 Combanc. All rights reserved.
//

#import "DatePickerView.h"

#define modeAddUnitWithStringAndUnit(string, unit) \
if ([dateFormatString rangeOfString:string].location != NSNotFound) { \
    _combinedMode |= unit; \
    [_componentUnitArray addObject:@(unit)]; \
}

#define pickerViewSelectRowWithRowAndUnit(row, unit) \
if ([unitNumber unsignedIntegerValue] == unit) { \
    [_pickerView selectRow:row inComponent:[_componentUnitArray indexOfObject:unitNumber] animated:YES]; \
}

@interface DatePickerView () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) NSDateComponents *selectedComponents;
@property (nonatomic, assign) DatePickerViewCombinedMode combinedMode;
@property (nonatomic, strong) NSMutableArray *componentUnitArray;
@property (nonatomic, assign) BOOL whetherAttachToolBar;
@property (nonatomic, assign) BOOL willShowOrDismiss;

@end

@implementation DatePickerView

#pragma mark - Constructor

+ (instancetype)datePickerViewWhetherAttachToolBar:(BOOL)whetherAttachToolBar {
    return [[self alloc] initWithWhetherAttachToolBar:whetherAttachToolBar];
}

- (instancetype)init {
    return [self initWithWhetherAttachToolBar:YES];
}

- (instancetype)initWithWhetherAttachToolBar:(BOOL)whetherAttachToolBar {
    CGRect frame = CGRectZero;
    frame.origin = CGPointZero;
    frame.size = (CGSize){[UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height * 0.5 - 20};
    return [self initWithFrame:frame whetherAttachToolBar:whetherAttachToolBar];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame whetherAttachToolBar:YES];
}

- (instancetype)initWithFrame:(CGRect)frame whetherAttachToolBar:(BOOL)whetherAttachToolBar {
    if (self = [super initWithFrame:frame]) {
        _whetherAttachToolBar = whetherAttachToolBar;
        [self createSubviews];
        [self setInitialData];
    }
    return self;
}

- (void)createSubviews {
    CGFloat toolBarHeight = _whetherAttachToolBar ? 44.f : 0.f;
    CGRect frame = self.frame;
    frame.size.height -= _whetherAttachToolBar ? 0 : 44.f;
    self.frame = frame;
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolBarHeight, self.bounds.size.width, self.bounds.size.height - toolBarHeight)];
    [self addSubview:_pickerView];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    
    if (!_whetherAttachToolBar) return;
    
    UIToolbar *toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, toolBarHeight)];
    UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(doneItemDidClicked:)];
    toolBar.items = @[flexibleSpaceItem, doneItem];
    [self addSubview:toolBar];
}

- (void)doneItemDidClicked:(UIBarButtonItem *)item {
    if ([self.delegate respondsToSelector:@selector(datePickerView:didClickedDoneItemWithDate:)]) {
        [self.delegate datePickerView:self didClickedDoneItemWithDate:[_calendar dateFromComponents:_selectedComponents].copy];
    } else if (self.didClickedDoneItemBlock) {
        self.didClickedDoneItemBlock([_calendar dateFromComponents:_selectedComponents].copy);
    }
}

#pragma mark - life cycle

//- (void)willMoveToSuperview:(UIView *)newSuperview {
//    if (!_willShowOrDismiss) { // 如果调出键盘直接点击完成
//        self.ownerView.text = [_dateFormatter stringFromDate:[_calendar dateFromComponents:_selectedComponents]];
//    }
//    _willShowOrDismiss = !_willShowOrDismiss;
//}
//
//- (void)dealloc {
//    
//}

#pragma mark - initialize

- (void)setInitialData {
    _willShowOrDismiss = YES;
    _calendar = [NSCalendar currentCalendar];
    
    
    NSDateFormatter *dateFormatterLocal = [[NSDateFormatter alloc] init];
    [dateFormatterLocal setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    _initialDate = [NSDate date];
    _startDate = [dateFormatterLocal dateFromString:@"1900-02-01 13:59:00"];
    _endDate = [dateFormatterLocal dateFromString:@"2100-12-31 13:59:00"];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    [self setDateFormatter:dateFormatter];
}

#pragma mark - stter

- (void)setInitialDate:(NSDate *)initialDate {
    _initialDate = initialDate;
    
    _selectedComponents = [_calendar components:(NSCalendarUnit)_combinedMode fromDate:_initialDate];
    [self adjustPickerViewCurrentSeletedRow];
}

- (void)setStartDate:(NSDate *)pickerStartDate {
    _startDate = pickerStartDate;
    [self.pickerView reloadAllComponents];
    [self adjustPickerViewCurrentSeletedRow];
}

- (void)setEndDate:(NSDate *)endDate {
    _endDate = endDate;
    [self.pickerView reloadAllComponents];
    [self adjustPickerViewCurrentSeletedRow];
}

- (void)setDateFormatter:(NSDateFormatter *)dateFormatter {
    if (dateFormatter.dateFormat.length == 0) {
        return;
    }
    _dateFormatter = dateFormatter;
    
    _combinedMode = 0;
    _componentUnitArray = [NSMutableArray array];
    NSString *dateFormatString = dateFormatter.dateFormat;
    modeAddUnitWithStringAndUnit(@"yyyy", NSCalendarUnitYear)
    modeAddUnitWithStringAndUnit(@"MM", NSCalendarUnitMonth)
    modeAddUnitWithStringAndUnit(@"dd", NSCalendarUnitDay)
    modeAddUnitWithStringAndUnit(@"HH", NSCalendarUnitHour)
    modeAddUnitWithStringAndUnit(@"mm", NSCalendarUnitMinute)
    modeAddUnitWithStringAndUnit(@"ss", NSCalendarUnitSecond)
    
    NSArray *allCombinedModeArray = @[@(DatePickerViewCombinedModeyyyyMMdd),
                                   @(DatePickerViewCombinedModeyyyyMMddHH),
                                   @(DatePickerViewCombinedModeyyyyMMddHHmm),
                                   @(DatePickerViewCombinedModeyyyyMMddHHmmss),
                                   @(DatePickerViewCombinedModeMMdd),
                                   @(DatePickerViewCombinedModeMMddHH),
                                   @(DatePickerViewCombinedModeMMddHHmm),
                                   @(DatePickerViewCombinedModeMMddHHmmss),
                                   @(DatePickerViewCombinedModeddHH),
                                   @(DatePickerViewCombinedModeddHHmm),
                                   @(DatePickerViewCombinedModeddHHmmss),
                                   @(DatePickerViewCombinedModeHHmm),
                                   @(DatePickerViewCombinedModeHHmmss)];
    if (![allCombinedModeArray containsObject:@(_combinedMode)]) {
        _combinedMode = DatePickerViewCombinedModeyyyyMMdd;
        [_componentUnitArray removeAllObjects];
        [_componentUnitArray addObjectsFromArray:@[@(NSCalendarUnitYear), @(NSCalendarUnitMonth), @(NSCalendarUnitDay)]];
    }
    
    // reload
    _selectedComponents = [_calendar components:(NSCalendarUnit)_combinedMode fromDate:_initialDate];
    [self.pickerView reloadAllComponents];
    [self adjustPickerViewCurrentSeletedRow];
}

- (void)adjustPickerViewCurrentSeletedRow {
    NSInteger yearRow = [_selectedComponents valueForComponent:NSCalendarUnitYear] - [_calendar component:NSCalendarUnitYear fromDate:_startDate];
    NSInteger monthRow = [_selectedComponents valueForComponent:NSCalendarUnitMonth] - 1;
    NSInteger dayRow = [_selectedComponents valueForComponent:NSCalendarUnitDay] - 1;
    NSInteger hourRow = [_selectedComponents valueForComponent:NSCalendarUnitHour];
    NSInteger minuteRow = [_selectedComponents valueForComponent:NSCalendarUnitMinute];
    NSInteger secondRow = [_selectedComponents valueForComponent:NSCalendarUnitSecond];
    for (NSNumber *unitNumber in _componentUnitArray) {
        pickerViewSelectRowWithRowAndUnit(yearRow, NSCalendarUnitYear)
        pickerViewSelectRowWithRowAndUnit(monthRow, NSCalendarUnitMonth)
        pickerViewSelectRowWithRowAndUnit(dayRow, NSCalendarUnitDay)
        pickerViewSelectRowWithRowAndUnit(hourRow, NSCalendarUnitHour)
        pickerViewSelectRowWithRowAndUnit(minuteRow, NSCalendarUnitMinute)
        pickerViewSelectRowWithRowAndUnit(secondRow, NSCalendarUnitSecond)
        
    }
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return _componentUnitArray.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSCalendarUnit unit = (NSCalendarUnit)[_componentUnitArray[component] unsignedIntegerValue];
    switch (unit) {
        case NSCalendarUnitYear:{
            NSDateComponents *startCpts = [_calendar components:NSCalendarUnitYear fromDate:_startDate];
            NSDateComponents *endCpts = [_calendar components:NSCalendarUnitYear fromDate:_endDate];
            return [endCpts year] - [startCpts year] + 1;
        }
        case NSCalendarUnitMonth:
            return 12;
        case NSCalendarUnitDay:
        {
            NSRange dayRange = [_calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:_initialDate];
            return dayRange.length;
        }
        case NSCalendarUnitHour:
            return 24;
        case NSCalendarUnitMinute:
            return 60;
        case NSCalendarUnitSecond:
            return 60;
        default:
            break;
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate Methods

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *dateLabel = (UILabel *)view;
    if (!dateLabel) {
        dateLabel = [[UILabel alloc] init];
        [dateLabel setFont:[UIFont systemFontOfSize:17]];
    }
    NSCalendarUnit unit = (NSCalendarUnit)[_componentUnitArray[component] unsignedIntegerValue];
    switch (unit) {
        case NSCalendarUnitYear:
        {
            NSDateComponents *components = [self.calendar components:NSCalendarUnitYear fromDate:self.startDate];
            NSString *currentYear = [NSString stringWithFormat:@"%ld年", [components year] + row];
            [dateLabel setText:currentYear];
            dateLabel.textAlignment = NSTextAlignmentCenter;
            break;
        }
        case NSCalendarUnitMonth:
        {
            NSString *currentMonth = [NSString stringWithFormat:@"%ld月",(long)row+1];
            [dateLabel setText:currentMonth];
            dateLabel.textAlignment = NSTextAlignmentCenter;
            break;
        }
        case NSCalendarUnitDay:
        {
            NSRange dateRange = [_calendar rangeOfUnit:NSCalendarUnitDay
                                                    inUnit:NSCalendarUnitMonth
                                                   forDate:_initialDate];
            NSString *currentDay = [NSString stringWithFormat:@"%lu日", (row + 1) % (dateRange.length + 1)];
            [dateLabel setText:currentDay];
            dateLabel.textAlignment = NSTextAlignmentCenter;
            break;
        }
        case NSCalendarUnitHour:
        {
            NSString *currentHour = [NSString stringWithFormat:@"%ld时",(long)row];
            [dateLabel setText:currentHour];
            dateLabel.textAlignment = NSTextAlignmentCenter;
            break;
        }
        case NSCalendarUnitMinute:
        {
            NSString *currentMin = [NSString stringWithFormat:@"%02ld分",(long)row];
            [dateLabel setText:currentMin];
            dateLabel.textAlignment = NSTextAlignmentCenter;
            break;
        }
        case NSCalendarUnitSecond:
        {
            NSString *currentMin = [NSString stringWithFormat:@"%02ld秒",(long)row];
            [dateLabel setText:currentMin];
            dateLabel.textAlignment = NSTextAlignmentCenter;
            break;
        }
        default:
            break;
    }
    return dateLabel;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 35.0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat contentWidth = screenWidth - (30.f * screenWidth / 320.f) * 2;
    CGFloat widthPerPiece = contentWidth / ([_componentUnitArray containsObject:@(NSCalendarUnitYear)] ? ( 13.0 + (_componentUnitArray.count -1) * 9) : _componentUnitArray.count);
    NSCalendarUnit unit = (NSCalendarUnit)[_componentUnitArray[component] unsignedIntegerValue];
    return unit == NSCalendarUnitYear ? widthPerPiece * 13 : widthPerPiece * 9;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSCalendarUnit unit = (NSCalendarUnit)[_componentUnitArray[component] unsignedIntegerValue];
    switch (unit) {
        case NSCalendarUnitYear:
        {
            NSInteger year = [_calendar components:(NSCalendarUnit)_combinedMode fromDate:_startDate].year + row;
            [_selectedComponents setYear:year];
        }
            break;
        case NSCalendarUnitMonth:
        {
            [_selectedComponents setMonth:row + 1];
        }
            break;
        case NSCalendarUnitDay:
        {
            [_selectedComponents setDay:row + 1];
        }
            break;
        case NSCalendarUnitHour:
        {
            [_selectedComponents setHour:row];
        }
            break;
        case NSCalendarUnitMinute:
        {
            [_selectedComponents setMinute:row];
        }
        case NSCalendarUnitSecond:
        {
            [_selectedComponents setSecond:row];
        }
            break;
        default:
            break;
    }
    [self updateOwnerView];
}

- (void)updateOwnerView {
    if (self.ownerView) {
        self.ownerView.text = [_dateFormatter stringFromDate:[_calendar dateFromComponents:_selectedComponents]];
    }
}

@end
