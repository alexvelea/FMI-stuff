#pragma once

#include "trie.hpp"

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <termios.h>
#include <time.h>
#include <sys/ioctl.h>

#include <algorithm>
#include <iostream>
#include <string>
#include <vector>

namespace menu {

using namespace std;

typedef long long int64;

int64 getch() {
    int64 ch = 0;
    struct termios old = {0};
    if (tcgetattr(0, &old) < 0)
        perror("tcsetattr()");
    old.c_lflag &= ~ICANON;
    old.c_lflag &= ~ECHO;
    old.c_cc[VMIN] = 1;
    old.c_cc[VTIME] = 0;
    if (tcsetattr(0, TCSANOW, &old) < 0)
        perror("tcsetattr ICANON");
    if (read(0, &ch, 8) < 0)
        perror("read()");
    old.c_lflag |= ICANON;
    old.c_lflag |= ECHO;
    if (tcsetattr(0, TCSADRAIN, &old) < 0)
        perror("tcsetattr ~ICANON");
    return ch;
}

const string default_color = "\033[0m";
const string white_color = "\033[01;37m";
const string blue = "\033[34m";

void clear() {
    cout << "\033[H\033[J";
    cout.flush();
}

void gotoxy(int x, int y) {
    cout << "\033[%" << x + 1 << ";" << y + 1 << "H";
    cout.flush();
}

auto SplitWord = [](string command) -> vector <string> {
    vector <string> commands;
    string current_command = "";
    bool inside_quote = false;
    for (int i = 0 ; i < int(command.size()) ; i += 1) {
        if (command[i] == '\'' or command[i] == '\"') {
            if (inside_quote) {
                if (current_command != "") {
                    commands.push_back(current_command);
                }
                current_command = "";
            }
            inside_quote ^= 1;
            continue;
        }

        if (inside_quote) {
            current_command += command[i];
            continue;
        }

        if (command[i] == ' ' or command[i] == '\n' or command[i] == '\t') {
            if (not current_command.empty()) {
                commands.push_back(current_command);
            }
            current_command = "";
        } else {
            current_command += command[i];
        }
    }

    commands.push_back(current_command);

    return commands;
};

auto JoinWords = [](const vector<string>& words) -> string {
    string result = "";
    for (auto itr : words) {
        result += itr + " ";
    }
    return result;
};

template<typename T>
vector <T> operator+(vector <T> lhs, const vector <T> &rhs) {
    lhs.insert(lhs.end(), rhs.begin(), rhs.end());
    return lhs;
}

class Menu {
// child classes
  private:
    class Base;

  public:
    class DropDown;

    class Final;

// usage
  public:
    void Run();

    Menu::DropDown *Root() { return root; }

// singleton things
  public:
    static Menu &GetSingleton() {
        static Menu menu;
        return menu;
    }

    Menu(const Menu &) = delete;

    Menu &operator=(const Menu &) = delete;

  private:
    Menu();

// scoped variables
  protected:
    vector <string> HandleChar(int64 new_ch);
//    vector<vector<ConsoleCharacter>> console;

  private:
    DropDown *root;
};

Menu &menu = Menu::GetSingleton();

// pure virtual and private
class Menu::Base {
  public:
    Base() = delete;

    Base(const string &name) : name_(name) { }

    virtual ~Base() { }

    virtual bool IsFinalMenu() = 0;

    virtual vector <string> Help() = 0;

    virtual vector <string> Recommend(const vector <string> &remaining_commands) = 0;

    virtual vector <string> Execute(const vector <string> &commands) = 0;

    virtual Menu::Base *NextCommand(const vector <string> &commands) = 0;

    const string &Name() { return name_; }

  public:
    const string name_;
};

class Menu::DropDown : public Menu::Base {
  public:
    DropDown() = delete;

    DropDown(const string &name, const string &help_string);

    virtual ~DropDown() = default;

    bool IsFinalMenu() final;

    virtual vector <string> Help();

    vector <string> Recommend(const vector <string> &remaining_commands) final;

    vector <string> Execute(const vector <string> &commands) final;

    Menu::Base *NextCommand(const vector <string> &commands) final;

    void AddMenu(Menu::Base *new_child);

  protected:
    Trie children_names_;
    vector <Menu::Base *> childrens_;
    const string help_string_;
};

class Menu::Final : public Menu::Base {
  public:
    Final() = delete;

    Final(const string &name, const string &help_string = "");

    virtual ~Final() = default;

    bool IsFinalMenu() final;

    virtual vector <string> Help();

    virtual vector <string> Recommend(const vector <string> &remaining_commands) = 0;

    virtual vector <string> Execute(const vector <string> &commands) = 0;

    Menu::Base *NextCommand(const vector <string> &commands) final;

  protected:
    const string help_string_;
};

Menu::Menu() : root(new DropDown(">", "")) { }

// Menu::DropDown
Menu::DropDown::DropDown(const string &name, const string &help_string)
        : Base(name), help_string_(help_string) { }

bool Menu::DropDown::IsFinalMenu() { return false; }

vector <string> Menu::DropDown::Help() {
    vector <string> result = {help_string_};
    result.push_back("Usage:");
    for (auto child : childrens_) {
        result.push_back(this->Name() + " " + child->Name());
    }
    return result;
}

vector <string> Menu::DropDown::Recommend(const vector <string> &remaining_commands) {
    if (remaining_commands.size() == 0) {
        return Help();
    }

    return children_names_.GetPrefix(remaining_commands[0]);
}

vector <string> Menu::DropDown::Execute(const vector <string> &commands) {
    return Help();
}

Menu::Base *Menu::DropDown::NextCommand(const vector <string> &commands) {
    if (commands.empty()) {
        return nullptr;
    }

    for (auto child : childrens_) {
        if (child->Name() == commands[0]) {
            return child;
        }
    }

    return nullptr;
}

void Menu::DropDown::AddMenu(Menu::Base *child) {
    this->childrens_.push_back(child);
    children_names_.Insert(child->Name());
}

// Menu::Final
Menu::Final::Final(const string &name, const string &help_string)
        : Base(name), help_string_(help_string) { }

bool Menu::Final::IsFinalMenu() { return true; }

vector <string> Menu::Final::Help() {
    vector <string> result = {help_string_};

    return result;
}

Menu::Base *Menu::Final::NextCommand(const vector <string> &commands) {
    return nullptr;
}

vector <string> Menu::HandleChar(int64 new_ch) {
    static string command = "";
    static vector<string> command_history = {""};
    static int current_command = 0;

    auto GetLast = [](vector <string> commands, vector <string> &args) -> Menu::Base * {
        Menu::Base *current = menu.Root();

        while (current != nullptr and commands.size() > 1) {
            if (current->IsFinalMenu()) {
                break;
            }

            current = current->NextCommand(commands);
            if (current == nullptr) {
                break;
            }

            commands.erase(commands.begin());
        }

        args = commands;
        return current;
    };

    if (new_ch == 4283163) { // up
        current_command -= 1;
        current_command = max(current_command, 0);
        command = command_history[current_command];
        return {command};
    }

    if (new_ch == 4348699) { // down
        current_command += 1;
        current_command = min(current_command, int(command_history.size()) - 1);
        command = command_history[current_command];
        return {command};
    }

    current_command = int(command_history.size()) - 1;

    if (new_ch == int('\t')) {
        vector <string> unused_args;
        Menu::Base *current = GetLast(SplitWord(command), unused_args);
        if (current == nullptr) {
            return {command, "invalid command " + unused_args[0]};
        } else {
            auto recommendations = current->Recommend(unused_args);
            if (recommendations.size() == 1) {
                auto new_command = SplitWord(command);
                new_command.pop_back();
                new_command.push_back(recommendations[0]);
                command = JoinWords(new_command);
                return {command};
            } else {
                return vector <string>({command}) + recommendations;
            }
        }
    } else if (new_ch == int('\n')) {
        if (command.size() and command != command_history.back()) {
            command_history.push_back(command);
        }
        auto shit = SplitWord(command);
        vector <string> unused_args;
        Menu::Base *current = GetLast(SplitWord(command), unused_args);

        if (current == nullptr) {
            command = "";
            return {"invalid command " + unused_args[0]};
        } else {

            vector<string> result = {"", command};
            if (unused_args.back() == "") {
                unused_args.pop_back(); // erase empty character at end
            }
            result = result + current->Execute(unused_args);
            command = "";
            return result;
        }
    } else if (new_ch == 127) { // backspace
        if (command.size()) {
            command.pop_back();
        }
        return {command};
    } else {
        command += char(new_ch);
        return {command};
    }
}

void Menu::Run() {
    clear();
    cout.flush();

    int64 new_ch;
    while (1) {
        new_ch = getch();
        clear();
        auto lines = HandleChar(new_ch);
        cout << blue << lines[0] << default_color << '\n';
        for (int i = 1; i < min(40, int(lines.size())); i += 1) {
            cout << lines[i] << '\n';
        }

        if (lines.size() > 40) {
            cout << "...\n";
        }

        gotoxy(0, lines[0].size());
        cout.flush();
    }
}

}  // namespace menu
