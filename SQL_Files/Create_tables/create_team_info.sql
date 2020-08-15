drop table if exists d_team_info;
create table d_team_info (
    team_id integer,
    venue_name varchar(100),
    venue_city varchar(100),
    first_year	varchar(4),
    division_id	integer,
    conference_id integer,
    primary key (team_id)

);