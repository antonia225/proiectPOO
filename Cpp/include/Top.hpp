#pragma once

#include <string>
#include <vector>
#include "ClothingItem.hpp"
#include "Utilities.hpp"

class Top : public ClothingItem {
    double lungimeManeca;
    std::string tipDecolteu;
    
public:
    Top(int id_, const std::string& color_, const std::vector<std::string>& materials_, const std::string& category_, const std::string& subcategory_, const std::vector<std::uint8_t>& image_, double lungimeManeca_, std::string tipDecolteu_)
    : ClothingItem(id_, color_, materials_, category_, subcategory_, image_), lungimeManeca(lungimeManeca_), tipDecolteu(tipDecolteu_) {
        lungimeManeca = roundToOneDecimal(lungimeManeca);
    }
    
    // getters
    double getManeca() const { return lungimeManeca; }
    std::string getDecolteu() const { return tipDecolteu; }
    
    // metoda virtuala pura pentru a afisa descrierea unui articol
    void virtual description(std::ostream& out) const {
        out << getManeca() << "\n" << getDecolteu();
    };
    
    
};
