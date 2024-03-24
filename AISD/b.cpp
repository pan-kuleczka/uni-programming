#include <bits/stdc++.h>
using namespace std;

const int MAX_C = 5e5 + 5;
struct Point
{
    int x, y;
    Point(int x = 0, int y = 0) : x(x), y(y) {}
};

long double dist(const Point &a, const Point &b)
{
    long double dx = a.x - b.x;
    long double dy = a.y - b.y;
    return sqrtl(dx * dx + dy * dy);
}

int n;
long double bestPerimeter = LDBL_MAX;
array<Point, 3> bestPoints;

vector<Point> points;
Point strip[MAX_C];

const int FWD_CONST = 20;

void maxPerimeter(int begin, int end)
{
    if(end - begin < 3)
        return;
    if(end - begin < 10)
    {
        for(int i = begin; i < end; ++i)
            for(int j = i + 1; j < end; ++j)
                for(int k = j + 1; k < end; ++k)
                {
                    long double perimeter = dist(points[i], points[j]) + dist(points[j], points[k]) + dist(points[k], points[i]);
                    if(perimeter < bestPerimeter)
                    {
                        bestPerimeter = perimeter;
                        bestPoints = {points[i], points[j], points[k]};
                    }
                }
        return;
    }
    int mid = (begin + end) / 2;
    maxPerimeter(begin, mid);
    maxPerimeter(mid, end);

    int stripLen = 0;
    for (int i = begin; i < end; ++i)
        if(abs(points[i].x - points[mid].x) < bestPerimeter / 2)
            strip[stripLen++] = points[i];
    sort(strip, strip + stripLen, [](const Point &a, const Point &b) {
        return a.y < b.y;
    });
    for (int i = 0; i < stripLen; ++i)
        for(int j = i + 1; j < min(i + FWD_CONST, stripLen); ++j)
        {
            if(dist(strip[i], strip[j]) >= bestPerimeter / 2)
                break;
            for(int k = j + 1; k < min(i + FWD_CONST, stripLen); ++k)
            {
                long double perimeter = dist(strip[i], strip[j]) + dist(strip[j], strip[k]) + dist(strip[k], strip[i]);
                if(perimeter < bestPerimeter)
                {
                    bestPerimeter = perimeter;
                    bestPoints = {strip[i], strip[j], strip[k]};
                }
            }
        }
    return;
}

int main()
{
    ios_base::sync_with_stdio(false);
    cin.tie(0);
    cout.tie(0);

    cin >> n;
    points.resize(n);
    for (int i = 0; i < n; ++i)
    {
        int x, y;
        cin >> points[i].x >> points[i].y;
    }
    sort(points.begin(), points.end(), [](const Point &a, const Point &b) {
        return a.x < b.x;
    });
    maxPerimeter(0, n);
    cout << bestPoints[0].x << " " << bestPoints[0].y << "\n";
    cout << bestPoints[1].x << " " << bestPoints[1].y << "\n";
    cout << bestPoints[2].x << " " << bestPoints[2].y << "\n";

    return 0;
}