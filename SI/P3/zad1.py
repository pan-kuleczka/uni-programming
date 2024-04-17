#!/bin/python3
import random
from typing import *

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

    def get_row(self, row : int) -> List[int]:
        return self.board[row]
    
    def get_col(self, col : int) -> List[int]:
        return [self.board[i][col] for i in range(len(self.board))]

    def is_solved(self) -> bool:
        for i in range(len(self.rows)):
            for j in range(len(self.columns)):
                if self.board[i][j] == -1:
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
    
    def deduce_row(self, row : int) -> None:
        still_possible = self.possible_row_solutions[row]
        for i in range(len(self.columns)):
            if self.board[row][i] != -1:
                still_possible = [x for x in still_possible if x[i] == self.board[row][i]]
        for i in range(len(self.columns)):
            if all([x[i] == 1 for x in still_possible]):
                self.board[row][i] = 1
            if all([x[i] == 0 for x in still_possible]):
                self.board[row][i] = 0

    def deduce_col(self, col : int) -> None:
        still_possible = self.possible_col_solutions[col]
        for i in range(len(self.rows)):
            if self.board[i][col] != -1:
                still_possible = [x for x in still_possible if x[i] == self.board[i][col]]
        for i in range(len(self.rows)):
            if all([x[i] == 1 for x in still_possible]):
                self.board[i][col] = 1
            if all([x[i] == 0 for x in still_possible]):
                self.board[i][col] = 0

    def deduce(self) -> None:
        for i in range(len(self.rows)):
            self.deduce_row(i)
        for i in range(len(self.columns)):
            self.deduce_col(i)

    def solve(self) -> bool:
        self.preprocess_solutions()
        while not self.is_solved():
            self.deduce()

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
