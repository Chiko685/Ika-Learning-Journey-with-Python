
--select 
--show_id,
--count(*) 
--from netflix 
--group by 1 
--having count(*) > 1 -->> checking if show_id has duplicates
--show_id is unique so can become a primary key


--1. 	create 4 new tables for listed-in, director, country, and cast
--create table separated director, so in show _id there will be duplicates for director 1 and director 2
SELECT
    n.show_id,
    -- UNNEST() expands the array into separate rows
    -- STRING_TO_ARRAY() converts the comma-separated string into a text array
    TRIM(UNNEST(STRING_TO_ARRAY(n.director, ','))) AS director
    into netflix_directors
FROM
    netflix n;

--create separated table for column listed-in 
SELECT                                                            
    n.show_id,                                                    
    TRIM(UNNEST(STRING_TO_ARRAY(n.listed_in, ','))) AS genre   
    into netflix_genre                                        
FROM                                                              
    netflix n; 

--create separated table for column cast                  
SELECT                                                                                                                            
    n.show_id,                                                
    TRIM(UNNEST(STRING_TO_ARRAY(n.cast, ','))) AS cast    
    into netflix_cast  
FROM                                                            
    netflix n;  

--create separated table for column country                   
SELECT                                                          
    n.show_id,                                                
    TRIM(UNNEST(STRING_TO_ARRAY(n.country, ','))) AS country    
    into netflix_country                                          
FROM                                                            
    netflix n;  

---------------------------------------------------------------------
--2. populate missing values and fill it with new value
--example missing value in country, so we can search for the director and fill 'country' base on the country movie's in other movie
insert into netflix_country 
select show_id, x.country
from netflix n
inner join (
select n.director, nc.country
from netflix_country nc --fill into netflix_country that already created earlier 
inner join netflix n on n.show_id = nc.show_id
group by n.director, nc.country
order by n.director) x on x.director = n.director
where n.country is null 


select *
from netflix
--where show_id = 's3'

----------------------------------------------------------------------
with cte as (
select *
,row_number() over(partition by title, type order by show_id) as rn 
from netflix 
)
select show_id, type, title, 
(date_added::date) as date_added, 
(release_year::text) as release_year,rating,
case 
	when duration is null then rating 
	else duration  
end as duration 
, description
into netflix_fix
from cte


-----------------------------------------------------------------------
-- NETFLIX DATA IS CLEAN AND WE CREATE A NEW TABLE NAME 'netflix_fix'
--*/1. QUESTION 1 =  for each director count the number of movies and tv shows created by them in separated columns 
--for directors who have created tv shows and movie both */

select nd.director
,count(distinct case when nf.type = 'Movie' then nf.show_id
end) as number_of_movie
,count(distinct case when nf.type = 'TV Show' then nf.show_id
end) as number_of_tvshow
from netflix_fix nf 
inner join netflix_directors nd on nd.show_id=nf.show_id
group by 1
having count(distinct nf.type) > 1
-----------------------------------------------------------------------

--*/QUESTION 2 = WHICH COUNTRY HAS HIGHEST NUMBER OF COMEDY MOVIES 
select 
nc.country as country,
ng.genre,
count(case when ng.genre = 'Comedies' then 1 else 0 
end) as number_of_comedies
from netflix_genre ng  
inner join netflix_country nc on nc.show_id = ng.show_id
where ng.genre = 'Comedies'
group by 1,2
order by number_of_comedies desc
----------------------------------------------------------------------
--*/	QUESTION 3 FOR EACH YEAR (AS PER DATE ADDED TO NETFLIX) WHICH DIRECTOR HAS MAXIMUM NUMBER OF MOVIES RELEASED

select 
extract(year from n.date_added::date) as year_added, nd.director, count(n.type) as no_movies
from netflix n
inner join netflix_directors nd on n.show_id=nd.show_id
where n.type = 'Movie'
group by 1, 2
order by 3 desc 
---
--CARA LAINNYA

with cte as (
select 
nd.director, extract(year from n.date_added::date) as year_added, count(distinct n.show_id) as no_movies
from netflix n
inner join netflix_directors nd on n.show_id=nd.show_id
where n.type = 'Movie'
group by 1, 2
order by 3 desc 
),
cte2 as (
select *, row_number() over(partition by year_added order by no_movies desc, director) as ranking
from cte
order by year_added
)
select *  
from cte2
where ranking = 1
--so we can conclude that Rajiv Chilaka released 17 movies with rank 1 in 2021

-------------------------------------------------------------------------
--*/QUESTION 4 WHAT IS AVERAGE DURATION OF MOVIES IN EACH GENRE 
select  
	ng.genre,
	avg(replace(duration, 'min', '')::integer) as avg_duration
from netflix n
inner join netflix_genre ng on n.show_id = ng.show_id
where n.type = 'Movie'
group by 1

-------------------------------------------------------------------------
--*/QUESTION 5 FIND THE LIST OF DIRECTORS WHO HAVE CREATED HORROR AND COMEDY MOVIES BOTH.
--DISPLAY DIRECTOR NAMES ALONG WITH NUMBER OF COMEDY AND HORROR MOVIES DIRECTED BY THEM 
select 
	nd.director, 
	count(ng.genre) as number_HC_movies,
	n.type 
from netflix n 
inner join netflix_genre ng 
on n.show_id = ng.show_id
inner join netflix_directors nd
on n.show_id = nd.show_id
where n.type = 'Movie'
	and ng.genre in ('Horror Movies','Comedies') 
group by 1,3
order by 1 asc 

--IF WE WANT TO COUNT EACH HORROR AND COMEDY THE WE CAN USE CASE WHEN 
select 
	nd.director, 
	count(distinct case when ng.genre='Horror Movies' then n.show_id end) as number_horror_movies,
	count(distinct case when ng.genre='Comedies' then n.show_id end) as number_comedies_movies 
from netflix n 
inner join netflix_genre ng 
on n.show_id = ng.show_id
inner join netflix_directors nd
on n.show_id = nd.show_id
where n.type = 'Movie'
	and ng.genre in ('Horror Movies','Comedies') 
group by 1
having count(distinct ng.genre) = 2











