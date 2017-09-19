//
//  RLUtils.m
//  Relaced
//
//  Created by Benjamin Madueme on 10/19/14.
//
//

#import "RLUtils.h"
#import "PAPSettingsActionSheetDelegate.h"
#import "PAPSettingsButtonItem.h"

NSString * const kRLMerchantID = @"merchant.mendedapp.kd";

NSString * const kRLBusinessName = @"Mended";
CGFloat const kRLShippingRate = 15.0f;
CGFloat const kRLMinimumPaidDollars = 0.5f; // Stripe's minimum is $0.50
NSString * const kRLPaymentTypeCreditCard = @"credit_card";
NSString * const kRLPaymentTypeApplePay = @"apple_pay";

NSString * const kRLShoeImage2 = @"image2";
NSString * const kRLShoeImage3 = @"image3";
NSString * const kRLShoeImage4 = @"image4";
NSString * const kRLShoeImage5 = @"image5";
NSString * const kRLShoeImage6 = @"image6";

NSString * const kRLPhotoClass = @"Photo";
NSString * const kRLUserClass = @"_User";
NSString * const kRLAddressClass = @"Address";
NSString * const kRLCreditsClass = @"Credits";
NSString * const kRLCardClass = @"Card";

NSString * const kRLUserKey = @"user";
NSString * const kRLObjectIdKey = @"objectId";
NSString * const kRLPriceKey = @"price";
NSString * const kRLSizeKey = @"size";
NSString * const kRLBrandKey = @"brand";
NSString * const kRLCategoryKey = @"category";
NSString * const kRLColorKey = @"color";
NSString * const kRLConditionKey = @"condition";
NSString * const kRLUpdatedAtKey = @"updatedAt";
NSString * const kRLCreatedAtKey = @"createdAt";
NSString * const kRLIsSoldKey = @"isSold";
NSString * const kRLDisplayNameKey = @"displayName";
NSString * const kRLLowercaseNameKey = @"lowercaseName";
NSString * const kRLBalanceKey = @"balance";
NSString * const kRLAddressLine1Key = @"addressLine1";
NSString * const kRLCityKey = @"city";
NSString * const kRLPersonNameKey = @"personName";
NSString * const kRLPostalCodeKey = @"postalCode";
NSString * const kRLStateOrRegionKey = @"stateOrRegion";
NSString * const kRLDescriptionKey = @"description";
NSString * const kRLExpirationMonthKey = @"expirationMonth";
NSString * const kRLExpirationYearKey = @"expirationYear";
NSString * const kRLLastFourKey = @"lastFour";
NSString * const kRLCustomerTokenKey = @"customerToken";
NSString * const kRLTransactionKey = @"transaction";
NSString * const kRLShippingAddressKey = @"shippingAddress";

NSString * const kRLCreateCustomerFunction = @"createCustomer";
NSString * const kRLBuyPhotoFunction = @"buyPhoto";
NSString * const kRLPerformPhotoReservationFunction = @"performPhotoReservation";
NSString * const kRLCancelPhotoReservationFunction = @"cancelPhotoReservation";

NSString * const kRLPhotoIdParameterKey = @"photoId";
NSString * const kRLTokenParameterKey = @"token";
NSString * const kRLCustomerParameterKey = @"customer";
NSString * const kRLPaymentTypeParameterKey = @"paymentType";
NSString * const kRLShippingAddressParameterKey = @"shippingAddress";
NSString * const kRLCalculatedCreditsDeductedParameterKey = @"calculatedCreditsDeducted";

NSString * const kRLTransactionSuccessfulMsgTitle = @"Purchase Successful!";
NSString * const kRLTransactionSuccessfulMsg = @"Your transaction was successfully processed, and your Relaced balance was updated.";

NSString * const kRLNetworkErrorMsgTitle = @"Network Problem!";
NSString * const kRLNetworkErrorMsg =  @"Relaced seems to be having some trouble accessing the Internet. Check your network settings, or try this operation again at a later time.";

NSString * const kRLApplePayUnsupportedMsgTitle = @"Apple Pay Unsupported";
NSString * const kRLApplePayUnsupportedMsg = @"Relaced had a problem processing your transaction with Apple Pay, and your Apple Pay account was not charged.  Let's try using a credit card instead.";

NSString * const kRLCardPaymentErrorOccurredMsgTitle = @"Payment Error!";
NSString * const kRLCardPaymentErrorOccurredMsg = @"An error occurred processing your transaction - please double-check your payment information.  If the problem persists, verify your device has Internet connectivity.";

static PAPSettingsButtonItem * settingsButtonItem = nil;
static PAPSettingsActionSheetDelegate * settingsActionSheetDelegate = nil;

@implementation RLUtils

+(UIColor *)relacedRed
{
    return [UIColor colorWithRed:65.0f/255.0f green:200.0f/255.0f blue:244.0f/255.0f alpha:1.0f];
}

+ (NSArray *)sizeFiltersList
{
    return @[@"xs", @"s", @"m", @"l", @"xl", @"xll", @"1", @"2", @"3", @"4", @"5", @"6",  @"7",  @"8",  @"9", @"10", @"11", @"12", @"13", @"14", @"15"];
}

+ (NSArray *)priceFiltersList
{
    return @[@"Less Than $20", @"$20 - $30", @"$30 - $50", @"$50 - $75", @"$75 - $100", @"$100 - $150", @"$150 - $250", @"$250 - $400",
             @"$400 - $600", @"$600 - $1000", @"Over $1000"];
}

+ (NSArray *)soldFiltersList
{
    return @[@"Already Sold", @"Still Available"];
}

+(NSArray *)categoryFiltersList
{
    return @[@"Accessories", @"Bags", @"Dresses", @"Intimates & Sleepwear", @"Jackets & Coats", @"Jeans", @"Jewelry", @"Makeup", @"Pants", @"Shoes",  @"Shorts", @"Skirts", @"Sweaters", @"Swim", @"Tops", @"Other"];
}

+(NSArray *)brandFiltersList//up-
{
    return @[@"Adidas", @"ASOS", @"André", @"Atmosphere", @"Abercrombie & Fitch", @"Bershka", @"Camaieu", @"Diesel", @"Etam", @"Forever 21",  @"Guess", @"H&M", @"IKKS", @"Jennyfer", @"Kiabi", @"La Redoute", @"Mango", @"Nike", @"Pimkie", @"Roxy", @"River Island", @"Stradivarius", @"Texto", @"Undiz", @"Vero Moda", @"Xanaka", @"Yessica", @"Zara"];
}

+(NSArray *)colorFiltersList//up-
{
    return @[@"Red", @"Pink", @"Orange", @"Yellow", @"Green", @"Blue", @"Purple", @"Gold", @"Silver", @"Black",  @"Gray", @"White", @"Cream", @"Brown", @"Tan"];
}

+(NSArray *)conditionFiltersList//up-
{
    return @[@"Good", @"Fair", @"Used"];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (PAPSettingsButtonItem *)sharedSettingsButtonItem
{
    if (settingsButtonItem == nil) {
        settingsButtonItem = [[PAPSettingsButtonItem alloc] initWithTarget:self action:@selector(settingsButtonAction:)];
    }
    return settingsButtonItem;
}

+ (UIButton *)sharedSettingsButton
{
    UIButton *button = [[UIButton alloc] init];
    [button setBackgroundImage:[UIImage imageNamed:@"buttonImageSettings.png"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(settingsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (void)settingsButtonAction:(id)sender {
    UIWindow * sharedWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController * displayedViewController = [RLUtils topViewControllerWithRootViewController:sharedWindow.rootViewController];
    
    settingsActionSheetDelegate = [[PAPSettingsActionSheetDelegate alloc] initWithNavigationController:displayedViewController.navigationController];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:settingsActionSheetDelegate
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Featured Users", nil),
                                  NSLocalizedString(@"My Messages", nil),
                                  NSLocalizedString(@"My Balance", nil),
                                  NSLocalizedString(@"Log Out", nil), nil];
    
    if(displayedViewController.tabBarController.navigationController)
        [actionSheet showFromTabBar:displayedViewController.tabBarController.tabBar];
    else [actionSheet showInView:displayedViewController.view];
}

//From http://stackoverflow.com/a/17578272/1133921
+ (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

+ (void)displayAlertWithTitle:(NSString *)title message:(NSString *)message postDismissalBlock:(void (^)(void))postDismissalHandler
{
    UIWindow * sharedWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController * displayedViewController = [RLUtils topViewControllerWithRootViewController:sharedWindow.rootViewController];

    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title
                                                                              message:message
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"OK, Got It"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action)
                                                        {
                                                            [alertController dismissViewControllerAnimated:YES completion:nil];
                                                            if (postDismissalHandler) postDismissalHandler();
                                                        }];
    
    [alertController addAction:okAction];
    [displayedViewController presentViewController:alertController animated:YES completion:nil];
    
}


@end
