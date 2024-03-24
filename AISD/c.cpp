#include <iostream>
#include <climits>
#include <array>
#include <algorithm>
using namespace std;

const int MAX_F = 1e6 + 5;
const int MAX_C = 100 + 5;

struct Coin
{
    long long value, weight;
    Coin(int value = 0, int weight = 0) : value(value), weight(weight) {}
};

int f, c;
Coin coins[MAX_C];

long long dpValue[MAX_F];
char dpValueLastCoin[MAX_F];

pair<long long, array<int, MAX_C>> getSolution(bool maximum = false)
{
    fill(dpValue, dpValue + f + 1, -1);
    fill(dpValueLastCoin, dpValueLastCoin + f + 1, -1);
    dpValue[0] = 0;
    for(int coinIndex = 0; coinIndex < c; ++coinIndex)
    {
        Coin c = coins[coinIndex];
        for(int w = 0; w < f; ++w)
        {
            if(dpValue[w] < 0)
                continue;
            int nextIndex = w + c.weight;
            if(nextIndex > f)
                continue;
            long long nextValue = dpValue[w] + c.value;
            bool shouldReplace = false;
            if(dpValue[nextIndex] < 0)
                shouldReplace = true;
            else if(maximum && dpValue[nextIndex] < nextValue)
                shouldReplace = true;
            else if(!maximum && dpValue[nextIndex] > nextValue)
                shouldReplace = true;
            if(shouldReplace)
            {
                dpValue[nextIndex] = nextValue;
                dpValueLastCoin[nextIndex] = coinIndex;
            }
        }
    }

    if(dpValue[f] < 0)
        return {-LLONG_MAX, {}};

    array<int, MAX_C> coinCounts;
    fill(coinCounts.begin(), coinCounts.end(), 0);
    int currentW = f;
    while(currentW > 0)
    {
        int lastCoinIndex = dpValueLastCoin[currentW];
        coinCounts[lastCoinIndex]++;
        currentW -= coins[lastCoinIndex].weight;
    }
    return {dpValue[f], coinCounts};
}

int main()
{
    ios_base::sync_with_stdio(false);
    cin.tie(0);
    cout.tie(0);

    cin >> f >> c;
    for(int i = 0; i < c; ++i)
        cin >> coins[i].value >> coins[i].weight;
    
    auto [minValue, minCoinCounts] = getSolution();
    auto [maxValue, maxCoinCounts] = getSolution(true);

    if(minValue < 0)
        cout << "NIE\n";
    else
    {
        cout << "TAK\n";
        cout << minValue << "\n";
        for(int i = 0; i < c; ++i)
            cout << minCoinCounts[i] << " ";
        cout << "\n";
        cout << maxValue << "\n";
        for(int i = 0; i < c; ++i)
            cout << maxCoinCounts[i] << " ";
        cout << "\n";
    }

    return 0;
}
