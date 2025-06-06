#pragma once

#include <chrono>
#include <iomanip>
#include <sstream>
#include <string>
#include <algorithm>

// Returneaza data de azi în format "DD-MM-YYYY"
static std::string getTodayDate() {
    using namespace std::chrono;
    auto today = floor<days>(system_clock::now());
    year_month_day ymd{ today };

    std::ostringstream oss;
    oss << std::setfill('0') << std::setw(2) << unsigned(ymd.day()) << "/"
        << std::setfill('0') << std::setw(2) << unsigned(ymd.month()) << "/"
        << int(ymd.year());
    return oss.str();
}

// Converteste string-ul "DD-MM-YYYY" intr-un obiect year_month_day
static std::chrono::year_month_day parseYMD(const std::string& s) {
    int d = std::stoi(s.substr(0, 2));
    int m = std::stoi(s.substr(3, 2));
    int y = std::stoi(s.substr(6, 4));
    return std::chrono::year{ y } / std::chrono::month{ (unsigned)m } / std::chrono::day{ (unsigned)d };
}

// Returnează numărul de zile între două date, ambele în format "DD-MM-YYYY"
static int daysBetween(const std::string& date1, const std::string& date2) {
    using namespace std::chrono;
    year_month_day ymd1 = parseYMD(date1);
    year_month_day ymd2 = parseYMD(date2);
    sys_days sd1{ ymd1 };
    sys_days sd2{ ymd2 };
    return (sd2 - sd1).count();
}

// Rotunjeste la o singura zeciamala
template <typename T>
inline T roundToOneDecimal(T number) {
    return std::floor(number * T(10) + T(0.5)) / T(10);
}
