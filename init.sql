CREATE DATABASE IF NOT EXISTS `GGG`;
USE `GGG`;
CREATE TABLE `GGG` (
  `id` VARCHAR(20) NOT NULL,
  `studentId` VARCHAR(20) NOT NULL,
  `name` VARCHAR(20) NOT NULL,
  `birthday` DATE NOT NULL,
  PRIMARY KEY (`id`)
);

INSERT INTO `GGG`
VALUES("1", "10346000", "Vincent", "1996-01-01");

INSERT INTO `GGG`
VALUES("9", "10346789", "Eric", "2004-01-01");

INSERT INTO `GGG`
VALUES("91", "1034679", "000", "2008-01-01");

-- Below you can just add your own SQL order to create the table in the database Team5DBFinal.
-- For example, you can comment below bitch table if you want
USE Team5DBFinal;
/*CREATE TABLE bitch (
  fuck VARCHAR(20) NOT NULL,
  PRIMARY KEY(fuck)
);
INSERT INTO bitch
VALUES("NingQung");

INSERT INTO bitch
VALUES("GJ");

INSERT INTO bitch
VALUES("KJC");

INSERT INTO bitch
VALUES("AKinom");

INSERT INTO bitch
VALUES("Notpotato");*/

-- table part below
CREATE TABLE IF NOT EXISTS User(
	user_ID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    account VARCHAR(50) NOT NULL UNIQUE,
    password CHAR(60) NOT NULL, -- password hash at frontend then pass in
    enrollment_date DATE, -- auto fill in by trigger "user_age_enro"
    address VARCHAR(120) NOT NULL,
    email_address VARCHAR(80) NOT NULL,
	birthdate DATE NOT NULL,
    age INT -- auto fill in by trigger "user_age_enro"
    -- phone_number varchar(18), in another table "user_phone"
);

CREATE TABLE IF NOT EXISTS user_phone(
	user_ID INT NOT NULL,
    phone_number VARCHAR(18) NOT NULL,-- phone number storage here
    PRIMARY KEY(user_ID,phone_number),
    FOREIGN KEY(user_ID) REFERENCES User(user_ID) ON DELETE CASCADE
    -- when delete user, the relate phone_num will be gone
);

CREATE TABLE IF NOT EXISTS paying_info(
	payment_ID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    bank_account VARCHAR(25) NOT NULL,
    bank_num VARCHAR(30) NOT NULL,
    delivering_address VARCHAR(120) NOT NULL,
    total_price DECIMAL(8,2) DEFAULT 0,
    time_slot TIMESTAMP -- front end get time and pass in
);

CREATE TABLE IF NOT EXISTS product(
	product_ID INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(80) NOT NULL,
    discount DOUBLE DEFAULT 1, -- front end decide value and pass in
    stock INT DEFAULT 0, -- auto decrease with trigger "product_stock" when the order is placed
    price DECIMAL(8,2) DEFAULT 0,
    tags VARCHAR(80),
    sales INT DEFAULT 0, -- auto increase with trigger "product_stock" when the order is placed
    likes INT DEFAULT 0, -- front end pass if anyone likes then +1, or if cancel then -1
    avg_score DOUBLE -- front end pass score 
    -- auto update with trigger "product_score" when score is added
);

CREATE TABLE IF NOT EXISTS orders(
	order_ID INT NOT NULL AUTO_INCREMENT,
    user_ID INT NOT NULL,
    status INT DEFAULT 0,
	PRIMARY KEY(user_ID,order_ID),
    FOREIGN KEY(user_ID) REFERENCES User(user_ID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS search_history(
	user_ID INT NOT NULL,
	keyword VARCHAR(80),
    PRIMARY KEY(user_ID,keyword),
    FOREIGN KEY(user_ID) REFERENCES User(user_ID) ON DELETE CASCADE
	-- if user got remove, delete whole history to that user
);

-- the paying table denotes the relationship between the order and the paying information about the order
CREATE TABLE IF NOT EXISTS  paying(
    order_ID INT NOT NULL,
    payment_ID INT NOT NULL,
    PRIMARY KEY(order_ID, payment_ID),
    FOREIGN KEY(order_ID) REFERENCES orders(user_ID) ON DELETE CASCADE,
    FOREIGN KEY(payment_ID) REFERENCES paying_info(payment_ID) ON DELETE CASCADE
);

-- the likes table denotes the like from the user for specifing product
CREATE TABLE IF NOT EXISTS  liking_list(
    user_ID INT NOT NULL,
    product_ID INT NOT NULL,
    PRIMARY KEY(user_ID, product_ID),
    FOREIGN KEY(user_ID) REFERENCES User(user_ID) ON DELETE CASCADE,
    FOREIGN KEY(product_ID) REFERENCES product(product_ID) ON DELETE CASCADE
);

-- the cart_item table record the detail for each product from every shopping cart 
CREATE TABLE IF NOT EXISTS  cart_item(
    cart_ID INT NOT NULL,
    product_ID INT NOT NULL,
    quantity INT NOT NULL,
    prices DECIMAL(8,2),
    PRIMARY KEY(cart_ID, product_ID),
    FOREIGN KEY(cart_ID) REFERENCES User(user_ID) ON DELETE CASCADE,
    FOREIGN KEY(product_ID) REFERENCES product(product_ID) ON DELETE CASCADE
);

-- the order_item table record the detail for each product from every order 
CREATE TABLE IF NOT EXISTS  order_item(
    order_ID INT NOT NULL,
    product_ID INT NOT NULL,
    quantity INT NOT NULL,
    prices DECIMAL(8,2),
    PRIMARY KEY(order_ID, product_ID),
    FOREIGN KEY(order_ID) REFERENCES orders(order_ID) ON DELETE CASCADE,
    FOREIGN KEY(product_ID) REFERENCES product(product_ID) ON DELETE CASCADE
);

INSERT INTO User
VALUES(-1,'admin','admin','1000-01-10','0','0','1000-01-10',0);



-- trigger part below
-- user_age_enro:
DELIMITER $$
CREATE TRIGGER user_age_enro
BEFORE INSERT ON User
FOR EACH ROW
BEGIN
	SET NEW.enrollment_date=now();
	IF(NEW.age=0)
		THEN SET NEW.age=0;
	ELSE
		SET NEW.age=TIMESTAMPDIFF(YEAR,NEW.birthdate,curdate());
	END IF;
END;
$$
DELIMITER ;


-- product_stock:
DELIMITER $$
CREATE TRIGGER product_stock
AFTER INSERT ON order_item
FOR EACH ROW
BEGIN
	SET @sal=0;
    SELECT quantity INTO @sal FROM
    order_item NATURAL JOIN product AS op
    WHERE op.product_ID=NEW.product_ID;
    UPDATE product
    SET stock=stock-@sal
    WHERE product.product_ID=NEW.product_ID;
    
    UPDATE product
    SET sales=sales+@sal
    WHERE product.product_ID=NEW.product_ID;
END;
$$
DELIMITER ;

-- avg_score:
/*DELIMITER $$
create trigger avg_score
after insert on products
for each row
begin
	--todo
end;
$$
DELIMITER ;*/


-- test data
-- INSERT INTO `User` VALUES("91", "1034679", "000", "2008-01-01", "123456", "123456", "2008-01-06", "5");

