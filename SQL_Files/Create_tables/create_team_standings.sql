drop table if exists d_team_standings;
Create table d_team_standings as (
    Select b.team_id,
           t.team_name,
           conference_id,
           division_id,
           count(b.team_id) games_played,
           sum(winner) + sum(so_win) wins,
           count(winner) - sum(winner) - sum(so_win) - (sum(otl)+ sum(shootouts_played) - sum(so_win))losses,
           sum(otl)+ sum(shootouts_played) - sum(so_win) otl,
           ((sum(winner) + sum(so_win))*2) + sum(otl)+ sum(shootouts_played) - sum(so_win) pts,
           sum(otw) otw,
           sum(gf) + sum(so_win) gf,
           sum(ga) + (sum(shootouts_played) - sum(so_win)) ga,
           (sum(gf) + sum(so_win))  / count(b.team_id) gfpg,
           (sum(ga) + (sum(shootouts_played) - sum(so_win))) / count(b.team_id) gapg,
           (sum(gf) + sum(so_win)) - (sum(ga) + (sum(shootouts_played) - sum(so_win))) gd,
           sum(so_win) shootout_wins,
           sum(shootouts_played) - sum(so_win) shootout_losses


    from nhl_db.d_box_scores b

    join (select distinct team_id,team_name from f_game_plays) t
    on t.team_id = b.team_id

    ## Filter out return to play
    where date < '2020-07-01'

    group by 1,2,3,4)

