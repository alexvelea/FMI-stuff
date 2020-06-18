#Ce trebuie sa aiba o clasa din librarie?
Tot ce are nevoie sa fie folosita normal.

```
vector<string> vs;
string s;

Trie t(vs);

Trie.Add("qwe");
Trie.Add(vs);
int cnt = Trie.Count(s);
bool success = Trie.Delete(s);
vector<string> matched_strings = Trie.PrefixMatch(s);

// returns the first words_limit elements from trie that match the gives prefix
// in ascending order. The trie can have elements multiple times and in that case
// elements can appear multiple times
vector<string> Trie::PrefixMatch(string prefix, int words_limit=-1);
```

Constructori, destructori, operatori.
##Se foloseste new sau pointeri fantoma?

###Nu?

```
class T {
  T() = default;
  ~T() = default;
  
  T(const T&) = default;
  T& operator=(const T&) = default;
  
  T(T&&) = default;
  T& operator=(T&&) = default;
}
```

###Da?
By default se copiaza pointerul, nu zona de memorie pointata.

#####Asa nu.
```
struct A {
  int *a
} a, b;
a.a = new int;
b = a;
a si b o sa arate spre acelasi int
```

#####Asa da.
```
class T {
public:
  T() = default;
  ~T() = default;
  
  T(const T& rhs) {
    *i = new int(*rhs.i);
    *f = new Foo(*rhs.f);
    *b = new Bar(*rhs.b);
    ...
  }
  T& operator=(const T& rhs) {
    *this = T(rhs);
  }
  
  T(T&&) = default;
  T& operator=(T&&) = default;
  
  int* i;
  Foo* f;
  Bar* b;
}
```
