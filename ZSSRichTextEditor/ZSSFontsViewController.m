//
//  ZSSFontsViewController.m
//  ZSSRichTextEditor
//
//  Created by Will Swan on 03/09/2016.
//  Copyright © 2016 Zed Said Studio. All rights reserved.
//

#import "ZSSFontsViewController.h"

@interface ZSSFontsViewController () <UITableViewDelegate,UITableViewDataSource> {
    
    ZSSFontFamily selectedFontFamily;
    
}

@end

@implementation ZSSFontsViewController

@synthesize delegate;

#pragma mark - Init Section
+ (ZSSFontsViewController *)cancelableFontPickerViewControllerWithFontFamily:(ZSSFontFamily)fontFamily {
    return [[ZSSFontsViewController alloc] initWithFontFamily:fontFamily];
}

- (id)initWithFontFamily:(ZSSFontFamily)fontFamily {

    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _font = fontFamily;
    }
    return self;
    
}

#pragma mark - View Did Load Section
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if (self.navigationController) {
        //Set up navigation
        [self setUpNavigation];
        
        //Create table view
        [self createTableView];
    }
    else {
        UIToolbar *toolbar = [UIToolbar.alloc initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
        toolbar.items = @[[UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)],
                          [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                          [UIBarButtonItem.alloc initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)]];
        [self.view addSubview:toolbar];
        
        UITableView *tableView = UITableView.new;
        tableView.frame = CGRectMake(0, CGRectGetMaxY(toolbar.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(toolbar.frame));
        tableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        tableView.delegate = self;
        tableView.dataSource = self;
        
        [self.view addSubview:tableView];
    }
    
}

#pragma mark - Set Up View Section

- (void)setUpNavigation {
    
    self.navigationItem.title = @"Fonts";
    
    UIBarButtonItem *buttonItem;
    
    buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = buttonItem;
    
    buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = buttonItem;
    
}

- (void)createTableView {
    
    UITableView *tableView = [[UITableView alloc] init];
    tableView.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height - self.navigationController.navigationBar.frame.size.height);
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:tableView];
    
}

#pragma mark - Table View Section

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 7;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"fontCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    float fontSize = 20.0f;
    
    switch (indexPath.row) {
        case 0:
        cell.textLabel.text = @"Default";
        cell.textLabel.font = [UIFont fontWithName:@"ArialMT" size:fontSize];
        break;

        case 1:
        cell.textLabel.text = @"Trebuchet";
        cell.textLabel.font = [UIFont fontWithName:@"TrebuchetMS" size:fontSize];
        break;
        
        case 2:
        cell.textLabel.text = @"Verdana";
        cell.textLabel.font = [UIFont fontWithName:@"Verdana" size:fontSize];
        break;
        
        case 3:
        cell.textLabel.text = @"Georgia";
        cell.textLabel.font = [UIFont fontWithName:@"Georgia" size:fontSize];
        break;
        
        case 4:
        cell.textLabel.text = @"Palatino";
        cell.textLabel.font = [UIFont fontWithName:@"Palatino-Roman" size:fontSize];
        break;
        
        case 5:
        cell.textLabel.text = @"Times New Roman";
        cell.textLabel.font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:fontSize];
        break;
        
        case 6:
        cell.textLabel.text = @"Courier New";
        cell.textLabel.font = [UIFont fontWithName:@"CourierNewPSMT" size:fontSize];
        break;
        
        default:
        break;
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    switch (indexPath.row) {
        case 0:
        selectedFontFamily = ZSSFontFamilyDefault;
        break;
        
        case 1:
        selectedFontFamily = ZSSFontFamilyTrebuchet;
        break;
        
        case 2:
        selectedFontFamily = ZSSFontFamilyVerdana;
        break;
        
        case 3:
        selectedFontFamily = ZSSFontFamilyGeorgia;
        break;
        
        case 4:
        selectedFontFamily = ZSSFontFamilyPalatino;
        break;
        
        case 5:
        selectedFontFamily = ZSSFontFamilyTimesNew;
        break;
        
        case 6:
        selectedFontFamily = ZSSFontFamilyCourierNew;
        break;
        
        default:
        break;
    }
    
}

#pragma mark - Navigation Item Interactions Section

- (void)save {
    
    if (self.delegate) {
        //HRRGBColor rgbColor = [colorPickerView RGBColor];
        [self.delegate setSelectedFontFamily:selectedFontFamily];
    }
    
    if (self.navigationController)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self dismissViewControllerAnimated:YES completion:NULL];

}

- (void)save:(id)sender {
    [self save];
}

- (void)cancel:(id)sender {
    if (self.navigationController)
        [self.navigationController popViewControllerAnimated:YES];
    else
        [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Memory Warning Section
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
