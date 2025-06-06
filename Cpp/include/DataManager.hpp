#pragma once

#include <string>
#include <vector>
#include <memory>
#include <functional>
#include "User.hpp"
#include "ClothingItem.hpp"
#include "Outfit.hpp"
#include "ItemFilter.hpp"
#include "OutfitFilter.hpp"

class DataManager {
public:
    using ItemsChangedCallback = std::function<void()>;
    using OutfitsChangedCallback = std::function<void()>;

    // aplicatia propriu zisa
    static DataManager& getInstance() {
        static DataManager instance;
        return instance;
    }

    // create user (cand faci sign in)
    
    bool createUser(const std::string& username,
                    const std::string& name,
                    const std::string& password);

    // logIn
    std::shared_ptr<User> loginUser(const std::string& username,
                                    const std::string& password);

    // clothing items for each user
    std::vector<std::shared_ptr<ClothingItem>>
    fetchClothingItemsForUser(const std::string& username);

    // saves a clothing item
    bool saveClothingItem(const std::string& username,
                          const ClothingItem& item);

    // delete clothing item
    bool deleteClothingItem(const std::string& username, int itemId);

    // outfits for each user
    std::vector<std::shared_ptr<Outfit>>
    fetchOutfitsForUser(const std::string& username);

    // save outfit
    bool saveOutfit(const std::string& username, const Outfit& outfit);

    // delete outfit
    bool deleteOutfit(const std::string& username, const std::string& outfitId);

    // today's suggestion
    std::shared_ptr<Outfit> getTodaySuggestion(const std::string& username);

    // clothing items filters
    std::vector<std::shared_ptr<ClothingItem>>
    fetchAndFilterItems(const std::string& username, const ItemFilter& filter);

    // outfit filters
    std::vector<std::shared_ptr<Outfit>>
    fetchAndFilterOutfits(const std::string& username, const OutfitFilter& filter);

    // Observer: înregistrează callback la schimbarea articolelor
    void setItemsChangedCallback(ItemsChangedCallback cb) {
        itemsChangedCallback_ = std::move(cb);
    }

    // Observer: înregistrează callback la schimbarea outfit-urilor
    void setOutfitsChangedCallback(OutfitsChangedCallback cb) {
        outfitsChangedCallback_ = std::move(cb);
    }
    
    // Returnează numărul de articole vestimentare pentru user
    int getClothingItemCount(const std::string& username);

    // Returnează numărul de outfit-uri pentru user
    int getOutfitCount(const std::string& username);

private:
    DataManager() = default;
    DataManager(const DataManager&) = delete;
    DataManager& operator=(const DataManager&) = delete;

    ItemsChangedCallback itemsChangedCallback_ = nullptr;
    OutfitsChangedCallback outfitsChangedCallback_ = nullptr;
};
