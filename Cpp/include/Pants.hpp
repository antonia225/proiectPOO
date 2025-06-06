#pragma once

#include <string>
#include <vector>
#include "ClothingItem.hpp"
#include "Utilities.hpp"

class Pants : public virtual ClothingItem {
    float lungime;
    std::string talie;
    
public:
    Pants(int id_, const std::string& color_, const std::vector<std::string>& materials_, const std::string& category_, const std::string& subcategory_, const std::vector<std::uint8_t>& image_, float lungime_, std::string talie_)
    : ClothingItem(id_, color_, materials_, category_, subcategory_, image_), lungime(lungime_), talie(talie_) {
        lungime = roundToOneDecimal(lungime);
    }
    
    // getters
    float getLungime() const {return lungime; }
    std::string getTalie() const {return talie; }
    
    // metoda virtuala pura pentru a afisa descrierea unui articol
    void virtual description(std::ostream& out) const {
        out << "\n" << getLungime() << "\n" << getTalie();
    };
};
