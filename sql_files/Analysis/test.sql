Select gpp.gamePk, playerID, player_name, count(gp.play_id) shots
from f_game_play_players gpp

left join f_game_plays gp
on  gp.play_id = gpp.play_id

where event = 'Shot'
and playerType = 'Goalie'
and period < 5

group by 1,2,3