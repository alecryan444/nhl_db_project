drop table if exists f_toi_jersey;

create table f_toi_jersey(
    gamePk varchar(50),
    team_id integer ,
    team_name varchar(100),
    player_id int,
    player_name varchar(100),
    jersey int,
    roster_status varchar(10),
    toi_min int,
    toi_sec int

                         )