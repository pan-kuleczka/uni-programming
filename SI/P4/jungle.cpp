#include <bits/stdc++.h>
typedef unsigned long long ull;

enum TileType
{
    EMPTY = 0,
    TRAP = 1,
    WHITE_CAVE = 2,
    BLACK_CAVE = 3,
    LAKE = 4
};

const std::array<std::array<TileType, 7>, 9> decodeBoard()
{
    const std::string ENCODED_BOARD[9] = {
    "..#*#..",
    "...#...",
    ".......",
    ".~~.~~.",
    ".~~.~~.",
    ".~~.~~.",
    ".......",
    "...#...",
    "..#!#.."};
    std::array<std::array<TileType, 7>, 9> decodedBoard;
    for (int i = 0; i < 9; ++i)
    {
        for (int j = 0; j < 7; ++j)
        {
            switch (ENCODED_BOARD[i][j])
            {
            case '.':
                decodedBoard[i][j] = EMPTY;
                break;
            case '#':
                decodedBoard[i][j] = TRAP;
                break;
            case '!':
                decodedBoard[i][j] = WHITE_CAVE;
                break;
            case '*':
                decodedBoard[i][j] = BLACK_CAVE;
                break;
            case '~':
                decodedBoard[i][j] = LAKE;
                break;
            }
        }
    }
    return decodedBoard;
}

const std::array<std::array<TileType, 7>, 9> DECODED_BOARD = decodeBoard();

struct BoardPosition
{
    char x;
    char y;

    bool doesExist() const
    {
        return x != -1 && y != -1;
    }

    bool isValid() const
    {
        if (x == -1 && y == -1)
            return true;
        return x >= 0 && x < 9 && y >= 0 && y < 7;
    }

    bool operator==(const BoardPosition &other) const
    {
        return x == other.x && y == other.y;
    }

    BoardPosition operator+(const BoardPosition &other) const
    {
        return {(char)(x + (char)other.x), (char)(y + (char)other.y)};
    }
};

const std::array<BoardPosition, 4> DIRECTIONS = {
    BoardPosition({1, 0}),
    BoardPosition({-1, 0}),
    BoardPosition({0, 1}),
    BoardPosition({0, -1})};

TileType getTile(const BoardPosition &pos)
{
    return DECODED_BOARD[pos.x][pos.y];
}

enum PlayerColor
{
    WHITE = 0,
    BLACK = 1
};

PlayerColor getOpponent(PlayerColor color)
{
    return color == WHITE ? BLACK : WHITE;
}

enum PieceType
{
    RAT = 0,
    CAT = 1,
    DOG = 2,
    WOLF = 3,
    PANTHER = 4,
    TIGER = 5,
    LION = 6,
    ELEPHANT = 7
};

PieceType charToPieceType(char c)
{
    switch (c)
    {
    case 'r':
        return RAT;
    case 'c':
        return CAT;
    case 'd':
        return DOG;
    case 'w':
        return WOLF;
    case 'j':
        return PANTHER;
    case 't':
        return TIGER;
    case 'l':
        return LION;
    case 'e':
        return ELEPHANT;
    }
    return RAT;
}

char pieceTypeToChar(PieceType type)
{
    switch (type)
    {
    case RAT:
        return 'r';
    case CAT:
        return 'c';
    case DOG:
        return 'd';
    case WOLF:
        return 'w';
    case PANTHER:
        return 'j';
    case TIGER:
        return 't';
    case LION:
        return 'l';
    case ELEPHANT:
        return 'e';
    }
    return 'r';
}

struct OptionalPiece
{
    bool exists;
    PlayerColor color;
    PieceType type;
};


class PiecePositions
{
    std::pair<std::array<BoardPosition, 8>, std::array<BoardPosition, 8>> pieces;
    std::array<std::array<OptionalPiece, 7>, 9> pieceAtPosition;

    void generateMap()
    {
        for (int i = 0; i < 9; ++i)
            for (int j = 0; j < 7; ++j)
                pieceAtPosition[i][j] = {false, WHITE, RAT};
        for (PlayerColor color : {WHITE, BLACK})
            for (PieceType type : {RAT, CAT, DOG, WOLF, PANTHER, TIGER, LION, ELEPHANT})
            {
                BoardPosition pos = getPiecePosition(color, type);
                pieceAtPosition[pos.x][pos.y] = {true, color, type};
            }
    }

    void setPositionWithoutMapUpdate(PlayerColor color, PieceType type, const BoardPosition &pos)
    {
        if (color == WHITE)
            pieces.first[type] = pos;
        else
            pieces.second[type] = pos;
    }

public:
    PiecePositions(const std::pair<std::array<BoardPosition, 8>, std::array<BoardPosition, 8>> &pieces)
    {
        this->pieces = pieces;
        generateMap();
    }
    PiecePositions() : PiecePositions(std::make_pair(std::array<BoardPosition, 8>(), std::array<BoardPosition, 8>())) {}

    const BoardPosition &getPiecePosition(PlayerColor color, PieceType type) const
    {
        if(color == WHITE)
            return pieces.first[type];
        return pieces.second[type];
    }

    OptionalPiece getPieceAtPosition(const BoardPosition &pos) const
    {
        return pieceAtPosition[pos.x][pos.y];
    }

    void setPosition(PlayerColor color, PieceType type, const BoardPosition &pos)
    {
        setPositionWithoutMapUpdate(color, type, pos);
        generateMap();
    }

    void movePiece(const BoardPosition &from, const BoardPosition &to)
    {
        OptionalPiece piece = getPieceAtPosition(from);
        if(!piece.exists)
            return;
        setPositionWithoutMapUpdate(piece.color, piece.type, to);
        OptionalPiece targetPiece = getPieceAtPosition(to);
        if(targetPiece.exists)
            setPositionWithoutMapUpdate(targetPiece.color, targetPiece.type, {-1, -1});
        generateMap();
    }

    std::string toString() const
    {
        std::string result = "";
        for (int i = 0; i < 9; ++i)
        {
            for (int j = 0; j < 7; ++j)
            {
                OptionalPiece piece = pieceAtPosition[i][j];
                if (piece.exists)
                {
                    if (piece.color == WHITE)
                        result += pieceTypeToChar(piece.type);
                    else
                        result += toupper(pieceTypeToChar(piece.type));
                }
                else
                    result += '.';
            }
            result += '\n';
        }
        return result;
    }
};

const PiecePositions generateInitialPiecePositions()
{
    const std::string ENCODED_PIECES[9] = {
        "L.....T",
        ".D...C.",
        "R.J.W.E",
        ".......",
        ".......",
        ".......",
        "e.w.j.r",
        ".c...d.",
        "t.....l"
    };

    std::array<BoardPosition, 8> whitePieces;
    std::array<BoardPosition, 8> blackPieces;

    for (int i = 0; i < 9; ++i)
    {
        for (int j = 0; j < 7; ++j)
        {
            char piece = ENCODED_PIECES[i][j];
            if (piece != '.')
            {
                BoardPosition position = {(char)i, (char)j};
                if (isupper(piece))
                    blackPieces[charToPieceType(tolower(piece))] = position;
                else
                    whitePieces[charToPieceType(piece)] = position;
            }
        }
    }

    return PiecePositions(std::make_pair(whitePieces, blackPieces));
}

const PiecePositions INITIAL_PIECE_POSITIONS = generateInitialPiecePositions();

struct Move
{
    BoardPosition from;
    BoardPosition to;
};

enum GameResult
{
    WHITE_WINS = 0,
    BLACK_WINS = 1,
    IN_PROGRESS = 2
};

// Jungle game state
class GameState
{
    PiecePositions piecePositions;
public:

    GameState()
    {
        piecePositions = INITIAL_PIECE_POSITIONS;
    }

    GameState(const PiecePositions &piecePositions)
    {
        this->piecePositions = piecePositions;
    }

    const PiecePositions &getPiecePositions() const
    {
        return piecePositions;
    }

    GameResult getGameResult() const
    {
        for(PlayerColor color : {WHITE, BLACK})
            for(PieceType type : {RAT, CAT, DOG, WOLF, PANTHER, TIGER, LION, ELEPHANT})
                {
                    BoardPosition pos = piecePositions.getPiecePosition(color, type);
                    if(getTile(pos) == WHITE_CAVE)
                        return BLACK_WINS;
                    if(getTile(pos) == BLACK_CAVE)
                        return WHITE_WINS;
                }
        return IN_PROGRESS;
    }

    std::vector<Move> getLegalMoves(PlayerColor color) const
    {
        std::vector<Move> legalMoves;
        for (PieceType type : {RAT, CAT, DOG, WOLF, PANTHER, TIGER, LION, ELEPHANT})
        {
            BoardPosition from = piecePositions.getPiecePosition(color, type);
            for (BoardPosition dir : DIRECTIONS)
            {
                BoardPosition to = from + dir;
                if(!to.isValid())
                    continue;
                if(color == WHITE && getTile(to) == WHITE_CAVE)
                    continue;
                if(color == BLACK && getTile(to) == BLACK_CAVE)
                    continue;
                
                if(getTile(to) == LAKE)
                {
                    if(type == RAT)
                    {
                        legalMoves.push_back({from, to});
                        continue;
                    }

                    if(type < TIGER || type > LION)
                        continue;

                    // Jumping over the lake
                    bool jumpingOverEnemyRat = false;
                    while(to.isValid() && getTile(to) == LAKE)
                    {
                        OptionalPiece piece = piecePositions.getPieceAtPosition(to);
                        if(piece.exists && piece.color != color && piece.type == RAT)
                        {
                            jumpingOverEnemyRat = true;
                            break;
                        }
                        to = to + dir;
                    }
                    if(!to.isValid() || jumpingOverEnemyRat)
                        continue;
                }

                OptionalPiece piece = piecePositions.getPieceAtPosition(to);
                if(piece.exists)
                {
                    if(piece.color == color)
                        continue;
                    if(type == RAT && getTile(from) == LAKE && getTile(to) != LAKE)
                        continue;
                    if(getTile(to) != TRAP)
                        if(!(type == RAT && piece.type == ELEPHANT))
                            if(type < piece.type)
                                continue;
                }
                legalMoves.push_back({from, to});
            }
        }
        return legalMoves;
    }

    void makeMove(const Move &move)
    {
        piecePositions.movePiece(move.from, move.to);
    }

    std::string toString() const
    {
        return piecePositions.toString();
    }
};

class GameAgent
{
public:
    virtual Move makeMove(PlayerColor myColor, const GameState &state) = 0;
    virtual ~GameAgent() {}
};

class AgentAlpha : public GameAgent 
{
    const int TOTAL_MOVES = 20000;
    float rateState(const GameState &state, PlayerColor myColor, int assignedMoves)
    {
        int won = 0;
        int lost = 0;
        while(assignedMoves > 0)
        {
            GameState currentState = state;
            PlayerColor currentColor = getOpponent(myColor);
            while(currentState.getGameResult() == IN_PROGRESS && assignedMoves > 0)
            {
                std::vector<Move> legalMoves = currentState.getLegalMoves(currentColor);
                if(legalMoves.size() == 0)
                    break;
                int moveIndex = std::rand() % legalMoves.size();
                currentState.makeMove(legalMoves[moveIndex]);
                currentColor = getOpponent(currentColor);
                assignedMoves--;
            }
            assignedMoves--;
            if(currentState.getGameResult() == myColor)
                won++;
            else if(currentState.getGameResult() == getOpponent(myColor))
                lost++;
        }
        if(won + lost == 0)
            return 0;
        return (float)won / (won + lost);
    }

    Move makeMove(PlayerColor myColor, const GameState &state) override
    {
        std::vector<Move> legalMoves = state.getLegalMoves(myColor);
        std::random_shuffle(legalMoves.begin(), legalMoves.end());
        int movesPerState = TOTAL_MOVES / legalMoves.size();
        float bestRate = -1;
        Move bestMove;
        for(int i = 0; i < legalMoves.size(); ++i)
        {
            Move move = legalMoves[i];
            GameState newState = state;
            newState.makeMove(move);
            float rate = rateState(newState, myColor, movesPerState);
            if(rate > bestRate || bestRate == -1)
            {
                bestRate = rate;
                bestMove = move;
            }
        }
        return bestMove;
    }
};

struct MCTSNode 
{
    MCTSNode *parent;
    std::map<Move, MCTSNode*> children;
    int visits = 0;
    float wins = 0;

    ~MCTSNode()
    {
        for(auto &child : children)
            delete child.second;
    }
};

class MCTSAgent : public GameAgent 
{
    const int N_ROUNDS = 100;
    Move makeMove(PlayerColor myColor, const GameState &state) override
    {
        MCTSNode root;
        for(int round = 0; round < N_ROUNDS; ++round)
        {
            MCTSNode *node = &root;
            GameState currentState = state;
            while(node->children.size() > 0)
            {
                float bestUCB = -1;
                Move bestMove;
                for(auto &child : node->children)
                {
                    float ucb = child.second->wins / child.second->visits + std::sqrt(2 * std::log(node->visits) / child.second->visits);
                    if(ucb > bestUCB || bestUCB == -1)
                    {
                        bestUCB = ucb;
                        bestMove = child.first;
                    }
                }
                node = node->children[bestMove];
                currentState.makeMove(bestMove);
            }
            PlayerColor currentColor = getOpponent(myColor);
            while(currentState.getGameResult() == IN_PROGRESS)
            {
                std::vector<Move> legalMoves = currentState.getLegalMoves(currentColor);
                if(legalMoves.size() == 0)
                    break;
                int moveIndex = std::rand() % legalMoves.size();
                currentState.makeMove(legalMoves[moveIndex]);
                currentColor = getOpponent(currentColor);
            }
            float result = 0;
            if(currentState.getGameResult() == myColor)
                result = 1;
            else if(currentState.getGameResult() == getOpponent(myColor))
                result = 0;
            else
                result = 0.5;
            while(node != nullptr)
            {
                node->visits++;
                node->wins += result;
                node = node->parent;
            }
        
        }
        float bestRate = -1;
        Move bestMove;
        for(auto &child : root.children)
        {
            float rate = child.second->wins / child.second->visits;
            if(rate > bestRate || bestRate == -1)
            {
                bestRate = rate;
                bestMove = child.first;
            }
        }
        return bestMove;
    }
};

class Jungle
{
    GameAgent *whiteAgent;
    GameAgent *blackAgent;

public:
    Jungle(GameAgent *white, GameAgent *black) : whiteAgent(white), blackAgent(black) {}

    GameResult play(bool print = true)
    {
        GameState state = GameState();
        PlayerColor toPlay = PlayerColor::WHITE;
        while (state.getGameResult() == IN_PROGRESS)
        {
            if (print)
                std::cout << state.toString() << std::endl;
            GameAgent *agent = toPlay == PlayerColor::WHITE ? whiteAgent : blackAgent;
            Move move = agent->makeMove(toPlay, state);
            if(print) 
                std::cout << "Move: " << (int)move.from.x << " " << (int)move.from.y << " -> " << (int)move.to.x << " " << (int)move.to.y << std::endl;
            state.makeMove(move);
            toPlay = getOpponent(toPlay);
        }

        GameResult result = state.getGameResult();

        if (print)
        {
            std::cout << state.toString() << std::endl;
            std::cout << "Winner: " << (result == WHITE_WINS ? "WHITE" : "BLACK") << std::endl;
        }

        return result;
    }

    ~Jungle()
    {
        delete whiteAgent;
        delete blackAgent;
    }
};

// void duellerMode()
// {
//     bool colorKnown = false;
//     GameState state = initialState;
//     PlayerColor myColor = PlayerColor::WHITE;
//     GameAgent *agent = new CleverAgent();

//     std::cout << "RDY" << std::endl;

//     while (true)
//     {
//         std::string command;
//         std::cin >> command;

//         if (command == "BYE")
//             break;

//         if (command == "ONEMORE")
//         {
//             colorKnown = false;
//             state = initialState;
//             std::cout << "RDY" << std::endl;
//         }

//         if (command == "UGO" || command == "HEDID")
//         {
//             float t1, t2;
//             std::cin >> t1 >> t2;
//             if (!colorKnown)
//             {
//                 if (command == "UGO")
//                     myColor = PlayerColor::WHITE;
//                 else
//                     myColor = PlayerColor::BLACK;
//                 colorKnown = true;
//             }

//             if (command == "HEDID")
//             {
//                 int x, y;
//                 std::cin >> x >> y;
//                 state.placeTile({(char)x, (char)y}, myColor == PlayerColor::WHITE ? TileType::BLACK : TileType::WHITE);
//             }

//             BoardPosition myMove = agent->makeMove(myColor, state);
//             state.placeTile(myMove, myColor == PlayerColor::WHITE ? TileType::WHITE : TileType::BLACK);
//             std::cout << "IDO " << (int)myMove.x << " " << (int)myMove.y << std::endl;
//         }
//     }
//     delete agent;
// }

int main(int argc, char **argv)
{
    std::srand(std::time(0));
    if (argc > 1 && std::string(argv[1]) == "test")
        return 0;
    else if (argc > 1 && std::string(argv[1]) == "human")
        return 0;
    

    GameAgent *whiteAgent = new AgentAlpha();
    GameAgent *blackAgent = new MCTSAgent();
    Jungle game = Jungle(whiteAgent, blackAgent);
    game.play();

    return 0;
}
