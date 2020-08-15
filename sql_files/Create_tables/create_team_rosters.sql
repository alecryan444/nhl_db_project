drop table if exists d_team_rosters;

create table d_team_rosters (
    id varchar(10),
    fullName varchar(100),
    team_id int,
    jerseyNumber int,
    code char(1),
    name varchar(50),
    type varchar(50),
    abbreviation varchar(5),
    primary key(id)

);