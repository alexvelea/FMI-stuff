#include <iostream>
using namespace std;
int main() {
    int a, b; cin >> a >> b;

    int result = 0;
    for (int i = 0; i < a; i += 1) {
        result += b;
    }

    cout << result << '\n';
    return 0;
}