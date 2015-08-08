#include <iostream>
#include <unordered_map>

#include "tuple_hash.hpp"

namespace memoizer {
namespace detail { struct no_copy{}; }

template<class Self, class F, template<class> class Hash = tuple_hash::hash>
struct y_memoizer;

template <class R, class ...Args, class F, template<class> class Hash>
struct y_memoizer<R(Args...), F, Hash> {
    using tupled_args = std::tuple<std::decay_t<Args>...>;

    F base;
    std::unordered_map<tupled_args, R, Hash<tupled_args>> cache;

public:
    template<class Fp>
    y_memoizer(detail::no_copy, Fp&& f)
        : base{std::forward<Fp>(f)}
    {}

    template<class ...Ts>
    R operator()(Ts&&... ts) {
        auto tupledArgs = std::tie(ts...);
        auto it = cache.find(tupledArgs);

        if (it != cache.end()) {
            std::cout << "[y_memoizer] Cache hit!" << std::endl;
            return it->second;
        }

        auto&& returnValue = base(*this, std::forward<Args>(ts)...);

        cache.emplace(std::move(tupledArgs), returnValue);
        return returnValue;
    }
};

template<class Self, class F>
y_memoizer<Self, std::decay_t<F>> memoize(F&& f) {
    return {detail::no_copy{}, std::forward<F>(f)};
}

} // namespace memoizer

int main() {
    auto fib_base = [](auto&& fib, std::size_t n) {
        if (n == 0u || n == 1u)
            return static_cast<long long>(n);
        return fib(n - 1u) + fib(n - 2u);
    };
    auto fib = memoizer::memoize<long long(std::size_t)>(fib_base);

    for (auto i = 0u; i < 93u; ++i)
        fib(i);

    return 0;
}
