#!/bin/python3
import random
from typing import *

MAX_TRIES = 1000
MAX_STEPS = 3000
P = 0.001

# The choices are selected with probabilities P, P(1 - P), P(1 - P)^2, ... from best to worst
# The probability of choosing the worst option is (1 - P)^(n - 1)



class Nonogram:
    def __init__(self, rows : List[List[int]], columns : List[List[int]]) -> None:
        self.rows = rows
        self.columns = columns
        self.board = [[0 for _ in range(len(columns))] for _ in range(len(rows))]
    def arr_to_bitmask(self, arr : List[int]) -> int:
        bitmask = 0
        for i in range(len(arr)):
            bitmask |= arr[i] << i
        return bitmask
    def bitmask_to_arr(self, bitmask : int, n : int) -> List[int]:
        return [1 if bitmask & (1 << i) else 0 for i in range(n)]
    def randomize_board(self) -> None:
        for i in range(len(self.board)):
            for j in range(len(self.board[i])):
                self.board[i][j] = random.choice([0, 1])
    def generate_possible_solutions(self, n : int, block_sizes : List[int]) -> List[List[int]]:
        possible_solutions = [] # List of all possible solutions satisfying the constraints
        current_solution = [0] * n # The current solution
        def generate_solutions(position : int, current_block : int) -> None:
            if current_block == len(block_sizes):
                possible_solutions.append(current_solution.copy())
                return
            for i in range(position, n - block_sizes[current_block] + 1):
                for j in range(i, i + block_sizes[current_block]):
                    current_solution[j] = 1
                generate_solutions(i + block_sizes[current_block] + 1, current_block + 1)
                for j in range(i, i + block_sizes[current_block]):
                    current_solution[j] = 0
        generate_solutions(0, 0)
        return possible_solutions
    def preprocess_solutions(self) -> None:
        self.possible_row_solutions = [self.generate_possible_solutions(len(self.columns), row) for row in self.rows]
        self.possible_col_solutions = [self.generate_possible_solutions(len(self.rows), col) for col in self.columns]
    def opt_row_dist(self, row : int, arr : List[int]) -> int:
        return min([sum([1 for j in range(len(self.columns)) if self.board[row][j] != self.possible_row_solutions[row][i][j]]) for i in range(len(self.possible_row_solutions[row]))])
    def opt_col_dist(self, col : int, arr : List[int]) -> int:
        return min([sum([1 for i in range(len(self.rows)) if self.board[i][col] != self.possible_col_solutions[col][j][i]]) for j in range(len(self.possible_col_solutions[col]))])
    def row_dist(self, row : int) -> int:
        arr = self.board[row]
        if self.row_distances[row][self.arr_to_bitmask(arr)] == -1:
            self.row_distances[row][self.arr_to_bitmask(arr)] = self.opt_row_dist(row, arr)
        return self.row_distances[row][self.arr_to_bitmask(arr)]
    def col_dist(self, col : int) -> int:
        arr = [self.board[i][col] for i in range(len(self.board))]
        if self.col_distances[col][self.arr_to_bitmask(arr)] == -1:
            self.col_distances[col][self.arr_to_bitmask(arr)] = self.opt_col_dist(col, arr)
        return self.col_distances[col][self.arr_to_bitmask(arr)]
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
            possibilities = []
            if random.choice([True, False]):
                col = random.randrange(0, len(self.columns))
                possibilities = [(i, col, self.dist_change(i, col, not self.board[i][col])) for i in range(len(self.rows))]
            else:
                row = random.randrange(0, len(self.rows))
                possibilities = [(row, j, self.dist_change(row, j, not self.board[row][j])) for j in range(len(self.columns))]
            random.shuffle(possibilities)
            possibilities.sort(key = lambda x : -x[2])
            for i in range(len(possibilities)):
                if random.random() < P or i == len(possibilities) - 1:
                    row, col, _ = possibilities[i]
                    self.board[row][col] = 1 - self.board[row][col]
                    break
        return False
    def solve(self, max_tries : int = MAX_TRIES) -> bool:
        self.preprocess_solutions()
        self.row_distances = [[-1 for _ in range(1 << len(self.columns))] for _ in range(len(self.rows))]
        self.col_distances = [[-1 for _ in range(1 << len(self.rows))] for _ in range(len(self.columns))]
        for _ in range(max_tries):
            self.randomize_board()
            if self.solve_board():
                return True
            # print("Try " + str(_ + 1) + " of " + str(max_tries) + " failed.")
    def __str__(self) -> str:
        return "\n".join(["".join([("#" if self.board[i][j] else ".") for j in range(len(self.board[i]))]) for i in range(len(self.board))])
        
    
def __main__() -> None:
    with open('zad_input.txt', 'r', encoding="utf8") as input_file:
        with open('zad_output.txt', 'w', encoding="utf8") as output_file:
            input = input_file.readlines()
            n_rows = int(input[0].split()[0])
            n_cols = int(input[0].split()[1])
            rows = []
            columns = []
            for i in range(n_rows):
                line_n = 1 + i
                rows.append([int(x) for x in input[line_n].split()])
            for i in range(n_cols):
                line_n = 1 + i + n_rows
                columns.append([int(x) for x in input[line_n].split()])
            print(rows)
            print(columns)
            n = Nonogram(rows, columns)
            n.solve()
            output_file.write(str(n))
            print(str(n))

if __name__ == "__main__":
    __main__()
