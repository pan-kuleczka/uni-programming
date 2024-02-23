import random

MAX_TRIES = 1000
MAX_STEPS = 1000
P = 0.95
# The choices are selected with probabilities P, P(1 - P), P(1 - P)^2, ... from best to worst
# The probability of choosing the worst option is (1 - P)^(n - 1)



class Nonogram:
    def __init__(self, rows : list[int], columns : list[int]) -> None:
        self.rows = rows
        self.columns = columns
        self.board = [[0 for _ in range(len(columns))] for _ in range(len(rows))]
    def randomize_board(self) -> None:
        for i in range(len(self.board)):
            for j in range(len(self.board[i])):
                self.board[i][j] = random.choice([0, 1])
    def opt_dist(self, arr : list[int], d : int) -> int:
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
    def row_dist(self, row : int) -> int:
        arr = self.board[row]
        return self.opt_dist(arr, self.rows[row])
    def col_dist(self, col : int) -> int:
        arr = [self.board[i][col] for i in range(len(self.board))]
        return self.opt_dist(arr, self.columns[col])
    def is_solved(self) -> bool:
        for i in range(len(self.rows)):
            if self.row_dist(i) != 0:
                return False
        for i in range(len(self.columns)):
            if self.col_dist(i) != 0:
                return False
        return True
    def dist_change(self, row : int, col : int, new_val : int) -> int:
        prev_dist = self.row_dist(row) + self.col_dist(col)
        old_val = self.board[row][col]
        self.board[row][col] = new_val
        new_dist = self.row_dist(row) + self.col_dist(col)
        self.board[row][col] = old_val
        return new_dist - prev_dist
    def solve_board(self, max_steps : int = MAX_STEPS) -> bool:
        for _ in range(max_steps):
            if self.is_solved():
                return True
            possibilities = [(i, j, self.dist_change(i, j, not self.board[i][j])) for i in range(len(self.rows)) for j in range(len(self.columns))]
            possibilities.sort(key = lambda x : -x[2])
            for i in range(len(possibilities)):
                if random.random() < P or i == len(possibilities) - 1:
                    row, col, _ = possibilities[i]
                    self.board[row][col] = 1 - self.board[row][col]
                    break
        return False
    def solve(self, max_tries : int = MAX_TRIES) -> bool:
        for _ in range(max_tries):
            self.randomize_board()
            if self.solve_board():
                return True
    def __str__(self) -> str:
        return "\n".join(["".join([("#" if self.board[i][j] else " ") for j in range(len(self.board[i]))]) for i in range(len(self.board))])
        
    
def __main__() -> None:
    with open('zad5_input.txt', 'r', encoding="utf8") as input_file:
        with open('zad5_output.txt', 'w', encoding="utf8") as output_file:
            input = input_file.readlines()
            n_rows = int(input[0].split()[0])
            n_cols = int(input[0].split()[1])
            rows = [0] * n_rows
            columns = [0] * n_cols
            for i in range(n_rows):
                rows[i] = int(input[i + 1])
            for i in range(n_cols):
                columns[i] = int(input[i + n_rows + 1])
            print(rows)
            print(columns)
            n = Nonogram(rows, columns)
            n.solve()
            output_file.write(str(n))
            print(str(n))

if __name__ == "__main__":
    __main__()
