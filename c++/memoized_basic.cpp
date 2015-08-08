#include <iostream>
#include <functional>
#include <unordered_map>

#include "tuple_hash.hpp"

namespace memoizer {

template<class R, class ...Args, template<class> class Hash = tuple_hash::hash>
auto memo(std::function<R(Args...)> fun) {
    using tupled_args = std::tuple<std::decay_t<Args>...>;

    auto cache = std::unordered_map<tupled_args, R, Hash<tupled_args>>{};

    return [fun, cache](Args... args) mutable {
        auto tupledArgs = std::make_tuple(args...);
        auto it = cache.find(tupledArgs);

        if (it != cache.end()) {
            std::cout << "[memo] Cache hit" << std::endl;
            return it->second;
        }

        auto&& retValue = fun(std::forward<decltype(args)>(args)...);

        cache.emplace(std::move(tupledArgs), retValue);
        return retValue;

    };
}

} // namespace memoizer

int main() {
    using namespace memoizer;

    // Generic add lambda
    auto genAdd = [](auto lhs, auto rhs) {
        return lhs + rhs;
    };

    // Version 1
    //
    // Don't like it: requires specifying the type - that's not modern C++.
    // Generic lambdas are cool.
    auto memoIntAdd = memo(std::function<int(int, int)>(genAdd));

    for (auto i = 0; i < 10; ++i)
        std::cout << memoIntAdd(i, 9 - i) << std::endl;
    for (auto i = 0; i < 10; ++i)
        std::cout << memoIntAdd(i, 9 - i) << std::endl;

    // Version 2
    //
    // Cool - we don't loose genericity.
    auto memoizeFun = [](auto fun) {
        return [=](auto ...args) {
            using tupled_args = std::tuple<std::decay_t<decltype(args)>...>;
            using return_t = decltype(fun(args...));

            static auto cache = std::unordered_map<
                                    tupled_args,
                                    return_t,
                                    tuple_hash::hash<tupled_args>
                                >{};
            auto tupledArgs = std::make_tuple(args...);
            auto it = cache.find(tupledArgs);

            if (it != cache.end()) {
                std::cout << "[memoizeFun] Cache hit!" << std::endl;
                return it->second;
            }

            auto&& retValue = fun(std::forward<decltype(args)>(args)...);

            cache.emplace(std::move(tupledArgs), retValue);
            return retValue;
        };
    };
    auto memoizedAdd = memoizeFun(genAdd);

    for (auto i = 0; i < 10; ++i)
        std::cout << memoizedAdd(i, 9 - i) << std::endl;
    for (auto i = 0; i < 10; ++i)
        std::cout << memoizedAdd(i, 9 - i) << std::endl;

    // Try getting an object of a different type.  The cache should be empty
    // initially.
    for (auto i = 0u; i < 10u; ++i)
        std::cout << memoizedAdd(i, 9u - i) << std::endl;
    for (auto i = 0u; i < 10u; ++i)
        std::cout << memoizedAdd(i, 9u - i) << std::endl;

    // Using (unsigned, int) should generate another instantiation.
    for (auto i = 0u; i < 10u; ++i)
        std::cout << memoizedAdd(i, (int)(9 - i)) << std::endl;


    auto genSub = [](auto lhs, auto rhs) {
        return lhs - rhs;
    };

    // Using it as in FP languages
    for (auto i = 10; i > 0; --i)
        // Haskellers read: memoizeFun . genSub $ i (9 - i)
        std::cout << memoizeFun(genSub)(i, 9 - i) << std::endl;
    for (auto i = 10; i > 0; --i)
        std::cout << memoizeFun(genSub)(i, 9 - i) << std::endl;

    return 0;
}
