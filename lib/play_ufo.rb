require_relative "ufo"

ufo = UFO.new
ufo.intro

while ufo.player_playing
  # instantiate new ufo 
  ufo = UFO.new

  # ask user for guess until game is over
  while !ufo.game_over?
    ufo.ask_user_for_guess
  end

  # game over, play again?
  ufo.game_over_msg
end

puts 'Goodbye!'