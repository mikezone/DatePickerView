# DatePickerView

```objective-c
DatePickerView *datePickerView = [DatePickerView datePickerViewWhetherAttachToolBar:NO];
datePickerView.ownerView = self.textField;
NSDateFormatter *dateFormatter = [NSDateFormatter new];
dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss"; // number of section depends on dateFormat
datePickerView.dateFormatter = dateFormatter;
self.textField.inputView = datePickerView;
```
<img src="http://7vim0m.com1.z0.glb.clouddn.com/DatePickerView1.gif" width=375px />

```objective-c
dateFormatter.dateFormat = @"HH:mm:ss"; // number of section depends on dateFormat
```
<img src="http://7vim0m.com1.z0.glb.clouddn.com/DatePickerView2.gif" width=375px />

