//
// Copyright 2023 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/Queah/blob/main/LICENSE.
//

#ifndef BinaryIo_h
#define BinaryIo_h

#include <cstdint>

// All read functions return true on success. If the function fails, any out
// parameters are unmodified.

// Verifies that all the bytes have been read. This should be the last call
// when procressing an input stream.
template<typename S>
inline bool read_complete(S& istrm) noexcept
{
   return istrm.peek() == S::traits_type::eof();
}

// Write/read "plain ol' data", i.e., data types that are memcpy'able.
template<typename S, typename T>
void write_pod(S& ostrm, const T& t) noexcept
{
   ostrm.write(reinterpret_cast<const char*>(&t), sizeof(t));
}

template<typename S, typename T>
bool read_pod(S& istrm, T& t) noexcept
{
   char buf[sizeof(T)];
   if (!istrm.read(buf, sizeof(buf))) {
      return false;
   }
   memcpy(&t, buf, sizeof(T));
   return true;
}

// Write a map (ordered or unordered) where both the key and the mapped type
// are PoD.
template<typename S, typename T>
void write_pod_map(S& ostrm, const T& t) noexcept
{
   uint64_t entries = t.size();
   write_pod(ostrm, entries);
   for (auto& i : t) {
      write_pod(ostrm, i.first);
      write_pod(ostrm, i.second);
   }
}

// Read a map (ordered or unordered) where both the key and the mapped type
// are PoD.
template<typename S, typename T>
bool read_pod_map(S& istrm, T& t)
{
   uint64_t entries;
   if (!read_pod(istrm, entries)) {
      return false;
   }
   T tmp;
   while (entries-- > 0) {
      typename T::key_type key;
      if (!read_pod(istrm, key)) {
         return false;
      }
      auto& value = tmp[key];
      if (!read_pod(istrm, value)) {
         return false;
      }
   }
   tmp.swap(t);
   return true;
}

// Write a vector where the elements are PoD.
template<typename S, typename T>
void write_pod_vector(S& ostrm, const T& t) noexcept
{
   uint64_t entries = t.size();
   write_pod(ostrm, entries);
   auto bytes = sizeof(typename T::value_type) * entries;
   ostrm.write(reinterpret_cast<const char*>(t.data()), bytes);
}

// Read a vector where the elements are PoD.
template<typename S, typename T>
bool read_pod_vector(S& istrm, T& t)
{
   uint64_t entries;
   if (!read_pod(istrm, entries)) {
      return false;
   }
   T tmp(entries);
   auto bytes = sizeof(typename T::value_type) * entries;
   if (!istrm.read(reinterpret_cast<char*>(tmp.data()), bytes)) {
      return false;
   }
   tmp.swap(t);
   return true;
}

#endif /* BinaryIo_h */
