require_relative './static/ufo_ascii'

DICTIONARY = []
File.open(File.dirname(__FILE__) + "/static/nouns.txt", "r") do |f|
  f.each_line do |line|
    DICTIONARY << line.chomp
  end
end

# DICTIONARY = ['dog', 'cat']

class UFO
  attr_reader :guess_word, :correctly_guessed, :incorrectly_guessed, :remaining_guesses, :player_play

  def self.random_word
    DICTIONARY.sample.upcase
  end

  def initialize
    @code_word = UFO.random_word
    @guess_word = Array.new(@code_word.length, '_')
    @correctly_guessed = []
    @incorrectly_guessed = []
    @remaining_guesses = 6
  end

  def already_guessed?(char)
    @correctly_guessed.include?(char) || @incorrectly_guessed.include?(char)
  end

  def get_matching_indices(char)
    indices = []

    @code_word.each_char.with_index do |ch, i|
      indices << i if ch == char
    end

    indices
  end

  def fill_indices(char, indices)
    indices.each { |idx| @guess_word[idx] = char }
  end

  def char_validator(char)
    if self.already_guessed?(char)
      puts
      puts "You can only guess that letter once, please try again."
      return false
    elsif char.length > 1
      puts "\nI cannot understand your input. Please guess a single letter.\n"
      return false
    elsif ('A'..'Z').include?(char)
      return true
    end

    puts "I cannot understand your input. Please guess a single letter."
  end

  def yes_no_validator(char)
    return false if !['N', 'Y'].include?(char)

    true
  end

  def player_playing
    return true if @player_play == 'Y'

    false
  end

  def intro
    system("clear")

    puts 'Welcome to UFO: The Game!'
    puts 'Instructions: save us from alien abduction by guessing letters in the codeword.'

    puts UFO_INTRO
    while true
      print 'Are you ready to play (Y/N)? '
      @player_play = gets.chomp.upcase
      break if self.yes_no_validator(@player_play)
    end
    system("clear")
  end

  def try_guess(char)
    system("clear")

    if self.already_guessed?(char)
      puts "You can only guess that letter once, please try again."
      return false
    end

    matching_indices = self.get_matching_indices(char)

    if matching_indices.empty?
      @remaining_guesses -= 1
      @incorrectly_guessed << char
      puts "Incorrect! The tractor beam pulls the person in further.\n"
    else
      self.fill_indices(char, matching_indices)
      @correctly_guessed << char
      puts "Correct! You're closer to cracking the codeword.\n"
    end

    true
  end

  def ask_user_for_guess
    self.bonus
    self.print_ufo_img

    puts "Incorrect guesses:"
    if self.incorrectly_guessed.empty?
      puts 'None'
    else
      puts "#{self.incorrectly_guessed.join(' ')}"
    end

    puts "\nCodeword:"
    puts "#{self.guess_word.join(' ')}"
    puts "\nNumber of dictionary matches: #{@counter}"

    while true
      print "\nPlease enter your guess: "
      char = gets.chomp.upcase
      break if self.char_validator(char)
    end

    self.try_guess(char)
  end

  def win?
    return true if @code_word == @guess_word.join('')
    
    false
  end

  def lose?
    if @remaining_guesses == 0
      return true
    else
      return false
    end
  end

  def game_over?
    return true if self.win? || self.lose?

    false
  end

  def print_ufo_img
    puts "\n" + UFO_PHASES[6 - self.remaining_guesses] + "\n"
  end

  def game_over_msg
    if self.win?
      puts UFO_PHASES.first + "\n"
    else
      self.print_ufo_img
    end

    if self.win?
      puts 'Correct! You saved the person and earned a medal of honor!'
    else
      puts 'Incorrect! You failed to save the person and are scrutinized heavily by the media!'
    end

    puts "The codeword is: " + @code_word + "."
    puts

    while true
      print "Would you like to play again (Y/N)? "
      @player_play = gets.chomp.upcase
      break if self.yes_no_validator(@player_play)
    end

    system("clear")
  end

  # bonus!
  def regexp_guess_word
    @regex_guess_word = @guess_word.map do |ch|
      if ch == '_'
        '.'
      else
        ch.downcase
      end
    end

    @regex_guess_word = Regexp.new @regex_guess_word.join('')
  end

  def bonus
    self.regexp_guess_word

    @counter = 0

    DICTIONARY.each do |word|
      @counter += 1 if word.match(@regex_guess_word)
    end
    
    @counter
  end
end