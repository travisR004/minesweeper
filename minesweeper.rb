require "debugger"
require "yaml"

class MinesweeperTile
  attr_reader :bomb, :pos, :game
  attr_accessor :revealed, :flagged

  def initialize(x_index, y_index, game)
    @bomb = false
    @pos = [x_index, y_index]
    @revealed = false
    @game = game
    @flagged = false
  end

  def reveal
    return nil if self.revealed
    return nil if self.flagged
    self.revealed = true
    return nil if self.bomb

    edge_bombs = self.adjacent_bombs
    if edge_bombs == 0
      @game.neighbors(@pos).each { |tile| tile.reveal }
    end

    nil
  end

  def adjacent_bombs
    bombs = 0
    neighbors = @game.neighbors(@pos)
    neighbors.each do |neighbor|
      bombs += 1 if neighbor.bomb
    end
    bombs
  end

  def add_bomb
    @bomb = true
  end
end

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
        @board.update_leaderboard
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

class MinesweeperBoard
  attr_accessor :grid, :last_action_time, :elapsed_time

  def initialize(bomb_freq, x_dim, y_dim)
    @grid = populate_grid(x_dim, y_dim)
    @last_action_time = Time.now
    @elapsed_time = 0
    seed_bombs(bomb_freq, x_dim, y_dim)
    @leaderboard_filepath = "highscores.txt"
  end

  def update_time
    @elapsed_time += Time.now - @last_action_time
    @last_action_time = Time.now
  end

  def update_leaderboard
    if File.exist?(@leaderboard_filepath)
      high_scores = File.readlines(@leaderboard_filepath).map(&:chomp).map(&:to_f)
      high_scores << @elapsed_time.round(3)
      high_scores.sort!
      high_scores = high_scores[0..9]
      File.open(@leaderboard_filepath, "w") { |f| f.write(high_scores.join("\n")) }
    else
      File.open(@leaderboard_filepath, "w")
      update_leaderboard
    end
  end

  def display_leaderboard
    if File.exist?(@leaderboard_filepath)
      high_scores = File.read(@leaderboard_filepath)
      puts "Top Ten High Scores: "
      puts high_scores
    else
      File.open(@leaderboard_filepath, "w")
      display_leaderboard
    end
  end

  def populate_grid(x_dim, y_dim)
    grid = Array.new(x_dim) { Array.new(y_dim) }
    (0..x_dim - 1).each do |x_index|
      (0..y_dim - 1).each do |y_index|
        grid[x_index][y_index] = MinesweeperTile.new(x_index, y_index, self)
      end
    end
    grid
  end

  def seed_bombs(bomb_freq, x_dim, y_dim)
    total_bombs = (bomb_freq * x_dim * y_dim).floor
    remaining_bombs = total_bombs
    until remaining_bombs == 0
      pos_tile = grid[rand(x_dim)][rand(y_dim)]
      unless pos_tile.bomb
        pos_tile.add_bomb
        remaining_bombs -= 1
      end
    end
    nil
  end

  def display_board
    display = ""
    num_cols = grid[0].length
    num_cols.times { |index| display << "#{index}|"}
    display << "\n"
    grid.each do |row|
      row.each do |tile|
        if tile.flagged
          display << "F"
        elsif tile.revealed && !tile.bomb
          display << tile.adjacent_bombs.to_s
        elsif tile.revealed && tile.bomb
          display << "*"
        else
          display << "-"
        end
        display << " "
      end
      display << "[#{grid.index(row)}]\n"
    end
    num_cols.times { |index| display << "#{index}|"}
    puts display
    puts "Elapsed Time: #{@elapsed_time}"
  end

  def neighbors(pos)
    neighbors = []
    (pos[0] - 1 .. pos[0] + 1).each do |x_ind|
      (pos[1] - 1 .. pos[1] + 1).each do |y_ind|
        if (0..grid.length - 1).include?(x_ind) && (0..grid[0].length - 1).include?(y_ind)
          neighbors << grid[x_ind][y_ind]
        end
      end
    end
    neighbors
  end

  def check_victory
    num_flags = 0
    num_bombs = 0
    num_unrevealed = 0

    grid.each do |row|
      row.each do |tile|
        num_bombs += 1 if tile.bomb
        num_flags += 1 if tile.flagged
        num_unrevealed +=1 unless tile.revealed
      end
    end

    if num_flags == num_bombs && num_flags == num_unrevealed
      true
    else
      false
    end
  end

  def check_loss
    grid.each do |row|
      row.each do |tile|
        return true if tile.bomb && tile.revealed
      end
    end
    false
  end

  def reveal_board
    grid.each do |row|
      row.each do |tile|
        tile.reveal
      end
    end
  end

  def execute_command(command, x_pos, y_pos)
    case command
    when "r"
      @grid[x_pos][y_pos].reveal
    when "f"
      @grid[x_pos][y_pos].flagged = true
    when "u"
      @grid[x_pos][y_pos].flagged = false
    end
    nil
  end

  def save
    #debugger
    yaml_grid = self.to_yaml
    begin
      puts "What would you like to name your saved game (not including .txt extension)?"
      filename = gets.chomp + ".txt"
      raise if File.exist?(filename)
      File.open(filename, "w") { |f| f.write(yaml_grid) }
    rescue
      puts "A file by that name already exists.  Overwrite?  (y/n)"
      if gets.chomp == "y"
        File.open(filename, "w") { |f| f.write(yaml_grid) }
      else
        retry
      end
    end
  end

  def x_dim
    return @grid.length
  end

  def y_dim
    return @grid[0].length
  end
end





if __FILE__ == $PROGRAM_NAME
  game = MinesweeperGame.new
  game.play
end






















