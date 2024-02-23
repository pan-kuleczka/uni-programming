words = set()

def import_words() -> None:
    with open('polish_words.txt', 'r', encoding="utf8") as file:
        for line in file:
            word = line.strip()
            words.add(word)

def is_word(word : str) -> bool:
    return word in words

def decode_row(row : str) -> list:
    dp = [(0, "") for _ in range(len(row) + 1)]
    for i in range(len(row)):
        for word_length in range(1, min(20, len(row) - i + 1)):
            word = row[i:i + word_length]
            if is_word(word):
                if dp[i + word_length][0] < dp[i][0] + word_length * word_length:
                    dp[i + word_length] = (dp[i][0] + word_length * word_length, word)
    result = []
    i = len(row)
    while i > 0:
        result.append(dp[i][1])
        i -= len(dp[i][1])
    return result[::-1]

def __main__() -> None:
    import_words()
    with open('zad2_input.txt', 'r', encoding="utf8") as input:
        with open('zad2_output.txt', 'w', encoding="utf8") as output:
            for line in input:
                row = line.strip()
                result = decode_row(row)
                output.write(" ".join(result) + "\n")

if __name__ == "__main__": 
    __main__()
