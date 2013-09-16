# example cmd line
# ruby bowling_scores.rb John 6 2 7 1 10 9 0 8 2 10 10 3 5 7 2 1 9 5

class Formatter
  def self.format_rolls(total_pins_felled)
    total_pins_felled.map!(&:to_i)
    pins_felled = Formatter.nil_pad_strikes(total_pins_felled)
    pins_felled_by_frame = Formatter.divide_pins_felled_by_frame(pins_felled)
    Formatter.make_frames_array(pins_felled_by_frame)
  end

  def self.nil_pad_strikes(total_pins_felled)
    formatted_pins_felled = []
    total_pins_felled.each do |pins|
      if pins == 10
        formatted_pins_felled << 10
        formatted_pins_felled << nil
      else
        formatted_pins_felled << pins
      end
    end
    formatted_pins_felled
  end

  def self.divide_pins_felled_by_frame(pins_felled)
    pins_felled_by_frame = pins_felled.each_slice(2).to_a
  end

  def self.make_frames_array(pins_felled_by_frame)
    frames_array = []
    pins_felled_by_frame.each_with_index do |frame, index|
      frame
      frames_array << Frame.new(index + 1, frame[0], frame[1])
    end
    frames_array
  end
end

class Frame
  attr_reader :frame_number, :roll_1, :roll_2, :is_spare, :is_strike
  def initialize(frame_number, roll_1, roll_2)
    @frame_number = frame_number
    @roll_1 = roll_1
    @roll_2 = roll_2
    @status = "no bonus"
    self.set_status
  end

  def set_status
    unless @roll_2 == nil
      @status = "spare" if @roll_1 + @roll_2 == 10
    end
    @status = "strike" if @roll_1 == 10
  end

  def is_spare
    @status == "spare"
  end

  def is_strike
    @status == "strike"
  end
end

class ScoresCalculator

  def initialize
    @frame_scores = {}
    @score_by_frame = {}
  end

  def calculate_frame_score(frames_array)
    frames_array.each_with_index do |frame, index|
      next_frame = frames_array[index + 1]
      third_frame = frames_array[index + 2]
      if next_frame == nil
        bonus_rolls = [0,0]
      elsif third_frame == nil
        bonus_rolls = [next_frame.roll_1, next_frame.roll_2]
      else
        bonus_rolls = [next_frame.roll_1, next_frame.roll_2, third_frame.roll_1].compact
      end
      if frame.is_strike
        strike_bonus = bonus_rolls[0] + bonus_rolls[1]
        @frame_scores[frame.frame_number] = 10 + strike_bonus
      elsif frame.is_spare
        spare_bonus = bonus_rolls[0]
        @frame_scores[frame.frame_number] = 10 + spare_bonus
      else
        @frame_scores[frame.frame_number] = frame.roll_1 + frame.roll_2.to_i
      end
    end
    @frame_scores
  end

  def calculate_score_by_frame(frame_scores)
    @score_by_frame = { 1 => @frame_scores[1] }
    @frame_scores.each do |frame, score|
      if @score_by_frame[frame - 1] != nil
        @score_by_frame[frame] = score + @score_by_frame[frame - 1]
      end
    end
    @score_by_frame
  end

  def calculate_scores(frames_array)
    @frame_scores = calculate_frame_score(frames_array)
    @score_by_frame = calculate_score_by_frame(@frame_scores)
  end
end

class ScoreSheet

  def initialize
  end

  def print_score(name, frames_array, score_by_frame)
    frame_rolls = format_rolls(frames_array)
    frame_rolls_score_hash = format_output(frame_rolls, score_by_frame)
    puts "#{name}'s final score: #{frame_rolls_score_hash[10][2]}"
    puts "Frame   Roll   Roll  Score"
    frame_rolls_score_hash.each do |frame, data|
      puts "#{frame}       #{data[0]}      #{data[1]}      #{data[2]}"
    end
  end

  def format_rolls(frames_array)
    frame_rolls = {}
    frames_array.each do |frame|
      if frame.is_strike
        frame_rolls[frame.frame_number] = ["X", " "]
      elsif frame.is_spare
        frame_rolls[frame.frame_number] = [frame.roll_1.to_s, "/"]
      else
        frame_rolls[frame.frame_number] = [frame.roll_1.to_s, frame.roll_2.to_s]
      end
      frame_rolls[frame.frame_number][0] = "-" if frame_rolls[frame.frame_number][0] == "0"
      frame_rolls[frame.frame_number][1] = "-" if frame_rolls[frame.frame_number][1] == "0"
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
end

class BowlingGame
  def initialize(name, total_pins_felled)
    @total_pins_felled = total_pins_felled
    @name = name
  end

  def bowling_score
    pins_felled_by_frame = Formatter.format_rolls(@total_pins_felled)

    score_calculator = ScoresCalculator.new
    score_by_frame = score_calculator.calculate_scores(pins_felled_by_frame)

    score_sheet = ScoreSheet.new
    score_sheet.print_score(@name, pins_felled_by_frame, score_by_frame)
  end
end


name =  ARGV[0]
total_pins_felled = ARGV[1..-1]
game = BowlingGame.new(name, total_pins_felled)
game.bowling_score

