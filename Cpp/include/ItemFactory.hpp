#pragma once

#include <string>
#include <memory>
#include <vector>
#include "ClothingItem.hpp"
#include "Pants.hpp"
#include "Jacket.hpp"
#include "Top.hpp"
#include "Suit.hpp"

class Factory {
public:
    // create Pants
    static std::shared_ptr<Pants> createPants(
        int                                  id_,
        const std::string&                   color_,
        const std::vector<std::string>&      materials_,
        const std::string&                   category_,      // pants
        const std::string&                   subcategory_,
        const std::vector<uint8_t>&          imageBytes_,
        float                                lungime_,
        const std::string&                   talie_
    ) {
        return std::make_shared<Pants>(
            id_,
            color_,
            materials_,
            category_,
            subcategory_,
            imageBytes_,
            lungime_,
            talie_
        );
    }

    // create Jacket
    static std::shared_ptr<Jacket> createJacket(
        int                                  id_,
        const std::string&                   color_,
        const std::vector<std::string>&      materials_,
        const std::string&                   category_,      // jacket
        const std::string&                   subcategory_,
        const std::vector<uint8_t>&          imageBytes_,
        bool                                 waterproof_
    ) {
        return std::make_shared<Jacket>(
            id_,
            color_,
            materials_,
            category_,
            subcategory_,
            const_cast<std::vector<uint8_t>&>(imageBytes_),
            waterproof_
        );
    }

    // create Top
    static std::shared_ptr<Top> createTop(
        int                                  id_,
        const std::string&                   color_,
        const std::vector<std::string>&      materials_,
        const std::string&                   category_,   // top
        const std::string&                   subcategory_,
        const std::vector<uint8_t>&          imageBytes_,
        double                               lungimeManeca_,
        const std::string&                   tipDecolteu_
    ) {
        return std::make_shared<Top>(
            id_,
            color_,
            materials_,
            category_,
            subcategory_,
            const_cast<std::vector<uint8_t>&>(imageBytes_),
            lungimeManeca_,
            tipDecolteu_
        );
    }

    // create Suit
    static std::shared_ptr<Suit> createSuit(
        int                                  id_,
        const std::string&                   color_,
        const std::vector<std::string>&      materials_,
        const std::string&                   category_,         // suit
        const std::string&                   subcategory_,
        const std::vector<uint8_t>&          imageBytes_,
        float                                lungime_,
        const std::string&                   talie_,
        bool                                 waterproof_,
        bool                                 isMatchy_,
        const std::string&                   pattern_
    ) {
        return std::make_shared<Suit>(
            id_,
            color_,
            materials_,
            category_,
            subcategory_,
            imageBytes_,
            lungime_,
            talie_,
            waterproof_,
            isMatchy_,
            pattern_
        );
    }

    // createOutfit
    static std::shared_ptr<Outfit> createOutfit(
        const std::string&            name,
        const std::string&            dateAdded,
        const std::string&            season
    ) {
        static int outfitCounter = 0;
        ++outfitCounter;
        std::string newId = "o" + std::to_string(outfitCounter);
        return std::make_shared<Outfit>(
            newId,
            name,
            dateAdded,
            season
        );
    }
};
