#include <iostream>
#include <vector>
#include <algorithm>
#include <stack>
using namespace std;

const int MAX_N = 1e6 + 5;

int n, q;

vector<pair<int, int>> sons;
pair<int, int> findRange(int father)
{
    int begin = lower_bound(sons.begin(), sons.end(), make_pair(father, 0)) - sons.begin();
    int end = lower_bound(sons.begin(), sons.end(), make_pair(father + 1, 0)) - sons.begin();
    return {begin, end};
}

int preorder[MAX_N];
int postorder[MAX_N];
int preTimer = 0;
int postTimer = 0;

void dfs(int v)
{
    stack<int> s;
    s.push(v);
    while(!s.empty())
    {
        int u = s.top();
        s.pop();
        if(u < 0)
        {
            postorder[-u] = postTimer++;
            continue;
        }
        preorder[u] = preTimer++;
        s.push(-u);
        pair<int, int> range = findRange(u);
        for (int i = range.first; i < range.second; ++i)
            s.push(sons[i].second);
    }
}

int main()
{
    ios_base::sync_with_stdio(false);
    cin.tie(0);
    cout.tie(0);
    sons.reserve(MAX_N);
    cin >> n >> q;

    for (int i = 0; i < n - 1; ++i)
    {
        int a;
        cin >> a;
        sons.push_back({a, i + 2});
    }

    sort(sons.begin(), sons.end());
    dfs(1);

    // for(int i = 1; i <= n; ++i)
    //     cout << i << " " << preorder[i] << " " << postorder[i] << "\n";

    while(q--)
    {
        int a, b;
        cin >> a >> b;
        if(preorder[a] < preorder[b] && postorder[a] > postorder[b])
            cout << "TAK\n";
        else
            cout << "NIE\n";
    }
    

    return 0;
}