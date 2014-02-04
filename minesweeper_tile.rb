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
