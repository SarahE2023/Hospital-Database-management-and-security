
DROP DATABASE IF EXISTS FoodserviceDB;

--Create Database FoodServiceDB
create Database FoodserviceDB;
Go

Use FoodServiceDB;

--Create Tables using the Import flat files Task 
--Create ERD diagram using Uploaded Tables


-- Selecting Medium Prices of open Area Mexican Restaurant

Select R.Name, R.price, R.area, RC.Cuisine
From Restaurant as R Full join Restaurant_Cuisines as RC
on R.Restaurant_ID = RC.Restaurant_ID
where R.price = 'Medium' and R.Area= 'Open' and RC.Cuisine= 'Mexican'; 

-- Selecting Mexican and Italian Restaurants who have Overall rating above 1

--Option A
-- Step one Selecting Mexican Restaurants with Overall ratings above 1

Select Count(RT.Restaurant_ID) as Total_number_of_mexican_restaurants_with_overall_ratings_of_1
from Ratings as RT left join Restaurant_Cuisines as RC
on RT.Restaurant_ID = RC.Restaurant_ID
where RT.Overall_Rating = 1 and RC.Cuisine= 'Mexican';

--Step two Selecting Italian Restaurants with Overall ratings above 1
Select Count(RT.Restaurant_ID) as Total_number_of_italian_restaurants_with_overall_ratings_of_1 
from Ratings as RT left join Restaurant_Cuisines as RC
on RT.Restaurant_ID = RC.Restaurant_ID
where RT.Overall_Rating = 1 and RC.Cuisine= 'Italian'; 

--Option B
--Converting Cuisine Column to bit data type and conducting a full Join on both tables
Select 
    SUM(Case When RC.Cuisine = 'Mexican' Then 1 Else 0 End) AS Total_number_of_mexican_restaurants_with_overall_ratings_of_1,
    SUM(Case When RC.Cuisine = 'Italian' Then 1 Else 0 End) As Total_number_of_italian_restaurants_with_overall_ratings_of_1
From [Ratings ] As RT
Left Join [Restaurant_Cuisines ] As RC On RT.Restaurant_ID = RC.Restaurant_ID
Where RT.Overall_Rating = 1;


-- Calculate Average age of cusumers with 0 rating on the Service_rating Column
Select AVG(C.Age) as Average_Consumer_age
From [Consumers ] as C left join [Ratings ] as RT
on C.Consumer_ID=RT.Consumer_ID
where RT.Service_Rating=0;

-- Selecting Restaurants ranked by the youngest consumer and sorting them based on food_rating from high to low
Select R.Name, RT.Food_Rating
from Restaurant as R join Ratings as RT 
ON R.Restaurant_ID = RT.Restaurant_ID join Consumers as C
ON RT.Consumer_ID= C.Consumer_ID 
where C.Age = (Select MIN(Age) From Consumers)
Order by RT.Food_Rating DESC;

CREATE PROCEDURE UspUpdateServiceRatingWithParking
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Ratings 
    SET Service_Rating = 2
    FROM Ratings as RT
    INNER JOIN Restaurant R ON RT.Restaurant_ID = R.Restaurant_ID
    WHERE R.Parking IN ('yes', 'public');
END;

Exec UspUpdateServiceRatingWithParking;

Select RT.Service_Rating, R.Parking
from Ratings as RT INNER JOIN Restaurant as R 
ON RT.Restaurant_ID = R.Restaurant_ID
    WHERE R.Parking IN ('yes', 'public');


-- Query containing the nested Query "IN"
-- Find all consumers who have rated restaurants with an overall rating of 1
SELECT DISTINCT c.Consumer_id, c.City
FROM [Consumers ] as C
WHERE C.Consumer_ID IN (
    SELECT RT.Consumer_ID
    FROM [Ratings ] as RT
    WHERE RT.Overall_Rating = 1
);

-- Query containing the nested Query "EXISTS"
-- Find all consumers who have given ratings for restaurants with a price level of 'high'
select distinct C.consumer_id, C.city
from [Consumers ]  as C
where exists (
    select 1
    from [Ratings ] as RT
    join Restaurant as R on RT.restaurant_id = R.restaurant_id
    where RT.consumer_id = C.consumer_id
    and R.price = 'high'
);



--Query to create System Function
--Function to calculate the average overall rating of restuarants 
CREATE FUNCTION dbo.GetAverageOverallRating()
RETURNS FLOAT
AS
BEGIN
    DECLARE @AverageRating FLOAT;

    SELECT @AverageRating = AVG(Overall_Rating)
    FROM Ratings;

    RETURN @AverageRating;
END;

SELECT dbo.GetAverageOverallRating() AS AverageRating;

-- Query containing GroupBy and Orderby
-- Find the cities with the highest average overall rating for restaurants
SELECT r.City, Max (ra.Overall_Rating) AS highestRating
FROM Restaurant r
JOIN [Ratings ] ra ON r.Restaurant_id = ra.Restaurant_id
GROUP BY r.City
ORDER BY highestRating DESC;

-- Other queries 
-- Query that lists how many restuarant are in each city 
SELECT City, COUNT(*) AS No_Restaurants
FROM Restaurant
GROUP BY City
ORDER BY No_Restaurants DESC;

-- Restuarants with the worst and best food service according to customers ratings
-- Worst Ratings according to Food Rating
SELECT R.Name, R.State, R.Country, RT.Food_Rating
FROM [Ratings ] as RT inner join Restaurant as R on RT.Restaurant_ID = R.Restaurant_ID
WHERE RT.Food_Rating = 0;
 

-- other queries  
-- Worst Restuarants according to Service Rating
SELECT R.Name, R.State, R.Country, RT.Service_Rating
FROM [Ratings ] as RT inner join Restaurant as R on RT.Restaurant_ID = R.Restaurant_ID
WHERE RT.Service_Rating = 0;

--Best Restuarants According to Food Ratings
SELECT R.Name, R.State, R.Country, RT.Food_Rating
FROM [Ratings ] as RT inner join Restaurant as R on RT.Restaurant_ID = R.Restaurant_ID
WHERE RT.Food_Rating = 2;

--Best Restuarants According to Service Ratings 
SELECT R.Name, R.State, R.Country, RT.Service_Rating
FROM [Ratings ] as RT inner join Restaurant as R on RT.Restaurant_ID = R.Restaurant_ID
WHERE RT.Service_Rating = 2;

--Query to show which restuarants allow smoking on its premises 
SELECT DISTINCT R.Restaurant_ID, R.Name, ( R.city + ' '+ R.State + ' '+ R.Country) As Restaurant_Address
FROM Restaurant as R
INNER JOIN [Ratings ] as RT ON R.Restaurant_ID = RT.Restaurant_ID	
INNER JOIN [Consumers ] as C ON RT.Consumer_ID = C.Consumer_ID
WHERE R.Smoking_Allowed = 'Yes';

-- Cusines served at the Top Restuarants based on overall Rating 
SELECT C.Cuisine, R.Name AS Top_Restaurant, Overall_Rating AS TopRatings
FROM Restaurant as R
JOIN [Restaurant_Cuisines ] as C ON R.Restaurant_ID = C.Restaurant_ID
JOIN [Ratings ] as RT ON R.Restaurant_ID = RT.Restaurant_ID
ORDER BY Overall_Rating Desc;

-- Average Ratings of each cuisine 
SELECT Cuisine, AVG(Overall_Rating) AS AverageRatings
FROM Restaurant as R
JOIN [Restaurant_Cuisines ] as C ON R.Restaurant_ID = C.Restaurant_ID
JOIN [Ratings ] RT ON R.Restaurant_ID = RT.Restaurant_ID
GROUP BY Cuisine
Order by AverageRatings Desc;

-- Top 10 consumers with the most reviews
SELECT TOP 10 Consumer_ID, COUNT(*) AS Review_Count
FROM [Ratings]
GROUP BY Consumer_ID
ORDER BY Review_Count DESC;

-- Percentage of smokers in each city
SELECT City, 
       SUM(CASE WHEN CONVERT(bit, Smoker) = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS Smoking_Percentage
FROM Consumers
GROUP BY City;







