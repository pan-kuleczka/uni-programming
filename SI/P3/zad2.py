#!/bin/python3
import random
from typing import *

MAX_TRIES = 1e6
MAX_BACKTRACK_DEPTH = 1e6
BACKTRACK_GUESSES = 1

class Nonogram:
    def __init__(self, rows : List[List[int]], columns : List[List[int]]) -> None:
        self.rows = rows
        self.columns = columns
        self.board = [[-1 for _ in range(len(columns))] for _ in range(len(rows))]

    def arr_to_bitmask(self, arr : List[int]) -> int:
        bitmask = 0
        for i in range(len(arr)):
            bitmask |= arr[i] << i
        return bitmask
    
    def bitmask_to_arr(self, bitmask : int, n : int) -> List[int]:
        return [1 if bitmask & (1 << i) else 0 for i in range(n)]

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

    def get_row(self, row : int) -> List[int]:
        return self.board[row]
    
    def get_col(self, col : int) -> List[int]:
        return [self.board[i][col] for i in range(len(self.board))]

    def n_empty(self) -> int:
        n = 0
        for i in range(len(self.rows)):
            for j in range(len(self.columns)):
                if self.board[i][j] == -1:
                    n += 1
        return n

    def is_filled(self) -> bool:
        return self.n_empty() == 0

    def is_row_contradicting(self, row : int) -> bool:
        still_possible = self.possible_row_solutions[row]
        for i in range(len(self.columns)):
            if self.board[row][i] != -1:
                still_possible = [x for x in still_possible if x[i] == self.board[row][i]]
        return len(still_possible) == 0
    
    def is_col_contradicting(self, col : int) -> bool:
        still_possible = self.possible_col_solutions[col]
        for i in range(len(self.rows)):
            if self.board[i][col] != -1:
                still_possible = [x for x in still_possible if x[i] == self.board[i][col]]
        return len(still_possible) == 0
    
    def is_contradicting(self) -> bool:
        for i in range(len(self.rows)):
            if self.is_row_contradicting(i):
                return True
        for i in range(len(self.columns)):
            if self.is_col_contradicting(i):
                return True
        return False

    def is_solved(self) -> bool:
        if not self.is_filled():
            return False
        # Check rows
        for i in range(len(self.rows)):
            row = self.get_row(i)
            if row not in self.possible_row_solutions[i]:
                return False
        # Check columns
        for i in range(len(self.columns)):
            col = self.get_col(i)
            if col not in self.possible_col_solutions[i]:
                return False
        
        return True
    
    def deduce_row(self, row : int) -> int:
        n_sets = 0
        still_possible = self.possible_row_solutions[row]
        for i in range(len(self.columns)):
            if self.board[row][i] != -1:
                still_possible = [x for x in still_possible if x[i] == self.board[row][i]]
        if len(still_possible) == 0:
            return 0
        for i in range(len(self.columns)):
            if all([x[i] == 1 for x in still_possible]):
                if self.board[row][i] == -1:
                    n_sets += 1
                self.board[row][i] = 1
            if all([x[i] == 0 for x in still_possible]):
                if self.board[row][i] == -1:
                    n_sets += 1
                self.board[row][i] = 0
        return n_sets

    def deduce_col(self, col : int) -> int:
        n_sets = 0
        still_possible = self.possible_col_solutions[col]
        if len(still_possible) == 0:
            return 0
        for i in range(len(self.rows)):
            if self.board[i][col] != -1:
                still_possible = [x for x in still_possible if x[i] == self.board[i][col]]
        for i in range(len(self.rows)):
            if all([x[i] == 1 for x in still_possible]):
                if self.board[i][col] == -1:
                    n_sets += 1
                self.board[i][col] = 1
            if all([x[i] == 0 for x in still_possible]):
                if self.board[i][col] == -1:
                    n_sets += 1
                self.board[i][col] = 0
        return n_sets

    def deduce(self) -> None:
        n_sets = 1
        while n_sets > 0:
            n_sets = 0
            for i in range(len(self.rows)):
                n_sets += self.deduce_row(i)
            for i in range(len(self.columns)):
                n_sets += self.deduce_col(i)

    def get_random_empty_cells(self, n : int) -> List[Tuple[int, int]]:
        empty_cells = []
        for i in range(len(self.rows)):
            for j in range(len(self.columns)):
                if self.board[i][j] == -1:
                    empty_cells.append((i, j))
        return random.sample(empty_cells, n)

    def backtrack(self, board_depth : int) -> bool:
        if board_depth >= MAX_BACKTRACK_DEPTH:
            return False
        if self.is_contradicting():
            return False
        self.deduce()
        if self.is_solved():
            return True
        n_guesses = min(BACKTRACK_GUESSES, self.n_empty())
        if n_guesses == 0:
            return False
        board_copy = [row.copy() for row in self.board]
        guessed_cells = self.get_random_empty_cells(n_guesses)
        for bitmask in range(1 << n_guesses):
            for i in range(n_guesses):
                self.board[guessed_cells[i][0]][guessed_cells[i][1]] = (bitmask >> i) & 1
            if self.backtrack(board_depth + 1):
                return True
            self.board = [row.copy() for row in board_copy]
        return False
    
    def solve(self) -> bool:
        self.preprocess_solutions()
        for i in range(int(MAX_TRIES)):
            if self.backtrack(0):
                return True
        return False

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
