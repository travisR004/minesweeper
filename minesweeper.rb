class MinesweeperTile
  attr_reader :bomb, :pos

  def initialize(x_dim, y_dim)
    @bomb = false
    @pos = [x_dim, y_dim]
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
end