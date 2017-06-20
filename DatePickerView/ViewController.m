//
//  ViewController.m
//  DatePickerView
//
//  Created by Mike on 16/7/9.
//  Copyright © 2016年 Mike. All rights reserved.
//

#import "ViewController.h"
#import "DatePickerView.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    DatePickerView *datePickerView = [DatePickerView datePickerViewWhetherAttachToolBar:NO]; // `YES` or `NO` depends on whether use IQKeyboardManager
    datePickerView.initialDate = [NSDate new];
    
    datePickerView.ownerView = self.textField;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss"; // number of section depends on dateFormat
    datePickerView.dateFormatter = dateFormatter;
    datePickerView.startDate = [NSDate dateWithTimeIntervalSinceNow:-20000000];
    self.textField.inputView = datePickerView;
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self.textField removeFromSuperview];
//}

@end
