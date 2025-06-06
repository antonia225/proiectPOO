#pragma once

#include <string>
#include <vector>
#include "ClothingItem.hpp"

class Jacket : public virtual ClothingItem {
    bool waterproof;
    
public:
    Jacket(int id_, const std::string& color_, const std::vector<std::string>& materials_, const std::string& category_, const std::string& subcategory_, const std::vector<std::uint8_t>& image_, bool waterproof_)
    : ClothingItem(id_, color_, materials_, category_, subcategory_, image_), waterproof(waterproof_) {}
    
    // getters
    bool isWaterproof() const {return waterproof; }
    
    // metoda virtuala pura pentru a afisa descrierea unui articol
    void virtual description(std::ostream& out) const {
        out << "\n" << isWaterproof();
    };
};
