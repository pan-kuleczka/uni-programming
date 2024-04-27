#include <iostream>
#include <climits>
#include <vector>
using namespace std;

const int MAX_K = 105;
const int MAX_L = 10005;

int k, l;
int cnt[MAX_L];
int prefSum[MAX_L]; // prefSum[i] = suma(cnt[j]) dla j od 0 do i
int prefLinSum[MAX_L]; // prefLinSum[i] = suma(cnt[j] * j) dla j od 0 do i

int getSum(int begin, int end)
{
    return prefSum[end] - prefSum[begin]; // suma(cnt[j]) dla j od begin do end
}

int getCost(int begin, int end)
{
    return prefLinSum[end] - prefLinSum[begin] - getSum(begin, end) * begin; // suma(cnt[j] * j) dla j od begin do end
}

int dp[MAX_L][MAX_K]; // dp[i][j] minimalny koszt napisania liter od 0 do i-1szej, jeśli klawisze 0 do j-1 mają te litery

int main()
{
    ios_base::sync_with_stdio(false);
    cin.tie(0);
    cout.tie(0);

    cin >> k >> l;
    for (int i = 0; i < l; i++)
        cin >> cnt[i];

    prefSum[0] = cnt[0];
    for (int i = 1; i <= l; i++)
        prefSum[i] = prefSum[i - 1] + cnt[i - 1];
    
    prefLinSum[0] = 0;
    for (int i = 1; i <= l; i++)
        prefLinSum[i] = prefLinSum[i - 1] + cnt[i - 1] * i;

    for (int i = 0; i <= l; i++)
        for (int j = 0; j <= k; j++)
            dp[i][j] = INT_MAX / 2;
    
    for(int keys = 0; keys <= k; keys++)
        dp[0][keys] = 0;

    // O(k * l^2)

    for (int keys = 1; keys <= k; keys++)
        for (int letters = 0; letters <= l; letters++)
            for(int prevLetters = 0; prevLetters <= letters; prevLetters++)
                dp[letters][keys] = min(
                    dp[letters][keys], dp[prevLetters][keys - 1]
                +   getCost(prevLetters, letters)
                );

    int result = dp[l][k]; // zawsze używamy wszystkich klawiszy (prosta obserwacja, do tego k <= l)
    vector<int> pathToResult;
    int letters = l;
    int keys = k;

    while (keys > 0)
    {
        for (int prevLetters = 0; prevLetters < letters; prevLetters++)
            if (dp[letters][keys] == dp[prevLetters][keys - 1] + getCost(prevLetters, letters))
            {
                pathToResult.push_back(letters - prevLetters);
                letters = prevLetters;
                keys--;
                break;
            }
    }

    cout << result << "\n";
    for (int i = pathToResult.size() - 1; i >= 0; i--)
        cout << pathToResult[i] << " ";
    cout << "\n";

    // DEBUG
    // // Print DP
    // for(int i = 0; i <= l; i++)
    // {
    //     for(int j = 0; j <= k; j++)
    //         cout << dp[i][j] << " ";
    //     cout << "\n";
    // }

    return 0;
}
