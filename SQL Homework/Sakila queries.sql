-- Homework
-- 1a. Display the first and last names of all actors from the table `actor`.
use sakila;
SELECT first_name as 'First Name', last_name as 'Last Name' FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT CONCAT (first_name," ",last_name) AS WHOLENAME FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name FROM actor WHERE first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE "%gen%";

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT last_name , first_name  FROM actor 
	WHERE last_name LIKE '%li%';
    
-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country 
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a) Create a column in the table `actor` named `description` and use the data type `BLOB` 
ALTER table actor ADD COLUMN Description Blob AFTER last_update;

-- Delete the `description` column.
ALTER table actor DROP COLUMN Description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(last_name) FROM actor GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- do this only for names that are shared by at least two actors

SELECT last_name, count(last_name) FROM actor GROUP BY last_name
	HAVING COUNT(last_name)>1;
    
-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
-- Write a query to fix the record.
UPDATE actor SET first_name = 'HARPO' WHERE (first_name = 'GROUCHO' AND last_name = 'Williams');

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor SET first_name = 'GROUCHO' WHERE (first_name = 'HARPO' AND last_name = 'Williams');

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. 
-- Use the tables `staff` and `address`:
SELECT first_name, last_name, address_id
FROM address
INNER JOIN staff 
USING (address_id);

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
-- Use tables `staff` and `payment`.
SELECT staff_id, first_name, last_name, SUM(amount) FROM Payment
INNER JOIN staff
USING (staff_id)
WHERE payment_date >= '2005-08-01' AND
	payment_date < '2005-09-01'
GROUP BY staff_id;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.
SELECT title, COUNT(actor_id) as 'Total Actors' FROM film
INNER JOIN film_actor
USING (film_id)
GROUP BY film_id;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT title, COUNT(film_id) as 'Number in Inventory' from film
INNER JOIN inventory
USING (film_id)
WHERE title = 'Hunchback Impossible'
GROUP BY film_id;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT customer_id, first_name, last_name, FORMAT(SUM(amount), 2) as 'Total paid by customer' from customer
INNER JOIN payment
USING (customer_id)
GROUP BY customer_id
ORDER BY last_name;

-- 7a Use subqueries to display the titles of movies starting with the letters `K` and `Q` 
-- whose language is English.
SELECT title FROM film
WHERE language_id in
	(SELECT language_id 
	FROM language
	WHERE name = 'English' )
AND (title LIKE 'K%') OR (title LIKE 'Q%');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name FROM actor
WHERE actor_id in
	(SELECT actor_id FROM film_actor
	WHERE film_id in
		(SELECT film_id 
		FROM film
		WHERE title = 'Alone Trip' ));
        
-- 7c Use joins to retrieve all email addresses from Canadian customers.
SELECT first_name, last_name, email FROM customer
INNER JOIN address
ON address.address_id = customer.address_id
	INNER JOIN city
	ON city.city_id = address.city_id
		INNER JOIN country
		ON city.country_id = country.country_id
			WHERE country.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.
SELECT title, description, release_year FROM film
WHERE film_id in
	(SELECT film_id FROM film_category
	WHERE category_id in
		(SELECT category_id 
		FROM category
		WHERE name = 'Family' ));

-- 7e. Display the most frequently rented movies in descending order.
SELECT title, COUNT(rental_id) AS 'Times Rented' FROM rental
INNER JOIN inventory
ON rental.inventory_id = inventory.inventory_id
	INNER JOIN film
	ON inventory.film_id = film.film_id
		GROUP BY film.title
		ORDER BY `Times Rented` DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store.store_id, SUM(amount) as 'Amount per Store ($)' FROM store
	INNER JOIN staff
    on store.store_id = staff.store_id
		INNER JOIN payment
        on payment.staff_id = staff.staff_id
        GROUP BY store_id
        ORDER BY `Amount per Store ($)` DESC;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country FROM store
INNER JOIN address
ON store.address_id = address.address_id
	INNER JOIN city
    ON address.city_id = city.city_id
		INNER JOIN country
        ON city.country_id = country.country_id
        ORDER BY country;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name as 'Genre', sum(payment.amount) as 'Gross Revenue' FROM category
INNER JOIN film_category
ON (category.category_id = film_category.category_id)
	INNER JOIN inventory
    ON (film_category.film_id = inventory.film_id)
		INNER JOIN rental
        ON (inventory.inventory_id = rental.inventory_id)
			INNER JOIN payment
            ON (rental.rental_id = payment.rental_id)
            GROUP BY category.name
            ORDER BY `Gross Revenue` DESC
            LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Genre_Top_Revenue as
SELECT category.name as 'Genre', sum(payment.amount) as 'Gross Revenue' FROM category
INNER JOIN film_category
ON (category.category_id = film_category.category_id)
	INNER JOIN inventory
    ON (film_category.film_id = inventory.film_id)
		INNER JOIN rental
        ON (inventory.inventory_id = rental.inventory_id)
			INNER JOIN payment
            ON (rental.rental_id = payment.rental_id)
            GROUP BY category.name
            ORDER BY `Gross Revenue` DESC
            LIMIT 5;	

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM Genre_Top_Revenue;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW Genre_Top_Revenue;
	