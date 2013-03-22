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

-- this pattern is called 2333M; see http://www.conwaylife.com/wiki/23334M

insert into life
  (x, y, state)
values
  ( 0,  0,  1),
  (-2,  1,  1),
  (-1,  1,  1),
  (-1,  2,  1),
  (-2,  3,  1),
  ( 1,  3,  1),
  ( 2,  4,  1),
  (-1,  5,  1),
  ( 2,  5,  1),
  ( 0,  6,  1),
  ( 2,  6,  1),
  (-1,  7,  1)
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
