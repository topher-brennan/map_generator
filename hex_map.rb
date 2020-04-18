class HexMap
  # Hex map where the first few hexes look like this:
  #      ___
  #  ___/0,1\___
  # /0,0\___/0,2\
  # \___/   \___/

  attr_accessor :hexes

  SVG_HEADER = "<!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' 'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'><svg version='1.1' xmlns='http://www.w3.org/2000/svg'>\n"
  SVG_FOOTER = "</svg>"

  # A hex map drawn as above will need about 15% more hexes across than it has
  # up and down to represent a square area.
  def initialize(height=29, width=33)
    @height = height
    @width = width
    @hexes = Array.new(height) { Array.new(width) }

    height.times do |h|
      width.times do |w|
        if h == 0 && w == 0
	  @hexes[h][w] = Plain.new
	elsif h == 0
	  @hexes[h][w] = @hexes[h][w-1].generate_adjacent
	elsif w == 0
	  @hexes[h][w] = @hexes[h-1][w].generate_adjacent
	else
	  possible_parents = [@hexes[h][w-1], @hexes[h-1][w]]
	  if w % 2 == 1
	    possible_parents << @hexes[h-1][w-1]
	    possible_parents << @hexes[h-1][w+1] if w < @width - 1
	  end
	  begin
	    @hexes[h][w] = possible_parents.sample.generate_adjacent
	  rescue
	    puts "Error occurred at indices (#{h}, #{w})"
	    print possible_parents
	    print '\n'
	    @hexes[h][w] = Plain.new
	  end
	end
      end
    end	
  end

  def to_s
    result = ""
    @height.times do |h|
      (0...@width).each do |w|
        result << (" " * 11)
	result << @hexes[h][w].to_s
      end
      result << "\n"

      (1..@width).each do |w|
        result << @hexes[h][w].to_s
	result << (" " * 11)
      end
      result << "\n"
    end
    result
  end

  def to_svg
    result = SVG_HEADER

    @width.times do |w|
      @height.times do |h|
	h1 = 24 * h + (w % 2 == 0 ? 12 : 0)
	h2 = h1 + 12
	h3 = h2 + 12
	w1 = 21 * w
	w2 = w1 + 7
	w3 = w2 + 14
	w4 = w3 + 7

	result << "  <polygon points='#{w2},#{h1} #{w3},#{h1} #{w4},#{h2} #{w3},#{h3} #{w2},#{h3} #{w1},#{h2}' fill='#{@hexes[h][w].class::COLOR}' stroke='black' stroke-width='1'/>\n"
      end
    end

    result += SVG_FOOTER
    result
  end
end

class Hex
  def generate_adjacent
    raise NotImplementedError
  end

  def to_s
    name = self.class.to_s
    name += ' ' * (11 - name.size)
    name
  end
end

class Plain < Hex
  COLOR = 'greenyellow'

  def generate_adjacent
    case rand(20)
    when 0...11
      return Plain.new
    when 12
      return Scrub.new
    when 13
      return Forest.new
    when 14
      return Rough.new
    when 15
      return Desert.new
    when 16
      return Hills.new
    when 17
      return Mountains.new
    when 18
      return Pond.new(self)
    else
      return Depression.new(self)
    end
  end
end

class Scrub < Hex
  COLOR = 'yellowgreen'

  def generate_adjacent
    case rand(20)
    when 0...3
      return Plain.new
    when 4...11
      return Scrub.new
    when 11...13
      return Forest.new
    when 14
      return Rough.new
    when 15
      return Hills.new
    when 16
      return Mountains.new
    when 17
      return Marsh.new
    when 18
      return Pond.new(self)
    else
      return Depression.new(self)
    end
  end
end

class Forest < Hex
  COLOR = 'forestgreen'

  def generate_adjacent
    case rand(20)
    when 0
      return Plain.new
    when 1...4
      return Scrub.new
    when 4...14
      return Forest.new
    when 14
      return Rough.new
    when 15
      return Hills.new
    when 16
      return Mountains.new
    when 17
      return Marsh.new
    when 18
      return Pond.new(self)
    else
      return Depression.new(self)
    end
  end
end

class Rough < Hex
  COLOR = 'orange'

  def generate_adjacent
    # I switch my convention here to more closely match the table in the DMG.
    # TODO: Re-do other classes to match.
    case rand(20)
    when 0
      return Depression.new(self)
    when 1..2
      return Plain.new
    when 3..4
      return Scrub.new
    when 5
      return Forest.new
    when 6..8
      return Rough.new
    when 9..10
      return Desert.new
    when 11..15
      return Hills.new
    when 16..17
      return Mountains.new
    when 18
      return Marsh.new
    else
      return Pond.new(self)
    end
  end
end

class Desert < Hex
  COLOR = 'lightyellow'

  def generate_adjacent
    case rand(20)
    when 0
      return Depression.new(self)
    when 1..3
      return Plain.new
    when 4..5
      return Scrub.new
    when 6..8
      return Rough.new
    when 9..14
      return Desert.new
    when 15
      return Hills.new
    when 16..17
      return Mountains.new
    when 18
      return Marsh.new
    else
      return Pond.new(self)
    end
  end
end

class Hills < Hex
  COLOR = 'sandybrown'

  def generate_adjacent
    case rand(20)
    when 0
      return Depression.new(self)
    when 1
      return Plain.new
    when 2..3
      return Scrub.new
    when 4..5
      return Forest.new
    when 6..7
      return Rough.new
    when 8
      return Desert.new
    when 9..14
      return Hills.new
    when 15..16
      return Mountains.new
    when 17
      return Marsh.new
    else
      return Pond.new(self)
    end
  end
end

class Mountains < Hex
  COLOR = 'brown'

  def generate_adjacent
    case rand(20)
    when 0
      return Depression.new(self)
    when 1
      return Plain.new
    when 2
      return Scrub.new
    when 3
      return Forest.new
    when 4..5
      return Rough.new
    when 6
      return Desert.new
    when 7..10
      return Hills.new
    when 11..18
      return Mountains.new
    else
      return Pond.new(self)
    end
  end
end

class Marsh < Hex
  COLOR = 'aquamarine'

  def generate_adjacent
    case rand(20)
    when 0
      return Depression.new(self)
    when 1..2
      return Plain.new
    when 3..4
      return Scrub.new
    when 5..6
      return Forest.new
    when 7
      return Rough.new
    when 8
      return Hills.new
    when 9..15
      return Marsh.new
    else
      return Pond.new(self)
    end
  end
end

class Inheritor < Hex
  def initialize(parent)
    @parent = parent
  end

  def generate_adjacent
    @parent.generate_adjacent
  end
end

class Pond < Inheritor
  COLOR = 'aqua'
end

class Depression < Inheritor
  COLOR = 'black'
end

if $PROGRAM_NAME == __FILE__
  hex_map = HexMap.new
  
  open('output.svg', 'w') do |f|
    f.puts hex_map.to_svg
  end
end  
