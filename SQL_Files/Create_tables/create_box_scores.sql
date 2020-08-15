drop table if exists d_box_scores;

CREATE TABLE d_box_scores AS (
    With sog as (
        Select gamePk, team_id, count(play_id) sog
        from f_game_plays

        where event in ('Goal', 'Shot')
        and gameType = 'R'
        group by 1, 2),

         fop as (
             Select gp.gamePk,
                    gp.team_id,
                    count(play_id)               faceoffs_won,
                    faceoffs,
                    count(play_id) / faceoffs as faceOffPercentage
             from f_game_plays gp

                      join (select gamePk, count(play_id) faceoffs
                            from f_game_plays
                            where event = 'Faceoff'
                            and gameType = 'R'
                            group by 1) as f
                           on f.gamePk = gp.gamePk

             where event = 'Faceoff'
             and gameType = 'R'

             group by 1, 2),

         hits as (
             Select gamePk, team_id, count(play_id) hits
             from f_game_plays

             where event = 'Hit'
             and gameType = 'R'

             group by 1, 2),

         blocks as (
             Select gamePk, team_id, count(play_id) blocked_shots
             from f_game_plays

             where event = 'Blocked Shot'
             and gameType = 'R'

             group by 1, 2),

         takeaways as (
             Select gamePk, team_id, count(play_id) takeaways
             from f_game_plays

             where event = 'Takeaway'
             and gameType = 'R'

             group by 1, 2),

         giveaways as (
             Select gamePk, team_id, count(play_id) giveaways
             from f_game_plays

             where event = 'Giveaway'
             and gameType = 'R'

             group by 1, 2),

         pm as (
             Select gamePk, team_id, sum(penaltyMinutes) penalty_minutes
             from f_game_plays

             group by 1, 2),

goals as(
        Select gamePk,team_id, count(play_id) goals
        from f_game_plays

        where event = 'Goal'
        and period < 5

        group by 1,2),

games as (
    Select gp.gamePk, gp.team_id, home_away, min(dateTime) date
    from f_game_plays gp

    where team_id is not null



    group by 1,2,3),

total_goals as (
    Select gamePk, count(play_id) total
    from f_game_plays
    where event = 'Goal'
    and period < 5
    group by 1
),

max_period as (
    Select gamePk, max(period) periods
        from f_game_plays

        where event = 'Goal'
        and period < 5
        and team_id is not null

        group by 1
),

final_goals as(

    Select
       gp.gamePk,
       gp.team_id,
       ifnull(goals, 0 ) gf,
       ifnull(tg.total, 0) - ifnull(goals,0) ga,
       case when ifnull(tg.total,0) - ifnull(goals,0) < ifnull(goals,0) then 1 else 0 end as winner,
       case when periods > 3 then 1 else 0 end as ot
    from games gp

    left join total_goals tg
    on tg.gamePk = gp.gamePk

    left join goals g
    on g.gamePk = gp.gamePk and g.team_id = gp.team_id

    left join max_period m
    on m.gamePk = gp.gamepk),

so_goals as(
        Select gamePk,team_id, count(play_id) goals
        from f_game_plays

        where event = 'Goal'
        and period = 5

        group by 1,2),

total_so_goals as (
    Select gamePk, count(play_id) total,  1 as shootouts_played
    from f_game_plays
    where event = 'Goal'
    and period = 5
    group by 1
),

so_final as (

Select gp.gamePk,
       gp.team_id,
       shootouts_played,
       ifnull(s.goals, 0) gf,
       ifnull(tg.total,0) - ifnull(s.goals,0) ga,
       case when ifnull(s.goals,0) > ifnull(tg.total,0) - ifnull(s.goals,0) then 1 else 0 end as sow

from games gp

left join so_goals s
on s.team_id = gp.team_id and s.gamePk = gp.gamePk

left join total_so_goals tg
on tg.gamePk = gp.gamePk)



Select     gp.gamePk,
           gp.date,
           gp.team_id,
           gp.home_away,
           sog,
           faceoffs_won,
           faceoffs,
           faceOffPercentage,
           hits,
           blocked_shots,
           takeaways,
           giveaways,
           penalty_minutes,
           fg.gf,
           fg.ga,
           winner,
           ot,
           shootouts_played,
           case when winner = 1 and ot = 1 then 2
                when winner = 0 and ot = 1 then 1
                when winner = 0 and ot = 0 then 0
                when winner = 1 and ot = 0 then 2
            end as pts,
           case when ot = 1 and winner = 1 then 1 else 0 end as otw,
           case when ot = 1 and winner = 0 then 1 else 0 end as otl,
           coalesce(s.sow, 0 ) so_win,
            conference_id,
            division_id


    from games gp

            left join sog
                on gp.team_id = sog.team_id and gp.gamePk = sog.gamePk

             left join fop
                  on gp.team_id = fop.team_id and fop.gamePk = gp.gamePk

             left join hits h
                  on h.team_id = gp.team_id and h.gamePk = gp.gamePk

             left join blocks b
                  on b.team_id = gp.team_id and b.gamePk = gp.gamePk

             left join takeaways t
                  on t.team_id = gp.team_id and t.gamePk = gp.gamePk

             left join giveaways g
                  on g.team_id = gp.team_id and g.gamePk = gp.gamePk

             left join pm
                  on pm.team_id = gp.team_id and pm.gamePk = gp.gamePk

             left join final_goals fg
                  on fg.team_id = gp.team_id and fg.gamePk = gp.gamePk

             left join so_final s
                  on s.team_id = gp.team_id and s.gamePk = gp.gamePk

            left join d_team_info d
            on d.team_id = gp.team_id

);
