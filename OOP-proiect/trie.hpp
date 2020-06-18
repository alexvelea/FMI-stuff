//  Created by Denis Mitã on 22/05/16.
//  Copyright © 2016 Denis Mitã. All rights reserved.
//
//  Trie

#ifndef TRIE_HPP
#define TRIE_HPP
#include <map>
#include <string>
#include <vector>

class TrieNode {
public:
    int total_count;
    int words_count;
    std::map<char, TrieNode*> son;
    TrieNode() {
        total_count = 0;
        words_count = 0;
        for (int i = 0; i < 27; ++i) {
            son[i] = NULL;
        }
    }
};

class Trie {
  private:
    TrieNode *root = new TrieNode();
    void trie_insert(TrieNode* &node, char *word);
    bool trie_erase(TrieNode* &node, char *word);
    bool trie_find(TrieNode* &node, char *word);
    void trie_get_prefix(TrieNode* &node, char *word, std::string &current, std::vector<std::string> &answer, int max_size);
    char* charify(std::string word);
  public:
    std::vector<std::string> GetPrefix(std::string word, int max_size = -1);
    bool Find(std::string word);
    void Insert(std::vector<std::string> list);
    void Erase(std::vector<std::string> list);
    bool Insert(std::string word);
    void Erase(std::string word);
    Trie() {};
    Trie(const std::vector<std::string>& elements) {
        Insert(elements);
    }
};

void Trie::Insert(std::vector<std::string> list) {
    for (auto &it : list) {
        Insert(it);
    }
};

bool Trie::Insert(std::string word) {
    char *p = charify(word);
    if (!trie_find(root, p)) {
        trie_insert(root, p);
        delete[] p;
        return false;
    } else {
        delete[] p;
        return true;
    }
};

void Trie::Erase(std::vector<std::string> list) {
    for (auto &it : list) {
        Erase(it);;
    }
};

void Trie::Erase(std::string word) {
    char *p = charify(word);
    if (trie_find(root, p)) {
        trie_erase(root, p);
    }
    delete[] p;
};

bool Trie::Find(std::string word) {
    char *p = charify(word);
    bool found = trie_find(root, p);
    delete[] p;
    return found;
};

std::vector<std::string> Trie::GetPrefix(std::string word, int max_size) {
    std::vector<std::string> answer;
    std::string current = "";
    char *p = charify(word);
    trie_get_prefix(root, p, current, answer, max_size);
    delete[] p;
    return answer;
};

char* Trie::charify(std::string word) {
    char *ptr = new char[word.size() + 1];
    std::copy(word.begin(), word.end(), ptr);
    ptr[word.length()] = '\0';
    
    return ptr;
};

void Trie::trie_insert(TrieNode* &node, char *word) {
    if (!(*word)) {
        if (node != root) {
            node->total_count++;
            node->words_count++;
        }
        return;
    }
    node->total_count++;
    if (!node->son[*word]) {
        node->son[*word] = new TrieNode();
    }
    trie_insert(node->son[*word], word + 1);
};

bool Trie::trie_erase(TrieNode* &node, char *word) {
    if (!(*word)) {
        node->words_count--;
        node->total_count--;
        if (!node->total_count) {
            delete(node);
            return true;
        }
        return true;
    }
    node->total_count--;
    if (trie_erase(node->son[*word], word + 1)) {
        node->son[*word] = NULL;
    }
    if (!node->total_count) {
        delete(node);
        return true;
    }
    return false;
};

bool Trie::trie_find(TrieNode* &node, char *word) {
    if (!(*word)) {
        if (node->words_count) {
            return true;
        }
        return false;
    }
    if (node->son[*word]) {
        return trie_find(node->son[*word], word + 1);
    }
    return false;
};

void Trie::trie_get_prefix(TrieNode* &node, char *word, std::string &current, std::vector<std::string> &answer, int max_size) {
    if (!(*word)) {
        for (int i = 0; i < node->words_count; ++i) {
            if (max_size != -1 && answer.size() == max_size) {
                return;
            }
            answer.push_back(current);
        }
        for (auto &it : node->son) {
            if (!it.second) {
                continue;
            }
            current += (it.first);
            trie_get_prefix(it.second, word, current, answer, max_size);
            current.pop_back();
        }
    } else {
        if (node->son[(*word)]) {
            current += (*word);
            trie_get_prefix(node->son[(*word)], word + 1, current, answer, max_size);
            current.pop_back();
        }
    }
}

#endif // TRIE_HPP