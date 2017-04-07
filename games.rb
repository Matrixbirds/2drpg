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

class Games < Gosu::Window
  def initialize
    super WIDTH, HEIGHT, :fullscreen => false

    self.caption = "Games."

    @sky = Gosu::Image.new("media/space.png", :tileable => true)
    @map = Map.new("media/cptn_ruby_map.txt")
    @camera_x = @camera_y = 0
  end

  def update
    move_x = 0
    if Gosu.button_down? Gosu::KB_LEFT
      puts "LEFT"
      move_x -= 5
    end
    if Gosu.button_down? Gosu::KB_RIGHT
      puts "RIGHT"
      move_x += 5
    end
    move_y = 0
    if Gosu.button_down? Gosu::KB_UP
      move_y -= 5
    end
    if Gosu.button_down? Gosu::KB_DOWN
      move_y += 5
    end
    @camera_x += move_x
    @camera_y += move_y
  end

  def draw
    @sky.draw 0, 0, 0
    Gosu.translate(-@camera_x, -@camera_y) do
      @map.draw
    end
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
