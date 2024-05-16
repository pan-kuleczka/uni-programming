#include <bits/stdc++.h>
typedef unsigned long long ull;

enum TileType
{
    EMPTY = 0,
    WHITE = 1,
    BLACK = 2
};

struct BoardPosition
{
    char x;
    char y;

    bool isValid() const
    {
        if (x == -1 && y == -1)
            return true;
        return x >= 0 && x < 8 && y >= 0 && y < 8;
    }

    ull getMask() const
    {
        return 1LL << (ull)(y * 8 + x);
    }

    bool operator==(const BoardPosition &other) const
    {
        return x == other.x && y == other.y;
    }
};

// Reversi board state
class GameState
{
    // 64 bit bitboard for white and black tiles
    ull white = 0;
    ull black = 0;

public:
    GameState(ull white = 0, ull black = 0) : white(white), black(black) {}
    GameState(const GameState &other) : white(other.white), black(other.black) {}

    const GameState &operator=(const GameState &other)
    {
        white = other.white;
        black = other.black;
        return *this;
    }

    bool isFull() const
    {
        return (white | black) == 0xFFFFFFFFFFFFFFFF;
    }

    int whiteCount() const
    {
        return __builtin_popcountll(white);
    }

    int blackCount() const
    {
        return __builtin_popcountll(black);
    }

    TileType getTile(BoardPosition pos) const
    {
        ull mask = pos.getMask();
        if (white & mask)
            return TileType::WHITE;
        if (black & mask)
            return TileType::BLACK;
        return TileType::EMPTY;
    }

    std::vector<BoardPosition> getValidMoves(TileType tile) const
    {
        std::vector<BoardPosition> result;
        for (char y = 0; y < 8; y++)
        {
            for (char x = 0; x < 8; x++)
            {
                BoardPosition pos = {x, y};
                if (getTile(pos) != TileType::EMPTY)
                    continue;
                bool valid = false;
                for (auto dir : directions)
                {
                    BoardPosition current = pos;
                    bool foundOpponent = false;
                    while (true)
                    {
                        current.x += dir.x;
                        current.y += dir.y;
                        if (!current.isValid())
                            break;
                        TileType currentTile = getTile(current);
                        if (currentTile == TileType::EMPTY)
                            break;
                        if (currentTile == tile)
                        {
                            valid = foundOpponent;
                            break;
                        }
                        foundOpponent = true;
                    }
                    if (valid)
                        break;
                }
                if (valid)
                    result.push_back(pos);
            }
        }
        return result;
    }

    void setTile(BoardPosition pos, TileType type)
    {
        ull mask = pos.getMask();
        white &= ~mask;
        black &= ~mask;
        if (type == TileType::WHITE)
            white |= mask;
        else if (type == TileType::BLACK)
            black |= mask;
    }

    std::string toString() const
    {
        std::string result;
        for (char y = 0; y < 8; y++)
        {
            for (char x = 0; x < 8; x++)
            {
                switch (getTile({x, y}))
                {
                case TileType::EMPTY:
                    result += ".";
                    break;
                case TileType::WHITE:
                    result += "W";
                    break;
                case TileType::BLACK:
                    result += "B";
                    break;
                }
            }
            result += "\n";
        }
        return result;
    }

    const BoardPosition directions[8] = {
        {1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {-1, -1}, {0, -1}, {1, -1}};

    void placeTile(BoardPosition pos, TileType type)
    {
        if (getTile(pos) != TileType::EMPTY)
            throw std::runtime_error("Tile already placed at " + std::to_string(pos.x) + ", " + std::to_string(pos.y) + "!");
        setTile(pos, type);

        for (auto dir : directions)
        {
            BoardPosition current = pos;

            while (true)
            {
                current.x += dir.x;
                current.y += dir.y;
                if (!current.isValid())
                    break;
                TileType currentTile = getTile(current);
                if (currentTile == TileType::EMPTY)
                    break;
                if (currentTile == type)
                {
                    BoardPosition reverse = current;
                    while (reverse.x != pos.x || reverse.y != pos.y)
                    {
                        reverse.x -= dir.x;
                        reverse.y -= dir.y;
                        setTile(reverse, type);
                    }
                    break;
                }
            }
        }
    }
};

GameState initialState = GameState(
    (ull)(1LL << 27 | 1LL << 36),
    (ull)(1LL << 28 | 1LL << 35));

enum PlayerColor
{
    WHITE = 0,
    BLACK = 1
};

class GameAgent
{
public:
    virtual BoardPosition makeMove(PlayerColor myColor, const GameState &state) = 0;
    virtual ~GameAgent() {}
};

class RandomAgent : public GameAgent
{
public:
    BoardPosition makeMove(PlayerColor myColor, const GameState &state) override
    {
        std::vector<BoardPosition> validMoves = state.getValidMoves(myColor == PlayerColor::WHITE ? TileType::WHITE : TileType::BLACK);
        if (validMoves.size() == 0)
            return {-1, -1};
        return validMoves[rand() % validMoves.size()];
    }
};

const bool ENABLE_SORTING = true;
const int MAX_DEPTH = 4;

class CleverAgent : public GameAgent
{
    // MinMax with Alpha-Beta pruning

    int heuristic(const GameState &state)
    {
        int tileBalance = state.whiteCount() - state.blackCount();
        int mobility = state.getValidMoves(TileType::WHITE).size() - state.getValidMoves(TileType::BLACK).size();

        std::vector<BoardPosition> corners = {{0, 0}, {0, 7}, {7, 0}, {7, 7}};

        int cornerControl = 0;
        int edgeTotal = 0;
        int edgeUnflippable = 0;

        for (auto corner : corners)
        {
            TileType cornerTile = state.getTile(corner);
            if (cornerTile == TileType::WHITE)
                cornerControl += 1;
            if (cornerTile == TileType::BLACK)
                cornerControl -= 1;

            int dx = corner.x == 0 ? 1 : -1;
            for (int x = corner.x + dx; x >= 0 && x < 8; x += dx)
            {
                if (state.getTile({(char)x, corner.y}) == cornerTile)
                    edgeUnflippable++;
                else
                    break;
            }

            int dy = corner.y == 0 ? 1 : -1;
            for (int y = corner.y + dy; y >= 0 && y < 8; y += dy)
            {
                if (state.getTile({corner.x, (char)y}) == cornerTile)
                    edgeUnflippable++;
                else
                    break;
            }
        }

        for (char x = 0; x < 8; x++)
        {
            for (char y = 0; y < 8; y++)
            {
                if (x == 0 || x == 7 || y == 0 || y == 7)
                {
                    TileType edgeTile = state.getTile({x, y});
                    if (edgeTile == TileType::WHITE)
                        edgeTotal++;
                    if (edgeTile == TileType::BLACK)
                        edgeTotal--;
                }
            }
        }

        float gameStage = (state.whiteCount() + state.blackCount()) / 64.0;

        float tileBalanceWeight = exp(3 * gameStage);
        float mobilityWeight = 2 * exp(-2 * gameStage);
        float cornerControlWeight = 1000.0;
        float edgeWeight = 10.0;
        float edgeUnflippableWeight = 50.0;


        float score = 0;
        score += tileBalance * tileBalanceWeight;
        score += mobility * mobilityWeight;
        score += cornerControl * cornerControlWeight;
        score += edgeTotal * edgeWeight;
        score += edgeUnflippable * edgeUnflippableWeight;
        return round(score);
    }

    std::pair<int, BoardPosition> evaluate(PlayerColor myColor, const GameState &state, int remainingDepth, int alpha, int beta)
    {
        if (remainingDepth == 0 || state.isFull())
            return {heuristic(myColor), {-1, -1}};

        std::vector<BoardPosition> validMoves = state.getValidMoves(myColor == PlayerColor::WHITE ? TileType::WHITE : TileType::BLACK);
        std::vector<std::pair<BoardPosition, GameState>> nextStates;

        for (auto move : validMoves)
        {
            GameState newState = state;
            newState.placeTile(move, myColor == PlayerColor::WHITE ? TileType::WHITE : TileType::BLACK);
            nextStates.push_back({move, newState});
        }

        if (ENABLE_SORTING)
            std::sort(
                nextStates.begin(),
                nextStates.end(),
                [&](const std::pair<BoardPosition, GameState> &a, const std::pair<BoardPosition, GameState> &b)
                {
                    if (myColor == PlayerColor::WHITE)
                        return heuristic(a.second) > heuristic(b.second);
                    return heuristic(a.second) < heuristic(b.second);
                });

        int bestValue = myColor == PlayerColor::WHITE ? INT_MIN : INT_MAX;
        BoardPosition bestMove = {-1, -1};

        for (auto nextState : nextStates)
        {
            GameState newState = nextState.second;
            PlayerColor reverseColor = myColor == PlayerColor::WHITE ? PlayerColor::BLACK : PlayerColor::WHITE;
            auto result = evaluate(reverseColor, newState, remainingDepth - 1, alpha, beta);
            if (myColor == PlayerColor::WHITE)
            {
                if (result.first > bestValue || bestMove.x == -1)
                {
                    bestValue = result.first;
                    bestMove = nextState.first;
                }
                alpha = std::max(alpha, bestValue);
            }
            else
            {
                if (result.first < bestValue || bestMove.x == -1)
                {
                    bestValue = result.first;
                    bestMove = nextState.first;
                }
                beta = std::min(beta, bestValue);
            }
            if (beta <= alpha)
                break;
        }

        return {bestValue, bestMove};
    }

public:
    BoardPosition makeMove(PlayerColor myColor, const GameState &state) override
    {
        auto result = evaluate(myColor, state, MAX_DEPTH, INT_MIN, INT_MAX);
        return result.second;
    }
};

class HumanAgent : public GameAgent
{
public:
    BoardPosition makeMove(PlayerColor myColor, const GameState &state) override
    {
        // Pretty print board
        std::cout << " 01234567\n";
        for (char y = 0; y < 8; y++)
        {
            std::cout << (int)y;
            for (char x = 0; x < 8; x++)
            {
                switch (state.getTile({x, y}))
                {
                case TileType::EMPTY:
                    std::cout << ".";
                    break;
                case TileType::WHITE:
                    std::cout << "W";
                    break;
                case TileType::BLACK:
                    std::cout << "B";
                    break;
                }
            }
            std::cout << std::endl;
        }

        std::vector<BoardPosition> validMoves = state.getValidMoves(myColor == PlayerColor::WHITE ? TileType::WHITE : TileType::BLACK);
        if (validMoves.size() == 0)
            return {-1, -1};

        int x, y;
        std::cout << "Enter your move: ";
        
        while(true)
        {
            std::cin >> x >> y;
            if(std::cin.fail())
            {
                std::cin.clear();
                std::cin.ignore(1000, '\n');
                std::cout << "Invalid input. Try again: ";
                continue;
            }
            if(std::find(validMoves.begin(), validMoves.end(), BoardPosition{(char)x, (char)y}) == validMoves.end())
            {
                std::cout << "Invalid move. Try again: ";
                continue;
            }
            break;
        }

        return {(char)x, (char)y};
    }
};

enum GameResult
{
    WHITE_WIN = 0,
    BLACK_WIN = 1,
    DRAW = 2
};

class Reversi
{
    GameAgent *whiteAgent;
    GameAgent *blackAgent;

public:
    Reversi(GameAgent *white, GameAgent *black) : whiteAgent(white), blackAgent(black) {}

    GameResult play(bool print = true)
    {
        GameState state = initialState;
        PlayerColor toPlay = PlayerColor::WHITE;
        int nPasses = 0;
        while (!state.isFull() && nPasses < 2)
        {
            if (print)
                std::cout << state.toString() << std::endl;
            GameAgent *agent = toPlay == PlayerColor::WHITE ? whiteAgent : blackAgent;
            BoardPosition move = agent->makeMove(toPlay, state);
            if (!move.isValid() || (move.x != -1 && state.getTile(move) != TileType::EMPTY))
                throw std::runtime_error((toPlay == PlayerColor::WHITE ? "White" : "Black") + std::string(" agent refused to move correctly"));
            if (move.x != -1)
            {
                nPasses = 0;
                state.placeTile(move, toPlay == PlayerColor::WHITE ? TileType::WHITE : TileType::BLACK);
            }
            else
                nPasses++;

            toPlay = toPlay == PlayerColor::WHITE ? PlayerColor::BLACK : PlayerColor::WHITE;
        }

        if (print)
        {
            std::cout << state.toString() << std::endl;
            std::cout << "White: " << state.whiteCount() << " Black: " << state.blackCount() << std::endl;
            std::cout << "Winner: " << (state.whiteCount() > state.blackCount() ? "White" : "Black") << std::endl;
        }

        if (state.whiteCount() > state.blackCount())
            return GameResult::WHITE_WIN;
        if (state.whiteCount() < state.blackCount())
            return GameResult::BLACK_WIN;
        return GameResult::DRAW;
    }

    ~Reversi()
    {
        delete whiteAgent;
        delete blackAgent;
    }
};

void simulateStandard()
{
    std::srand(std::time(nullptr));
    Reversi game(new CleverAgent(), new RandomAgent());
    int gameCount = 1000;
    int whiteWins = 0;
    int blackWins = 0;
    for (int i = 0; i < gameCount; i++)
    {
        if (i % (gameCount / 10) == 0)
            std::cout << "Game " << i + 1 << " out of " << gameCount << std::endl;
        GameResult result = game.play(false);
        if (result == GameResult::WHITE_WIN)
            whiteWins++;
        if (result == GameResult::BLACK_WIN)
            blackWins++;
    }
    std::cout << "White wins: " << whiteWins << " Black wins: " << blackWins << std::endl;
}

void duellerMode()
{
    bool colorKnown = false;
    GameState state = initialState;
    PlayerColor myColor = PlayerColor::WHITE;
    GameAgent *agent = new CleverAgent();

    std::cout << "RDY" << std::endl;

    while (true)
    {
        std::string command;
        std::cin >> command;

        if (command == "BYE")
            break;

        if (command == "ONEMORE")
        {
            colorKnown = false;
            state = initialState;
            std::cout << "RDY" << std::endl;
        }

        if (command == "UGO" || command == "HEDID")
        {
            float t1, t2;
            std::cin >> t1 >> t2;
            if (!colorKnown)
            {
                if (command == "UGO")
                    myColor = PlayerColor::WHITE;
                else
                    myColor = PlayerColor::BLACK;
                colorKnown = true;
            }

            if (command == "HEDID")
            {
                int x, y;
                std::cin >> x >> y;
                state.placeTile({(char)x, (char)y}, myColor == PlayerColor::WHITE ? TileType::BLACK : TileType::WHITE);
            }

            BoardPosition myMove = agent->makeMove(myColor, state);
            state.placeTile(myMove, myColor == PlayerColor::WHITE ? TileType::WHITE : TileType::BLACK);
            std::cout << "IDO " << (int)myMove.x << " " << (int)myMove.y << std::endl;
        }
    }
    delete agent;
}

void humanMode()
{
    Reversi game(new HumanAgent(), new CleverAgent());
    game.play();
}

int main(int argc, char **argv)
{

    if (argc > 1 && std::string(argv[1]) == "test")
        simulateStandard();
    else if (argc > 1 && std::string(argv[1]) == "human")
        humanMode();
    else
        duellerMode();

    return 0;
}
