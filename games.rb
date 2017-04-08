# encoding: utf-8

require 'gosu'

WIDTH, HEIGHT = 640, 480

module Tiles
  Grass = 0
  Earth = 1
end

class Map
  attr_reader :width, :height, :gems, :tiles

  def initialize(filename)
    @tileset = Gosu::Image.load_tiles("media/tileset.png", 60, 60, :tileable => true)

    lines = File.readlines(filename).map { |line| line.chomp }
    @height = lines.size
    @width = lines[0].size
    @tiles = Array.new(@width) do |x|
      Array.new(@height) do |y|
        case lines[y][x, 1]
        when '"'
          Tiles::Grass
        when '#'
          Tiles::Earth
        else
          nil
        end
      end
    end
  end

  def draw
    @height.times do |y|
      @width.times do |x|
        tile = @tiles[x][y]
        if tile
          @tileset[tile].draw(x * 50 - 5, y * 50 - 5, 0)
        end
      end
    end
  end
end

class Player
  attr_reader :gravity, :x, :y
  def initialize(map, x, y)
    @map = map
    @gravity = 0
    @x, @y = x, y
    @dir = :right
    @standing, @walk1, @walk2, @jump = *Gosu::Image.load_tiles("media/cptn_ruby.png", 50, 50)
    @cur_image = @standing
  end

  def update_cur_image(move_x)
    if move_x == 0
      @cur_image = @standing
    else
      @cur_image = (Gosu.milliseconds / 175 % 2 == 0) ? @walk1 : @walk2
    end
  end

  def update_position(move_x)
    if move_x > 0
      @dir = :right
      move_x.times { @x += 1 }
    end
    if move_x < 0
      @dir = :left
      move_x.abs.times { @x -= 1 }
    end
  end

  def update(move_x)
    update_cur_image(move_x)
    update_position(move_x)
  end

  def draw
    if @dir == :left
      offs_x = -25
      factor = 1.0
    else
      offs_x = 25
      factor = -1.0
    end
    @cur_image.draw(@x + offs_x, @y - 49, 0, factor, 1.0)
  end

  def jump
    if @gravity == 0
      @gravity -= 1
    end
  end
end

class Camera
  attr_reader :x, :y
  def initialize(map, player)
    @x, @y = 0, 0
    @map, @player = map, player
  end

  def update(move_x)
    @player.update(move_x)
    @x = [[@player.x - Games::WIDTH / 2, 0].max, @map.width * 50 - Games::WIDTH].min
  end

  def draw
    Gosu.translate(-@x, -@y) do
      @map.draw
      @player.draw
    end
  end

  private
  attr_reader :map, :player
end

class Games < Gosu::Window
  WIDTH = ::WIDTH
  HEIGHT = ::HEIGHT
  def initialize
    super WIDTH, HEIGHT, :fullscreen => false

    self.caption = "Games."

    @sky = Gosu::Image.new("media/space.png", :tileable => true)
    @map = Map.new("media/cptn_ruby_map.txt")
    @player = Player.new(@map, 400, 100)
    @camera = Camera.new(@map, @player)
  end

  def update
    move_x = 0
    if Gosu.button_down? Gosu::KB_LEFT
      move_x -= 5
    end
    if Gosu.button_down? Gosu::KB_RIGHT
      move_x += 5
    end
    @camera.update(move_x)
  end

  def draw
    @sky.draw 0, 0, 0
    @camera.draw
  end

  def button_down(id)
    case id
    when Gosu::KB_ESCAPE
      close
    else
      super
    end
  end
end

Games.new.show if __FILE__ == $0
