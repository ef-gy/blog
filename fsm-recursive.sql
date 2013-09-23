create table fsm(
state integer not null, -- current state
trans char(1),          -- transition character
to_ integer,            -- new state after transition 
final integer not null, -- 1 = the new state is an accepting state, 0 otherwise
check(final in (0,1))
);

create table word(
pos integer not null,
item char(1) not null
);

insert into fsm
(state, trans, to_, final)
values
(1, 'a', 2, 0),
(1, 'b', 3, 0),
(2, 'a', 2, 0),
(2, 'c', 4, 1),
(3, 'b', 3, 0),
(3, 'd', 4, 1);

-- aaaac
insert into word
(pos, item)
values
(1, 'a'),
(2, 'a'),
(3, 'a'),
(4, 'a'),
(5, 'c');

with recursive check_word (curr_state, final, curr_pos) as
(
select m.state as curr_state, m.final as final, w.pos as curr_pos from FSM m, word w where m.state = 1 and w.pos = 1
union all
select m.to_ as curr_state, m.final as final, cw.curr_pos + 1 as curr_pos from check_word cw, FSM m, word w 
        where m.state = curr_state and w.pos = cw.curr_pos and w.item = m.trans
)
select distinct 'accept' as check from check_word cw where final = 1 and curr_pos >= all (select c.curr_pos from check_word c);

delete from word;
insert into word
(pos, item)
values
(1, 'a'),
(2, 'a'),
(3, 'b'),
(4, 'c'),
(5, 'a');



with recursive check_word (curr_state, final, curr_pos) as
(
select m.state as curr_state, m.final as final, w.pos as curr_pos from FSM m, word w where m.state = 1 and w.pos = 1
union all
select m.to_ as curr_state, m.final as final, cw.curr_pos + 1 as curr_pos from check_word cw, FSM m, word w 
        where m.state = curr_state and w.pos = cw.curr_pos and w.item = m.trans
)
select distinct 'accept' as check from check_word cw where final = 1 and curr_pos >= all (select c.curr_pos from check_word c);