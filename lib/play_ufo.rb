require_relative "ufo"

ufo = UFO.new
ufo.intro

while ufo.player_playing
  ufo = UFO.new

  until ufo.game_over?
    ufo.ask_user_for_guess
  end

  ufo.game_over_msg
end

puts 'Goodbye!'