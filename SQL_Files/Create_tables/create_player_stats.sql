drop table if exists d_player_stats;

create table d_player_stats as (
    with participants as (
        Select playerID, player_name, p.gamePk, r.abbreviation
        from f_game_play_players p

                 left join f_game_plays gp
                           on gp.play_id = p.play_id

                 left join d_team_rosters r
                           on r.id = p.playerID

        where p.gameType = 'R'
        and period <  5

        group by 1, 2, 3, 4),

         goals as (Select playerID,
                          player_name,
                          p.gamePk,
                          p.team_id,
                          r.abbreviation,
                          case when playerType = 'Scorer' then 1 else 0 end as goals,
                          case when playerType = 'Assist' then 1 else 0 end as assists,
                          case when playerType = 'Goalie' then 1 else 0 end as goals_allowed
                   from f_game_play_players p

                            left join f_game_plays gp
                                      on gp.play_id = p.play_id

                            left join d_team_rosters r
                                      on r.id = p.playerID

                   where event = 'Goal'
                    and period <5),

         goal_agg as (
             Select gamePk,
                    playerID,
                    player_name,
                    abbreviation,
                    sum(goals)         g,
                    sum(assists)       a,
                    sum(goals_allowed) ga
             from goals
             group by 1, 2, 3),


         shots as (Select playerID,
                          event,
                          player_name,
                          p.gamePk,
                          p.team_id,
                          r.abbreviation,
                          case when playerType = 'Shooter' then 1 else 0 end as shots,
                          case when playerType = 'Goalie' then 1 else 0 end  as saves
                   from f_game_play_players p

                            left join f_game_plays gp
                                      on gp.play_id = p.play_id

                            left join d_team_rosters r
                                      on r.id = p.playerID

                   where event in ('Shot')
                    and period < 5
         ),

         shots_agg as (
             Select gamePk,
                    playerID,
                    player_name,
                    abbreviation,
                    sum(shots) sog,
                    sum(saves) saves
             from shots

             group by 1, 2, 3
         ),


         missed_shots as (Select playerID,
                                 event,
                                 player_name,
                                 p.gamePk,
                                 p.team_id,
                                 r.abbreviation,
                                 case when playerType = 'Shooter' then 1 else 0 end as shots
                          from f_game_play_players p

                                   left join f_game_plays gp
                                             on gp.play_id = p.play_id

                                   left join d_team_rosters r
                                             on r.id = p.playerID

                          where event in ('Missed Shot')
                            and period < 5),

         missed_shots_agg as (
             Select gamePk,
                    playerID,
                    player_name,
                    abbreviation,
                    sum(shots) missed_s
             from missed_shots

             group by 1, 2, 3),

         facoffs as (Select playerID,
                            player_name,
                            playerType,
                            p.gamePk,
                            p.team_id,
                            r.abbreviation,
                            case when playerType = 'Winner' then 1 else 0 end as fo_won,
                            case when playerType = 'Loser' then 1 else 0 end  as fo_lost

                     from f_game_play_players p

                              left join f_game_plays gp
                                        on gp.play_id = p.play_id

                              left join d_team_rosters r
                                        on r.id = p.playerID

                     where event = 'Faceoff'
                     and period < 5),

         faceoffs_agg as (
             Select gamePk,
                    playerID,
                    player_name,
                    abbreviation,
                    sum(fo_won)  fow,
                    sum(fo_lost) fol
             from facoffs

             group by 1, 2, 3),

         stats as (Select p.gamePk,
                          p.playerID,
                          p.player_name,
                          p.abbreviation    position,
                          g                 goals,
                          a                 assist,
                          g + a             points,
                          sog,
                          fow               faceoffs_won,
                          fol               faceoffs_lost,
                          fow + fol         faceoffs_taken,
                          fow / (fow + fol) faceoff_wonp,
                          ga                goals_allowed,
                          saves

                   from participants p

                            left join shots_agg s
                                      on s.gamePk = p.gamePk and s.playerID = p.playerID

                            left join goal_agg g
                                      on g.gamePk = p.gamePk and g.playerID = p.playerID

                            left join missed_shots_agg ms
                                      on ms.gamePk = p.gamePk and ms.playerID = p.playerID

                            left join faceoffs_agg f
                                      on f.gamePk = p.gamePk and f.playerID = p.playerID),

    player_stats as (Select playerID,
           position,
           player_name,
           count(gamepk)                           gp,
           sum(goals)                              goals,
           sum(assist)                             assists,
           sum(points)                             points,
           sum(sog)                                sog,
           sum(faceoffs_won)                       faceoffs_won,
           sum(faceoffs_lost)                      faceoffs_lost,
           sum(faceoffs_won) / sum(faceoffs_taken) faceoff_percentage
    from stats
    where position <> 'G'
    group by 1, 2, 3)

Select id player_id, fullName, team_id, jerseyNumber, position, gp, goals,
       assists, points, sog, faceoffs_won, faceoffs_lost, faceoff_percentage
from d_team_rosters r

left join player_stats s
on s.playerID = r.id

where r.abbreviation != 'G'
);