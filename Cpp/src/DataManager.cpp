#include "DataManager.hpp"
#include "CurrentUser.hpp"
#include "Utilities.hpp"
#include <random>
#include <chrono>

// Declarații funcții externe din CoreDataAdapter.mm
extern bool objcCreateUser(const std::string&, const std::string&, const std::string&);
extern std::shared_ptr<User> objcLoginUser(const std::string&, const std::string&);
extern bool objcUpdateUserLoginMeta(const std::string&, const std::string&, int);

extern std::vector<std::shared_ptr<ClothingItem>> objcFetchClothingItems(const std::string&);
extern bool objcSaveClothingItem(const std::string&, const ClothingItem&);
extern bool objcDeleteClothingItem(const std::string&, int);

extern std::vector<std::shared_ptr<Outfit>> objcFetchOutfits(const std::string&);
extern bool objcSaveOutfit(const std::string&, const Outfit&);
extern bool objcDeleteOutfit(const std::string&, const std::string&);

bool DataManager::createUser(const std::string& username,
                                      const std::string& name,
                                      const std::string& password)
{
    return objcCreateUser(username, name, password);
}

std::shared_ptr<User> DataManager::loginUser(const std::string& username,
                                                      const std::string& password)
{
    auto userPtr = objcLoginUser(username, password);
    if (!userPtr) {
        return nullptr;
    }

    // Actualizare streak și lastLoginDate
    std::string today = getTodayDate();
    std::string lastDate = userPtr->getLastLogIn();

    if (lastDate.empty()) {
        userPtr->setStreak();
    } else {
        int delta = daysBetween(lastDate, today);
        if (delta == 0) {
            // deja logat azi → nu schimb streak
        } else if (delta == 1) {
            userPtr->incrementStreak();
        } else {
            userPtr->setStreak();
        }
    }

    userPtr->setLastLogIn(today);
    objcUpdateUserLoginMeta(username, today, userPtr->getStreak());

    CurrentUser::getInstance().setUser(userPtr);
    return userPtr;
}

std::vector<std::shared_ptr<ClothingItem>>
DataManager::fetchClothingItemsForUser(const std::string& username)
{
    return objcFetchClothingItems(username);
}

bool DataManager::saveClothingItem(const std::string& username,
                                            const ClothingItem& item)
{
    bool ok = objcSaveClothingItem(username, item);
    if (ok && itemsChangedCallback_) {
        itemsChangedCallback_();
    }
    return ok;
}

bool DataManager::deleteClothingItem(const std::string& username, int itemId)
{
    bool ok = objcDeleteClothingItem(username, itemId);
    if (ok && itemsChangedCallback_) {
        itemsChangedCallback_();
    }
    return ok;
}

std::vector<std::shared_ptr<Outfit>>
DataManager::fetchOutfitsForUser(const std::string& username)
{
    return objcFetchOutfits(username);
}

bool DataManager::saveOutfit(const std::string& username, const Outfit& outfit)
{
    bool ok = objcSaveOutfit(username, outfit);
    if (ok && outfitsChangedCallback_) {
        outfitsChangedCallback_();
    }
    return ok;
}

bool DataManager::deleteOutfit(const std::string& username, const std::string& outfitId)
{
    bool ok = objcDeleteOutfit(username, outfitId);
    if (ok && outfitsChangedCallback_) {
        outfitsChangedCallback_();
    }
    return ok;
}

// alegem random sugestia in functie de sezon
std::shared_ptr<Outfit> DataManager::getTodaySuggestion(const std::string& username)
{
    auto allOutfits = fetchOutfitsForUser(username);
    if (allOutfits.empty()) return nullptr;

    // Determinăm sezonul curent
    std::time_t t = std::time(nullptr);
    std::tm localTime;
    localtime_r(&t, &localTime);
    int luna = localTime.tm_mon + 1;
    std::string sezon;
    if (luna >= 6 && luna <= 8) {
        sezon = "vara";
    } else if (luna >= 9 && luna <= 11) {
        sezon = "toamna";
    } else if (luna == 12 || luna <= 2) {
        sezon = "iarna";
    } else {
        sezon = "primavara";
    }

    // Filtrăm după sezon
    std::vector<std::shared_ptr<Outfit>> potrivite;
    for (auto& o : allOutfits) {
        if (o->getSeason() == sezon) {
            potrivite.push_back(o);
        }
    }
    if (potrivite.empty()) return nullptr;

    // Alegem random
    static std::mt19937_64 rng{ std::random_device{}() };
    std::uniform_int_distribution<size_t> dist(0, potrivite.size() - 1);
    return potrivite[dist(rng)];
}

// se aplica filtrele pentru articolele vestimentare
std::vector<std::shared_ptr<ClothingItem>>
DataManager::fetchAndFilterItems(const std::string& username, const ItemFilter& filter)
{
    auto all = fetchClothingItemsForUser(username);
    std::vector<std::shared_ptr<ClothingItem>> result;
    for (auto& it : all) {
        if (filter.matches(*it)) {
            result.push_back(it);
        }
    }
    return result;
}

// se aplica filtrele pentru outfituri
std::vector<std::shared_ptr<Outfit>>
DataManager::fetchAndFilterOutfits(const std::string& username, const OutfitFilter& filter)
{
    auto all = fetchOutfitsForUser(username);
    std::vector<std::shared_ptr<Outfit>> result;
    for (auto& o : all) {
        if (filter.matches(*o)) {
            result.push_back(o);
        }
    }
    return result;
}

int DataManager::getClothingItemCount(const std::string& username) {
    auto items = fetchClothingItemsForUser(username);
    return static_cast<int>(items.size());
}

int DataManager::getOutfitCount(const std::string& username) {
    auto outfits = fetchOutfitsForUser(username);
    return static_cast<int>(outfits.size());
}
