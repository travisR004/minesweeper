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

  def update_leaderboard(name)
    if File.exist?(@leaderboard_filepath)
      high_scores = File.read(@leaderboard_filepath)
      high_scores = YAML.load(high_scores)
      high_scores[@elapsed_time.round(3)] = name
      high_scores_array = high_scores.sort
      high_scores_array = high_scores_array[0..9]
      new_high_scores = {}
      high_scores_array.each do |entry|
        new_high_scores[entry[0]] = entry[1]
      end
      File.open(@leaderboard_filepath, "w") { |f| f.write(new_high_scores.to_yaml) }
    else
      initialize_leaderboard
      update_leaderboard(name)
    end
  end

  def display_leaderboard
    if File.exist?(@leaderboard_filepath)
      high_scores = YAML.load(File.read(@leaderboard_filepath))
      puts "Top Ten High Scores: "
      high_scores.each do |score, name|
        puts "#{name}:  #{score} seconds"
      end
    else
      initialize_leaderboard
      display_leaderboard
    end
  end

  def initialize_leaderboard
    default_leaderboard = {}
    10.times do |time|
      default_leaderboard[((time + 1) * 100)] = "HAL 9000"
    end
    File.open(@leaderboard_filepath, "w") { |f| f.write(default_leaderboard.to_yaml) }
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
