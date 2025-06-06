#pragma once

#include "ClothingItem.hpp"
#include "Outfit.hpp"
#include <string>
#include <vector>

class User {
    // date de logare
    std::string username;
    std::string password;
    std::string name;
    
    // statistici
    int streak;
    std::string singInDate;
    std::string lastLogIn;
    
    // preferinte
    bool darkMode;
    std::string accentColor;
    
    // colectia de obiecte
    std::vector<std::shared_ptr<ClothingItem>> clothingItems;
    std::vector<std::shared_ptr<Outfit>> outfits;
    
public:
    User(const std::string& _name, const std::string& _username, const std::string& _password)
    : name(_name), username(_username), password(_password), accentColor("#000000"), lastLogIn(""), streak(0), darkMode(false) {}
    ~User() = default;
    
    // getters
    std::string getName() const { return name; }
    std::string getUsername() const { return username; }
    std::string getPassword() const { return password; }
    std::string getAccentColor() const { return accentColor; }
    bool isDarkMode() const { return darkMode; }
    int getStreak() const { return streak; }
    std::string getLastLogIn() const { return lastLogIn; }
    
    // setters
    void setDarkMode(bool toggle) { darkMode = toggle; }
    void setAccentColor(std::string& color) { accentColor = color; }
    void setLastLogIn(std::string& date) { lastLogIn = date; }
    
    // pentru streak
    void incrementStreak() { streak += 1; }
    void resetStreak() { streak = 0; }
    void setStreak() { streak = 1; }
    
    // clothingItems management
    std::vector<std::shared_ptr<ClothingItem>> getClothingItems() const { return clothingItems; }
    
    void addClothingItem(std::shared_ptr<ClothingItem> item) {
        clothingItems.push_back(std::move(item));
    }
    
    // outfits management
    std::vector<std::shared_ptr<Outfit>> getOutfits() const { return outfits; }
    
    void addOutfits(std::shared_ptr<Outfit> outfit) {
        outfits.push_back(std::move(outfit));
    }
};
