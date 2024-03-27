#!/bin/python3
import enum
from typing import *
import random
import queue

# Zad 2: python3 validator2.py zad2 pypy3 zad2.py; 7/14
# Zad 3: python3 validator2.py zad3 pypy3 zad2.py; 17/21

DEBUG = False

MAX_ATTEMPTS = int(1e6)
MAX_MOVES = 150
MAX_BFS_STATES = int(2000)
RANDOM_MOVES = 110

class TileType(enum.Enum):
    WALL = 0
    TARGET = 1
    START = 2
    START_TARGET = 3
    EMPTY = 4

    def from_char(c : str) -> 'TileType':
        if c == '#':
            return TileType.WALL
        if c == 'G':
            return TileType.TARGET
        if c == 'S':
            return TileType.START
        if c == 'B':
            return TileType.START_TARGET
        if c == ' ':
            return TileType.EMPTY
        raise ValueError("Invalid character")

class Direction(enum.Enum):
    UP = 0
    DOWN = 1
    LEFT = 2
    RIGHT = 3

class Position:
    def __init__(self, x : int, y : int) -> None:
        self.x = x
        self.y = y
    
    def __eq__(self, other : 'Position') -> bool:
        return self.x == other.x and self.y == other.y
    
    def __hash__(self) -> int:
        return hash((self.x, self.y))
    
    def __str__(self) -> str:
        return f"({self.x}, {self.y})"
    
    def move(self, direction : Direction) -> 'Position':
        if direction == Direction.UP:
            return Position(self.x - 1, self.y)
        if direction == Direction.DOWN:
            return Position(self.x + 1, self.y)
        if direction == Direction.LEFT:
            return Position(self.x, self.y - 1)
        if direction == Direction.RIGHT:
            return Position(self.x, self.y + 1)

class State:
    def __init__(self, possible_positions : List[Position]) -> None:
        self.possible_positions = set(possible_positions)

    def __str__(self) -> str:
        string = "("
        for pos in self.possible_positions:
            string += str(pos) + " "
        string += ")"
        return string

    def __eq__(self, other : 'State') -> bool:
        return self.possible_positions == other.possible_positions
    def __lt__(self, other : 'State') -> bool:
        return self.possible_positions < other.possible_positions
    def __hash__(self) -> int:
        return hash(frozenset(self.possible_positions))

class Board:
    def __init__(self, board : List[str]) -> None:
        self.board = [[TileType.from_char(c) for c in row] for row in board]
        self.starts = []
        self.targets = []
        for x in range(len(self.board)):
            for y in range(len(self.board[x])):
                if self.board[x][y] == TileType.START or self.board[x][y] == TileType.START_TARGET:
                    self.starts.append(Position(x, y))
                if self.board[x][y] == TileType.TARGET or self.board[x][y] == TileType.START_TARGET:
                    self.targets.append(Position(x, y))
    
    def is_valid_position(self, pos : Position) -> bool:
        return pos.x >= 0 and pos.x < len(self.board) and pos.y >= 0 and pos.y < len(self.board[pos.x])
    def is_unblocked(self, pos : Position) -> bool:
        return self.is_valid_position(pos) and self.board[pos.x][pos.y] != TileType.WALL
    def is_target(self, pos : Position) -> bool:
        return self.is_valid_position(pos) and (self.board[pos.x][pos.y] == TileType.TARGET or self.board[pos.x][pos.y] == TileType.START_TARGET)
    def is_start(self, pos : Position) -> bool:
        return self.is_valid_position(pos) and (self.board[pos.x][pos.y] == TileType.START or self.board[pos.x][pos.y] == TileType.START_TARGET)
    
    def move(self, pos : Position, direction : Direction) -> Position:
        new_pos = pos.move(direction)
        if self.is_unblocked(new_pos):
            return new_pos
        return pos
    def move_state(self, state : State, direction : Direction) -> State:
        return State([self.move(pos, direction) for pos in state.possible_positions])
    
    def get_initial_state(self) -> State:
        return State(self.starts)
    def is_state_final(self, state : State) -> bool:
        return all([self.is_target(pos) for pos in state.possible_positions])
    
    def make_random_move(self, state : State) -> Tuple[State, Direction]:
        direction = random.choice(list(Direction))
        return self.move_state(state, direction), direction
    
    def rate_move(self, state : State, direction : Direction) -> int:
        new_state = self.move_state(state, direction)
        return len(state.possible_positions)- len(new_state.possible_positions)
    
    def make_greedy_move(self, state : State) -> Tuple[State, Direction]:
        best_direction = None
        best_rate = -1
        for direction in Direction:
            rate = self.rate_move(state, direction)
            if rate > best_rate:
                best_rate = rate
                best_direction = direction
        return self.move_state(state, best_direction), best_direction
    
    def make_greedy_random_move(self, state : State) -> Tuple[State, Direction]:
        if random.random() < 0.5:
            return self.make_random_move(state)
        return self.make_greedy_move(state)

    def bfs(self, initial_state : State, initial_path_length : int) -> Optional[List[Direction]]:
        visited = set()
        visited.add(initial_state)
        queue = [(initial_state, [])]
        while queue:
            if len(visited) > MAX_BFS_STATES:
                return None
            state, moves = queue.pop(0)
            if self.is_state_final(state):
                return moves
            for direction in Direction:
                new_state = self.move_state(state, direction)
                if new_state not in visited:
                    if len(moves) + 1 > MAX_MOVES - initial_path_length:
                        continue
                    visited.add(new_state)
                    queue.append((new_state, moves + [direction]))
        return None

    def a_star_heuristic(self, pos : Position) -> int:
        # BFS from pos to all targets
        visited = set()
        visited.add(pos)
        queue = [(pos, 0)]
        while queue:
            state, distance = queue.pop(0)
            if self.is_target(state):
                return distance
            for direction in Direction:
                new_state = self.move(state, direction)
                if new_state not in visited:
                    visited.add(new_state)
                    queue.append((new_state, distance + 1))
        return int(1e9)

    def preprocess_a_star(self) -> None:
        dictionary = {}
        for x in range(len(self.board)):
            for y in range(len(self.board[x])):
                if self.board[x][y] == TileType.WALL:
                    continue
                pos = Position(x, y)
                dictionary[pos] = self.a_star_heuristic(pos)
        self.a_star_dictionary = dictionary

    def a_star_heuristic_state(self, state : State) -> int:
        return max([self.a_star_heuristic(pos) for pos in state.possible_positions])

    def a_star(self, initial_state : State) -> Optional[List[Direction]]:
        distances = {initial_state : 0}
        q = queue.PriorityQueue()
        q.put((0, initial_state, []))
        while not q.empty():
            _, state, moves = q.get()
            if self.is_state_final(state):
                return moves
            for direction in Direction:
                new_state = self.move_state(state, direction)
                new_distance = distances[state] + 1
                if new_state not in distances or new_distance < distances[new_state]:
                    distances[new_state] = new_distance
                    new_moves = moves + [direction]
                    q.put((new_distance + self.a_star_heuristic_state(new_state), new_state, new_moves))
        return None

    def solve(self, task : int = 2) -> Optional[List[Direction]]:
        if DEBUG:
            print("Starts:")
            for start in self.starts:
                print(start)
            print("Targets:")
            for target in self.targets:
                print(target)
        if task == 1:        
            for _ in range(MAX_ATTEMPTS):
                state = self.get_initial_state()
                moves = []
                for _ in range(RANDOM_MOVES):
                    if DEBUG: print(state)
                    state, direction = self.make_greedy_random_move(state)
                    moves.append(direction)
                    if self.is_state_final(state):
                        return moves
                bfs_solution = self.bfs(state, len(moves))
                if bfs_solution is not None:
                    return moves + bfs_solution
        elif task == 2:
            self.preprocess_a_star()
            state = self.get_initial_state()
            return self.a_star(state)
        return None

def __main__() -> None:
    with open('zad_input.txt', 'r', encoding="utf8") as input_file:
        with open('zad_output.txt', 'w', encoding="utf8") as output_file:
            input = input_file.readlines()
            input = [line.strip("\n") for line in input]
            board = Board(input)
            solution = board.solve()
            if DEBUG: print(len(solution))
            readable_solution = []
            for move in solution:
                if move == Direction.UP:
                    readable_solution.append("U")
                if move == Direction.DOWN:
                    readable_solution.append("D")
                if move == Direction.LEFT:
                    readable_solution.append("L")
                if move == Direction.RIGHT:
                    readable_solution.append("R")
            if DEBUG: print("".join(readable_solution))
            output_file.write("".join(readable_solution))

if __name__ == "__main__":
    __main__()
