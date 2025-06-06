#import "CoreAdapter.h"
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import "DressDiary-Swift.h"
#import "ItemFactory.hpp"

// Helpers for string conversion
static NSString* toNSString(const std::string& s) {
    return [NSString stringWithUTF8String:s.c_str()];
}
static std::string toStdString(NSString* s) {
    return std::string([s UTF8String]);
}

// User operations

bool objcCreateUser(const std::string& username,
                    const std::string& name,
                    const std::string& password)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Check if username already exists
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *err = nil;
    NSArray *results = [ctx executeFetchRequest:fetch error:&err];
    if (err || results.count > 0) {
        return false;
    }

    // Create new User managed object
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"CDUser"
                                           inManagedObjectContext:ctx];
    NSManagedObject *userMO = [[NSManagedObject alloc] initWithEntity:ent
                                                 insertIntoManagedObjectContext:ctx];
    [userMO setValue:toNSString(username) forKey:@"username"];
    [userMO setValue:toNSString(name)     forKey:@"name"];
    [userMO setValue:toNSString(password) forKey:@"password"];

    // Default values for new user
    [userMO setValue:@"" forKey:@"lastLoginDate"];
    [userMO setValue:@0  forKey:@"streak"];
    [userMO setValue:@NO forKey:@"darkMode"];
    [userMO setValue:@"#FFFFFF" forKey:@"accentColor"];

    if (![ctx save:&err]) {
        NSLog(@"Error creating User: %@", err.localizedDescription);
        return false;
    }
    return true;
}

std::shared_ptr<User> objcLoginUser(const std::string& username,
                                    const std::string& password)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Fetch user by username & password
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"username == %@ AND password == %@",
                       toNSString(username), toNSString(password)];
    NSError *err = nil;
    NSArray *results = [ctx executeFetchRequest:fetch error:&err];
    if (err || results.count == 0) {
        return nullptr;
    }

    NSManagedObject *userMO = results.firstObject;
    std::string u = toStdString([userMO valueForKey:@"username"]);
    std::string n = toStdString([userMO valueForKey:@"name"]);
    std::string p = toStdString([userMO valueForKey:@"password"]);
    std::string accent = toStdString([userMO valueForKey:@"accentColor"]);
    std::string lastDate = toStdString([userMO valueForKey:@"lastLoginDate"]);
    int streak = [[userMO valueForKey:@"streak"] intValue];
    bool dark = [[userMO valueForKey:@"darkMode"] boolValue];

    auto cppUser = std::make_shared<User>(u, n, p);
    cppUser->setAccentColor(accent);
    cppUser->setLastLogIn(lastDate);
    cppUser->setStreak();
    cppUser->setDarkMode(dark);
    return cppUser;
}

bool objcUpdateUserLoginMeta(const std::string& username,
                             const std::string& lastLoginDate,
                             int streak)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Fetch user by username
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    fetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *err = nil;
    NSArray *results = [ctx executeFetchRequest:fetch error:&err];
    if (err || results.count == 0) {
        return false;
    }

    NSManagedObject *userMO = results.firstObject;
    [userMO setValue:toNSString(lastLoginDate) forKey:@"lastLoginDate"];
    [userMO setValue:@(streak)            forKey:@"streak"];
    if (![ctx save:&err]) {
        NSLog(@"Error updating login meta: %@", err.localizedDescription);
        return false;
    }
    return true;
}

// ClothingItem operations

std::vector<std::shared_ptr<ClothingItem>> objcFetchClothingItems(const std::string& username)
{
    std::vector<std::shared_ptr<ClothingItem>> result;

    // 1) Obținem contextul Core Data
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // 2) Luăm User MO după username
    NSFetchRequest *userFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    userFetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *uErr = nil;
    NSArray *uResults = [ctx executeFetchRequest:userFetch error:&uErr];
    if (uErr || uResults.count == 0) {
        return result;  // nu există user sau eroare
    }
    NSManagedObject *userMO = uResults.firstObject;

    // 3) Luăm toate ClothingItem‐urile ale lui userMO
    NSFetchRequest *itemFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDClothingItem"];
    itemFetch.predicate = [NSPredicate predicateWithFormat:@"owner == %@", userMO];
    NSError *iErr = nil;
    NSArray *items = [ctx executeFetchRequest:itemFetch error:&iErr];
    if (iErr) {
        return result;  // eroare la fetch
    }

    // 4) Pentru fiecare NSManagedObject (ciMO) trebuie să construim o clasă derivată concretă
    for (NSManagedObject *ciMO in items) {
        // 4.a) Preluăm câmpurile comune
        int id = [[ciMO valueForKey:@"id"] intValue];
        std::string color    = toStdString([ciMO valueForKey:@"color"]);
        std::string category = toStdString([ciMO valueForKey:@"category"]);
        std::string subcat   = toStdString([ciMO valueForKey:@"subcategory"]);

        // 4.b) „materials” e stocat ca NSString cu elemente separate prin virgulă?
        //     În acest exemplu presupunem că în baza de date „materials” este chiar
        //     un string de forma "cotton,polyester,lana" (dacă ați folosit componentJoinedByString).
        //     Dacă, în schimb, stored‐ul e un NSArray<NSString *>, atunci folosiţi
        //     toStdStringVector() direct, fără split.
        std::vector<std::string> matList;
        {
            NSString *matsJoined = [ciMO valueForKey:@"materials"];
            if ([matsJoined isKindOfClass:NSString.class]) {
                NSArray<NSString *> *arr = [matsJoined componentsSeparatedByString:@","];
                for (NSString *m in arr) {
                    NSString *trimmed = [m stringByTrimmingCharactersInSet:
                                         [NSCharacterSet whitespaceCharacterSet]];
                    matList.push_back(toStdString(trimmed));
                }
            }
        }

        // 4.c) Imaginea (NSData → vector<uint8_t>)
        NSData *imgData = [ciMO valueForKey:@"imageData"];
        std::vector<uint8_t> imgBytes;
        if (imgData && imgData.length > 0) {
            imgBytes.resize(imgData.length);
            memcpy(imgBytes.data(), imgData.bytes, imgData.length);
        }

        // 5) În funcție de „category”, apelăm exact Factory::createXxx(...)
        std::shared_ptr<ClothingItem> cppItem = nullptr;

        if (category == "pants") {
            // Preluăm câmpurile specifice pentru „pants”:
            float lungP = [[ciMO valueForKey:@"lungimePants"] floatValue];
            std::string tal = "";
            NSString *talNS = [ciMO valueForKey:@"taliePants"];
            if (talNS && [talNS isKindOfClass:NSString.class]) {
                tal = toStdString(talNS);
            }
            cppItem = Factory::createPants(
                id,
                color,
                matList,
                category,
                subcat,
                imgBytes,
                lungP,
                tal
            );
        }
        else if (category == "jacket") {
            // Preluăm câmpurile specifice pentru „jacket”:
            bool wp = [[ciMO valueForKey:@"waterproofJacket"] boolValue];
            cppItem = Factory::createJacket(
                id,
                color,
                matList,
                category,
                subcat,
                imgBytes,
                wp
            );
        }
        else if (category == "top") {
            // Preluăm câmpurile specifice pentru „top”:
            double lungM = [[ciMO valueForKey:@"lungimeManecaTop"] doubleValue];
            std::string decStr = "";
            NSString *decNS = [ciMO valueForKey:@"decolteuTop"];
            if (decNS && [decNS isKindOfClass:NSString.class]) {
                decStr = toStdString(decNS);
            }
            cppItem = Factory::createTop(
                id,
                color,
                matList,
                category,
                subcat,
                imgBytes,
                lungM,
                decStr
            );
        }
        else if (category == "suit") {
            // Preluăm câmpurile specifice pentru „suit”:
            float lungS = [[ciMO valueForKey:@"lungimeSuit"] floatValue];
            std::string talS = "";
            NSString *talNS = [ciMO valueForKey:@"talieSuit"];
            if (talNS && [talNS isKindOfClass:NSString.class]) {
                talS = toStdString(talNS);
            }
            bool wpS = [[ciMO valueForKey:@"waterproofSuit"] boolValue];
            bool isM = [[ciMO valueForKey:@"isMatchySuit"] boolValue];
            std::string patStr = "";
            NSString *patNS = [ciMO valueForKey:@"patternSuit"];
            if (patNS && [patNS isKindOfClass:NSString.class]) {
                patStr = toStdString(patNS);
            }
            cppItem = Factory::createSuit(
                id,
                color,
                matList,
                category,
                subcat,
                imgBytes,
                lungS,
                talS,
                wpS,
                isM,
                patStr
            );
        }
        else {
            // categorie necunoscută → nu punem nimic
            continue;
        }

        // 6) Dacă obiectul creat e valid, îl adăugăm în vector
        if (cppItem) {
            result.push_back(cppItem);
        }
    }

    return result;
}

bool objcSaveClothingItem(const std::string& username,
                          const ClothingItem& item)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Fetch User MO
    NSFetchRequest *userFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    userFetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *uErr = nil;
    NSArray *uResults = [ctx executeFetchRequest:userFetch error:&uErr];
    if (uErr || uResults.count == 0) {
        return false;
    }
    NSManagedObject *userMO = uResults.firstObject;

    // Create ClothingItem MO
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"CDClothingItem"
                                           inManagedObjectContext:ctx];
    NSManagedObject *ciMO = [[NSManagedObject alloc] initWithEntity:ent
                                              insertIntoManagedObjectContext:ctx];
    [ciMO setValue:@(item.getId())       forKey:@"id"];
    [ciMO setValue:toNSString(item.getColor())     forKey:@"color"];

    // Join materials vector into a comma-separated string
    const auto& matVec = item.getMaterials();
    NSMutableArray *matStrings = [NSMutableArray array];
    for (const auto& m : matVec) {
        [matStrings addObject:toNSString(m)];
    }
    NSString *joinedMats = [matStrings componentsJoinedByString:@","];
    [ciMO setValue:joinedMats forKey:@"materials"];

    [ciMO setValue:toNSString(item.getCategory())   forKey:@"category"];
    [ciMO setValue:toNSString(item.getSubcategory()) forKey:@"subcategory"];

    // ImageData
    const auto& imgVec = item.getImage();
    if (!imgVec.empty()) {
        NSData *data = [NSData dataWithBytes:imgVec.data() length:imgVec.size()];
        [ciMO setValue:data forKey:@"imageData"];
    }

    [ciMO setValue:userMO forKey:@"owner"];
    NSError *saveErr = nil;
    if (![ctx save:&saveErr]) {
        NSLog(@"Error saving ClothingItem: %@", saveErr.localizedDescription);
        return false;
    }
    return true;
}

bool objcDeleteClothingItem(const std::string& username,
                            int itemId)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Fetch User MO
    NSFetchRequest *userFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    userFetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *uErr = nil;
    NSArray *uResults = [ctx executeFetchRequest:userFetch error:&uErr];
    if (uErr || uResults.count == 0) {
        return false;
    }
    NSManagedObject *userMO = uResults.firstObject;

    // Fetch ClothingItem by id and owner
    NSFetchRequest *ciFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDClothingItem"];
    ciFetch.predicate = [NSPredicate predicateWithFormat:@"id == %d AND owner == %@", itemId, userMO];
    NSError *ciErr = nil;
    NSArray *ciResults = [ctx executeFetchRequest:ciFetch error:&ciErr];
    if (ciErr || ciResults.count == 0) {
        return false;
    }
    NSManagedObject *ciMO = ciResults.firstObject;
    [ctx deleteObject:ciMO];
    NSError *delErr = nil;
    if (![ctx save:&delErr]) {
        NSLog(@"Error deleting ClothingItem: %@", delErr.localizedDescription);
        return false;
    }
    return true;
}

// --------------------
// Outfit operations
// --------------------

std::vector<std::shared_ptr<Outfit>> objcFetchOutfits(const std::string& username)
{
    std::vector<std::shared_ptr<Outfit>> result;
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Fetch User MO
    NSFetchRequest *userFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    userFetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *uErr = nil;
    NSArray *uResults = [ctx executeFetchRequest:userFetch error:&uErr];
    if (uErr || uResults.count == 0) {
        return result;
    }
    NSManagedObject *userMO = uResults.firstObject;

    // Fetch Outfit by owner
    NSFetchRequest *oFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDOutfit"];
    oFetch.predicate = [NSPredicate predicateWithFormat:@"owner == %@", userMO];
    NSError *oErr = nil;
    NSArray *outfits = [ctx executeFetchRequest:oFetch error:&oErr];
    if (oErr) {
        return result;
    }

    for (NSManagedObject *oMO in outfits) {
        std::string id        = toStdString([oMO valueForKey:@"id"]);
        std::string name      = toStdString([oMO valueForKey:@"name"]);
        std::string dateAdded = toStdString([oMO valueForKey:@"dateAdded"]);
        std::string season    = toStdString([oMO valueForKey:@"season"]);

        auto cppOutfit = std::make_shared<Outfit>(id, name, dateAdded, season);
        result.push_back(cppOutfit);
    }
    return result;
}

bool objcSaveOutfit(const std::string& username,
                    const Outfit& outfit)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Fetch User MO
    NSFetchRequest *userFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    userFetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *uErr = nil;
    NSArray *uResults = [ctx executeFetchRequest:userFetch error:&uErr];
    if (uErr || uResults.count == 0) {
        return false;
    }
    NSManagedObject *userMO = uResults.firstObject;

    // Create Outfit MO
    NSEntityDescription *ent = [NSEntityDescription entityForName:@"CDOutfit"
                                           inManagedObjectContext:ctx];
    NSManagedObject *oMO = [[NSManagedObject alloc] initWithEntity:ent
                                              insertIntoManagedObjectContext:ctx];
    [oMO setValue:toNSString(outfit.getId())        forKey:@"id"];
    [oMO setValue:toNSString(outfit.getName())      forKey:@"name"];
    [oMO setValue:toNSString(outfit.getDateAdded()) forKey:@"dateAdded"];
    [oMO setValue:toNSString(outfit.getSeason())    forKey:@"season"];
    [oMO setValue:userMO forKey:@"owner"];

    NSError *saveErr = nil;
    if (![ctx save:&saveErr]) {
        NSLog(@"Error saving Outfit: %@", saveErr.localizedDescription);
        return false;
    }
    return true;
}

bool objcDeleteOutfit(const std::string& username,
                      const std::string& outfitId)
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *ctx = app.persistentContainer.viewContext;

    // Fetch User MO
    NSFetchRequest *userFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDUser"];
    userFetch.predicate = [NSPredicate predicateWithFormat:@"username == %@", toNSString(username)];
    NSError *uErr = nil;
    NSArray *uResults = [ctx executeFetchRequest:userFetch error:&uErr];
    if (uErr || uResults.count == 0) {
        return false;
    }
    NSManagedObject *userMO = uResults.firstObject;

    // Fetch Outfit by id and owner
    NSFetchRequest *oFetch = [NSFetchRequest fetchRequestWithEntityName:@"CDOutfit"];
    oFetch.predicate = [NSPredicate predicateWithFormat:@"id == %@ AND owner == %@", toNSString(outfitId), userMO];
    NSError *oErr = nil;
    NSArray *oResults = [ctx executeFetchRequest:oFetch error:&oErr];
    if (oErr || oResults.count == 0) {
        return false;
    }
    NSManagedObject *oMO = oResults.firstObject;
    [ctx deleteObject:oMO];

    NSError *delErr = nil;
    if (![ctx save:&delErr]) {
        NSLog(@"Error deleting Outfit: %@", delErr.localizedDescription);
        return false;
    }
    return true;
}
