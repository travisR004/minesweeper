require "yaml"
require "./minesweeper_tile"
require "./minesweeper_board"
require "io/console"
require 'colorize'

class MinesweeperGame
  attr_reader :board, :cursor
  def initialize(bomb_freq = 0.125, x_dim = 9, y_dim = 9)
    @board = load
    @cursor = [0,0]
    unless @board
      @board = MinesweeperBoard.new(bomb_freq, x_dim, y_dim)
    end

  end

  def display_board
    display = ""
    @board.grid.each do |row|
      row.each do |tile|
        if tile.pos == @cursor
          display << "| ".blink if tile.pos == @cursor
        else
         display << "\u2691".red + " " if tile.flagged
          if tile.revealed && !tile.bomb
            display << tile.adjacent_bombs.to_s.blue + " " unless tile.adjacent_bombs == 0
            display << "  " if tile.adjacent_bombs == 0
          end
          display << "* " if tile.revealed && tile.bomb
          display << "- " if !tile.revealed && !tile.flagged
        end
      end
      display << "\n"
    end
    puts display
  end

  def play

    while true
      if @board.check_loss
        puts "Boom!  You lose.  Better luck next time."
        break
      elsif @board.check_victory
        puts "You win!!!!"
        puts "Want to see if you have a high score? Enter Name: "
        name = gets.chomp
        @board.update_leaderboard(name)
        break
      end
      system("clear")
      display_board
      puts "Elapsed Time: #{@board.elapsed_time.round(0)}"
      move = STDIN.getch
      next unless !valid_input?(move)
      break if !toggle(move)
      @board.update_time
    end

    @board.reveal_board
    display_board
    @board.display_leaderboard
  end

  def toggle(move)
    tile = @board.grid[@cursor[0]][@cursor[1]]
    case move
      when "i"
        @cursor[0] -= 1 unless @cursor[0] == 0
      when "j"
        @cursor[1] -= 1 unless @cursor[1] == 0
      when "k"
        @cursor[0] += 1 unless @cursor[0] == 8
      when "l"
        @cursor[1] += 1 unless @cursor[1] == 8
      when "r"
        tile.reveal
      when "f"
        tile.flagged = true
      when "u"
        tile.flagged = false
      when "q"
        return false
      when "s"
        @board.update_time
        @board.save
        puts "Game saved.  Exiting..."
        return false
    end
    true
  end

  def valid_input?(move)
    return true if !["s", "r" , "f" , "u" , "l", "k", "j", "i", "q"].include?(move)
    false
  end

  def load
    puts "Would you like to load a previous game? (y/n)"
    load = gets.chomp
    if load =="y"
      begin
        puts "What is the name of the saved game? Type q if no game"
        saved_game = gets.chomp + ".txt"
        return if saved_game == "q"
        board = YAML.load(File.read(saved_game))
        board.last_action_time = Time.now
      rescue
        puts "Game does not exist!"
        retry
      end
      return board
    end
  end

end

if __FILE__ == $PROGRAM_NAME
  game = MinesweeperGame.new
  game.play
end
