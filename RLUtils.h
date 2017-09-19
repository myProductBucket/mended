//
//  RLUtils.h
//  Relaced
//
//  Created by Benjamin Madueme on 10/19/14.
//
//

#import <Foundation/Foundation.h>
@class PAPSettingsButtonItem;

extern NSString * const kRLMerchantID;

extern NSString * const kRLBusinessName;
extern CGFloat const kRLShippingRate;
extern CGFloat const kRLMinimumPaidDollars;
extern NSString * const kRLPaymentTypeCreditCard;
extern NSString * const kRLPaymentTypeApplePay;

extern NSString * const kRLShoeImage2;
extern NSString * const kRLShoeImage3;
extern NSString * const kRLShoeImage4;
extern NSString * const kRLShoeImage5;
extern NSString * const kRLShoeImage6;

extern NSString * const kRLPhotoClass;
extern NSString * const kRLUserClass;
extern NSString * const kRLAddressClass;
extern NSString * const kRLCreditsClass;
extern NSString * const kRLCardClass;

extern NSString * const kRLObjectIdKey;
extern NSString * const kRLPriceKey;
extern NSString * const kRLSizeKey;
extern NSString * const kRLBrandKey;
extern NSString * const kRLCategoryKey;
extern NSString * const kRLColorKey;
extern NSString * const kRLConditionKey;
extern NSString * const kRLUpdatedAtKey;
extern NSString * const kRLCreatedAtKey;
extern NSString * const kRLIsSoldKey;
extern NSString * const kRLDisplayNameKey;
extern NSString * const kRLLowercaseNameKey;
extern NSString * const kRLUserKey;
extern NSString * const kRLBalanceKey;
extern NSString * const kRLAddressLine1Key;
extern NSString * const kRLCityKey;
extern NSString * const kRLPersonNameKey;
extern NSString * const kRLPostalCodeKey;
extern NSString * const kRLStateOrRegionKey;
extern NSString * const kRLDescriptionKey;
extern NSString * const kRLExpirationMonthKey;
extern NSString * const kRLExpirationYearKey;
extern NSString * const kRLLastFourKey;
extern NSString * const kRLCustomerTokenKey;
extern NSString * const kRLTransactionKey;
extern NSString * const kRLShippingAddressKey;

extern NSString * const kRLCreateCustomerFunction;
extern NSString * const kRLBuyPhotoFunction;
extern NSString * const kRLPerformPhotoReservationFunction;
extern NSString * const kRLCancelPhotoReservationFunction;

extern NSString * const kRLPhotoIdParameterKey;
extern NSString * const kRLTokenParameterKey;
extern NSString * const kRLCustomerParameterKey;
extern NSString * const kRLPaymentTypeParameterKey;
extern NSString * const kRLShippingAddressParameterKey;
extern NSString * const kRLCalculatedCreditsDeductedParameterKey;

extern NSString * const kRLTransactionSuccessfulMsgTitle;
extern NSString * const kRLTransactionSuccessfulMsg;

extern NSString * const kRLNetworkErrorMsgTitle;
extern NSString * const kRLNetworkErrorMsg;
extern NSString * const kRLApplePayUnsupportedMsgTitle;
extern NSString * const kRLApplePayUnsupportedMsg;
extern NSString * const kRLCardPaymentErrorOccurredMsgTitle;
extern NSString * const kRLCardPaymentErrorOccurredMsg;

@interface RLUtils : NSObject

+ (UIColor *)relacedRed;
+ (UIColor *)colorFromHexString:(NSString *)hexString;

+ (NSArray *)sizeFiltersList;
+ (NSArray *)priceFiltersList;
+ (NSArray *)soldFiltersList;
+ (NSArray *)categoryFiltersList;
+ (NSArray *)brandFiltersList;
+ (NSArray *)colorFiltersList;
+ (NSArray *)conditionFiltersList;
+ (PAPSettingsButtonItem *)sharedSettingsButtonItem;
+ (UIButton *)sharedSettingsButton;//created by urban
+ (void)displayAlertWithTitle:(NSString *)title message:(NSString *)message postDismissalBlock:(void (^)(void))postDismissalHandler;

@end
