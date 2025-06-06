#pragma once

#include <string>
#include <vector>
#include "ClothingItem.hpp"

// Interfață abstractă pentru filtrarea ClothingItem
class ItemFilter {
public:
    virtual ~ItemFilter() = default;
    virtual bool matches(const ClothingItem& item) const = 0;
};

// filtur pe culoare
class ColorFilter : public ItemFilter {
public:
    explicit ColorFilter(const std::string& color_)
        : color(color_) {}
    bool matches(const ClothingItem& item) const override {
        return item.getColor() == color;
    }
private:
    std::string color;
};

// filtrate pe categorie
class TypeFilter : public ItemFilter {
public:
    explicit TypeFilter(const std::string& type_)
        : type(type_) {}
    bool matches(const ClothingItem& item) const override {
        return item.getCategory() == type;
    }
private:
    std::string type;
};

// filtrate ps ubcategorii
class SubcategoryFilter : public ItemFilter {
public:
    explicit SubcategoryFilter(const std::string& subcategory_)
        : subcategory(subcategory_) {}
    bool matches(const ClothingItem& item) const override {
        return item.getSubcategory() == subcategory;
    }
private:
    std::string subcategory;
};

// filtre pe material
class MaterialFilter : public ItemFilter {
public:
    explicit MaterialFilter(const std::string& material_)
        : material(material_) {}
    bool matches(const ClothingItem& item) const override {
        for (const auto& m : item.getMaterials()) {
            if (m == material) return true;
        }
        return false;
    }
private:
    std::string material;
};

// CompositeFilter pentru combinații AND/OR de ItemFilter-uri
class CompositeItemFilter : public ItemFilter {
public:
    enum class Mode { AND, OR };

    CompositeItemFilter(const std::vector<std::shared_ptr<ItemFilter>>& filters_, Mode mode_)
        : filters(filters_), mode(mode_) {}

    bool matches(const ClothingItem& item) const override {
        if (mode == Mode::AND) {
            for (const auto& f : filters) 
                if (!f->matches(item)) return false;
            return true;
        } else {
            for (const auto& f : filters)
                if (f->matches(item)) return true;
            return false;
        }
    }

private:
    std::vector<std::shared_ptr<ItemFilter>> filters;
    Mode mode;
};
