-- Queries
-- Question 1: Adding a new facility -a spa
INSERT INTO cd.facilities (
    facid, name, membercost, guestcost,
    initialoutlay, monthlymaintenance
)
VALUES
    (9, 'Spa', 20, 30, 100000, 800);


-- Question 2: Adding multiple facility in one command
insert into cd.facilities
    (facid, name, membercost, guestcost,
    initialoutlay, monthlymaintenance)
select (select max(facid) from cd.facilities)+1, 'Spa', 20, 30, 100000, 800;


-- Question 3: Inserting calculated data into a table
UPDATE
    cd.facilities
SET
    initialoutlay = 10000
where
    facid = 1;

-- Question 4: Update a row based on the contents of another row
UPDATE
    cd.facilities fac
SET
    membercost = (
        SELECT
            membercost * 1.1
        FROM
            cd.facilities
        WHERE
            facid = 0
    ),
    guestcost = (
        SELECT
            guestcost * 1.1
        FROM
            cd.facilities
        WHERE
            facid = 0
    )
WHERE
    fac.facid = 1;

-- Question 5: Delete all bookings
DELETE FROM cd.bookings;

-- Question 6: Delete a member from the cd.members table
DELETE FROM cd.members mb
WHERE mb.memid = 37;

-- BASIC
-- Question 7: Control which rows are retrieved - part 2
select facid, name, membercost, monthlymaintenance
    from cd.facilities
where
    membercost > 0 and
    (membercost < monthlymaintenance/50.0);


-- Question 8: Basic string Searches(searching facilites with the word Tennis)
select * from
    cd.facilities
where
    name like '%Tennis%';


-- Question 9: Matching against multiple possible values
select * from cd.facilities facs
where facs.facid in (1, 5);

-- Question 10: Working with dates(listing start date)
select
    memid,
    surname,
    firstname,
    joindate
from
    cd.members
where joindate >= '2012-09-01';

-- Question 11: Combining results from multiple queires
select surname
from cd.members
union
select name from cd.facilities;

--JOIN
-- Question 12: Retrieve the start time of members' bookings named 'David Farrell'
select bks.starttime
    from cd.bookings bks
        inner join cd.members mems
                   on mems.memid = bks.memid
where
    mems.firstname='David'
  and mems.surname='Farrell';

-- Question 13 : Work out the start times of bookings for tennis courts
select bks.starttime as Start, facs.name as Name
    from cd.facilities facs
        inner join cd.bookings bks
            on facs.facid = bks.facid
where
    facs.name like 'Tennis Court%'
  and bks.starttime >= '2012-09-21'
  and bks.starttime < '2012-09-22'
order by bks.starttime;

-- 	Question 14: Produce a list of all members, along with their recommender
select mbs.firstname as memfname, mbs.surname as memsname, recs.firstname as recfname, recs.surname as recsname
    from cd.members mbs
         left outer join cd.members recs
            on recs.memid = mbs.recommendedby
order by memsname, memfname

-- Question 15: Produce a list of all members who have recommended another member
select distinct recs.firstname as FirstName, recs.surname as Surname
    from cd.members mbs
         inner join cd.members recs
            on recs.memid = mbs.recommendedby
order by Surname , Firstname;

-- Question 16: Produce a list of all members, along with their recommender, using no joins.
select distinct mbs.firstname || ' ' || mbs.surname as member,
        (select recs.firstname || ' ' || recs.surname as recommender
            from cd.members recs
                where recs.memid = mbs.recommendedby
        )
    from cd.members mbs
order by member;

-- Aggergation
-- Question 17: Count the number of recommendations each member makes.
select mbs.recommendedby, count(*)
    from cd.members mbs
        WHERE mbs.recommendedby is not null
    group by mbs.recommendedby
Order by mbs.recommendedby;

-- Question 18: List the total slots booked per facility
select bks.facid, SUM(bks.slots) as "Total Slots"
    from cd.bookings bks
        group by facid
order by bks.facid;

-- Question 19: List the total slots booked per facility in a given month
select facid, sum(slots) as "Total Slots"
    from cd.bookings bks
        where bks.starttime >= '2012-09-01'
            and bks.starttime < '2012-10-01'
    group by facid
order by sum(bks.slots)

-- Question 20: List the total slots booked per facility per month
select facid, extract(month from starttime) as month, sum(slots) as "Total Slots"
    from cd.bookings
        where extract(year from starttime) = 2012
        group by facid, month
order by facid, month

-- Question 21: Find the count of members who have made at least one booking
select count(distinct memid)
from cd.bookings

-- Question 22: List each member's first booking after September 1st 2012
select mbs.surname, mbs.firstname, mbs.memid, min(bks.starttime) as starttime
from cd.bookings bks
        inner join cd.members mbs on
    mbs.memid = bks.memid
    where starttime >= '2012-09-01'
group by mbs.surname, mbs.firstname, mbs.memid
order by mbs.memid;

-- Question 23: Produce a list of member names, with each row containing the total member count
select count(*) over(), mbs.firstname, mbs.surname
    from cd.members mbs
order by joindate;

-- Question 24: Produce a numbered list of members
select row_number() over(order by joindate), mbs.firstname,mbs.surname
    from cd.members mbs
order by mbs.joindate

-- Question 25: Output the facility id that has the highest number of slots of booked, again
select facid, total from(
            select bk.facid, sum(bk.slots) total, rank() over (order by sum(bk.slots) desc) rank
                from cd.bookings bk
                    group by facid
            )as ranked
where rank = 1

-- STRING
-- Question 26: Output the names of all members, formatted as 'Surname, Firstname'
select mbs.surname || ', ' || mbs.firstname as name
from cd.members mbs;

-- Question 27: Find telephone numbers with parentheses
select memid, telephone
from cd.members
where telephone ~ '[()]'

-- Question 28: Count the number of members whose surname starts with each letter of the alphabet
select substr(mbs.surname, 1, 1) as letter, count(*) as count
    from cd.members mbs
        group by letter
order by letter
