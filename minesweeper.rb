require "yaml"
require "./minesweeper_tile"
require "./minesweeper_board"

class MinesweeperGame
  attr_reader :board
  def initialize(bomb_freq = 0.125, x_dim = 9, y_dim = 9)
    @board = load

    unless @board
      @board = MinesweeperBoard.new(bomb_freq, x_dim, y_dim)
    end

  end


  def load
    puts "Would you like to load a previous game? (y/n)"
    load = gets.chomp
    if load =="y"
      begin
        puts "What is the name of the saved game (not including .txt extension)?"
        saved_game = gets.chomp + ".txt"
        board = YAML.load(File.read(saved_game))
        board.last_action_time = Time.now
      rescue
        puts "Invalid name"
        retry
      end
      return board
    end
    nil
  end

  def play
    @board.display_board

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

      command, x_pos, y_pos = get_user_input
      if command == "s"
        @board.update_time
        @board.save
        puts "Game saved.  Exiting..."
        return nil
      else
        @board.execute_command(command, x_pos.to_i, y_pos.to_i)
      end

      @board.update_time
      @board.display_board
    end

    puts "Game Over"
    @board.reveal_board
    @board.display_board
    @board.display_leaderboard
  end

  def get_user_input
    valid_input = false
    inputs = ""

    until valid_input
      puts "Please enter the coordinates of the space you wish to affect."
      puts "Possible actions: f = flag, r = reveal, u = unflag; s = save and quit."
      puts "(Example:  'f, 0, 1')"

      inputs = gets.chomp.gsub(" ", "").split(",")
      valid_input = valid_input?(inputs)
      if !valid_input
        puts "Error: Input invalid.  Please re-enter."
      end
    end
    inputs
  end

  def valid_input?(inputs)
    if inputs[0] == "s"
      return true
    elsif !["f", "r", "u"].include?(inputs[0])
      return false
    elsif !(0..@board.x_dim - 1).include?(inputs[1].to_i)
      return false
    elsif !(0..@board.y_dim - 1).include?(inputs[2].to_i)
      return false
    elsif @board.grid[inputs[1].to_i][inputs[2].to_i].revealed
      return false
    elsif inputs[0] == "u" && !@board.grid[inputs[1].to_i][inputs[2].to_i].flagged
      return false
    else
      true
    end
  end

end

if __FILE__ == $PROGRAM_NAME
  game = MinesweeperGame.new
  game.play
end
