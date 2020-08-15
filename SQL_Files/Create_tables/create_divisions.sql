drop table if exists d_divisions;

create table d_divisions (
    id varchar(10),
    name varchar(50),
    nameShort varchar(10),
    abbreviation varchar(10),
    conferenceId varchar(10),
    active varchar(10),

    primary key (id)


)