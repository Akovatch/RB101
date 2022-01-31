require 'yaml'
MESSAGES = YAML.load_file('mortgage_calc_messages.yml')

system 'clear'

def prompt(message)
  puts "=> #{message}"
end

def number?(input)
  input.to_f.to_s == input || input.to_i.to_s == input
end

def greet
  prompt(MESSAGES['welcome'])
  prompt(MESSAGES['line'])
end

def get_loan_amount
  prompt(MESSAGES['amount'])

  loan_amount = ''
  loop do
    loan_amount = gets.chomp

    if number?(loan_amount) && loan_amount.to_f > 0
      break
    else
      prompt(MESSAGES['valid_amount'])
    end
  end
  loan_amount
end

def get_apr
  prompt(MESSAGES['apr'])
  prompt(MESSAGES['apr_example'])

  apr = ''
  loop do
    apr = gets.chomp

    if number?(apr) && apr.to_f >= 0
      break
    else
      prompt(MESSAGES['valid_apr'])
    end
  end
  apr.to_f / 100
end

def get_loan_duration_years
  prompt(MESSAGES['loan_duration'])

  years = ''
  loop do
    years = gets.chomp

    if number?(years) && years.to_f > 0
      break
    else
      prompt(MESSAGES['valid_duration'])
    end
  end
  years
end

def get_loan_duration_months
  prompt(MESSAGES['loan_duration_months'])

  months = ''
  loop do
    months = gets.chomp

    if number?(months) && months.to_f > 0
      break
    else
      prompt(MESSAGES['valid_duration'])
    end
  end
  months
end

def compute_monthly_payment(loan_amount, monthly_interest_rate, months)
  if monthly_interest_rate == 0
    monthly_payment = loan_amount.to_f / months
  else
    monthly_payment = loan_amount.to_f *
                      (monthly_interest_rate /
                      (1 - (1 + monthly_interest_rate)**(-months)))
  end
  format("%.2f", monthly_payment)
end

greet

loop do
  loan_amount = get_loan_amount

  system 'clear'
  apr = get_apr

  loan_duration_years = get_loan_duration_years
  loan_duration_additional_months = get_loan_duration_months

  monthly_interest_rate = apr / 12
  months =
    (loan_duration_years.to_f * 12) + loan_duration_additional_months.to_f

  result = compute_monthly_payment(loan_amount, monthly_interest_rate, months)

  system 'clear'
  prompt("Your monthly payment is $#{result}")

  prompt(MESSAGES['again'])
  answer = gets.chomp
  break unless answer.downcase.start_with?('y')

  prompt("Thank you for using the loan calculator! Goodbye.")
end
