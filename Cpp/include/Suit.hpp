#pragma once

#include <string>
#include <vector>
#include "Pants.hpp"
#include "Jacket.hpp"
#include "ClothingItem.hpp"

class Suit : public Pants, public Jacket {
    bool isMatchy;
    std::string pattern;
    
public:
    Suit(int id_,
         const std::string& color_,
         const std::vector<std::string>& materials_,
         const std::string& category_,
         const std::string& subcategory_,
         const std::vector<std::uint8_t>& imageBytes_,
         float lungime_,
         const std::string& talie_,
         const bool& waterproof_,
         const bool isMatchy_,
         const std::string& pattern_)
      : ClothingItem(id_, color_, materials_, category_, subcategory_, imageBytes_)
      , Pants(id_, color_, materials_, category_, subcategory_, imageBytes_, lungime_, talie_)
      , Jacket(id_, color_, materials_, category_, subcategory_, imageBytes_, waterproof_)
      , isMatchy(isMatchy_)
      , pattern(pattern_)
    { }
    
    // getters
    bool getIsMatchy() const { return isMatchy; }
    std::string getPattern() const { return pattern; }
    
    // metoda virtuala pura pentru a afisa descrierea unui articol
    void virtual description(std::ostream& out) const {
        out << getIsMatchy() << "\n" << getPattern();
    };
};
