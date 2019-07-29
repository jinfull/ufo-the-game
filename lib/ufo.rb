DICTIONARY = []

File.open(File.dirname(__FILE__) + "/static/nouns.txt", "r") do |f|
  f.each_line do |line|
    DICTIONARY << line.chomp
  end
end

# DICTIONARY = ['dog', 'cat', 'bootcamp']

class UFO
  attr_reader :guess_word, :correctly_guessed, :incorrectly_guessed, :remaining_guesses

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

  def try_guess(char)
    if self.already_guessed?(char)
      puts "You can only guess that letter once, please try again."
      return false
    end

    matching_indices = self.get_matching_indices(char)

    if matching_indices.empty?
      @remaining_guesses -= 1
      @incorrectly_guessed << char
      puts "Incorrect! The tractor beam pulls the person in further."
    else
      self.fill_indices(char, matching_indices)
      @correctly_guessed << char
      puts "Correct! You're closer to cracking the codeword."
    end

    true
  end

  def ask_user_for_guess
    print "Please enter your guess: "
    char = gets.chomp.upcase
    self.try_guess(char)
  end

  def win?
    if @code_word == @guess_word.join('')
      puts 'Correct! You saved the person and earned a medal of honor!'
      return true
    else
      return false
    end
  end

  def lose?
    if @remaining_guesses == 0
      puts 'Incorrect! You failed to save the person and are scrutinized heavily by the media!'
      return true
    else
      return false
    end
  end

  def game_over?
    if win? || lose?
      puts 'The codeword is ' + @code_word
      return true
    else
      return false
    end
  end
end