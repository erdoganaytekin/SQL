/* Do the following exercises, using the data model.

     a) Create a database named "Manufacturer"

     b) Create the tables in the database.

     c) Define table constraints.
*/
CREATE DATABASE Manufacturer;

USE Manufacturer;

CREATE TABLE Product (
  prod_id INT PRIMARY KEY,
  prod_name VARCHAR(200),
  quantity INT
);

CREATE TABLE Supplier (
  supp_id INT PRIMARY KEY,
  supp_name VARCHAR(200),
  supp_location VARCHAR(200),
  supp_country VARCHAR(200),
  is_active BIT
);

CREATE TABLE Component (
  comp_id INT PRIMARY KEY,
  comp_name VARCHAR(200),
  description VARCHAR(200),
  quantity_comp INT
);

CREATE TABLE ProdComp (
  prod_id INT,
  comp_id INT,
  FOREIGN KEY (prod_id) REFERENCES Product (prod_id),
  FOREIGN KEY (comp_id) REFERENCES Component (comp_id),
  PRIMARY KEY (prod_id, comp_id)
);

CREATE TABLE CompSupp (
  comp_id INT,
  supp_id INT,
  order_date DATE,
  quantity INT,
  FOREIGN KEY (comp_id) REFERENCES Component (comp_id),
  FOREIGN KEY (supp_id) REFERENCES Supplier (supp_id),
  PRIMARY KEY (comp_id, supp_id)
);


ALTER TABLE Product
ADD CONSTRAINT non_negative_quantity CHECK (quantity >= 0);

ALTER TABLE Component
ADD CONSTRAINT non_negative_quantity_comp CHECK (quantity_comp >= 0);

ALTER TABLE Supplier
ADD CONSTRAINT is_active_only CHECK (is_active IN (0, 1));

ALTER TABLE CompSupp
ADD CONSTRAINT positive_quantity CHECK (quantity > 0);


select * from Product
select * from Supplier