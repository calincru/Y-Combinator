#ifndef INCLUDED_TUPLE_HASH_HPP
#define INCLUDED_TUPLE_HASH_HPP

#include <functional>

namespace memoizer { namespace tuple_hash {

    template<class T>
    struct hash {
        std::size_t operator()(const T& value) const {
            return std::hash<T>{}(value);
        }
    };

    template<class T>
    inline void hash_combine(std::size_t& seed, const T& v) {
        seed ^= tuple_hash::hash<T>{}(v)
                + 0x9e3779b9 + (seed << 6)
                + (seed >> 2);
    }

    namespace detail {

        template<class Tuple, size_t index = std::tuple_size<Tuple>::value - 1>
        struct hash_value_impl {
            void operator()(size_t& seed, const Tuple& tup) const {
                hash_value_impl<Tuple, index - 1>{}(seed, tup);
                hash_combine(seed, std::get<index>(tup));
            }
        };

        template<class Tuple>
        struct hash_value_impl<Tuple, 0> {
            void operator()(size_t& seed, const Tuple& tup) const {
                hash_combine(seed, std::get<0>(tup));
            }
        };

    } // detail

    template<class ...Args>
    struct hash<std::tuple<Args...>> {
        std::size_t operator()(const std::tuple<Args...>& tup) const {
            std::size_t seed = 0;

            detail::hash_value_impl<std::tuple<Args...>>{}(seed, tup);
            return seed;
        }
    };

} // namespace tuple_hash
} // namespace memoizer

#endif // INCLUDED_TUPLE_HASH_HPP
