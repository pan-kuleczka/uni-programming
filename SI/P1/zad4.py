def opt_dist(arr : list[int], d : int) -> int:
    pref_sums = [0] * (len(arr) + 1)
    pref_sums[0] = 0
    for i in range(len(arr)):
        pref_sums[i + 1] = pref_sums[i] + arr[i]
    total_ones = pref_sums[-1]
    best_result = len(arr)
    for i in range(len(arr) - d + 1):
        ones = pref_sums[i + d] - pref_sums[i]
        zeros = d - ones
        result = zeros + total_ones - ones
        best_result = min(best_result, result)
    return best_result

def __main__() -> None:
    arr = list(input())
    for i in range(len(arr)):
        arr[i] = int(arr[i])
    d = int(input())
    print(opt_dist(arr, d))

if __name__ == "__main__":
    __main__()
