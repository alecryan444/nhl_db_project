Select g.gamePk,
       g.dateTime,
       g.playerID,
       g.player_name,
       r.team_id,
       i.team_name,
       g.ga,
       g.shots,
       g.min

from nhl_db.d_game_goalie_stats g

left join d_team_rosters r
on r.id = g.playerID

left join d_team_standings i
on i.team_id = r.team_id
