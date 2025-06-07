# Proiect POO - aplicatie DressDiary


## 1. Organizarea generală a proiectului

```
DressDiary/
├── Cpp/
│   ├── include/        ← Fișiere header (.hpp)
│   └── src/            ← Fișiere sursă (.cpp)
├── Wrappers/           ← Bridge Swift ↔ C++
├── Resources/          ← Asset-uri și model CoreData
└── Views/              ← Interfață SwiftUI
```

## 2. Directorul `Cpp/include/`

Aici găsim definițiile claselor și interfețelor. Fiecare fișier `.hpp` conține prototipuri, membri și comentarii despre responsabilități.

1. **Modele de date**

   * `ClothingItem.hpp`
     → Clasa de bază pentru orice articol vestimentar (id, culoare, materiale, categorie, imagine etc.).
   * `Top.hpp`, `Pants.hpp`, `Jacket.hpp`, `Suit.hpp`
     → Clase derivate din `ClothingItem`, adaugă atribute specifice:

     * `Top`: tip de mânecă, lungime
     * `Pants`: talie, lungime
     * `Jacket`, `Suit`: croială, material suplimentar

2. **Utilitare**

   * `Utilities.hpp`
     → Funcții statice de ajutor (transformări, validări etc.).

3. **Gestionarea utilizatorilor și a sesiunilor**

   * `User.hpp`
     → Reprezintă un utilizator (username, nume, parolă, preferințe).
   * `CurrentUser.hpp`
     → Singleton pentru stocarea utilizatorului autentificat în aplicație.

4. **Filtre și factory-uri**

   * `Outfit.hpp`
     → Clasa care grupează mai multe `ClothingItem` într-un outfit (sezon, data adăugării etc.).
   * `ItemFilter.hpp`, `OutfitFilter.hpp`
     → Interfețe abstracte pentru definirea filtrelor (polimorfism).

     * Exemple de filtre concrete: `CategoryFilter`, `SeasonFilter`, `DateAddedFilter`.
   * `ItemFactory.hpp`
     → Creează obiecte `ClothingItem` pe baza unor parametri dinamici (pattern Factory).
   * `EventManager.hpp`
     → Publică/subscrie evenimente interne (de ex. când se adaugă un nou outfit).

5. **Manager de date**

   * `DataManager.hpp`
     → Singleton responsabil cu operațiile CRUD (create, read, update, delete) pentru utilizatori, articole și outfit-uri.
     → Defineste callback-uri (`ItemsChangedCallback`, `OutfitsChangedCallback`) pentru notificarea View-urilor SwiftUI atunci când datele se modifică.
     

## 3. Directorul `Cpp/src/`

Aici se află implementările metodelor declarate în header-uri:

* **`DataManager.cpp`**

  * Conține definițiile tuturor funcțiilor din `DataManager.hpp`.
  * Apelează funcții externe (declarații `extern`):
    • `objcCreateUser`, `objcLoginUser` etc. – adaptori către CoreData (scrise în Objective-C++).
    • `objcFetchClothingItems`, `objcSaveClothingItem` – pentru persistență.
  * Logica de autentificare, stocarea și recuperarea datelor se face aici, delegând la nivelul de persistence din Wrappers.

> **Notă:** toate apelurile către baza de date se fac prin puntea Objective-C++ (`Wrappers/CoreAdapter.mm` și `CppBridge.mm`), pentru că Swift nu poate apela direct C++.

## 4. Cum se leagă totul împreună

1. **View-urile SwiftUI** (“Views/…”) trimit comenzi (ex. adaugă un articol) către `DataManager::getInstance()`.
2. `DataManager` transformă apelurile în apeluri `objc…` către Core Data, prin fișierele din `Wrappers/`.
3. După orice modificare, `DataManager` declanșează callback-uri (`ItemsChangedCallback`) pe care SwiftUI le ascultă pentru a-și actualiza interfața.
4. Obiectele (modelul) sunt definite în `.hpp` și `.cpp`, separate clar de interfața (Swift).
