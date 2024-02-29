from enum import Enum
from typing import *
import queue

class Player(Enum):
    WHITE = 1
    BLACK = 2

class Position:
    def __init__(self, x : int = 0, y : int = 0) -> None:
        self.x = x
        self.y = y
    def __str__(self) -> str:
        return chr(ord('a') + self.x) + str(self.y + 1)
    def __eq__(self, other : "Position") -> bool:
        if not isinstance(other, Position):
            return False
        return self.x == other.x and self.y == other.y
    def from_string(self, string : str) -> "Position":
        self.x = ord(string[0]) - ord('a')
        self.y = int(string[1]) - 1
        return self

    def is_valid(self) -> bool:
        return self.x >= 0 and self.x < 8 and self.y >= 0 and self.y < 8
    def is_next_to(self, other : "Position") -> bool:
        return abs(self.x - other.x) <= 1 and abs(self.y - other.y) <= 1
    def is_in_same_row_or_column(self, other : "Position") -> bool:
        return self.x == other.x or self.y == other.y

class Move:
    def __init__(self, from_position : Position, to_position : Position, piece : str) -> None:
        self.from_position = from_position
        self.to_position = to_position
        self.piece = piece
    def __str__(self) -> str:
        return self.piece + " " + str(self.from_position) + " " + str(self.to_position)

class GameState:
    def __init__(
            self,
            toPlay : Player = Player.WHITE,
            white_king_position : Position = Position(),
            white_rook_position : Position = None,
            black_king_position : Position = Position(),
            move_history : List[Move] = []
    ) -> None:
        self.toPlay = toPlay
        self.white_king_position = white_king_position
        self.white_rook_position = white_rook_position
        self.black_king_position = black_king_position
        self.move_history = move_history

    def from_string(self, string : str) -> "GameState":
        parts = string.split(" ")
        self.toPlay = Player.WHITE if parts[0] == "white" else Player.BLACK
        self.white_king_position = Position().from_string(parts[1])
        self.white_rook_position = Position().from_string(parts[2])
        self.black_king_position = Position().from_string(parts[3])
        return self
    
    def to_actual_state(self) -> Tuple[Player, str, str, str]:
        return (self.toPlay, str(self.white_king_position), str(self.white_rook_position), str(self.black_king_position))

    def is_valid(self) -> bool:
        if not self.white_king_position.is_valid() or not self.black_king_position.is_valid():
            return False
        if self.white_king_position.is_next_to(self.black_king_position):
            return False
        if self.white_rook_position:
            if not self.white_rook_position.is_valid():
                return False
            if self.white_rook_position == self.white_king_position or self.white_rook_position == self.black_king_position:
                return False
        return True
    
    def does_rook_attack(self, position : Position) -> bool:
        if not position.is_valid():
            return False
        if not self.white_rook_position:
            return False
        if self.white_rook_position.x == position.x and self.white_rook_position.y == position.y:
            return False
        if self.white_rook_position.x == position.x:
            if self.white_rook_position.y < position.y:
                for y in range(self.white_rook_position.y + 1, position.y):
                    if Position(self.white_rook_position.x, y) == self.white_king_position:
                        return False
            else:
                for y in range(position.y + 1, self.white_rook_position.y):
                    if Position(self.white_rook_position.x, y) == self.white_king_position:
                        return False
            return True
        if self.white_rook_position.y == position.y:
            if self.white_rook_position.x < position.x:
                for x in range(self.white_rook_position.x + 1, position.x):
                    if Position(x, self.white_rook_position.y) == self.white_king_position:
                        return False
            else:
                for x in range(position.x + 1, self.white_rook_position.x):
                    if Position(x, self.white_rook_position.y) == self.white_king_position:
                        return False
            return True
        return False

    def next_positions(self) -> List["GameState"]:
        if not self.is_valid():
            return []
        if self.toPlay == Player.WHITE:
            return self.next_positions_white()
        else:
            return self.next_positions_black()
        
    def next_positions_white(self) -> List["GameState"]:
        result = []
        # White king moves
        for dx in range(-1, 2):
            for dy in range(-1, 2):
                if dx == 0 and dy == 0:
                    continue
                new_position = Position(self.white_king_position.x + dx, self.white_king_position.y + dy)
                if new_position.is_valid() and not new_position.is_next_to(self.black_king_position) and not new_position == self.white_rook_position:
                    new_game_state = GameState(
                        toPlay = Player.BLACK,
                        white_king_position = new_position,
                        white_rook_position = self.white_rook_position,
                        black_king_position = self.black_king_position,
                        move_history = self.move_history + [Move(self.white_king_position, new_position, "K")]
                    )
                    result.append(new_game_state)
        # White rook moves
        if self.white_rook_position:
            for position_delta in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
                dx, dy = position_delta
                new_position = Position(self.white_rook_position.x + dx, self.white_rook_position.y + dy)
                while new_position.is_valid() and not new_position == self.white_king_position:
                    new_game_state = GameState(
                        toPlay = Player.BLACK,
                        white_king_position = self.white_king_position,
                        white_rook_position = new_position,
                        black_king_position = self.black_king_position,
                        move_history = self.move_history + [Move(self.white_rook_position, new_position, "R")]
                    )
                    result.append(new_game_state)
                    new_position = Position(new_position.x + dx, new_position.y + dy)
        return result

    def next_positions_black(self) -> List["GameState"]:
        # Black king moves
        result = []
        for dx in range(-1, 2):
            for dy in range(-1, 2):
                if dx == 0 and dy == 0:
                    continue
                new_position = Position(self.black_king_position.x + dx, self.black_king_position.y + dy)
                if new_position.is_valid() and not new_position.is_next_to(self.white_king_position) and not self.does_rook_attack(new_position):
                    white_rook_position = self.white_rook_position
                    if self.white_rook_position and new_position == self.white_rook_position:
                        white_rook_position = None
                    new_game_state = GameState(
                        toPlay = Player.WHITE,
                        white_king_position = self.white_king_position,
                        white_rook_position = white_rook_position,
                        black_king_position = new_position,
                        move_history = self.move_history + [Move(self.black_king_position, new_position, "k")]
                    )
                    result.append(new_game_state)
        return result
    
    def is_stalemate(self) -> bool:
        return len(self.next_positions()) == 0 or not self.white_rook_position
    def is_checkmate(self) -> bool:
        return self.is_stalemate() and self.does_rook_attack(self.black_king_position)


DEBUG = True
MAX_POSITIONS = 1000000

def __main__() -> None:
    initial_state = GameState().from_string(input())

    visited_positions = 0

    visited_set = set()
    visited_set.add(initial_state.to_actual_state())

    q = queue.Queue()
    q.put(initial_state)

    while not q.empty():
        current_state = q.get()
        visited_positions += 1
        if visited_positions > MAX_POSITIONS:
            print("INF")
            return
        if current_state.is_checkmate():
            print(len(current_state.move_history))
            if DEBUG:
                print("Visited positions:", visited_positions)
                print("Move history:")
                for move in current_state.move_history:
                    print(move)
            return
        if not current_state.is_stalemate():
            for next_state in current_state.next_positions():
                if next_state.to_actual_state() not in visited_set:
                    visited_set.add(next_state.to_actual_state())
                    q.put(next_state)

    print("INF")

if __name__ == "__main__":
    __main__()
