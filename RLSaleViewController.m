//
//  RLSaleViewController.m
//  Relaced
//
//  Created by Mybrana on 14/04/15.
//
//

#import "RLSaleViewController.h"
#import "RLUtils.h"

@interface RLSaleViewController ()

@property (weak, nonatomic) IBOutlet UILabel *addressDetailsLabel;

@end

@implementation RLSaleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"SALE";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.addressDetailsLabel.text = self.transactionObject[kRLShippingAddressKey];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
