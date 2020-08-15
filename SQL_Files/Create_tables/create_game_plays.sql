drop table if exists test_f_game_plays;

create table test_f_game_plays (

    play_id             varchar(50) not null unique,
    dateTime            date,
    description         varchar(100),
    emptyNet            varchar(50),
    event               varchar(100),
    eventCode           varchar(11),
    eventId             int,
    eventIdx            int,
    eventTypeId         varchar(100),
    gamePk              int,
    gameType            varchar(2),
    gameWinningGoal     int,
    team_id             int,
    link                varchar(100),
    team_name                varchar(100) not null,
    ordinalNum          varchar(4),
    penaltyMinutes      int,
    penaltySeverity     varchar(100),
    period              int default(1),
    periodTime          varchar(10),
    periodTimeRemaining varchar(10),
    periodType          varchar(10),
    secondaryType       varchar(50),
    triCode             char(3),
    x                   int,
    y                   int,
    home_away           int,
    primary key(play_id),
    constraint play_id check(play_id>1)

)

