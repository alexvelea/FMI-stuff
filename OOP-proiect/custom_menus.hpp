#pragma once

#include "menu.hpp"
#include "trie.hpp"
#include "diff.hpp"

#include <fstream>
#include <vector>
#include <unordered_map>

namespace menu {
using namespace std;

std::string RunBashCommand(const char *cmd) {
    std::shared_ptr<FILE> pipe(popen(cmd, "r"), pclose);
    if (!pipe) return "ERROR";
    char buffer[128];
    std::string result = "";
    while (!feof(pipe.get())) {
        if (fgets(buffer, 128, pipe.get()) != NULL)
            result += buffer;
    }
    return result;
}

std::string RunBashCommand(const std::string cmd) {
    return RunBashCommand(cmd.c_str());
}

bool ValidFile(std::string file) {
    std::string answer = RunBashCommand("( test -e " + file + " ) && echo \"yes\" || echo \"no\"");
    return answer == "yes\n";
}

std::string ReadFile(std::string file) {
    std::ifstream fin(file, std::ios::in | std::ios::binary);

    fin.seekg(0, std::ios::end);
    std::string file_information;
    file_information.resize(fin.tellg());

    fin.seekg(0, std::ios::beg);
    fin.read(&file_information[0], file_information.size());
    fin.close();
    return file_information;
}

class DictSelector {
  public:
    DictSelector() = delete;

    DictSelector(unordered_map<string, Trie*>& trie_childrens, Trie& trie_names)
            : trie_childrens_(trie_childrens), trie_names_(trie_names) { }

    bool AddTrie(const string& name, Trie* trie) {
        if (GetTrie(name) != nullptr) {
            return false;
        }

        trie_names_.Insert(name);
        trie_childrens_[name] = trie;
        return true;
    }

    Trie* GetTrie(const string& name) {
        if (trie_childrens_.find(name) != trie_childrens_.end()) {
            return trie_childrens_[name];
        } else {
            return nullptr;
        };
    }

    vector<string> RecommendNames(const string& prefix) {
        return trie_names_.GetPrefix(prefix);
    }

  protected:
    unordered_map<string, Trie*>& trie_childrens_;
    Trie& trie_names_;
};

class GlobalDict {
  public:
    Menu::Final* InsertDict() { return insert_dict_menu_; }
    Menu::Final* PrefixWord() { return prefix_word_menu_; }
    Menu::Final* FindWord() { return find_word_menu_; }
    Menu::Final* InsertWord() { return insert_word_menu_; }
    Menu::Final* LoadFile() { return load_file_menu_; }
    Menu::Final* DiffFiles() { return diff_files_menu_; }

    GlobalDict() : trie_childrens_(), trie_names_(),
                   insert_dict_menu_(new InsertDictMenu("insert_dict", "Usage: insert_dict *name*", trie_childrens_, trie_names_)),
                   prefix_word_menu_(new PrefixWordMenu("prefix", "Usage: prefix *dict_name* *word_prefix* ...", trie_childrens_, trie_names_)),
                   find_word_menu_(new FindWordMenu("find", "Usage: find *dict_name* *word* ...", trie_childrens_, trie_names_)),
                   insert_word_menu_(new InsertWordMenu("insert_word", "insert_word *dict_name* *word* ...", trie_childrens_, trie_names_)),
                   load_file_menu_(new LoadFileMenu("load", "load *file_name*...", trie_childrens_, trie_names_)),
                   diff_files_menu_(new DiffFilesMenu("diff_files", "diff_files *file_name1* *file_name2*", trie_childrens_, trie_names_))
    { }

  protected:
    unordered_map<string, Trie*> trie_childrens_;
    Trie trie_names_;

    class InsertDictMenu : public Menu::Final, public DictSelector {
      public:

        InsertDictMenu(const string& name, const string& help_menu,
                       unordered_map<string, Trie*>& trie_childrens, Trie& trie_names)
                : Menu::Final(name, help_menu), DictSelector(trie_childrens, trie_names) { }

        vector<string> Recommend(const vector <string> &remaining_commands) {
            if (remaining_commands.empty()) { return {}; }
            return RecommendNames(remaining_commands[0]);
        }

        vector<string> Execute(const vector <string> &commands) {
            if (commands.empty()) { return Help(); }

            vector<string> result;
            for (auto itr : commands) {
                if (itr == "") {
                    continue;
                }

                if (AddTrie(itr, new Trie())) {
                    result.push_back("Added a trie with name:" + itr);
                } else {
                    result.push_back("Could not add a trie with name:" + itr + "Maybe it's already in added");
                }
            }
            return result;
        }

    } *insert_dict_menu_;

    class PrefixWordMenu : public Menu::Final, public DictSelector {
      public:

        PrefixWordMenu(const string& name, const string& help_menu,
                       unordered_map<string, Trie*>& trie_childrens, Trie& trie_names)
                : Menu::Final(name, help_menu), DictSelector(trie_childrens, trie_names) { }

        vector<string> Recommend(const vector <string> &remaining_commands) {
            if (remaining_commands.size() == 1) {
                return RecommendNames(remaining_commands[0]);
            } else {
                Trie* trie = GetTrie(remaining_commands[0]);
                if (trie == nullptr) {
                    return {};
                } else {
                    return trie->GetPrefix(remaining_commands.back());
                }
            }
        }

        vector<string> Execute(const vector <string> &commands) {
            if (commands.size() < 2) { return Help(); }

            Trie* trie = GetTrie(commands[0]);
            if (trie == nullptr) {
                return {"Invalid trie name:", commands[0]};
            }

            vector<string> result;
            for (int i = 1; i < int(commands.size()); i += 1) {
                if (i != 1) {
                    result.push_back("~~~~~~~~~~~~");
                }
                result.push_back("  > " + commands[i]);
                result = result + trie->GetPrefix(commands[i]);
            }

            return result;
        }
    } *prefix_word_menu_;

    class FindWordMenu : public Menu::Final, public DictSelector {
      public:
        FindWordMenu(const string& name, const string& help_menu,
                       unordered_map<string, Trie*>& trie_childrens, Trie& trie_names)
                : Menu::Final(name, help_menu), DictSelector(trie_childrens, trie_names) { }

        vector<string> Recommend(const vector <string> &remaining_commands) {
            if (remaining_commands.size() == 1) {
                return RecommendNames(remaining_commands[0]);
            } else {
                Trie* trie = GetTrie(remaining_commands[0]);
                if (trie == nullptr) {
                    return {};
                } else {
                    return trie->GetPrefix(remaining_commands.back());
                }
            }
        }

        vector<string> Execute(const vector <string> &commands) {
            if (commands.size() < 2) { return Help(); }

            Trie* trie = GetTrie(commands[0]);
            if (trie == nullptr) {
                return {"Invalid trie name:", commands[0]};
            }

            vector<string> result;
            for (int i = 1; i < int(commands.size()); i += 1) {
//                bool exists = trie.Find(commands[i]);
                bool exists = true;
                if (exists) {
                    result.push_back("Word: " + commands[i] + " is in the trie");
                } else {
                    result.push_back("Word: " + commands[i] + " is NOT in the trie");
                }
            }

            return result;
        }
    } *find_word_menu_;

    class InsertWordMenu : public Menu::Final, public DictSelector {
      public:

        InsertWordMenu(const string& name, const string& help_menu,
                       unordered_map<string, Trie*>& trie_childrens, Trie& trie_names)
                : Menu::Final(name, help_menu), DictSelector(trie_childrens, trie_names) { }

        vector<string> Recommend(const vector <string> &remaining_commands) {
            if (remaining_commands.size() == 1) {
                return RecommendNames(remaining_commands[0]);
            } else {
                Trie* trie = GetTrie(remaining_commands[0]);
                if (trie == nullptr) {
                    return {};
                } else {
                    return trie->GetPrefix(remaining_commands.back());
                }
            }
        }

        vector<string> Execute(const vector <string> &commands) {
            if (commands.size() < 2) { return Help(); }

            Trie* trie = GetTrie(commands[0]);
            if (trie == nullptr) {
                return {"Invalid trie name:", commands[0]};
            }

            vector<string> result;
            for (int i = 1; i < int(commands.size()); i += 1) {
                bool status = true; trie->Insert(commands[i]);
//                bool status = true;
                if (status) {
                    result.push_back("Word: " + commands[i] + " was added to the trie");
                } else {
                    result.push_back("Word: " + commands[i] + " was already in the trie");
                }
            }

            return result;
        }
    } *insert_word_menu_;

    class LoadFileMenu : public Menu::Final, public DictSelector {
      public:

        LoadFileMenu(const string& name, const string& help_menu,
                       unordered_map<string, Trie*>& trie_childrens, Trie& trie_names)
                : Menu::Final(name, help_menu), DictSelector(trie_childrens, trie_names) { }

        vector<string> Recommend(const vector <string> &remaining_commands) {
            Trie trie(SplitWord(RunBashCommand("ls")));
            return trie.GetPrefix(remaining_commands.back());
        }

        vector<string> Execute(const vector <string>& commands) {
            if (commands.size() < 1) { return Help(); }

            vector<string> result;

            for (const string& itr : commands) {
                if (itr == "") {
                    continue;
                }

                if (ValidFile(itr)) {
                    Trie* trie = new Trie(SplitWord(ReadFile(itr)));
                    trie_childrens_[itr] = trie;
                    trie_names_.Insert(itr);
                    result.push_back("File " + itr + " was loaded successfully.");
                } else {
                    result.push_back("File " + itr + " does not exist.");
                }
            }
            return result;
        }
    } *load_file_menu_;

    class DiffFilesMenu : public Menu::Final, public DictSelector {
      public:

        DiffFilesMenu(const string& name, const string& help_menu,
                     unordered_map<string, Trie*>& trie_childrens, Trie& trie_names)
                : Menu::Final(name, help_menu), DictSelector(trie_childrens, trie_names) { }

        vector<string> Recommend(const vector <string> &remaining_commands) {
            Trie trie(SplitWord(RunBashCommand("ls")));
            return trie.GetPrefix(remaining_commands.back());
        }

        vector<string> Execute(const vector <string>& commands) {
            if (commands.size() < 2) { return Help(); }

            if (not ValidFile(commands[0])) {
                return {"File:" + commands[0] + " does not exist"};
            }

            if (not ValidFile(commands[1])) {
                return {"File:" + commands[1] + " does not exist"};
            }

            string a = ReadFile(commands[0]), b = ReadFile(commands[1]);

            Diff diff;
            return {diff.MakeDiffString(a, b)};
        }
    } *diff_files_menu_;
};

void InitialiseMenus() {
    GlobalDict* global_dict = new GlobalDict();

    menu.Root()->AddMenu(global_dict->InsertDict());
    menu.Root()->AddMenu(global_dict->PrefixWord());
    menu.Root()->AddMenu(global_dict->FindWord());
    menu.Root()->AddMenu(global_dict->InsertWord());
    menu.Root()->AddMenu(global_dict->LoadFile());
    menu.Root()->AddMenu(global_dict->DiffFiles());
}

}  // namespace menu