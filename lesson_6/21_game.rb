require 'yaml'
MESSAGES = YAML.load_file('21_messages.yml')

# CONSTANTS
# ============================================================

LIMIT = 21
NAME_OF_GAME = 'Twenty-one'
DEALER_FLOOR = 17
GRAND_WINNER = 5
SUITS = ['H', 'S', 'D', 'C']
VALUES = ['2', '3', '4', '5', '6', '7', '8', '9', 'J', 'Q', 'K', 'A']
CONVERSION = { 'H' => 'Hearts',
               'C' => 'Clubs',
               'S' => 'Spades',
               'D' => 'Diamonds',
               'J' => 'Jack',
               'Q' => 'Queen',
               'K' => 'King',
               'A' => 'Ace',
               '2' => '2',
               '3' => '3',
               '4' => '4',
               '5' => '5',
               '6' => '6',
               '7' => '7',
               '8' => '8',
               '9' => '9' }

GREETING = <<-MSG

       *** Welcome to #{NAME_OF_GAME}! ***

Type 'help' if you would like to view the rules

   Otherwise, enter any key to begin playing

MSG

GAME_INFO = <<-MSG

               *** A Guide to #{NAME_OF_GAME} ***

The goal of #{NAME_OF_GAME} is to try to get your hand's total
as close to #{LIMIT} as possible, without going over. If you go over #{LIMIT},
it's called a "bust" and you lose. The first player to win #{GRAND_WINNER}
rounds is named the grand winner!

Card Values:
2 - 10 = face value
Jack, Queen, King = 10
Ace = 1 or 11 (depending on the total of your hand)

Gameplay: You start with two cards and then must decide whether to hit or stay.
If you hit, the value of the new card is added to your total. The dealer will
show you one of their cards to aid in your strategy.

If nobody busts, the your cards are compared to the dealer's cards,
and whoever has a higher total wins!

MSG

# GAME SETUP METHODS:
# ============================================================

def prompt(msg)
  puts "=> #{msg}"
end

def welcome_message
  system 'clear'
  puts GREETING
  input = gets.chomp
  help_message if input == 'help'
end

def help_message
  system 'clear'
  puts GAME_INFO
  prompt MESSAGES['press_any']
  gets
end

def initialize_deck
  SUITS.product(VALUES).shuffle
end

def deal_cards(deck)
  result = []
  2.times { result << deck.pop }
  result
end

# PLAYER / DEALER TURN METHODS
# ============================================================

def convert_cards(cards)
  cards.each do |card|
    prompt " - The #{CONVERSION[card[1]]} of #{CONVERSION[card[0]]}"
  end
end

def display_player_cards(cards, turn_total)
  puts
  prompt "You currently have #{cards.count} cards:"
  convert_cards(cards)
  puts
  prompt "The total of your hand is #{turn_total}"
end

def display_dealer_card(cards)
  visible_card = cards.sample
  puts
  prompt "The dealer shows you one card:
   - The #{CONVERSION[visible_card[1]]} of #{CONVERSION[visible_card[0]]}"
end

def hit(cards, deck)
  cards << deck.sample
end

def dealer_turn(cards, deck, turn_total)
  loop do
    sleep 1.5
    if busted?(turn_total)
      prompt "*** The dealer busted with a total of #{turn_total}" \
             " - you win this round! ***"
      break
    elsif turn_total < DEALER_FLOOR
      hit(cards, deck)
      turn_total = total(cards)
      prompt MESSAGES['dealer_hit']
    elsif turn_total >= DEALER_FLOOR
      prompt MESSAGES['dealer_stay']
      break
    end
  end
end

def ask_player
  answer = ''
  loop do
    prompt "------------------------------"
    prompt MESSAGES['hit_or_stay']
    answer = gets.chomp
    break if ['h', 's'].include?(answer)
    prompt MESSAGES['h_or_s']
  end
  answer
end

def player_turn(cards, deck, turn_total)
  loop do
    answer = ask_player
    system 'clear'
    if answer == 'h'
      hit(cards, deck)
      prompt MESSAGES['hit']
      turn_total = total(cards)
      display_player_cards(cards, turn_total)
    end
    break if answer == 's' || busted?(turn_total)
  end
  system 'clear'
  busted?(turn_total) ? (prompt MESSAGES['busted']) : (prompt MESSAGES['stay'])
end

# END-GAME ANAYSIS METHODS
# ============================================================

def busted?(turn_total)
  turn_total > LIMIT
end

def total(cards)
  values = cards.map { |card| card[1] }

  sum = 0
  values.each do |value|
    sum += if value == 'A' 
             11
           elsif value.to_i == 0 # J, Q, K
             10
           else
             value.to_i
           end
  end

  values.select { |value| value == 'A' }.count.times do # correcting for aces
    sum -= 10 if sum > LIMIT
  end

  sum
end

def grand_winner?(scores)
  scores[:wins] == GRAND_WINNER || scores[:losses] == GRAND_WINNER
end

def update_scores!(player_total, dealer_total, scores)
  if player_total > LIMIT
    scores[:losses] += 1
  elsif dealer_total > LIMIT
    scores[:wins] += 1
  elsif dealer_total < player_total
    scores[:wins] += 1
  elsif dealer_total > player_total
    scores[:losses] += 1
  else
    scores[:ties] += 1
  end
end

# END-GAME DISPLAY METHODS
# ============================================================
def display_comparison(player_total, dealer_total)
  sleep 1.5
  puts
  if player_total > dealer_total
    prompt MESSAGES['congrats']
  elsif dealer_total > player_total
    prompt MESSAGES['dealer_won']
  else
    prompt MESSAGES['tie']
  end
end

def display_hands(player_total, dealer_total, player_cards, dealer_cards)
  puts
  puts MESSAGES['final_hands']
  prompt 'The Dealer had:'
  convert_cards(dealer_cards)
  prompt "for a total of: #{dealer_total}"
  puts MESSAGES['line']
  prompt "You had:"
  convert_cards(player_cards)
  prompt "for a total of: #{player_total}"
  puts MESSAGES['line']
  puts
end

def display_grand_winner(scores)
  if scores[:wins] == 5
    prompt "*** CONGRATULATIONS! You have won #{GRAND_WINNER}" \
           " times and are the grand winner! ***"
  else
    prompt "Sorry, the dealer has won #{GRAND_WINNER}" \
           " times and is the grand winner."
  end
end

def display_scoreboard(scores)
  system 'clear'
  scoreboard = <<-MSG

  ***********  The current score is:  ***************
  *                                                 *
  *   You: #{scores[:wins]}                                        *
  *                                                 *
  *   Computer: #{scores[:losses]}                                   *
  *                                                 *
  *   Ties: #{scores[:ties]}                                       *
  *                                                 *
  *   (First to win #{GRAND_WINNER} games is the Grand Winner!)   *
  *                                                 *
  ***************************************************
  MSG
  puts scoreboard
end

# PLAY AGAIN / RESTART METHODS
# ============================================================
def play_again?
  puts
  prompt MESSAGES['new_game']
  prompt MESSAGES['new_game_prompt']
  answer = gets.chomp
  answer.downcase == 'y'
end

def another_round?
  prompt MESSAGES['another_round']
  input = gets.chomp.downcase
  input != 'q'
end

def any_key
  prompt MESSAGES['any_key_round']
  gets
end

# PROGRAM
# ============================================================
system 'clear'
welcome_message

loop do
  scores = { wins: 0, losses: 0, ties: 0 }

  loop do
    system 'clear'
    deck = initialize_deck # deck created

    player_cards = deal_cards(deck) # deal cards to player
    player_total = total(player_cards)

    dealer_cards = deal_cards(deck) # deal cards to dealer
    dealer_total = total(dealer_cards)

    display_player_cards(player_cards, player_total) # show player their cards
    display_dealer_card(dealer_cards)

    player_turn(player_cards, deck, player_total) # player gameplay
    player_total = total(player_cards)

    unless busted?(player_total)
      prompt MESSAGES['dealer_turn'] # dealer gameplay (if player didn't bust)
      dealer_turn(dealer_cards, deck, dealer_total)
      dealer_total = total(dealer_cards)
    end

    unless busted?(player_total) || busted?(dealer_total) # compare scores
      display_comparison(player_total, dealer_total)
    end
    # display both players' hands at end of round
    display_hands(player_total, dealer_total, player_cards, dealer_cards)

    update_scores!(player_total, dealer_total, scores) # update and show scores

    if grand_winner?(scores) # determine if / display grand_winner
      display_grand_winner(scores)
      break
    end

    break unless another_round? # ask to continue to next round
    display_scoreboard(scores)
    any_key
  end

  break unless play_again? # ask to start a new game (all scores will reset)
end
system 'clear'
prompt "Thank you for playing #{NAME_OF_GAME}! Bye!"
