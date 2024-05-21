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
CREATE DATABASE IF NOT EXISTS `Team5DBFinal`;
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
    PRIMARY KEY(order_ID, user_ID),
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

-- the liking_list table denotes the liking from the user for specifing product
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

DELIMITER $$
CREATE PROCEDURE RegisterMember (account VARCHAR(50), password  CHAR(60), enrollment_date DATE, address VARCHAR(120), email_address VARCHAR(80), birthdate DATE)
 BEGIN
	INSERT INTO User (account, password, enrollment_date, address, email_address, birthdate) 
	VALUES(account, password, enrollment_date, address, email_address, birthdate); 
 END;
$$
DELIMITER ;

-- CALL RegisterMember ('faker','lck666777','2024-05-19','666777','666777@gmail.com','9999-04-25');

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

INSERT INTO User VALUES(-1,'admin','admin','1000-01-10','0','0','1000-01-10',0);
INSERT INTO User (account, password, enrollment_date, address, email_address, birthdate) VALUES('amber','qqq123','2024-05-17','123','123@gmail.com','2002-05-10');
INSERT INTO User (account, password, enrollment_date, address, email_address, birthdate) VALUES('brown','www456','2024-05-17','456','456@yahoo.com.tw','2005-08-17');
INSERT INTO User (account, password, enrollment_date, address, email_address, birthdate) VALUES('cindy','lpl999','2024-05-17','999','999@gapps.ntnu.edu.tw','1999-02-19');
INSERT INTO User (account, password, enrollment_date, address, email_address, birthdate) VALUES('youma','lck777','2024-05-17','777','777@gmail.com','1995-04-25');
INSERT INTO User (account, password, enrollment_date, address, email_address, birthdate) VALUES('elon','elan456','2024-05-17','elon','elon@gmail.com','1900-08-17');

INSERT INTO user_phone VALUES(1,'0987563258');
INSERT INTO user_phone VALUES(2,'0912345678');
INSERT INTO user_phone VALUES(3,'0951113355');
INSERT INTO user_phone VALUES(4,'0945678139');
INSERT INTO user_phone VALUES(5,'0945337788');

INSERT INTO product (product_name, discount, stock, price, tags, sales, likes, avg_score) VALUES('pen'    ,'1','1000','100','pencil','50',0,0);
INSERT INTO product (product_name, discount, stock, price, tags, sales, likes, avg_score) VALUES('eraser' ,'1','1000','50','eraser','65',0,0);
INSERT INTO product (product_name, discount, stock, price, tags, sales, likes, avg_score) VALUES('ruler'  ,'1','600','75','ruler','110',0,0);
INSERT INTO product (product_name, discount, stock, price, tags, sales, likes, avg_score) VALUES('paper'  ,'1','1000','1','paper','1000',0,0);
INSERT INTO product (product_name, discount, stock, price, tags, sales, likes, avg_score) VALUES('magzine','1','10000','150','book','40',0,0);

INSERT INTO cart_item VALUES('1','1','10','100');
INSERT INTO cart_item VALUES('1','4','10','1');
INSERT INTO cart_item VALUES('1','5','10','150');
INSERT INTO cart_item VALUES('3','3','10','75');
INSERT INTO cart_item VALUES('3','2','10','50');

INSERT INTO liking_list VALUES('3','2');
INSERT INTO liking_list VALUES('2','1');
INSERT INTO liking_list VALUES('5','4');
INSERT INTO liking_list VALUES('5','5');
INSERT INTO liking_list VALUES('1','3');

INSERT INTO orders VALUES('1','3','0');
INSERT INTO orders VALUES('2','5','0');
INSERT INTO orders VALUES('3','4','0');
INSERT INTO orders VALUES('4','1','0');
INSERT INTO orders VALUES('5','2','0');

INSERT INTO order_item VALUES('5','2','10','50');
INSERT INTO order_item VALUES('4','3','10','75');
INSERT INTO order_item VALUES('2','1','10','100');
INSERT INTO order_item VALUES('3','4','10','1');
INSERT INTO order_item VALUES('1','5','10','150');

INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('3','123','777','10','2024-05-19');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('4','456','123','750','2024-05-19');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('5','789','456','500','2024-05-19');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('1','963','999','1500','2024-05-19');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('2','258','elon','1000','2024-05-19');

INSERT INTO paying VALUES('3','1');
INSERT INTO paying VALUES('4','2');
INSERT INTO paying VALUES('5','3');
INSERT INTO paying VALUES('1','4');
INSERT INTO paying VALUES('2','5');

INSERT INTO search_history VALUES('1','pen');
INSERT INTO search_history VALUES('1','ruler');
INSERT INTO search_history VALUES('2','pen');
INSERT INTO search_history VALUES('2','paper');
INSERT INTO search_history VALUES('4','magzine');


