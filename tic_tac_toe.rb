# TIC TAC TOE

# A tic-tac-toe game on the command line where two human players can play 
# against each other and the board is displayed in between turns.

class TicTacToe

  attr_accessor :board, :player_1, :player_2

  def initialize
    @player_1 = Player.new("Player 1", 'X')
    @player_2 = Player.new("Player 2", 'O')
    @board = Board.new
    @winner = nil
  end

  def start_game
    puts "Welcome to Tic-Tac-Toe!"
    puts "#{@player_1.name} will be #{@player_1.symbol} and #{@player_2.name} will be #{@player_2.symbol}."
    puts ""
    @board.instructions
    swap_players
    @board.display_board
    take_turn
  end

  # Logic for each game turn is placed here.
  def take_turn
    until is_winner? || @board.board_full?
      move = get_player_input
      @board.place_symbol(move, @current_player.symbol)
      @board.display_board
      is_winner?
      @board.board_full?
      if is_winner?
        puts "Congratulations, #{@current_player.name}! You win!"
        play_again?
      elsif @board.board_full?
        puts "Cat's Game!"
        play_again?
      end
      swap_players
    end
  end

  def swap_players
    @current_player == @player_1 ? @current_player = @player_2 : @current_player = @player_1
  end

  def get_player_input
    move = nil
    until (0..8).include?(move) && @board.space_open?(move)
      print "#{@current_player.name}, please enter your move (1-9). "
      move = gets.to_i - 1
      if !(0..8).include?(move)
        puts "That is not a valid entry.  Please enter a number between 1 and 9."
      elsif !@board.space_open?(move)
        puts "That space is already taken.  Please try again."
      end
    end
    move
  end

  # Runs through each array within 'winning_lines' by checking if the current
  # player has completed a row of 3 of their symbols after placement on their
  # turn.  @winner then obtains a value and validates the #take_turn 'until' loop.
  def is_winner?
    winning_lines = [[0, 1, 2], [3, 4, 5],
                     [6, 7, 8], [0, 3, 6],
                     [1, 4, 7], [2, 5, 8],
                     [0, 4, 8], [2, 4, 6]]
    winning_lines.each do |line|
      @winner = @current_player if line.all? {|i| @board.check(i) == @current_player.symbol}
    end
    @winner ? true : false
  end

  def play_again?
    print "Do you want to play again? "
    entry = gets.downcase
    if entry.include? "y"
      puts ""
      game = TicTacToe.new
      game.start_game
    end
  end
end

class Player

  attr_accessor :name, :symbol

  def initialize(name, symbol)
    @name = name
    @symbol = symbol
  end
end

class Board

  def initialize
    @board = [" ", " ", " ", " ", " ", " ", " ", " ", " "]
    @empty_square = " "
  end

  def display_board
    puts ""
    puts " #{@board[0]} | #{@board[1]} | #{@board[2]} "
    puts "---|---|---"
    puts " #{@board[3]} | #{@board[4]} | #{@board[5]} "
    puts "---|---|---"
    puts " #{@board[6]} | #{@board[7]} | #{@board[8]} "
    puts ""
  end

  def instructions
    puts "The squares are numbered from 1-9, with 1 in the top left corner"
    puts "and 9 in the bottom right corner.  Place your mark (X or O) by"
    puts "entering the number corresponding to your desired location."
  end

  def place_symbol(move, symbol)
    @board[move] = symbol
  end

  def check(space)
    @board[space]
  end

  def space_open?(move)
    @board[move] == @empty_square ? true : false
  end

  def board_full?
    !@board.include?(@empty_square) ? true : false
  end
end

game = TicTacToe.new
game.start_game
