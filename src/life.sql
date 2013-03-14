create table life
(
  id integer not null,
  x integer not null,
  y integer not null,
  state integer null,

  primary key (id, x, y)
);

create table neighbourspec
(
  id integer not null,
  x integer not null,
  y integer not null,

  primary key (id, x, y)
);

insert into neighbourspec
  (id, x, y)
values
  (1, -1, -1),
  (1, -1,  0),
  (1, -1,  1),
  (1,  0, -1),
  (1,  0,  1),
  (1,  1, -1),
  (1,  1,  0),
  (1,  1,  1);

create view vdimensions as
select
  id,
  min(x) - 1 as minx,
  max(x) + 1 as maxx,
  min(y) - 1 as miny,
  max(y) + 1 as maxy
from life
where state = 1
group by id;

create view vexpands as
select
  life.id,
  null as nid,
  life.x,
  life.y,
  life.state
from life
union select
  life.id,
  neighbourspec.id as nid,
  life.x + neighbourspec.x as x,
  life.y + neighbourspec.y as y,
  0 as state
from life, neighbourspec;

create view vexpand as
select
  life.id,
  life.x,
  life.y,
  max(life.state) as state
from vexpands as life
group by life.id, life.x, life.y;

create view vscore as
select
  x1.id,
  x1.x,
  x1.y,
  x1.state > 0 as alive,
  sum(x2.state) as score
from vexpand as x1, vexpand as x2, neighbourspec
where x1.id = x2.id
  and x2.x = x1.x + neighbourspec.x
  and x2.y = x1.y + neighbourspec.y
group by x1.id, x1.x, x1.y, x1.state;

create view vlifenext as
select
  vscore.id,
  x,
  y,
  score = 3 or (score = 2 and alive) as state
from vscore;

-- xml output view

create view vxmlfragment as
select
  id,
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
    (id, x, y, state)
    select
      id, x, y, state
    from vlifenext;
end;

-- test data

insert into life
  (id, x, y, state)
values
  (1, 0,  0, 1),
  (1, 1,  0, 1),
  (1, 2,  0, 1),
  (1, 3,  0, 1),
  (1, 4,  0, 1),
  (1, 5,  0, 1),
  (1, 6,  0, 1),
  (1, 7,  0, 1),
  (1, 9,  0, 1),
  (1, 10, 0, 1),
  (1, 11, 0, 1),
  (1, 12, 0, 1),
  (1, 13, 0, 1),
  (1, 17, 0, 1),
  (1, 18, 0, 1),
  (1, 19, 0, 1),
  (1, 26, 0, 1),
  (1, 27, 0, 1),
  (1, 28, 0, 1),
  (1, 29, 0, 1),
  (1, 30, 0, 1),
  (1, 31, 0, 1),
  (1, 32, 0, 1),
  (1, 34, 0, 1),
  (1, 35, 0, 1),
  (1, 36, 0, 1),
  (1, 37, 0, 1),
  (1, 38, 0, 1)
;

-- oh yeah, not to forget the classic...

--insert into life
--  (id, x, y, state)
--values
--  (2, 0, 2, 1),
--  (2, 1, 0, 1),
--  (2, 1, 2, 1),
--  (2, 2, 1, 1),
--  (2, 2, 2, 1)
--;
