#include <iostream>
using namespace std;
int main() {
    int a, b; cin >> a >> b;

    int result = 0;
    for (int i = 0; i < a; i += 1) {
        for (int j = 0; j < b; j += 1) {
            result += 1;
        }
    }

    cout << result << '\n';
    return 0;
}