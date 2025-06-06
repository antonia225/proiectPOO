#pragma once

#include <string>
#include <vector>

class ClothingItem {
    // luate din "formularul" de adaugare a unui articol vestimentar
    int id;                  // id generat
    std::string color;
    std::vector<std::string> materials;   // lista cu materialele din compozitie
    std::string category;
    std::string subcategory;
    std::vector<std::uint8_t> image;    // imaginea este transformata in biti in swift
    
public:
    ClothingItem(int id_, const std::string& color_, const std::vector<std::string>& materials_, const std::string& category_, const std::string& subcategory_, const std::vector<std::uint8_t>& image_)
    : id(id_), color(color_), materials(materials_), category(category_), subcategory(subcategory_), image(image_) {}
    virtual ~ClothingItem() = default;
    
    // getters
    int getId() const { return id; }
    std::string getColor() const { return color; }
    const std::vector<std::string>& getMaterials() const { return materials; }
    std::string getCategory() const { return category; }
    std::string getSubcategory() const { return subcategory; }
    const std::vector<std::uint8_t>& getImage() const { return image; }
    
    // pentru sortare
    bool operator< (const ClothingItem& other) const {
        return getId() < other.getId();
    }
    
    bool operator== (int otherID) const {
        return getId() == otherID;
    }
    
    // metoda virtuala pura pentru a afisa descrierea unui articol
    void virtual description(std::ostream& out) const = 0;
};
