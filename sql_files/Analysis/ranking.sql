with cte as (
    Select gamePk, date, team_name, home_away, bs.gf + ifnull(so_win,0) gf,
       ifnull(bs.ga,0) + ifnull(shootouts_played,0) - ifnull(so_win,0) ga
    from nhl_db.d_box_scores bs

    left join d_team_standings s
    on s.team_id = bs.team_id),

home as (Select gamePk,
       date,
       team_name home,
       sum(gf) gf

from cte

where home_away = 1


group by 1,2,3),

away as (Select gamePk,
       date,
       team_name away,
       sum(gf) gf

from cte

where home_away = 0


group by 1,2,3 )


Select a.date,
       h.home,
       a.away,
       h.gf home_goals,
       a.gf away_goals
from home h

join away a
on h.gamePk = a.gamePk

where left(a.gamePk, 4) >= 2019