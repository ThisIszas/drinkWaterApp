//
//  MainPageViewController.m
//  DailyRecord
//
//  Created by Zheng Li on 2021/7/15.
//

#import "MainPageViewController.h"
#import <YYKit/YYKit.h>
#import <Masonry/Masonry.h>

@interface MainPageViewController ()
@property(nonatomic, strong) UILabel *isDrugEatedLabel;
@property(nonatomic, strong) UIButton *markDrugEatedButton;
@property(nonatomic, strong) UILabel *dailyDrinkedWaterLiterLabel;
@property(nonatomic, strong) UITextField *waterDrinkPerTimeTextField;
@property(nonatomic, strong) UIButton *recordWaterDrinkedButton;
@end

@implementation MainPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor grayColor];
    
    self.isDrugEatedLabel = [self getTitleLabelWithFontSize:20 andText:@"💊不能停"];
    self.dailyDrinkedWaterLiterLabel = [self getTitleLabelWithFontSize:20 andText:@"已经喝了 0 ml"];
    
    self.markDrugEatedButton = [UIButton new];
    [self.markDrugEatedButton setTitle:@"吃!" forState:UIControlStateNormal];
    self.markDrugEatedButton.layer.borderWidth = 2;
    self.markDrugEatedButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.markDrugEatedButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    
    self.recordWaterDrinkedButton = [UIButton new];
    [self.recordWaterDrinkedButton setTitle:@"继续喝!" forState:UIControlStateNormal];
    self.recordWaterDrinkedButton.layer.borderWidth = 2;
    self.recordWaterDrinkedButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.recordWaterDrinkedButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    
    self.waterDrinkPerTimeTextField = [UITextField new];
    self.waterDrinkPerTimeTextField.layer.borderWidth = 3;
    self.waterDrinkPerTimeTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    self.waterDrinkPerTimeTextField.leftView = paddingView;
    self.waterDrinkPerTimeTextField.leftViewMode = UITextFieldViewModeAlways;

    
    [self.view addSubview:self.isDrugEatedLabel];
    [self.view addSubview:self.dailyDrinkedWaterLiterLabel];
    [self.view addSubview:self.markDrugEatedButton];
    [self.view addSubview:self.recordWaterDrinkedButton];
    [self.view addSubview:self.waterDrinkPerTimeTextField];
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


- (UILabel *)getTitleLabelWithFontSize: (CGFloat)fontSize andText:(NSString *)titleText{
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont systemFontOfSize:fontSize];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByClipping; // break in words
    
    titleLabel.text = titleText;
    return titleLabel;
}

@end
