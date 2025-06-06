#pragma once

#include <string>
#include <vector>
#include <algorithm>
#include "ClothingItem.hpp"

class Outfit {
    std::string id;
    std::string name;
    std::string season;
    std::string dateAdded;
    std::vector<std::shared_ptr<ClothingItem>> items;
    
public:
    Outfit(const std::string& id_, const std::string& name_, const std::string& season_, const std::string& dateAdded_)
    : id(id_), name(name_), season(season_), dateAdded(dateAdded_) {}
    ~Outfit() = default;

    // getters
    std::string getId() const { return id; }
    std::string getName() const { return name; }
    std::string getDateAdded() const { return dateAdded; }
    std::string getSeason() const { return season; }
    const std::vector<std::shared_ptr<ClothingItem>>& getItems() const { return items;}
    
    // setters
    void setName(const std::string& newName) { name = newName; }
    
    // clothing items management
    void addItem(std::shared_ptr<ClothingItem> item) {
        items.push_back(item);
    }
    
    void removeItem(int itemId) {
        auto it = std::find_if(items.begin(), items.end(),
                [&](const std::shared_ptr<ClothingItem>& ci) {
                return *ci == itemId; });
        if (it != items.end()) { items.erase(it); }
    }
    
    bool operator<(const Outfit& other) const {
        return name < other.getName();
    }
    
    bool operator==(const Outfit& other) const {
        if (items.size() != other.items.size()) { return false; }

        std::vector<int> ids1, ids2; // id-urile ci din fiecare outfit
        for (const auto& ci : items)
            ids1.push_back(ci->getId());

        for (const auto& ci : other.items)
            ids2.push_back(ci->getId());

        // Sortam ambii vectori și comparăm
        std::sort(ids1.begin(), ids1.end());
        std::sort(ids2.begin(), ids2.end());
        return ids1 == ids2;
    }
};
