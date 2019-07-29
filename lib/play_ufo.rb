require_relative "ufo"
require_relative "game"

ufo = UFO.new
game = Game.new(ufo)

game.intro

while game.player_input == 'Y' 
  while !ufo.game_over?
    game.print_ufo_img
    puts

    puts "Incorrect guesses: #{ufo.incorrectly_guessed.join(' ')}"
    puts "Correct guesses: #{ufo.correctly_guessed.join(' ')}"
    puts

    puts "Incorrect Guesses Remaining: #{ufo.remaining_guesses}"
    puts "Codeword: #{ufo.guess_word.join(' ')}"
    puts

    print "\n" until ufo.ask_user_for_guess
    system("clear")
  end

  game.print_ufo_img
  puts
  ufo.win? || ufo.lose?
  puts

  game.endtro
  if game.player_input != 'Y'
    break
  end
end