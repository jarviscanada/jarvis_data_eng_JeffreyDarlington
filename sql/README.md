# Introduction
This project uses a relational test database with information about a resort, including tables for bookings, members, and facilities. 
The database was set up in a PostgreSQL (psql) instance running inside a Docker container and initialized using a SQL file called `clubdata.sql` and storing 
solutions into `queries.sql`.I created SQL queries to solve different business-related problems while improving my SQL skills and understanding of queries. 
Git was also used to manage files and track changes throughout the project.

###### Table Setup (DDL)
Creating the Members table:

```sql
CREATE TABLE cd.members (
    memid integer NOT NULL,
    surname character varying(200) NOT NULL,
    firstname character varying(200) NOT NULL,
    address character varying(300) NOT NULL,
    zipcode integer NOT NULL,
    telephone character varying(20) NOT NULL,
    recommendedby integer,
    joindate timestamp without time zone NOT NULL
);
```

Creating the Booking table:
```sql
CREATE TABLE bookings (
    bookid integer NOT NULL,
    facid integer NOT NULL,
    memid integer NOT NULL,
    starttime timestamp without time zone NOT NULL,
    slots integer NOT NULL
);
```
Creating the Facilities table:
```sql
CREATE TABLE facilities (
    facid integer NOT NULL,
    name character varying(100) NOT NULL,
    membercost numeric NOT NULL,
    guestcost numeric NOT NULL,
    initialoutlay numeric NOT NULL,
    monthlymaintenance numeric NOT NULL
);
```
### SQL Queries (DDL)
#### Solutions to business questions

###### Question 1: Inserting data to facilities

```sql
INSERT INTO cd.facilities
    (facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES (9, 'Spa', 20, 30, 100000, 800)

```

###### Question 2: Insert calculated data into a table

```sql
INSERT INTO cd.facilities
SELECT (SELECT MAX(facid) FROM cd.facilities) + 1, 'Spa', 20, 30, 100000, 800;
```

###### Question 3: Update incorrect value in initial outlay column
```sql
UPDATE 
  cd.facilities 
SET 
  initialoutlay = 10000 
WHERE 
  facid = 1;
```

###### Question 4: Insert calculated data into a table
```sql
UPDATE 
  cd.facilities fac 
SET 
  membercost = (
    SELECT membercost * 1.1 
    FROM cd.facilities 
    WHERE facid = 0
  ), 
  guestcost = (
    SELECT guestcost * 1.1 
    FROM cd.facilities WHERE facid = 0
  ) WHERE 
  fac.facid = 1;
```
###### Question 5: Insert calculated data into a table
```sql
DELETE FROM cd.bookings;
```
###### Question 6: Delete a member from the cd.members table
```sql
DELETE FROM cd.members mb
WHERE mb.memid = 37;
```
###### Question 7: Control which rows are retrieved
```sql
SELECT facid, name, membercost, monthlymaintenance
    FROM cd.facilities
WHERE
    membercost > 0 AND
    (membercost < monthlymaintenance/50.0);
```
###### Question 8: Basic string searches for the word 'Tennis'
```sql
SELECT * FROM 
    cd.facilities
WHERE 
    name LIKE '%Tennis%';
```

###### Question 9: Matching against multiple possible values
```sql
SELECT * FROM cd.facilities facs
WHERE facs.facid IN (1, 5);
```

###### Question 10: Working with dates
```sql
SELECT 
    memid,
    surname,
    firstname,
    joindate
FROM
    cd.members
WHERE joindate >= '2012-09-01';

```

###### Question 11: Combining results from multiple queries
```sql
SELECT 
    name
FROM
    cd.facilities
UNION 
SELECT 
    name
FROM cd.facilities
```

###### Question 12: Retrieve the start time of members' bookings named 'David Farrell'
```sql
SELECT
    bks.starttime
FROM cd.bookings AS bks
INNER JOIN cd.members AS mems
    ON mems.memid = bks.memid
WHERE mems.firstname = 'David'
    AND mems.surname = 'Farrell';
```

###### Question 13: Work out the start times of bookings for tennis courts

```sql
SELECT
    bks.starttime AS start,
    facs.name AS name
FROM cd.facilities AS facs
INNER JOIN cd.bookings AS bks
    ON facs.facid = bks.facid
WHERE facs.name LIKE 'Tennis Court%'
    AND bks.starttime >= '2012-09-21'
    AND bks.starttime < '2012-09-22'
ORDER BY bks.starttime;
```

###### Question 14: Produce a list of all members, along with their recommender
```sql
SELECT
    mbs.firstname AS memfname,
    mbs.surname AS memsname,
    recs.firstname AS recfname,
    recs.surname AS recsname
FROM cd.members AS mbs
LEFT OUTER JOIN cd.members AS recs
    ON recs.memid = mbs.recommendedby
ORDER BY memsname, memfname;
```

###### Question 15: Produce a list of all members who have recommended another member
```sql
SELECT DISTINCT
    recs.firstname AS FirstName,
    recs.surname AS Surname
FROM cd.members AS mbs
INNER JOIN cd.members AS recs
    ON recs.memid = mbs.recommendedby
ORDER BY Surname, FirstName;
```

###### Question 16: Produce a list of all members, along with their recommender, using no joins.
```sql
SELECT DISTINCT
    mbs.firstname || ' ' || mbs.surname AS member,
    (
        SELECT
            recs.firstname || ' ' || recs.surname AS recommender
        FROM cd.members AS recs
        WHERE recs.memid = mbs.recommendedby
    )
FROM cd.members AS mbs
ORDER BY member;
```

###### Question 17: Count the number of recommendations each member makes.
```sql
SELECT
    mbs.recommendedby,
    COUNT(*)
FROM cd.members AS mbs
WHERE mbs.recommendedby IS NOT NULL
GROUP BY mbs.recommendedby
ORDER BY mbs.recommendedby;
```

###### Question 18: List the total slots booked per facility
```sql
SELECT
    facid,
    SUM(slots) AS "Total Slots"
FROM cd.bookings AS bks
WHERE bks.starttime >= '2012-09-01'
  AND bks.starttime < '2012-10-01'
GROUP BY facid
ORDER BY SUM(bks.slots);
```
###### Question 19: List the total slots booked per facility in a given month
```sql
SELECT
    facid,
    SUM(slots) AS "Total Slots"
FROM cd.bookings AS bks
WHERE bks.starttime >= '2012-09-01'
    AND bks.starttime < '2012-10-01'
GROUP BY facid
ORDER BY SUM(bks.slots);
```

###### Question 20: List the total slots booked per facility per month
```sql
SELECT
    facid,
    EXTRACT(MONTH FROM starttime) AS month,
    SUM(slots) AS "Total Slots"
FROM cd.bookings
WHERE EXTRACT(YEAR FROM starttime) = 2012
GROUP BY facid, EXTRACT(MONTH FROM starttime)
ORDER BY facid, month;
```

###### Question 21: Find the count of members who have made at least one booking
```sql
SELECT
    COUNT(DISTINCT memid)
FROM cd.bookings;
```

###### Question 22: List each member's first booking after September 1st 2012
```sql
SELECT
    mbs.surname,
    mbs.firstname,
    mbs.memid,
    MIN(bks.starttime) AS starttime
FROM cd.bookings AS bks
INNER JOIN cd.members AS mbs
    ON mbs.memid = bks.memid
WHERE bks.starttime >= '2012-09-01'
GROUP BY
    mbs.surname,
    mbs.firstname,
    mbs.memid
ORDER BY mbs.memid;
```

###### Question 23: Produce a list of member names, with each row containing the total member count
```sql
SELECT
    COUNT(*) OVER(),
    mbs.firstname,
    mbs.surname
FROM cd.members AS mbs
ORDER BY joindate;
```
###### Question 24: Produce a numbered list of members
```sql
SELECT
    ROW_NUMBER() OVER (ORDER BY joindate),
    mbs.firstname,
    mbs.surname
FROM cd.members AS mbs
ORDER BY mbs.joindate;
```
###### Question 25:
```sql
SELECT
    facid,
    total
FROM (
    SELECT
        bk.facid,
        SUM(bk.slots) AS total,
        RANK() OVER (ORDER BY SUM(bk.slots) DESC) AS rank
    FROM cd.bookings AS bk
    GROUP BY bk.facid
) AS ranked
WHERE rank = 1;
```
###### Question 26:
```sql
SELECT
    mbs.surname || ', ' || mbs.firstname AS name
FROM cd.members AS mbs;
```

###### Question 27:
```sql
SELECT
    memid,
    telephone
FROM cd.members
WHERE telephone ~ '[()]';
```

###### Question 28:
```sql
SELECT
    SUBSTR(mbs.surname, 1, 1) AS letter,
    COUNT(*) AS count
FROM cd.members AS mbs
GROUP BY SUBSTR(mbs.surname, 1, 1)
ORDER BY letter;
```







