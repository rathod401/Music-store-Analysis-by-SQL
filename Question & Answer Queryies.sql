/*1. Who is the senior most employee based on job title? */

SELECT * FROM EMPLOYEE
ORDER BY LEVELS DESC 
LIMIT 1

/* 2. Which countries have the most Invoices? */

SELECT BILLING_COUNTRY,COUNT(BILLING_COUNTRY) AS COUNTS
FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY COUNTS DESC4

/* 3. What are top 3 values of total invoice? */

SELECT TOTAL FROM INVOICE
ORDER BY TOTAL DESC 
LIMIT 3

/* 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals */

SELECT DISTINCT
	BILLING_CITY,
	SUM(TOTAL) OVER (PARTITION BY BILLING_CITY ) AS TOTAL_INVOICE
FROM INVOICE
ORDER BY TOTAL_INVOICE DESC

/* 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money? */

SELECT
	C.FIRST_NAME,
	C.CUSTOMER_ID,
	SUM(I.TOTAL) AS TOTAL
FROM INVOICE I
JOIN CUSTOMER C 
ON C.CUSTOMER_ID = I.CUSTOMER_ID
GROUP BY C.CUSTOMER_ID
ORDER BY TOTAL DESC

/*6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A? */

SELECT DISTINCT
    C.EMAIL,
    C.FIRST_NAME,
    C.LAST_NAME
FROM
    CUSTOMER C
    JOIN INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
    JOIN INVOICE_LINE IL ON I.INVOICE_ID = IL.INVOICE_ID
    JOIN TRACK T ON IL.TRACK_ID = T.TRACK_ID
    JOIN GENRE G ON T.GENRE_ID = G.GENRE_ID
WHERE
    G.NAME = 'Rock'
ORDER BY
    C.EMAIL;

--------ALTERNATIVE CODE--------

SELECT DISTINCT
	EMAIL,FIRST_NAME,LAST_NAME
	FROM CUSTOMER C
	JOIN INVOICE I ON C.CUSTOMER_ID = I.CUSTOMER_ID
	JOIN INVOICE_LINE I2 ON I.INVOICE_ID = I2.INVOICE_ID
WHERE I2.TRACK_ID IN (
		SELECT TRACK_ID FROM TRACK T
		JOIN GENRE G ON T.GENRE_ID = G.GENRE_ID
		WHERE G.NAME LIKE 'Rock'
	)
ORDER BY EMAIL

/*7.Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands? */

SELECT DISTINCT
	AR.NAME,
	AR.ARTIST_ID,
	COUNT(AR.ARTIST_ID) AS TOTAL_SONGS
FROM
	ARTIST AR
	JOIN ALBUM AL ON AL.ARTIST_ID = AR.ARTIST_ID
	JOIN TRACK ON TRACK.ALBUM_ID = AL.ALBUM_ID
	JOIN GENRE ON GENRE.GENRE_ID = TRACK.GENRE_ID
WHERE GENRE.NAME = 'Rock'
GROUP BY AR.ARTIST_ID
ORDER BY TOTAL_SONGS DESC

/*8.Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first*/

SELECT NAME, MILLISECONDS
FROM TRACK
WHERE
	MILLISECONDS > (SELECT AVG(MILLISECONDS) FROM TRACK)
ORDER BY MILLISECONDS DESC

/*9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent ?
*/
SELECT
    c.First_Name,
    c.Last_Name,
    a.Name AS ArtistName,
    SUM(il.Quantity * il.Unit_Price) AS TotalSpent
FROM Customer c
JOIN Invoice i ON c.customer_id = i.Customer_Id
JOIN Invoice_Line il ON i.Invoice_Id = il.Invoice_Id
JOIN Track t ON il.Track_Id = t.Track_Id
JOIN Album alb ON t.Album_Id = alb.Album_Id
JOIN Artist a ON alb.Artist_Id = a.Artist_Id
GROUP BY c.First_Name, c.Last_Name, a.Name;

/* 10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres ? */

WITH GenreRank AS (
  SELECT c.Country, g.Name AS Genre, COUNT(il.invoice_line_id) AS PurchaseCount,
  ROW_NUMBER() OVER (PARTITION BY c.Country ORDER BY COUNT(il.Invoice_Line_Id) DESC) as Row_num
  FROM Customer c
  JOIN Invoice i ON c.Customer_Id = i.Customer_Id
  JOIN Invoice_Line il ON i.Invoice_Id = il.Invoice_Id
  JOIN Track t ON il.Track_Id = t.Track_Id
  JOIN Genre g ON t.Genre_Id = g.Genre_Id
  GROUP BY c.Country, g.Name
)
SELECT *
FROM GenreRank
WHERE  Row_num <= 1;

/* 11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount? */

WITH CTE AS (
		SELECT C.CUSTOMER_ID, FIRST_NAME, LAST_NAME, BILLING_COUNTRY, SUM(TOTAL) AS TOTAL_SPEND,
		ROW_NUMBER() OVER ( PARTITION BY BILLING_COUNTRY ORDER BY SUM(TOTAL) ASC) AS RANK
		FROM INVOICE I
		JOIN CUSTOMER C ON C.CUSTOMER_ID = I.CUSTOMER_ID
		GROUP BY 1, 2, 3, 4
		ORDER BY 4 ASC, 5 DESC
	)
SELECT * FROM CTE
WHERE RANK <= 1
