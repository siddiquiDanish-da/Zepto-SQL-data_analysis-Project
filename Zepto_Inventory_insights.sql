DROP TABLE IF EXISTS zepto;

	CREATE TABLE zepto (
	sku_id SERIAL PRIMARY KEY,
	Category VARCHAR(120),
	name VARCHAR(150) NOT NULL,
	mrp NUMERIC(8,2),
	discountPercent NUMERIC(5,2),
	availableQuantity INTEGER,
	discountedSellingPrice NUMERIC(8,2),
	weightInGms INTEGER,
	outOfStock BOOLEAN,
	quantity INTEGER
	);

												--Data Exploration--
	--Check data we loaded is present or not --
	SELECT COUNT(*) FROM zepto;  --OR
	                                  SELECT * FROM zepto;

	--Now looking for null values--
		SELECT * FROM zepto
		WHERE Category IS  NULL
		OR
		name IS  NULL
		OR
		mrp IS  NULL
		OR
		discountPercent IS  NULL
		OR
		availableQuantity IS  NULL
		OR
		discountedSellingPrice IS  NULL
		OR
		weightInGms IS  NULL
		OR
		outOfStock IS  NULL
		OR
		quantity IS  NULL;

	--	NOW FIND UNIQUE Category--
		SELECT DISTINCT Category 
		FROM zepto 
		ORDER BY Category;
		
    -- now find product in stock vs in stock --
		SELECT outOfStock,COUNT(sku_id) FROM zepto
		GROUP BY outOfStock;
		
	--PRODUCT name present more then 1 time (Multiple times)--
		SELECT name, COUNT(sku_id)as "Number of SKUs"
		FROM zepto
		GROUP BY name
		HAVING COUNT(sku_id)>1
		ORDER BY COUNT(sku_id) DESC;

													--DATA CLEANING--
   				--Check product where price might be 0--
				   SELECT * FROM zepto WHERE mrp =0 OR discountedSellingPrice =0;

	--now we r getting 1 product with mrp 0 so we need to delete it .
	DELETE FROM zepto WHERE mrp =0;
	
	-- now we see mrp is in paise so now convert paise into rupee--
	UPDATE zepto
	SET mrp = mrp/100.0,
	discountedSellingPrice =discountedSellingPrice/100.0;
	
	--now to check wether paise is converted into rupee.
	SELECT mrp ,discountedSellingPrice from zepto;


								--Business Insights --
-- Q1.Find the top 10 best value Products based on the discounted percentage.
	SELECT DISTINCT name , mrp ,discountPercent 
	from zepto
	ORDER BY discountPercent DESC
	LIMIT 10;
	
-- Q2.What are the Products with High MRP but Out of Stock
    SELECT  DISTINCT name ,mrp 
	FROM zepto 
	WHERE outOfStock=TRUE AND 
	mrp>300   -- Assuming high MRP means greater than 300
	ORDER BY mrp DESC;
	
-- Q3.Calculate Estimated Revenue for each category
	SELECT category,
	SUM(discountedSellingPrice * availableQuantity) AS total_revenue
	FROM zepto 
	GROUP BY category
	ORDER BY total_revenue;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%
	SELECT DISTINCT name ,mrp ,discountPercent
	FROM zepto
	WHERE mrp>500 AND discountPercent<10
	ORDER BY mrp DESC;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.
	SELECT category ,
	ROUND (AVG(discountPercent),2) AS avg_discount_percent
	FROM zepto 
	GROUP BY category
	ORDER BY  avg_discount_percent DESC 
	LIMIT 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
	SELECT DISTINCT name ,weightInGms ,discountedSellingPrice,
	ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
	FROM zepto
	WHERE weightInGms >=100
	ORDER BY price_per_gram;
	
-- Q7. Group the products into categories like Low, Medium, Bulk.
	SELECT DISTINCT name ,weightInGms ,
	CASE WHEN weightInGms <1000 THEN 'Low'
	 WHEN weightInGms <5000 THEN 'Medium'
	 ELSE 'Bulk'
	 END AS weight_Category FROM zepto;
	 
-- Q8. What is the total inventory Weight per Category.
		SELECT category ,
		SUM(weightInGms * availableQuantity) AS total_weight
		FROM zepto
		GROUP BY category
		ORDER BY total_weight;