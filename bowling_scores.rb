# example cmd line
# ruby bowling_scores.rb John 6 2 7 1 10 9 0 8 2 10 10 3 5 7 2 1 9 5

name =  ARGV[0]
total_pins_felled = ARGV[1..-1]

class Formatter

	def self.insert_empty_string_after_strike(total_pins_felled)
	  formatted_pins_felled = []
	  total_pins_felled.each_with_index do |pins, index|
		  if pins == "10"
		  	formatted_pins_felled << 10
		  	formatted_pins_felled << nil
		  else
		  	formatted_pins_felled << pins.to_i
		  end
		end
		formatted_pins_felled
	end

	def self.divide_pins_felled_by_frame(pins_felled)
		pins_by_frame = pins_felled.each_slice(2).to_a
	end

  def self.format_rolls(total_pins_felled)
    pins_felled = Formatter.insert_empty_string_after_strike(total_pins_felled)
    Formatter.divide_pins_felled_by_frame(pins_felled)
  end
end


class ScoresCalculator

	def initialize
		@frame_scores = {}
		@cumulative_scores = {}
	end

	def calculate_frame_score(pins_by_frame)
	  pins_by_frame.each_with_index do |frame, index|
	  	if frame[0] == 10
	  		bonus_array = pins_by_frame[(index + 1)..-1].flatten.compact
	  		strike_bonus = bonus_array[0] + bonus_array[1]
	  		@frame_scores[index + 1] = 10 + strike_bonus
	  	elsif frame[0].to_i + frame[1].to_i == 10
	  		bonus_array = pins_by_frame[(index + 1)..-1].flatten.compact
	  		spare_bonus = bonus_array[0]
	  		@frame_scores[index + 1] = 10 + spare_bonus.to_i
	  	else
	  		@frame_scores[index + 1] = frame[0].to_i + frame[1].to_i
	  	end
	  end
	  @frame_scores
	end

	def calculate_score_by_frame(frame_scores)
		@cumulative_scores = { 1 => @frame_scores[1] }
		@frame_scores
		@frame_scores.each do |frame, score|
	    if @cumulative_scores[frame - 1] != nil
			  @cumulative_scores[frame] = score + @cumulative_scores[frame - 1]
			end
		end
	  @cumulative_scores
	end

	def calculate_scores(pins_by_frame)
    @frame_scores = calculate_frame_score(pins_by_frame)
    @cumulative_scores = calculate_score_by_frame(@frame_scores)
	end
end

class ScoreSheet

	def initialize
	end

	def format_rolls(pins_by_frame)
		frame_rolls = {}
		pins_by_frame.each_with_index do |frame, index|
			if frame[0] == 10
				frame_rolls[index + 1] = ["X", " "]
			elsif frame[0].to_i + frame[1].to_i == 10
				frame_rolls[index + 1] = [frame[0].to_s, "/"]
			elsif frame[0] == 0 || frame[1] == 0
				frame.each_with_index do |roll, index|
					frame[index] = "-" if roll == 0
				end
				frame_rolls[index + 1] = [frame[0].to_s, frame[1].to_s]
			else
				frame_rolls[index + 1] = [frame[0].to_s, frame[1].to_s]
			end
		end
		frame_rolls
	end

	def format_output(frame_rolls, score_by_frame)
	  frame_rolls_score_hash = {}
	  frame_rolls.each do |frame, rolls|
	  	rolls << score_by_frame[frame]
	  	frame_rolls_score_hash[frame] = rolls
	  end
	  if frame_rolls_score_hash.key?(11)
	  	frame_rolls_score_hash["*"] = frame_rolls_score_hash[11]
	  	frame_rolls_score_hash["*"][2] = " "
	  	frame_rolls_score_hash.reject!{ |key| key == 11}
	  end
	  if frame_rolls_score_hash["*"][1] == "/"
	  	frame_rolls_score_hash["*"][1] = (10 - frame_rolls_score_hash["*"][0].to_i).to_s
	  end
	  frame_rolls_score_hash
	end

	def print_score(name, pins_by_frame, score_by_frame)
		frame_rolls = format_rolls(pins_by_frame)
		frame_rolls_score_hash = format_output(frame_rolls, score_by_frame)
	  puts "#{name}'s final score: #{frame_rolls_score_hash[10][2]}"
	  puts "Frame   Roll   Roll  Score"
	  frame_rolls_score_hash.each do |frame, data|
	  	puts "#{frame}       #{data[0]}      #{data[1]}      #{data[2]}"
	  end
	end
end

class BowlingGame
	def initialize(name, total_pins_felled)
		@total_pins_felled = total_pins_felled
		@name = name
	end

	def bowling_score
	pins_by_frame = Formatter.format_rolls(@total_pins_felled)

	score_calculator = ScoresCalculator.new
	score_by_frame = score_calculator.calculate_scores(pins_by_frame)

	score_sheet = ScoreSheet.new
	score_sheet.print_score(@name, pins_by_frame, score_by_frame)
	end
end


game = BowlingGame.new(name, total_pins_felled)
game.bowling_score

