require_relative "ufo"
require_relative "game"

ufo = UFO.new

ufo.intro

while ufo.player_play == 'Y' 
  ufo = UFO.new

  while !ufo.game_over?
    ufo.print_ufo_img
    ufo.ask_user_for_guess
  end

  ufo.print_ufo_img

  puts
  ufo.game_over_msg
  puts
  ufo.play_again?
end