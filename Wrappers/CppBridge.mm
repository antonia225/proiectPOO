#import "CppBridge.hpp"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#include <string>
#include <vector>
#include <memory>      
#include <functional>

// Include-urile pentru modelele și DataManager-ul C++
#include "DataManager.hpp"
#include "ClothingItem.hpp"
#include "Outfit.hpp"
#include "Utilities.hpp"
#include "ItemFactory.hpp"
#include "User.hpp"
#include "ItemFilter.hpp"
#include "OutfitFilter.hpp"
#include "CurrentUser.hpp"
#include "EventManager.hpp"

using namespace std;

// Helper: convertește NSArray<NSString *> în vector<string>
static vector<string> toStdStringVector(NSArray<NSString *> *array) {
    vector<string> result;
    for (NSString *str in array) {
        result.push_back(string([str UTF8String]));
    }
    return result;
}

// Helper: construiește NSDictionary pentru un ClothingItem C++
static NSDictionary<NSString *, id> *dictFromClothingItem(const shared_ptr<ClothingItem> &item) {
    NSNumber *itemId = [NSNumber numberWithInt:item->getId()];
    NSString *category = [NSString stringWithUTF8String:item->getCategory().c_str()];
    NSString *color = [NSString stringWithUTF8String:item->getColor().c_str()];

    // materials
    vector<string> mats = item->getMaterials();
    NSMutableArray<NSString *> *matArray = [NSMutableArray arrayWithCapacity:mats.size()];
    for (const auto &m : mats) {
        [matArray addObject:[NSString stringWithUTF8String:m.c_str()]];
    }

    NSString *subcategory = [NSString stringWithUTF8String:item->getSubcategory().c_str()];

    // image
    const vector<uint8_t> &bytes = item->getImage();
    NSData *imageData = nil;
    if (!bytes.empty()) {
        imageData = [NSData dataWithBytes:bytes.data() length:bytes.size()];
    } else {
        imageData = [NSData data];
    }

    return @{
        @"id"         : itemId,
        @"category"   : category,
        @"color"      : color,
        @"materials"  : (matArray.count ? matArray : @[]),
        @"subcategory": subcategory,
        @"image"      : imageData
    };
}

// Helper: construiește NSDictionary pentru un Outfit C++
static NSDictionary<NSString *, id> *dictFromOutfit(const shared_ptr<Outfit> &outfit) {
    NSString *outfitId  = [NSString stringWithUTF8String:outfit->getId().c_str()];
    NSString *name      = [NSString stringWithUTF8String:outfit->getName().c_str()];
    NSString *dateAdded = [NSString stringWithUTF8String:outfit->getDateAdded().c_str()];
    NSString *season    = [NSString stringWithUTF8String:outfit->getSeason().c_str()];
    return @{
        @"id"        : outfitId,
        @"name"      : name,
        @"dateAdded" : dateAdded,
        @"season"    : season
    };
}

@implementation CppBridge

#pragma mark – User

+ (BOOL)createUser:(NSString *)username
               name:(NSString *)name
           password:(NSString *)password
{
    std::string u = [username UTF8String];
    std::string n = [name UTF8String];
    std::string p = [password UTF8String];
    return DataManager::getInstance().createUser(u, n, p);
}

+ (nullable NSString *)loginUser:(NSString *)username
                        password:(NSString *)password
{
    std::string u = [username UTF8String];
    std::string p = [password UTF8String];
    auto cppUser = DataManager::getInstance().loginUser(u, p);
    if (!cppUser) {
        return nil;
    }
    return [NSString stringWithUTF8String:cppUser->getUsername().c_str()];
}

+ (int)getClothingItemCountForUser:(NSString *)username {
    std::string u = [username UTF8String];
    return DataManager::getInstance().getClothingItemCount(u);
}

+ (int)getOutfitCountForUser:(NSString *)username {
    std::string u = [username UTF8String];
    return DataManager::getInstance().getOutfitCount(u);
}

#pragma mark – ClothingItem

+ (NSArray<NSDictionary *> *)fetchClothingItemsForUser:(NSString *)username {
    std::string u = [username UTF8String];
    auto cppItems = DataManager::getInstance().fetchClothingItemsForUser(u);
    NSMutableArray<NSDictionary *> *result = [NSMutableArray arrayWithCapacity:cppItems.size()];
    for (auto &itemPtr : cppItems) {
        [result addObject:dictFromClothingItem(itemPtr)];
    }
    return result;
}

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
                         image:(NSData * _Nullable)imageData
{
    
    std::string u   = [username UTF8String];
    std::string c   = [color    UTF8String];
    std::string cat = [category UTF8String];
    std::string sub = [subcategory UTF8String];

    vector<string> mats = toStdStringVector(materials);

    vector<uint8_t> bytes;
    if (imageData != nil && imageData.length > 0) {
        const uint8_t *rawPtr = (const uint8_t *)imageData.bytes;
        bytes.assign(rawPtr, rawPtr + imageData.length);
    }

    static int clothingCounter = 0;
    int newId = ++clothingCounter;

    std::shared_ptr<ClothingItem> cppItem;

    if ([category isEqualToString:@"pants"]) {
        std::string tal = "";
        if (taliePants != nil) {
            tal = [taliePants UTF8String];
        }
        float lungP = lungimePants;

        cppItem = Factory::createPants(
            newId,
            c,
            mats,
            cat,
            sub,
            bytes,
            lungP,
            tal
        );
    }
    else if ([category isEqualToString:@"jacket"]) {
        bool wp = waterproofJacket;
        cppItem = Factory::createJacket(
            newId,
            c,
            mats,
            cat,
            sub,
            bytes,
            wp
        );
    }
    else if ([category isEqualToString:@"top"]) {
        std::string decStr = "";
        if (decolteuTop != nil) {
            decStr = [decolteuTop UTF8String];
        }
        double lungMan = lungimeManecaTop;
        cppItem = Factory::createTop(
            newId,
            c,
            mats,
            cat,
            sub,
            bytes,
            lungMan,
            decStr
        );
    }
    else if ([category isEqualToString:@"suit"]) {
        std::string talStr = "";
        if (talieSuit != nil) {
            talStr = [talieSuit UTF8String];
        }
        std::string patStr = "";
        if (patternSuit != nil) {
            patStr = [patternSuit UTF8String];
        }
        float lungS = lungimeSuit;
        bool  wpS   = waterproofSuit;
        bool  im    = isMatchySuit;

        cppItem = Factory::createSuit(
            newId,
            c,
            mats,
            cat,
            sub,
            bytes,
            lungS,
            talStr,
            wpS,
            im,
            patStr
        );
    }
    else {
        // categorie necunoscută → returnăm NO
        return NO;
    }

    if (!cppItem) {
        return NO;
    }

    bool succes = DataManager::getInstance().saveClothingItem(u, *cppItem);
    return (succes ? YES : NO);
}

+ (BOOL)deleteClothingItemForUser:(NSString *)username
                           itemId:(int)itemId
{
    std::string u = [username UTF8String];
    return DataManager::getInstance().deleteClothingItem(u, itemId);
}

#pragma mark – Outfit

+ (NSArray<NSDictionary *> *)fetchOutfitsForUser:(NSString *)username {
    std::string u = [username UTF8String];
    auto cppOutfits = DataManager::getInstance().fetchOutfitsForUser(u);
    NSMutableArray<NSDictionary *> *result = [NSMutableArray arrayWithCapacity:cppOutfits.size()];
    for (auto &oPtr : cppOutfits) {
        [result addObject:dictFromOutfit(oPtr)];
    }
    return result;
}

+ (BOOL)saveOutfitForUser:(NSString *)username
                     name:(NSString *)name
                dateAdded:(NSString *)dateAdded
                   season:(NSString *)season
{
    std::string u    = [username UTF8String];
    std::string nm   = [name UTF8String];
    std::string date = [dateAdded UTF8String];
    std::string s    = [season UTF8String];

    auto cppOutfit = Factory::createOutfit(nm, date, s);
    return DataManager::getInstance().saveOutfit(u, *cppOutfit);
}

+ (BOOL)deleteOutfitForUser:(NSString *)username
                  outfitId:(NSString *)outfitId
{
    std::string u   = [username UTF8String];
    std::string oid = [outfitId UTF8String];
    return DataManager::getInstance().deleteOutfit(u, oid);
}

+ (nullable NSDictionary *)getTodaySuggestionForUser:(NSString *)username {
    std::string u = [username UTF8String];
    auto suggestion = DataManager::getInstance().getTodaySuggestion(u);
    if (!suggestion) {
        return nil;
    }
    return dictFromOutfit(suggestion);
}

#pragma mark – Filtrare simplă

+ (NSArray<NSDictionary *> *)fetchAndFilterItemsForUser:(NSString *)username
                                                  color:(NSString *)color
{
    std::string u = [username UTF8String];
    std::string c = [color UTF8String];
    ColorFilter filter(c);
    auto filtered = DataManager::getInstance().fetchAndFilterItems(u, filter);
    NSMutableArray<NSDictionary *> *result = [NSMutableArray arrayWithCapacity:filtered.size()];
    for (auto &itemPtr : filtered) {
        [result addObject:dictFromClothingItem(itemPtr)];
    }
    return result;
}

+ (NSArray<NSDictionary *> *)fetchAndFilterOutfitsForUser:(NSString *)username
                                                    season:(NSString *)season
{
    std::string u = [username UTF8String];
    std::string s = [season UTF8String];
    SeasonFilter filter(s);
    auto filtered = DataManager::getInstance().fetchAndFilterOutfits(u, filter);
    NSMutableArray<NSDictionary *> *result = [NSMutableArray arrayWithCapacity:filtered.size()];
    for (auto &oPtr : filtered) {
        [result addObject:dictFromOutfit(oPtr)];
    }
    return result;
}

@end
