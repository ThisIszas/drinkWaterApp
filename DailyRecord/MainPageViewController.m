//
//  MainPageViewController.m
//  DailyRecord
//
//  Created by Zheng Li on 2021/7/15.
//

#import "MainPageViewController.h"
#import <Masonry/Masonry.h>
#import <PINCache/PINCache.h>
#import <YYKit/YYKit.h>

#define dailyCacheKey @"dailyRecordConfig"

static NSDateFormatter *staticDateFormatter = nil;

@interface MainPageViewController ()
@property(nonatomic, strong) UILabel *isDrugEatedLabel;
@property(nonatomic, strong) UIButton *markDrugEatedButton;
@property(nonatomic, strong) UILabel *dailyDrinkedWaterLiterLabel;
@property(nonatomic, strong) UITextField *waterDrinkPerTimeTextField;
@property(nonatomic, strong) UIButton *recordWaterDrinkedButton;
@property(nonatomic, strong) NSMutableDictionary *storedConfig;
@property(nonatomic, strong) NSTimer *storeToStorageTimer;
@end

@implementation MainPageViewController
+ (void)initialize {
    staticDateFormatter = [[NSDateFormatter alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.storedConfig = [self getStoredConfig];
    
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    
    self.isDrugEatedLabel = [self getTitleLabelWithFontSize:20 andText:@"💊不能停"];
    self.dailyDrinkedWaterLiterLabel = [self getTitleLabelWithFontSize:20 andText:@"0"];
    self.dailyDrinkedWaterLiterLabel.text = [NSString stringWithFormat:@"已经喝了 %@ ml", self.storedConfig[@"totalDrinked"]];
    
    self.markDrugEatedButton = [UIButton new];
    [self.markDrugEatedButton setTitle:@"吃!" forState:UIControlStateNormal];
    self.markDrugEatedButton.layer.borderWidth = 2;
    self.markDrugEatedButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.markDrugEatedButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    [self.markDrugEatedButton addTarget:self action:@selector(markDrugEated) forControlEvents:UIControlEventTouchUpInside];
    
    self.recordWaterDrinkedButton = [UIButton new];
    [self.recordWaterDrinkedButton setTitle:@"继续喝!" forState:UIControlStateNormal];
    self.recordWaterDrinkedButton.layer.borderWidth = 2;
    self.recordWaterDrinkedButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.recordWaterDrinkedButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [self.recordWaterDrinkedButton addTarget:self action:@selector(updateDrinkedWaterValue) forControlEvents:UIControlEventTouchUpInside];
    
    self.waterDrinkPerTimeTextField = [UITextField new];
    self.waterDrinkPerTimeTextField.layer.borderWidth = 3;
    self.waterDrinkPerTimeTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    self.waterDrinkPerTimeTextField.leftView = paddingView;
    self.waterDrinkPerTimeTextField.leftViewMode = UITextFieldViewModeAlways;
    [self.waterDrinkPerTimeTextField addTarget:self action:@selector(editingValueChange:) forControlEvents:UIControlEventEditingChanged];
    self.waterDrinkPerTimeTextField.keyboardType = UIKeyboardTypeASCIICapable;

    [self.view addSubview:self.isDrugEatedLabel];
    [self.view addSubview:self.dailyDrinkedWaterLiterLabel];
    [self.view addSubview:self.markDrugEatedButton];
    [self.view addSubview:self.recordWaterDrinkedButton];
    [self.view addSubview:self.waterDrinkPerTimeTextField];
    
    /// 0 是没吃
    if(![self.storedConfig[@"drugEated"] isEqual: @"0"]){
        [self markDrugEated];
    }
    self.waterDrinkPerTimeTextField.text = self.storedConfig[@"drinkPerTime"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)updateViewConstraints{
    [self.isDrugEatedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.navigationController.navigationBar.mas_bottom).offset(100);
        make.right.mas_equalTo(self.view.mas_centerX).offset(-10);
    }];
    
    [self.markDrugEatedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.isDrugEatedLabel);
        make.left.mas_equalTo(self.view.mas_centerX).offset(10);
        make.width.mas_equalTo(50);
    }];
    
    [self.waterDrinkPerTimeTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(200);
        make.top.mas_equalTo(self.isDrugEatedLabel.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self.view);
    }];
    
    [self.dailyDrinkedWaterLiterLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.top.mas_equalTo(self.waterDrinkPerTimeTextField.mas_bottom).offset(10);
        make.width.mas_lessThanOrEqualTo(200);
    }];
    
    [self.recordWaterDrinkedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dailyDrinkedWaterLiterLabel.mas_right).offset(20);
        make.centerY.mas_equalTo(self.dailyDrinkedWaterLiterLabel);
        make.width.mas_equalTo(80);
    }];
    
    [super updateViewConstraints];
}

#pragma mark - 获取label
- (UILabel *)getTitleLabelWithFontSize: (CGFloat)fontSize andText:(NSString *)titleText{
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont systemFontOfSize:fontSize];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByClipping; // break in words
    
    titleLabel.text = titleText;
    return titleLabel;
}
#pragma mark - 获取并初始化StoredConfig
//@{
// @"drugEated": @"0",
// @"drinkPerTime": @"400",
// @"totalDrinked": @500,
// @"storedDate": 2021-02-02
//}
- (NSMutableDictionary *)getStoredConfig{
    BOOL isContains= [[PINCache sharedCache] containsObjectForKey:dailyCacheKey];
    NSDictionary *returnDict = @{};
    NSString *currentDate = [self getDateString];
    
    if(isContains){
        NSMutableDictionary *tempDict = [[[PINCache sharedCache] objectForKey:dailyCacheKey] mutableCopy];
        
        NSString *storedDate = tempDict[@"storedDate"];
        if (![storedDate isEqualToString: currentDate]) {
            tempDict[@"drugEated"] = @"0";
            tempDict[@"totalDrinked"] = @0;
            tempDict[@"storedDate"] = currentDate;
            
            [[PINCache sharedCache] setObject:tempDict forKey:dailyCacheKey];
        }
        
        returnDict = tempDict;
    }
    else{
        returnDict = @{
            @"drugEated": @"0",
            @"drinkPerTime": @"500",
            @"totalDrinked": @0,
            @"storedDate": currentDate
        };
        
        [[PINCache sharedCache] setObject:returnDict forKey:dailyCacheKey];
    }
    return [returnDict mutableCopy];
}

- (NSString *)getDateString{
    NSTimeZone* timeZone = [NSTimeZone localTimeZone];
    [staticDateFormatter setTimeZone:timeZone];
    
    [staticDateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [staticDateFormatter stringFromDate:[NSDate date]];
}

- (void)hideKeyboard{
    [self.view endEditing:YES];
}
#pragma mark - 会对storedConfig做修改的的方法
- (void)updateDrinkedWaterValue{
    int totalDrinked = [self.storedConfig[@"totalDrinked"] intValue];
    int currentDrinkPerTime = [self.waterDrinkPerTimeTextField.text intValue];
    totalDrinked += currentDrinkPerTime;
    self.storedConfig[@"totalDrinked"] = @(totalDrinked);
    
    self.dailyDrinkedWaterLiterLabel.text = [NSString stringWithFormat:@"已经喝了 %d ml", totalDrinked];
    
    [self storeDailyConfigToLocal];
}

- (void)markDrugEated{
    self.storedConfig[@"drugEated"] = @"1";
    self.isDrugEatedLabel.text = @"恰过💊了";
    self.markDrugEatedButton.hidden = YES;
    
    [self storeDailyConfigToLocal];
}

- (void)editingValueChange:(UITextField *)field{
    self.storedConfig[@"drinkPerTime"] = field.text;
    
    [self storeDailyConfigToLocal];
}

#pragma mark - 存配置到本地
- (void)storeDailyConfigToLocal{
    if (self.storeToStorageTimer) {
        [self.storeToStorageTimer invalidate];
        self.storeToStorageTimer = nil;
    }
    
    self.storeToStorageTimer = [NSTimer timerWithTimeInterval:2 block:^(NSTimer * _Nonnull timer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[PINCache sharedCache] setObject:self.storedConfig forKey:dailyCacheKey];
        });
    } repeats:NO];
}
@end
