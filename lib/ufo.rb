require_relative './static/ufo_ascii.rb'


DICTIONARY = []

File.open(File.dirname(__FILE__) + "/static/nouns.txt", "r") do |f|
  f.each_line do |line|
    DICTIONARY << line.chomp
  end
end

DICTIONARY = ['dog', 'cat', 'bootcamp']

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

  # UI / Frontend Behavior

  def intro
    system("clear")
    puts 'Welcome to UFO: The Game!'
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
      puts "Incorrect! The tractor beam pulls the person in further."
      puts
    else
      self.fill_indices(char, matching_indices)
      @correctly_guessed << char
      puts "Correct! You're closer to cracking the codeword."
      puts
    end

    true
  end

  def ask_user_for_guess

    self.print_ufo_img
    puts
    puts "Incorrect guesses:"
    puts "#{self.incorrectly_guessed.join(' ')}"
    puts
    puts "Correct guesses:"
    puts "#{self.correctly_guessed.join(' ')}"
    puts

    puts "Codeword: #{self.guess_word.join(' ')}"
    puts
    
    while true
      print "Please enter your guess: "
      char = gets.chomp.upcase
      break if self.char_validator(char)
    end

    self.try_guess(char)
    # system("clear")
  end

  def win?
    if @code_word == @guess_word.join('')
      return true
    else
      return false
    end
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
    # system("clear")
    puts UFO_PHASES[6 - self.remaining_guesses]
  end

  def game_over_msg
    if @code_word == @guess_word.join('')
      puts UFO_PHASES.first
    else
      self.print_ufo_img
    end

    puts

    if self.win?
      puts 'Correct! You saved the person and earned a medal of honor!'
    else
      puts 'Incorrect! You failed to save the person and are scrutinized heavily by the media!'
    end

    puts 'The codeword is: ' + @code_word + '.'
    puts

    while true
      print "Would you like to play again (Y/N)? "
      @player_play = gets.chomp.upcase
      break if self.yes_no_validator(@player_play)
    end

    system("clear")
  end
end