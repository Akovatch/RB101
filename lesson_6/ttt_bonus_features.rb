require 'yaml'
MESSAGES = YAML.load_file('ttt_messages.yml')

# CONSTANTS
# ===================================================================
WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] + # rows
                [[2, 5, 8], [1, 4, 7], [3, 6, 9]] + # cols
                [[1, 5, 9], [3, 5, 7]]              # diagonals

INITIAL_MARKER = ' '
USER_MARKER = 'X'
COMPUTER_MARKER = 'O'
GRAND_WINNER = 3

GREETING = <<-MSG

       *** Welcome to Tic Tac Toe! ***

Type 'help' if you would like to view the rules

   Otherwise, enter any key to begin playing

MSG

GAME_INFO = <<-MSG

*** A Guide to Tic Tac Toe ***

How to win: A round is won if a player is able to select squares in a row,
either horizontally, vertically, or diagonally.

Taking turns: The user chooses who will play first. Afterwards, the order of
turns alternates each round.

Selecting a square: The squares are numbered from 1 - 9. To select a square,
type the square's number using the guide below as reference.

 -----------
| 1 | 2 | 3 |
|---+---+---|
| 4 | 5 | 6 |
|---+---+---|
| 7 | 8 | 9 |
 -----------

The first player to win #{GRAND_WINNER} rounds becomes the grand-winner!

MSG

# GREETING AND HELP INFO METHODS
# ===================================================================
def prompt(msg)
  puts "=> #{msg}"
end

def welcome
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

# ORDER OF PLAY
# ===================================================================
def order_of_play
  response = ''
  system 'clear'
  prompt MESSAGES['which_player']
  loop do
    prompt MESSAGES['enter_player']
    response = gets.chomp.downcase
    (response = 'user') if ['u', 'user'].include?(response)
    (response = 'computer') if ['c', 'computer'].include?(response)
    break if ['u', 'user', 'c', 'computer'].include?(response)
    prompt MESSAGES['sorry']
  end
  response
end

def alternate_turns(player)
  player == 'user' ? 'computer' : 'user'
end

# BOARD DISPLAY METHODS
# ===================================================================
def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def display_board(brd)
  system 'clear'
  gameboard = <<-MSG

  You are #{USER_MARKER}. Computer is #{COMPUTER_MARKER}


       |     |                            Square Number
    #{brd[1]}  |  #{brd[2]}  |  #{brd[3]}                          -----------
       |     |                            | 1 | 2 | 3 |
  -----+-----+-----                       |---+---+---|
       |     |                            | 4 | 5 | 6 |
    #{brd[4]}  |  #{brd[5]}  |  #{brd[6]}                         |---+---+---|
       |     |                            | 7 | 8 | 9 |
  -----+-----+-----                        -----------
       |     |                                Guide
    #{brd[7]}  |  #{brd[8]}  |  #{brd[9]}
       |     |

  MSG
  puts gameboard
end

# TURN-TAKING / AI METHODS
# ===================================================================
def empty_squares(brd)
  brd.keys.select { |num| brd[num] == INITIAL_MARKER }
end

def joinor(arr, delimiter=', ', word='or')
  case arr.size
  when 1 then arr.first
  when 2 then arr.join(" #{word} ")
  else
    arr[-1] = "#{word} #{arr.last}"
    arr.join(delimiter)
  end
end

def place_piece!(brd, player)
  player == 'user' ? user_places_piece!(brd) : computer_places_piece!(brd)
end

def user_places_piece!(brd)
  square = ''
  loop do
    prompt "Choose a position to place a piece: #{joinor(empty_squares(brd))}:"
    square = gets.chomp.to_i
    break if empty_squares(brd).include?(square)
    prompt MESSAGES['sorry']
  end
  brd[square] = USER_MARKER
end

def find_at_risk_square(line, board, marker)
  if board.values_at(*line).count(marker) == 2
    board.select { |k, v| line.include?(k) && v == INITIAL_MARKER }.keys.first
  end
end

def computer_offense(brd)
  square = nil
  WINNING_LINES.each do |line|
    square = find_at_risk_square(line, brd, COMPUTER_MARKER)
    break if square
  end

  if empty_squares(brd).include?(5)
    square = 5
  end
  square
end

def computer_defense(brd)
  square = nil
  WINNING_LINES.each do |line|
    square = find_at_risk_square(line, brd, USER_MARKER)
    break if square
  end
  square
end

def computer_places_piece!(brd)
  square = computer_offense(brd)
  (square = computer_defense(brd)) if !square
  (square = empty_squares(brd).sample) if !square

  brd[square] = COMPUTER_MARKER
end

# GAME RESULT METHODS
# ===================================================================
def detect_winner(brd)
  WINNING_LINES.each do |line|
    return 'User' if brd.values_at(*line).count(USER_MARKER) == 3
    return 'Computer' if brd.values_at(*line).count(COMPUTER_MARKER) == 3
  end
  nil
end

def someone_won?(brd)
  !!detect_winner(brd) # converts a string or nil into true or false
end

def tie?(brd)
  empty_squares(brd).empty?
end

def display_winner(brd)
  system 'clear'
  prompt MESSAGES['user_wins'] if detect_winner(brd) == 'User'
  prompt MESSAGES['compy_wins'] if detect_winner(brd) == 'Computer'
end

def display_tie(brd)
  system 'clear'
  prompt MESSAGES['tie'] if tie?(brd)
end

def update_scores!(brd, scores)
  scores[:wins] += 1 if detect_winner(brd) == 'User'
  scores[:losses] += 1 if detect_winner(brd) == 'Computer'
  scores[:ties] += 1 if tie?(brd)
end

def display_scoreboard(scores)
  scoreboard = <<-MSG

  ***************** Scoreboard **********************
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

def grandwinner?(scores)
  scores[:wins] == GRAND_WINNER || scores[:losses] == GRAND_WINNER
end

def display_grandwinner(scores)
  if scores[:wins] == 5
    prompt "Congratulations! You have won #{GRAND_WINNER}"\
            " times and are the grand winner!"
  else
    prompt "Sorry, the computer has won #{GRAND_WINNER}"\
            " times and is the grand winner."
  end
end

# RESTART / EXIT METHODS
# ===================================================================
def play_another_round?
  prompt MESSAGES['another_round']
  input = gets.chomp.downcase
  input != 'q'
end

def restart_game?
  system 'clear'
  prompt MESSAGES['new_game']
  prompt MESSAGES['new_game_prompt']
  answer = gets.chomp
  answer.downcase == 'y'
end

# MAIN PROGRAM
# ===================================================================
welcome
loop do # main loop
  current_player = order_of_play
  first_move = current_player
  scores = { wins: 0, losses: 0, ties: 0 }

  loop do # single round loop
    board = initialize_board
    display_board(board)

    loop do # gameplay loop
      display_board(board)
      place_piece!(board, current_player)
      current_player = alternate_turns(current_player)
      break if someone_won?(board) || tie?(board)
    end

    if someone_won?(board)
      display_winner(board)
    else
      display_tie(board)
    end

    update_scores!(board, scores)
    display_scoreboard(scores)

    if grandwinner?(scores)
      display_grandwinner(scores)
      break
    end

    break unless play_another_round?

    current_player = alternate_turns(first_move)
    first_move = current_player
  end # end of single round loop

  break unless restart_game?
end # end of main loop

system 'clear'
prompt MESSAGES['thanks']
