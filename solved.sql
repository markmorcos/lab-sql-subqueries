-- 1.
SELECT COUNT(*) AS cnt
FROM inventory
JOIN film ON film.film_id = inventory.film_id
WHERE title = "Hunchback Impossible";

-- 2.
SELECT title
FROM film
WHERE length > (SELECT AVG(length) FROM film);

-- 3.
SELECT CONCAT(first_name, " ", last_name) AS actor
FROM actor
WHERE actor_id IN (
	SELECT actor_id
    FROM film_actor
    JOIN film ON film.film_id = film_actor.film_id
    WHERE title = "Alone Trip"
);

-- 4.
SELECT title FROM film_category
JOIN film ON film.film_id = film_category.film_id
JOIN category ON category.category_id = film_category.category_id
WHERE name = "Family";

-- 5.
SELECT customer_name, customer_email
FROM (
	SELECT country.country AS country_name, CONCAT(first_name, " ", last_name) as customer_name, email AS customer_email
    FROM customer
    JOIN address ON address.address_id = customer.address_id
    JOIN city ON city.city_id = address.city_id
    JOIN country ON country.country_id = city.country_id
) customers_with_address
WHERE country_name = "Canada";

-- 6.
WITH cte_acted_films_per_actors AS (
	SELECT actor.actor_id, COUNT(*) number_of_acted_films FROM film_actor
	JOIN actor ON actor.actor_id = film_actor.actor_id
	JOIN film ON film.film_id = film_actor.film_id
	GROUP BY actor.actor_id
)
SELECT title FROM film_actor
JOIN film ON film.film_id = film_actor.film_id
WHERE film_actor.actor_id = (
	SELECT actor_id FROM cte_acted_films_per_actors
    ORDER BY number_of_acted_films DESC
    LIMIT 1
);

-- 7.
WITH cte_profit_per_customer AS (
	SELECT customer_id, SUM(amount) AS profit
	FROM payment
	GROUP BY customer_id
)
SELECT film.title
FROM film
JOIN inventory ON inventory.film_id = film.film_id
JOIN rental ON rental.inventory_id = inventory.inventory_id
WHERE customer_id = (
	SELECT customer_id
    FROM cte_profit_per_customer
    ORDER BY profit DESC
    LIMIT 1
);

-- 8.
SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING total_amount_spent > (
	SELECT AVG(amount) AS total_amount
    FROM payment
    GROUP BY customer_id
    ORDER BY total_amount DESC
    LIMIT 1
);