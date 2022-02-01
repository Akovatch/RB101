require 'yaml'
MESSAGES = YAML.load_file('rps_messages.yml')

VALID_CHOICES = %w(rock paper scissors lizard spock)
ABBREVIATED_CHOICES = %w(r p sc l sp)
WINNING_COMBOS = {
    'rock' => ['scissors', 'lizard'],
    'paper' => ['rock', 'spock'],
    'scissors' => ['paper', 'lizard'],
    'lizard' => ['spock', 'paper'],
    'spock' => ['scissors', 'rock']
   }

def prompt(message)
  puts("=> #{message}")
end

def win?(first_choice, second_choice)
  WINNING_COMBOS[first_choice].include?(second_choice)
end

def convert_abbreviation(input)
  case input
  when 'r' then 'rock'
  when 'p' then 'paper'
  when 'sc' then 'scissors'
  when 'l' then 'lizard'
  when 'sp' then 'spock'
  end
end

def get_player_choice
  input = ''
  loop do
    prompt(MESSAGES['line'])
    prompt("Choose one: #{VALID_CHOICES.join(', ')}")
    prompt(MESSAGES['abbreviations'])
    input = gets.chomp.downcase

    if VALID_CHOICES.include?(input) || ABBREVIATED_CHOICES.include?(input)
      input.length <= 2 ? (input = convert_abbreviation(input)) : input
      break
    else
      prompt(MESSAGES['not_valid'])
    end
  end
  input
end

def display_results(player, computer)
  if win?(player, computer)
    prompt(MESSAGES['win'])
  elsif player == computer
    prompt(MESSAGES['tie'])
  else
    prompt(MESSAGES['lose'])
  end
end

def final_count(wins, loses)
  if wins == 3
    prompt(MESSAGES['ast_line'])
    puts
    prompt(MESSAGES['congrats'])
  elsif loses == 3
    prompt(MESSAGES['ast_line'])
    puts
    prompt(MESSAGES['sorry'])
  end
end

system 'clear'

prompt(MESSAGES['welcome'])
prompt(MESSAGES['ast_line'])
prompt(MESSAGES['grand_winner'])

loop do
  win_count = 0
  lose_count = 0
  tie_count = 0
  choice = ''

  loop do
    choice = get_player_choice

    computer_choice = VALID_CHOICES.sample

    system "clear"
    prompt("You chose: #{choice.upcase}")
    prompt("Computer chose: #{computer_choice.upcase}")

    puts
    display_results(choice, computer_choice)
    puts

    if win?(choice, computer_choice)
      win_count += 1
    elsif choice == computer_choice
      tie_count += 1
    else
      lose_count += 1
    end

    scores = <<-MSG
     Scoreboard:
        -----------
        You: #{win_count}
        Computer: #{lose_count}
        Tie: #{tie_count}
    MSG

    prompt(scores)
    puts
    final_count(win_count, lose_count)

    break if win_count == 3 || lose_count == 3
  end

  puts
  prompt(MESSAGES['play_again?'])
  answer = gets.chomp.downcase
  break unless answer == 'y' || answer == 'yes'
end

prompt(MESSAGES['bye'])
