// Fisierul Trie.h
#ifndef TRIEH
#define TRIEH

#include <string>
#include <vector>
#include <algorithm>
#define LOWER_LIMIT 'a'
#define UPPER_LIMIT 'z'

class Node{
public:
    Node();
    ~Node(){};
    void AddChild(Node*);
    Node* FindChild(char);
    Node* GetChild(int);
    int GetChildrenLength();
    bool SetPrefix(int);
    int GetPrefix();
    bool SetWordTrue();
    bool SetWordFalse();
    bool GetWord();
    bool SetLetter(char);
    char GetLetter();
private:
    std::vector<Node*> Children;
    char Letter;
    int Prefix;
    bool Word;
};

Node::Node() : Prefix(0), Word(false), Letter(' '){}

void Node::AddChild(Node* child){
    Children.push_back(child);
}

Node* Node::FindChild(char c){
    for(int i = 0;i < Children.size();i++){
        Node* temp = Children[i];
        if(temp->GetLetter() == c){
            return temp;
        }
    }
    return NULL;
}

Node* Node::GetChild(int x){
    return Children[x];
}

int Node::GetChildrenLength(){
    return Children.size() - 1;
}

bool Node::SetPrefix(int x){
    return Prefix = x;
}

int Node::GetPrefix(){
    return Prefix;
}

bool Node::SetWordTrue(){
    return Word = true;
}

bool Node::SetWordFalse(){
    return Word = false;
}

bool Node::GetWord(){
    return Word;
}

bool Node::SetLetter(char c){
    return Letter = c;
}

char Node::GetLetter(){
    return Letter;
}

class Trie {
public:
    Trie();
    Trie(std::vector<std::string>);
    ~Trie();
    std::vector<std::string> PrefixMatch(std::string,int WordsLimit = -1);
    bool AddWord(std::string);
    bool AddWordsVector(std::vector<std::string>);
    int CountWordsWithPrefix(std::string);
    bool DeleteWord(std::string);
private:
    Node* Root;
    bool SearchWord(std::string);
    void Traverse(std::string,Node*,int&);
    bool WordVerify(std::string);
    bool WordVerify(std::vector<std::string>);
    void Add(std::string);
    std::vector<std::string> VectorString;
};

Trie::Trie(){
    Root = new Node;
}

Trie::Trie(std::vector<std::string> vs){
    Root = new Node;
    AddWordsVector(vs);
}

Trie::~Trie(){
    if(Root != NULL)
        delete Root;
}

std::vector<std::string> Trie::PrefixMatch(std::string s,int WordsLimit){
    Node* clone = Root;
    VectorString.clear();
    if(!WordVerify(s))
        return VectorString;
    if(WordsLimit == 0)
        return VectorString;
    for(int i = 0;i < s.size();i++){
        Node* child = clone->FindChild(s[i]);
        if(child == NULL)
            return VectorString;
        clone = child;
    }
    if(clone->GetWord()){
        VectorString.push_back(s);
        if(WordsLimit > 0)
            WordsLimit--;
    }
    if(WordsLimit == -1)
        WordsLimit=clone->GetPrefix();
    else{
        if(clone->GetPrefix() < WordsLimit)
            WordsLimit = clone->GetPrefix();
    }
    s.resize(s.size() - 1);
    if(WordsLimit > 0)
        Traverse(s,clone,WordsLimit);
    sort(VectorString.begin(),VectorString.end());
    return VectorString;
}

void Trie::Add(std::string s){
    Node* clone = Root;
    clone->SetPrefix(clone->GetPrefix() + 1);
    for(int i = 0;i < s.size();i++){
        Node* child = clone->FindChild(s[i]);
        if(child != NULL)
        {
            clone->SetPrefix(clone->GetPrefix() + 1);
            clone = child;
        }else{
            Node* temp = new Node;
            temp->SetLetter(s[i]);
            clone->AddChild(temp);
            clone->SetPrefix(clone->GetPrefix() + 1);
            clone = temp;
        }
        if(i == s.size() - 1){
            clone->SetWordTrue();
        }
    }
}

bool Trie::AddWord(std::string s){
    if(!WordVerify(s))
        return false;
    Add(s);
    return true;
}

bool Trie::AddWordsVector(std::vector<std::string> s){
    if(!WordVerify(s))
        return false;
    for(int i = 0;i < s.size();i++){
        Add(s[i]);
    }
    return true;
}

int Trie::CountWordsWithPrefix(std::string s){
    if(!WordVerify(s))
        return 0;
    Node* clone = Root;
    for(int i = 0;i < s.size();i++){
        Node* child = clone->FindChild(s[i]);
        if(child == NULL)
            return false;
        clone = child;
    }
    if(clone->GetWord())
        return clone->GetPrefix() + 1;
    return clone->GetPrefix();
}

bool Trie::DeleteWord(std::string s){
    if(!SearchWord(s))
        return false;
    Node* clone = Root;
    clone->SetPrefix(clone->GetPrefix() - 1);
    for(int i = 0;i < s.size();i++){
        clone = clone->FindChild(s[i]);
        clone->SetPrefix(clone->GetPrefix() - 1);
        if(i == s.size() - 1)
            clone->SetWordFalse();
        if(clone->GetPrefix() == 0){
            if(i != s.size() - 1){
                Node* child = clone->GetChild(s[i + 1]);
                delete clone;
                clone = child;
            }else{
                delete clone;
            }
        }
    }
    return true;
}

bool Trie::SearchWord(std::string s){
    Node* clone = Root;
    for(int i = 0;i < s.size();i++){
        Node* temp = clone->FindChild(s[i]);
        if(temp == NULL)
            return false;
        clone = temp;
        if(i == s.size() - 1)
            if(clone->GetWord())
                return true;
            else
                return false;
    }
}

void Trie::Traverse(std::string s,Node* nod,int& limit){
    if(limit == 0) return;
    s = s + nod->GetLetter();
    if(nod->GetWord()){
        VectorString.push_back(s);
        limit--;
    }
    int x = nod->GetChildrenLength();
    for(int i = 0;i <= x;i++){
        Traverse(s,nod->GetChild(i),limit);
    }
    s.resize(s.size() - 1);
}

bool Trie::WordVerify(std::string s){
    for(int i = 0;i < s.size();i++){
        if(s[i] < LOWER_LIMIT || s[i] > UPPER_LIMIT)
            return false;
    }
    return true;
}

bool Trie::WordVerify(std::vector<std::string> s){
    for(int i = 0;i < s.size();i++){
        if(!WordVerify(s[i]))
            return false;
    }
    return true;
}

#endif
