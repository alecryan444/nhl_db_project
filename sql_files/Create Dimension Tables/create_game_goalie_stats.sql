drop table if exists d_game_goalie_stats;

create table d_game_goalie_stats as (
    with g as (
        Select gp.gamePk, playerID, player_name, dateTime
        from f_game_play_players gpp

                 left join f_game_plays gp
                           on gp.play_id = gpp.play_id

        where playerType = 'Goalie'
          and period != 5
        group by 1, 2, 3, 4
    ),


         ga as (Select gpp.gamePk, playerID, player_name, count(gp.play_id) ga
                from f_game_play_players gpp

                         left join f_game_plays gp
                                   on gp.play_id = gpp.play_id

                where event = 'Goal'
                  and playerType = 'Goalie'
                  and period < 5

                group by 1, 2, 3),

         shots as (Select gpp.gamePk, playerID, player_name, count(gp.play_id) shots
                   from f_game_play_players gpp

                            left join f_game_plays gp
                                      on gp.play_id = gpp.play_id

                   where event = 'Shot'
                     and playerType = 'Goalie'
                     and period < 5

                   group by 1, 2, 3),


    final_agg as (Select g.gamePk,
           g.dateTime,
           g.playerID,
           g.player_name,
           'G' as position,

           ifnull(ga.ga, 0) ga,
           ifnull(shots, 0) shots,
           ifnull(min, 0) min

    from g

             left join ga
                       on g.playerID = ga.playerID and g.gamePk = ga.gamePk

             left join d_team_rosters r
                       on r.id = ga.playerID

             left join (Select ROUND(sum(toi_sec) / 60, 0) + sum(toi_min) min,
                               player_id,
                               gamePk
                        from f_toi_jersey

                        where gamePk like '%201902%'
                        group by 2, 3
    ) toi
                       on toi.gamePk = g.gamePk and toi.player_id = g.playerID

             left join shots s
                       on s.playerID = g.playerID and s.gamePk = g.gamePk)


    Select g.gamePk,
       g.dateTime,
       g.playerID,
       g.player_name,
       g.position,
       t.team_id,
       i.team_name,
       g.ga,
       g.shots,
       g.min
    from final_agg g

     left join d_team_rosters t
            on t.id = g.playerID

            left join d_team_standings i
            on i.team_id = t.team_id



    )

