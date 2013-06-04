create view vseq1  as select 0 as b union select 1 as b;
create view vseq2  as select (b1.b << 1)  | (b0.b) as b from vseq1  as b0, vseq1  as b1;
create view vseq4  as select (b1.b << 2)  | (b0.b) as b from vseq2  as b0, vseq2  as b1;
create view vseq8  as select (b1.b << 4)  | (b0.b) as b from vseq4  as b0, vseq4  as b1;
create view vseq16 as select (b1.b << 8)  | (b0.b) as b from vseq8  as b0, vseq8  as b1;
create view vseq32 as select (b1.b << 16) | (b0.b) as b from vseq16 as b0, vseq16 as b1;

create table seq1
(
    b integer not null primary key
);
create table seq2
(
    b integer not null primary key
);
create table seq4
(
    b integer not null primary key
);
create table seq8
(
    b integer not null primary key
);
create table seq16
(
    b integer not null primary key
);

insert into seq1  select b from vseq1;
insert into seq2  select b from vseq2;
insert into seq4  select b from vseq4;
insert into seq8  select b from vseq8;
insert into seq16 select b from vseq16;
