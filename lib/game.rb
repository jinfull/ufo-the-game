require_relative './static/ufo_ascii.rb'

class Game
  attr_reader :player_input

  def initialize(ufo)
    @ufo = ufo
    @player_input = nil
  end

  def intro
    system("clear")
    puts 'Welcome to UFO: The Game!'
    puts UFO_INTRO
    print 'Are you ready to play (Y/N)? '
    @player_input = gets.chomp.upcase
  end

  def print_ufo_img
    system("clear")
    puts UFO_PHASES[6 - @ufo.remaining_guesses]
  end

  def endtro
    print "Would you like to play again (Y/N)? "
    @player_input = gets.chomp.upcase
  end
end

