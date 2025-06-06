#pragma once

#include <functional>
#include <vector>

class EventManager {
public:
    using Callback = std::function<void()>;
    EventManager() = default;
    ~EventManager() = default;

    // Înregistrează un callback care va fi apelat la notificare
    void subscribe(const Callback cb) {
            callbacks_.push_back(std::move(cb));
    }

    // Notifică toți subscriberii
    void notifyAll() {
        for (auto& cb : callbacks_)
            if (cb)
                cb();
    }
    
private:
    std::vector<Callback> callbacks_;
};
