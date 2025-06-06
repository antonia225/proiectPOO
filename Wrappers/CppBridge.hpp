#pragma once

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CppBridge : NSObject

#pragma mark – User

+ (BOOL)createUser:(NSString *)username
               name:(NSString *)name
           password:(NSString *)password;

+ (nullable NSString *)loginUser:(NSString *)username
                        password:(NSString *)password;

+ (int)getClothingItemCountForUser:(NSString *)username;
+ (int)getOutfitCountForUser:(NSString *)username;

#pragma mark – ClothingItem

/**
 Fetch-ează toate ClothingItem-urile pentru un user.
 Fiecare NSDictionary conține:
   @"id": NSNumber (int),
   @"category": NSString,
   @"color": NSString,
   @"materials": NSArray<NSString *>,
   @"subcategory": NSString,
   @"image": NSData
*/
+ (NSArray<NSDictionary *> *)fetchClothingItemsForUser:(NSString *)username;

/**
 Salvează un ClothingItem nou pentru user.
 @param username       – username-ul proprietarului
 @param color          – culoarea articolului
 @param materials      – array de NSString cu materialele
 @param category       – categoria articolului (ex. "pants", "jacket", "top", "suit")
 @param subcategory    – subcategoria articolului
 @param pantLungime    – lungimea pentru `pants` (Float). Ignorat dacă nu e pants.
 @param pantTalie      – talia pentru `pants` (NSString). Ignorat dacă nu e pants.
 @param jacketWaterproof – `BOOL` pentru `jacket` (waterproof). Ignorat dacă nu e jacket.
 @param topLungimeManeca – lungimea mânecii pentru `top` (Double). Ignorat dacă nu e top.
 @param topDecolteu      – tip de decolteu pentru `top` (NSString). Ignorat dacă nu e top.
 @param suitLungime      – lungimea pentru `suit` (Float). Ignorat dacă nu e suit.
 @param suitTalie        – talia pentru `suit` (NSString). Ignorat dacă nu e suit.
 @param suitWaterproof   – `BOOL` pentru `suit` (waterproof). Ignorat dacă nu e suit.
 @param suitIsMatchy     – `BOOL` pentru `suit` (matchy set). Ignorat dacă nu e suit.
 @param suitPattern      – pattern-ul pentru `suit` (NSString). Ignorat dacă nu e suit.
 @param imageData        – NSData conținând bytes-ul imaginii
 @return YES dacă a reușit salvarea, NO altfel.
*/
+ (BOOL)saveClothingItemForUser:(NSString *)username
                          color:(NSString *)color
                      materials:(NSArray<NSString *> *)materials
                       category:(NSString *)category
                    subcategory:(NSString *)subcategory
                   pantLungime:(float)lungimePants
                     pantTalie:(NSString * _Nullable)taliePants
             jacketWaterproof:(BOOL)waterproofJacket
              topLungimeManeca:(double)lungimeManecaTop
                  topDecolteu:(NSString * _Nullable)decolteuTop
                   suitLungime:(float)lungimeSuit
                    suitTalie:(NSString * _Nullable)talieSuit
                suitWaterproof:(BOOL)waterproofSuit
                  suitIsMatchy:(BOOL)isMatchySuit
                    suitPattern:(NSString * _Nullable)patternSuit
                         image:(NSData * _Nullable)imageData;

/**
 Șterge ClothingItem-ul cu id-ul dat pentru user.
 @return YES dacă a găsit și a șters elementul, NO altfel.
*/
+ (BOOL)deleteClothingItemForUser:(NSString *)username
                           itemId:(int)itemId;

#pragma mark – Outfit

/**
 Fetch-ează toate Outfit-urile pentru un user.
 Fiecare NSDictionary conține:
   @"id": NSString,
   @"name": NSString,
   @"dateAdded": NSString (format "DD-MM-YYYY"),
   @"season": NSString
*/
+ (NSArray<NSDictionary *> *)fetchOutfitsForUser:(NSString *)username;

/**
 Salvează un Outfit nou pentru user.
 @param username  – username-ul proprietarului
 @param name      – numele outfit-ului
 @param dateAdded – data adăugării ("DD-MM-YYYY")
 @param season    – sezonul (“vara”, “iarna” etc.)
 @return YES dacă a reușit salvarea, NO altfel.
*/
+ (BOOL)saveOutfitForUser:(NSString *)username
                     name:(NSString *)name
                dateAdded:(NSString *)dateAdded
                   season:(NSString *)season;

/**
 Șterge Outfit-ul cu id-ul dat pentru user.
 @return YES dacă a găsit și a șters outfit-ul, NO altfel.
*/
+ (BOOL)deleteOutfitForUser:(NSString *)username
                  outfitId:(NSString *)outfitId;

/**
 Returnează sugestia de outfit pentru ziua curentă (bazat pe sezon).
 Dacă nu există niciun outfit pentru sezonul curent, returnează nil.
 Formatul NSDictionary este același ca la fetchOutfitsForUser: cheile
   @"id", @"name", @"dateAdded", @"season"
*/
+ (nullable NSDictionary *)getTodaySuggestionForUser:(NSString *)username;

#pragma mark – Filtrare simplă

/**
 Filtrează ClothingItem-urile după culoare.
 Returnează array de NSDictionary ca la fetchClothingItemsForUser.
*/
+ (NSArray<NSDictionary *> *)fetchAndFilterItemsForUser:(NSString *)username
                                                 color:(NSString *)color;

/**
 Filtrează Outfit-urile după sezon.
 Returnează array de NSDictionary ca la fetchOutfitsForUser.
*/
+ (NSArray<NSDictionary *> *)fetchAndFilterOutfitsForUser:(NSString *)username
                                                   season:(NSString *)season;

@end

NS_ASSUME_NONNULL_END
