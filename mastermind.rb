# MASTERMIND

# A Mastermind game on the command line where you have 12 turns to guess the
# secret code. Includes a rudimentary computer AI and the option to choose 
# to be the creater of the code or the guesser.

class Mastermind

  def initialize
    @max_guesses = 12
    @total_guesses = 0
    @computer = Computer.new('', '', '', '')
    @player = Player.new
    @winner = nil
    @loser = nil
  end

  def start_game
    puts "Welcome to Mastermind, a code-breaking game."
    puts ""
    choose_role
  end

  # User can choose the role played.
  def choose_role
    role = nil
    puts "Choose your role!"
    puts "Would you like to be the code creator or the code breaker?"
    puts ""
    until (1..2).include?(role)
      print "Please enter '1' for code creator or '2' for code breaker. "
      role = gets.chomp.to_i
      if role == 1
        maker_instructions
        game_turn_1
      elsif role == 2
        breaker_instructions
        puts "Break the computer's code!"
        puts ""
        game_turn_2
      end
    end
  end

  # Code for one turn of the "code creator" route.
  def game_turn_1
    @player.enter_code
    until @total_guesses == @max_guesses || is_loser?
      @total_guesses += 1
      puts "Attempt: #{@total_guesses}"
      @computer.guess_code(@player.code)
      @player.check_guess(@player.code, @computer.comp_guess)
      if @player.partially_correct > 0 && @player.correct == 0
        @computer.smart_guess = @computer.comp_guess
      elsif @player.correct > 0
        @computer.smarter_guess = @computer.smart_guess
      end
      puts ""
      is_loser?
      if is_loser?
        puts "The computer cracked your code! You lose."
        play_again?
        break
      elsif @total_guesses == @max_guesses
        puts "The computer failed to crack your code. You win!"
        play_again?
        break
      end
      @player.correct = 0
      @player.partially_correct = 0
      @computer.comp_guess = ''
      sleep(1)
    end
  end

  # Code for one turn of the "code breaker" route.
  def game_turn_2
    @computer.create_code
    until @total_guesses == @max_guesses || is_winner?
      @total_guesses += 1
      @player.get_guess
      @player.check_guess(@computer.secret_code, @player.guess)
      @player.display_hint
      display_guesses
      is_winner?
      if is_winner?
        puts "Congratulations, you guessed the secret code! It was #{@computer.secret_code}."
        play_again?
      elsif @total_guesses == @max_guesses
        puts "You are out of guesses! Game over. The secret code was #{@computer.secret_code}."
        play_again?
      end
      @player.correct = 0
      @player.partially_correct = 0
      @player.guess = nil
    end
  end

  def display_guesses
    puts "Total guesses: #{@total_guesses}"
    puts ""
  end

  def breaker_instructions
    puts ""
    puts "As the code breaker, your goal is to guess the secret code (a 4-digit"
    puts "combination of the numbers 1-6 eg. 3446). After each guess, you will"
    puts "be given a hint which provides feedback about your guess. 'Correct'"
    puts "means that a number you have guessed is within the secret code and"
    puts "in the correct position.  'Partially Correct' means that a number you"
    puts "have guessed is within the secret code but not in the correct"
    puts "position.  You have 12 guesses, good luck!"
    puts ""
  end

  def maker_instructions
    puts ""
    puts "As the code maker, you must enter a secret code (a 4-digit combination"
    puts "of the numbers 1-6 eg. 3446) for the computer to guess. The computer"
    puts "may be smarter than you think. Good luck!"
    puts ""
  end

  def is_winner?
    @winner = true if @player.guess.eql?(@computer.secret_code)
    return @winner
  end

  def is_loser?
    @loser = true if @computer.smarter_guess.eql?(@player.code)
    return @loser
  end

  def play_again?
    print "Do you want to play again? "
    entry = gets.downcase
    if entry.include? "y"
      puts ""
      game = Mastermind.new
      game.start_game
    end
  end
end

class Player

  attr_accessor :guess, :correct, :partially_correct, :code

  def initialize
    @code = nil
    @guess = nil
    @correct = 0
    @partially_correct = 0
  end

  # Returns true only if input is 4 numeric characters between 1 and 6.
  def is_valid_input?(guess)
    /^[1-6]{4}$/.match(guess) ? true : false
  end

  def get_guess
    until is_valid_input?(@guess)
      print "Enter your guess. "
      @guess = gets.chomp
      if !is_valid_input?(@guess)
        puts "That is not a valid guess. Please try again."
        puts ""
      end
    end
    @guess
  end

  # Same as above, but slightly changed text for the "code creator" route.
  def enter_code
    until is_valid_input?(@code)
      print "Enter your code. "
      @code = gets.chomp
      puts ""
      if !is_valid_input?(@code)
        puts "That is not a valid code. Please try again."
        puts ""
      end
    end
    @code
  end

  def display_hint
    puts "Correct: #{@correct}         Partially Correct: #{@partially_correct}"
  end

  # Runs through each character in the guess and compares it to the character
  # in the same position in the secret code.
  def check_guess(code, guess)
    count = 0
    guess.each_char do |i|
      if guess[count] === code[count]
        @correct += 1
      elsif guess.include?(code[count])
        @partially_correct += 1
      end
      count += 1  
    end
  end
end

class Computer

  attr_accessor :secret_code, :comp_guess, :smart_guess, :smarter_guess

  # The Computer class initializes 3 'versions' of guess as part of the AI.
  def initialize(secret_code, comp_guess, smart_guess, smarter_guess)
    @secret_code = secret_code
    @comp_guess = comp_guess
    @smart_guess = smart_guess
    @smarter_guess = smarter_guess
    @already_guessed = []
  end

  def create_code
    random_num = [1,2,3,4,5,6]
    4.times do 
      @secret_code += random_num.sample(1).join
    end
    @secret_code
  end

  # This is the computer's AI.  It is very basic and needs some work.  If the
  # computer guesses a number in the code but in the wrong position, its next
  # guess will be a shuffling of 'smart_guess'.  When a future guess contains
  # a number in the same position as the code, the AI will put that value
  # into 'smarter_guess'. The AI will then shuffle code characters until it 
  # happens upon the code (or not).  All previous guesses are pushed to an array
  # to prevent them from being guessed twice.  There probably need to be some 
  # more steps added before the computer determines all of the correct numbers.
  def guess_code(code)
    if @smart_guess == ''
      random_num = [1,2,3,4,5,6]
      4.times do
        @comp_guess += random_num.sample(1).join
      end
      @already_guessed.push(@comp_guess)
      puts @comp_guess
    elsif @smart_guess != nil && @smarter_guess == nil
      until !@already_guessed.include?(@smart_guess)
        @smart_guess = @smart_guess.split("").shuffle.join
      end
      @already_guessed.push(@smart_guess)
      puts @smart_guess
    elsif @smarter_guess != nil
      until !@already_guessed.include?(@smarter_guess)
        @smarter_guess = code.split("").shuffle.join
      end
      @already_guessed.push(@smarter_guess)
      puts @smarter_guess
    end
  end
end

game = Mastermind.new
game.start_game