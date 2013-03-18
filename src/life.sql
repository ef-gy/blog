create table life
(
  x integer not null,
  y integer not null,
  state integer null,

  primary key (x, y)
);

create table neighbourspec
(
  x integer not null,
  y integer not null,

  primary key (x, y)
);

insert into neighbourspec
  (x, y)
values
  (-1, -1),
  (-1,  0),
  (-1,  1),
  ( 0, -1),
  ( 0,  1),
  ( 1, -1),
  ( 1,  0),
  ( 1,  1);

create view vexpands as
select
  life.x,
  life.y,
  life.state
from life
union select
  life.x + neighbourspec.x as x,
  life.y + neighbourspec.y as y,
  0 as state
from life, neighbourspec;

create view vexpand as
select
  life.x,
  life.y,
  max(life.state) as state
from vexpands as life
group by life.x, life.y;

create view vscore as
select
  x1.x,
  x1.y,
  x1.state > 0 as alive,
  sum(x2.state) as score
from vexpand as x1, vexpand as x2, neighbourspec
where x2.x = x1.x + neighbourspec.x
  and x2.y = x1.y + neighbourspec.y
group by x1.x, x1.y, x1.state;

create view vlifenext as
select
  x,
  y,
  score = 3 or (score = 2 and alive) as state
from vscore;

-- xml output view

create view vxmlfragment as
select
  '<bit x="' || x || '" y="' || y || '"/>' as fragment
from life
where state = 1;

--

create view vprogress as
select 1 as id;

create trigger insertProgress instead of insert on vprogress
for each row
begin
  delete from life where not state > 0;
  insert or replace into life
    (x, y, state)
    select
      x, y, state
    from vlifenext;
end;

-- test data

insert into life
  (x, y, state)
values
  (0,  0, 1),
  (1,  0, 1),
  (2,  0, 1),
  (3,  0, 1),
  (4,  0, 1),
  (5,  0, 1),
  (6,  0, 1),
  (7,  0, 1),
  (9,  0, 1),
  (10, 0, 1),
  (11, 0, 1),
  (12, 0, 1),
  (13, 0, 1),
  (17, 0, 1),
  (18, 0, 1),
  (19, 0, 1),
  (26, 0, 1),
  (27, 0, 1),
  (28, 0, 1),
  (29, 0, 1),
  (30, 0, 1),
  (31, 0, 1),
  (32, 0, 1),
  (34, 0, 1),
  (35, 0, 1),
  (36, 0, 1),
  (37, 0, 1),
  (38, 0, 1)
;

-- oh yeah, not to forget the classic...

--insert into life
--  (id, x, y, state)
--values
--  (0, 2, 1),
--  (1, 0, 1),
--  (1, 2, 1),
--  (2, 1, 1),
--  (2, 2, 1)
--;
