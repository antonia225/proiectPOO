#pragma once

#include <string>
#include <vector>
#include <memory>
#include "Outfit.hpp"

// Interfață abstractă pentru filtrarea Outfit
class OutfitFilter {
public:
    virtual ~OutfitFilter() = default;
    virtual bool matches(const Outfit& outfit) const = 0;
};

// Filtre pentru Outfit

class SeasonFilter : public OutfitFilter {
public:
    explicit SeasonFilter(const std::string& season_)
        : season(season_) {}
    bool matches(const Outfit& outfit) const override {
        return outfit.getSeason() == season;
    }
private:
    std::string season;
};

class DateAddedFilter : public OutfitFilter {
public:
    // dateRange format: {"YYYY-MM-DD", "YYYY-MM-DD"} inclusive
    DateAddedFilter(const std::string& startDate_, const std::string& endDate_)
        : startDate(startDate_), endDate(endDate_) {}
    bool matches(const Outfit& outfit) const override {
        const std::string& d = outfit.getDateAdded();
        return (d >= startDate && d <= endDate);
    }
private:
    std::string startDate;
    std::string endDate;
};

// CompositeFilter pentru combinații AND/OR de OutfitFilter-uri
class CompositeOutfitFilter : public OutfitFilter {
public:
    enum class Mode { AND, OR };

    CompositeOutfitFilter(const std::vector<std::shared_ptr<OutfitFilter>>& filters_, Mode mode_)
        : filters(filters_), mode(mode_) {}

    bool matches(const Outfit& outfit) const override {
        if (mode == Mode::AND) {
            for (const auto& f : filters) {
                if (!f->matches(outfit)) return false;
            }
            return true;
        } else { // OR
            for (const auto& f : filters) {
                if (f->matches(outfit)) return true;
            }
            return false;
        }
    }

private:
    std::vector<std::shared_ptr<OutfitFilter>> filters;
    Mode mode;
};
