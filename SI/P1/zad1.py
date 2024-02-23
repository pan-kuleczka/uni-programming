from enum import Enum

class Player(Enum):
    WHITE = 1
    BLACK = 2

class Position:
    # Board positions are represented in format "a1", "h8", etc.
    def __init__(self, toPlay : Player = Player.WHITE, white_king : str = "a1", white_rook : str = "a2", black_king : str = "a3", move_history : list[str] = []) -> None:
        self.toPlay = toPlay
        self.white_king = white_king
        self.white_rook = white_rook
        self.black_king = black_king
        self.move_history = move_history

    def fromString(self, s : str) -> None:
        tokens = s.split()
        self.toPlay = Player.WHITE if tokens[0] == "white" else Player.BLACK
        self.white_king = tokens[1]
        self.white_rook = tokens[2]
        self.black_king = tokens[3]
    
    def isMate(self) -> bool:
        if self.toPlay == Player.WHITE:
            return False
        return len(self.nextPositionsBlack(can_take_rook=True)) == 0
    
    def nextPositions(self) -> list:
        if self.toPlay == Player.WHITE:
            return self.nextPositionsWhite()
        return self.nextPositionsBlack()
    
    def nextPositionsWhite(self) -> list:
        positions = []
        for i in range(-1, 2):
            for j in range(-1, 2):
                if i == 0 and j == 0:
                    continue
                new_king = chr(ord(self.white_king[0]) + i) + str(int(self.white_king[1]) + j)
                if new_king[0] < 'a' or new_king[0] > 'h' or new_king[1] < '1' or new_king[1] > '8':
                    continue
                if new_king == self.white_rook:
                    continue
                if abs(ord(new_king[0]) - ord(self.black_king[0])) <= 1 and abs(int(new_king[1]) - int(self.black_king[1])) <= 1:
                    continue
                positions.append(Position(Player.BLACK, new_king, self.white_rook, self.black_king, self.move_history + ["White king to " + str(new_king)]))

        for i in range(-7, 8):
            new_rook = chr(ord(self.white_rook[0]) + i) + self.white_rook[1]
            if new_rook[0] < 'a' or new_rook[0] > 'h':
                continue
            if new_rook == self.white_king:
                continue
            if new_rook == self.black_king:
                continue
            positions.append(Position(Player.BLACK, self.white_king, new_rook, self.black_king, self.move_history + ["White rook to " + str(new_rook)]))

        for i in range(-7, 8):
            new_rook = self.white_rook[0] + chr(ord(self.white_rook[1]) + i)
            if new_rook[1] < '1' or new_rook[1] > '8':
                continue
            if new_rook == self.white_king:
                continue
            if new_rook == self.black_king:
                continue
            positions.append(Position(Player.BLACK, self.white_king, new_rook, self.black_king, self.move_history + ["White rook to " + str(new_rook)]))
        return positions
    
    def nextPositionsBlack(self, can_take_rook : bool = False) -> list:
        positions = []
        for i in range(-1, 2):
            for j in range(-1, 2):
                if i == 0 and j == 0:
                    continue
                new_king = chr(ord(self.black_king[0]) + i) + str(int(self.black_king[1]) + j)
                if new_king[0] < 'a' or new_king[0] > 'h' or new_king[1] < '1' or new_king[1] > '8':
                    continue
                if new_king == self.white_rook and not can_take_rook:
                    # If the king takes the rook, we have a stalemate. This position is not valid.
                    continue
                if abs(ord(new_king[0]) - ord(self.white_king[0])) <= 1 and abs(int(new_king[1]) - int(self.white_king[1])) <= 1:
                    continue
                if (new_king[0] == self.white_rook[0] or new_king[1] == self.white_rook[1]) and not new_king == self.white_rook:
                    continue
                positions.append(Position(Player.WHITE, self.white_king, self.white_rook, new_king, self.move_history + ["Black king to " + str(new_king)]))
        return positions


MAX_POSITIONS = 100000

def findMate(initial_position : Position) -> list:
    queue = [initial_position]
    n_positions = 0
    while len(queue) > 0:
        n_positions += 1
        if n_positions > MAX_POSITIONS:
            return []
        current_position = queue.pop(0)
        if current_position.isMate():
            return current_position.move_history
        for next_position in current_position.nextPositions():
            queue.append(next_position)
    return []
    
DEBUG = True

def __main__() -> None:
    initial_position = Position()
    initial_position.fromString(input())
    result = findMate(initial_position)
    if len(result) == 0:
        print("INF")
    else:
        print(len(result))
    if DEBUG:
        print(result)
    
if __name__ == "__main__":
    __main__()
