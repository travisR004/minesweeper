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
    return true if self.bomb



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
  attr_reader :grid
  def initialize(bomb_freq = 0.2, x_dim = 9, y_dim = 9)
    @grid = populate_grid(bomb_freq, x_dim, y_dim)
  end

  def play
    display_board
    while true
      command, x_pos, y_pos = get_user_input
      x_pos = x_pos.to_i
      y_pos = y_pos.to_i
      case command
      when "r"
        grid[x_pos][y_pos].reveal
      when "f"
        grid[x_pos][y_pos].flagged = true
      when "u"
        grid[x_pos][y_pos].flagged = false
      end
      #check_victory
      display_board
    end
  end

  def get_user_input
    valid_input = false
    inputs = ""
    until valid_input
      puts "Please enter the coordinates of the space you wish to affect."
      puts "Possible actions: f = flag, r = reveal, u = unflag"
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
    if !["f", "r", "u"].include?(inputs[0])
      puts "1"
      return false
    elsif !(0..grid.length - 1).include?(inputs[1].to_i)
      puts "2"
      return false
    elsif !(0..grid[0].length - 1).include?(inputs[2].to_i)
      puts "3"
      return false
    elsif grid[inputs[1].to_i][inputs[2].to_i].revealed
      puts "4"
      return false
    elsif inputs[0] == "u" && !grid[inputs[1].to_i][inputs[2].to_i].flagged
      puts "5"
      return false
    else
      true
    end
  end

  def populate_grid(bomb_freq, x_dim, y_dim)
    total_bombs = (bomb_freq * x_dim * y_dim).floor
    grid = Array.new(x_dim) { Array.new(y_dim) }
    (0..x_dim - 1).each do |x_index|
      (0..y_dim - 1).each do |y_index|
        #Expand this definition later
        grid[x_index][y_index] = MinesweeperTile.new(x_index, y_index, self)
      end
    end
    remaining_bombs = total_bombs
    until remaining_bombs == 0
      pos_tile = grid[rand(x_dim)][rand(y_dim)]
      unless pos_tile.bomb
        pos_tile.add_bomb
        remaining_bombs -= 1
      end
    end
    grid
  end

  def display_board
    display = ""
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
      end
      display << "\n"
    end
    puts display
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
end