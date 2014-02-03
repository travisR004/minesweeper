class MinesweeperTile
  attr_reader :bomb, :pos. :game
  attr_accessor :revealed, :flagged

  def initialize(x_index, y_index, game)
    @bomb = false
    @pos = [x_index, y_index]
    @revealed = false
    @game = game
  end

  def reveal
    return true if self.bomb
    return nil if self.revealed
    self.revealed = true

    edge_bombs = self.adjacent_bombs

    if edge_bombs == 0
      self.adjacent_tiles.each.reveal
    end
    nil
  end

  def adjacent_bombs
  end



  def add_bomb
    @bomb = true
  end
end

class MinesweeperGame
  def initialize(bomb_freq = 0.2, x_dim = 9, y_dim = 9)
    @grid = populate_grid(bomb_freq, x_dim, y_dim)
  end

  def populate_grid(bomb_freq, x_dim, y_dim)
    total_bombs = (bomb_freq * x_dim * y_dim).floor
    grid = Array.new(x_dim) { Array.new(y_dim) }
    p grid
    (0..x_dim - 1).each do |x_index|
      (0..y_dim - 1).each do |y_index|
        #Expand this definition later
        grid[x_index][y_index] = MinesweeperTile.new(x_index, y_index)
      end
    end
    p total_bombs
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