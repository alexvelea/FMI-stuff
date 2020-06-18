#include "menu.hpp"
#include "custom_menus.hpp"

int main() {
    menu::InitialiseMenus();
    menu::menu.Run();
    return 0;
}
