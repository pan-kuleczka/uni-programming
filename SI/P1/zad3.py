from enum import Enum
import random
import typing

class CardColor(Enum):
    HEARTS = 1
    DIAMONDS = 2
    CLUBS = 3
    SPADES = 4

class CardRank(Enum):
    TWO = 2
    THREE = 3
    FOUR = 4
    FIVE = 5
    SIX = 6
    SEVEN = 7
    EIGHT = 8
    NINE = 9
    TEN = 10
    JACK = 11
    QUEEN = 12
    KING = 13
    ACE = 14

class PokerHand(Enum):
    HIGH_CARD = 1
    ONE_PAIR = 2
    TWO_PAIR = 3
    THREE_OF_A_KIND = 4
    STRAIGHT = 5
    FLUSH = 6
    FULL_HOUSE = 7
    FOUR_OF_A_KIND = 8
    STRAIGHT_FLUSH = 9
    ROYAL_FLUSH = 10

class Card:
    def __init__(self, color : CardColor, rank : CardRank) -> None:
        self.color = color
        self.rank = rank

def get_poker_hand(cards) -> PokerHand:
    if len(cards) != 5:
        raise ValueError("Invalid number of cards")
    cards.sort(key=lambda card: card.rank.value)
    if cards[0].rank == CardRank.TEN and cards[1].rank == CardRank.JACK and cards[2].rank == CardRank.QUEEN and cards[3].rank == CardRank.KING and cards[4].rank == CardRank.ACE:
        if cards[0].color == cards[1].color == cards[2].color == cards[3].color == cards[4].color:
            return PokerHand.ROYAL_FLUSH
        return PokerHand.STRAIGHT_FLUSH
    if cards[0].rank.value + 1 == cards[1].rank.value and cards[1].rank.value + 1 == cards[2].rank.value and cards[2].rank.value + 1 == cards[3].rank.value and cards[3].rank.value + 1 == cards[4].rank.value:
        if cards[0].color == cards[1].color == cards[2].color == cards[3].color == cards[4].color:
            return PokerHand.STRAIGHT_FLUSH
    if cards[0].rank == cards[1].rank == cards[2].rank == cards[3].rank:
        return PokerHand.FOUR_OF_A_KIND
    if cards[1].rank == cards[2].rank == cards[3].rank == cards[4].rank:
        return PokerHand.FOUR_OF_A_KIND
    if cards[0].rank == cards[1].rank == cards[2].rank and cards[3].rank == cards[4].rank:
        return PokerHand.FULL_HOUSE
    if cards[0].rank == cards[1].rank and cards[2].rank == cards[3].rank == cards[4].rank:
        return PokerHand.FULL_HOUSE
    if cards[0].color == cards[1].color == cards[2].color == cards[3].color == cards[4].color:
        return PokerHand.FLUSH
    if cards[0].rank.value + 1 == cards[1].rank.value and cards[1].rank.value + 1 == cards[2].rank.value and cards[2].rank.value + 1 == cards[3].rank.value and cards[3].rank.value + 1 == cards[4].rank.value:
        return PokerHand.STRAIGHT
    if cards[0].rank == cards[1].rank == cards[2].rank:
        return PokerHand.THREE_OF_A_KIND
    if cards[1].rank == cards[2].rank == cards[3].rank:
        return PokerHand.THREE_OF_A_KIND
    if cards[2].rank == cards[3].rank == cards[4].rank:
        return PokerHand.THREE_OF_A_KIND
    if cards[0].rank == cards[1].rank and cards[2].rank == cards[3].rank:
        return PokerHand.TWO_PAIR
    if cards[0].rank == cards[1].rank and cards[3].rank == cards[4].rank:
        return PokerHand.TWO_PAIR
    if cards[1].rank == cards[2].rank and cards[3].rank == cards[4].rank:
        return PokerHand.TWO_PAIR
    if cards[0].rank == cards[1].rank:
        return PokerHand.ONE_PAIR
    if cards[1].rank == cards[2].rank:
        return PokerHand.ONE_PAIR
    if cards[2].rank == cards[3].rank:
        return PokerHand.ONE_PAIR
    if cards[3].rank == cards[4].rank:
        return PokerHand.ONE_PAIR
    return PokerHand.HIGH_CARD

figurant_deck = [Card(color, rank) for color in CardColor for rank in [CardRank.JACK, CardRank.QUEEN, CardRank.KING, CardRank.ACE]]
blotkarz_deck = [Card(color, rank) for color in CardColor for rank in [CardRank.TWO, CardRank.THREE, CardRank.FOUR, CardRank.FIVE, CardRank.SIX, CardRank.SEVEN, CardRank.EIGHT, CardRank.NINE, CardRank.TEN]]
blotkarz_winning = [Card(color, rank) for color in CardColor for rank in [CardRank.EIGHT, CardRank.NINE, CardRank.TEN]]

def get_random_five_cards(deck):
    return random.sample(deck, 5)

MONTE_CARLO_ITERATIONS = 100000

def get_figurant_winning_probability(deck1, deck2) -> float:
    wins = 0
    for _ in range(MONTE_CARLO_ITERATIONS):
        figurant_hand = get_random_five_cards(deck1)
        blotkarz_hand = get_random_five_cards(deck2)
        if get_poker_hand(figurant_hand).value >= get_poker_hand(blotkarz_hand).value:
            wins += 1
    return wins / MONTE_CARLO_ITERATIONS

def __main__() -> None:
    print(get_figurant_winning_probability(figurant_deck, blotkarz_deck))
    print(get_figurant_winning_probability(figurant_deck, blotkarz_winning))

if __name__ == "__main__":
    __main__()
