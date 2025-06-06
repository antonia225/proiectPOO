#import <Foundation/Foundation.h>
#import "User.hpp"
#import "ClothingItem.hpp"
#import "Outfit.hpp"

// --- User operations ---
bool objcCreateUser(const std::string& username,
                    const std::string& name,
                    const std::string& password);

std::shared_ptr<User> objcLoginUser(const std::string& username,
                                    const std::string& password);

bool objcUpdateUserLoginMeta(const std::string& username,
                             const std::string& lastLoginDate,
                             int streak);

// --- ClothingItem operations ---
std::vector<std::shared_ptr<ClothingItem>> objcFetchClothingItems(const std::string& username);

bool objcSaveClothingItem(const std::string& username,
                          const ClothingItem& item);

bool objcDeleteClothingItem(const std::string& username,
                            int itemId);

// --- Outfit operations ---
std::vector<std::shared_ptr<Outfit>> objcFetchOutfits(const std::string& username);

bool objcSaveOutfit(const std::string& username,
                    const Outfit& outfit);

bool objcDeleteOutfit(const std::string& username,
                      const std::string& outfitId);
