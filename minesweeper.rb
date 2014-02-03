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
      @game.neighbors.each.reveal
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