drop table if exists f_game_play_players;

create table f_game_play_players (
    play_id varchar(50) not null,
    gamePk int,
    player_name varchar(500),
    playerType varchar(50),
    playerID int,
    eventIdx int,
    gameType varchar(4),
    eventCode varchar(8),
    team_id int
);