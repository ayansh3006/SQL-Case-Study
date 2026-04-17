

Drop table if exists sales;
Drop table if exists customers;
Drop table if exists products;
Drop table if exists city;

Create table city
(
    city_id INT PRIMARY KEY,
	city_name VARCHAR(20),
	population BIGNIT,
	esimates_rent FLOAT,
	city_rank INT
	
);


Create table sales
(
    sales_id INT PRIMARY KEY,
	sales_date  date,
	product_id int,
	total float
	rating int,
	CONSTRAINT fk_products FOREIGN KEY (product_id) REFERENCES products(products_id) ,
	CONSTRAINT fk_custom FOREIGN KEY ()
)
