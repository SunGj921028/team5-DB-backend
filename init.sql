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
CREATE TABLE IF NOT EXISTS user(
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
    FOREIGN KEY(user_ID) REFERENCES user(user_ID) ON DELETE CASCADE
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
    original_price DECIMAL(8,2) DEFAULT 0,
    selling_price DECIMAL(8,2) DEFAULT 0, -- update by trigger "after_price"
    tags VARCHAR(80),
	stock INT DEFAULT 0, -- auto decrease with trigger "product_stock" when the order is placed
    sales INT DEFAULT 0, -- auto increase with trigger "product_stock" when the order is placed
    likes INT DEFAULT 0, -- front end pass if anyone likes then +1, or if cancel then -1
    avg_score DOUBLE, -- front end pass score 
    num_of_comment INT DEFAULT 0
    -- auto update with trigger "product_score" when score is added
);

CREATE TABLE IF NOT EXISTS orders(
	order_ID INT NOT NULL AUTO_INCREMENT,
    user_ID INT NOT NULL,
    status INT DEFAULT 0,
    PRIMARY KEY(order_ID, user_ID),
    FOREIGN KEY(user_ID) REFERENCES user(user_ID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS search_history(
	user_ID INT NOT NULL,
	keyword VARCHAR(80),
    PRIMARY KEY(user_ID,keyword),
    FOREIGN KEY(user_ID) REFERENCES user(user_ID) ON DELETE CASCADE
	-- if user got remove, delete whole history to that user
);

-- the paying table denotes the relationship between the order and the paying information about the order
CREATE TABLE IF NOT EXISTS  paying(
    order_ID INT NOT NULL,
    payment_ID INT NOT NULL,
    PRIMARY KEY(order_ID, payment_ID),
    FOREIGN KEY(order_ID) REFERENCES orders(order_ID) ON DELETE CASCADE,
    FOREIGN KEY(payment_ID) REFERENCES paying_info(payment_ID) ON DELETE CASCADE
);

-- the liking_list table denotes the liking from the user for specifing product
CREATE TABLE IF NOT EXISTS  liking_list(
    user_ID INT NOT NULL,
    product_ID INT NOT NULL,
    PRIMARY KEY(user_ID, product_ID),
    FOREIGN KEY(user_ID) REFERENCES user(user_ID) ON DELETE CASCADE,
    FOREIGN KEY(product_ID) REFERENCES product(product_ID) ON DELETE CASCADE
);

-- the cart_item table record the detail for each product from every shopping cart 
CREATE TABLE IF NOT EXISTS  cart_item(
    cart_ID INT NOT NULL,
    product_ID INT NOT NULL,
    quantity INT NOT NULL,
    prices DECIMAL(8,2),
    PRIMARY KEY(cart_ID, product_ID),
    FOREIGN KEY(cart_ID) REFERENCES user(user_ID) ON DELETE CASCADE,
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
BEFORE INSERT ON user
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

-- after_price:
DELIMITER $$
CREATE TRIGGER after_price
BEFORE INSERT ON product
FOR EACH ROW
BEGIN
    SET NEW.selling_price=NEW.discount*NEW.original_price;
END;
$$
DELIMITER ;

-- delete_order_n_payinginfo:
DELIMITER $$
CREATE TRIGGER delete_order_n_payinginfo
AFTER DELETE ON paying
FOR EACH ROW
BEGIN
    DELETE FROM paying_info WHERE payment_ID=OLD.paying.payment_ID;
END;
$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE RegisterMember (account VARCHAR(50), password  CHAR(60), enrollment_date DATE, address VARCHAR(120), email_address VARCHAR(80), birthdate DATE)
 BEGIN
	INSERT INTO user(account, password, enrollment_date, address, email_address, birthdate) 
	VALUES(account, password, enrollment_date, address, email_address, birthdate); 
 END;
$$
DELIMITER ;

-- CALL RegisterMember ('faker','lck666777','2024-05-19','666777','666777@gmail.com','9999-04-25');

-- test data
-- INSERT INTO `User` VALUES("91", "1034679", "000", "2008-01-01", "123456", "123456", "2008-01-06", "5");

INSERT INTO user VALUES(-1,'admin','admin','1000-01-10','0','0','1000-01-10',0);
INSERT INTO user (account, password, enrollment_date, address, email_address, birthdate) VALUES('amber','qqq123','2024-05-17','123','123@gmail.com','2002-05-10');
INSERT INTO user (account, password, enrollment_date, address, email_address, birthdate) VALUES('brown','www456','2024-05-17','456','456@yahoo.com.tw','2005-08-17');
INSERT INTO user (account, password, enrollment_date, address, email_address, birthdate) VALUES('cindy','lpl999','2024-05-17','999','999@gapps.ntnu.edu.tw','1999-02-19');
INSERT INTO user (account, password, enrollment_date, address, email_address, birthdate) VALUES('youma','lck777','2024-05-17','777','777@gmail.com','1995-04-25');
INSERT INTO user (account, password, enrollment_date, address, email_address, birthdate) VALUES('elon','elan456','2024-05-17','elon','elon@gmail.com','1900-08-17');

INSERT INTO user_phone VALUES(1,'0987563258');
INSERT INTO user_phone VALUES(2,'0912345678');
INSERT INTO user_phone VALUES(3,'0951113355');
INSERT INTO user_phone VALUES(4,'0945678139');
INSERT INTO user_phone VALUES(5,'0945337788');

INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('pen'    ,'0.7','1000','100','pencil','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('eraser' ,'0.2','1000','50','eraser','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ruler'  ,'0.1','600','75','ruler','110',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('paper'  ,'1','1000','1','paper','1000',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('magzine','0.9','10000','150','book','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('notebook','0.5','800','200','stationery','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('marker','0.3','500','120','marker','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('stapler','0.4','300','180','office','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('glue','0.2','700','50','adhesive','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('scissors','0.6','400','250','tool','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('sharpener','0.1','1000','30','sharpener','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('folder','0.3','900','60','organizer','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tape','0.5','600','40','adhesive','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('sticker','0.2','1200','20','decorative','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('highlighter','0.4','550','70','marker','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('post-it','0.3','950','30','note','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('binder','0.5','450','220','organizer','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('calculator','0.7','350','300','tool','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('whiteboard','0.6','250','500','board','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('envelope','0.2','800','15','mail','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('label','0.1','750','25','organizer','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('paperclip','0.2','1000','5','stationery','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('file','0.4','500','40','organizer','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('calendar','0.5','300','100','planner','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('clipboard','0.3','400','80','organizer','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('drawing pad','0.5','600','150','art','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('canvas','0.6','200','500','art','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('paint brush','0.3','800','100','art','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('watercolor','0.4','400','300','art','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('easel','0.5','150','700','art','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('oil paint','0.6','100','600','art','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('pastel','0.3','700','250','art','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('charcoal','0.2','900','120','art','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('sketchbook','0.4','500','200','art','28',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('sculpting clay','0.5','300','400','art','18',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('colored pencils','0.3','850','180','art','38',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ink pen','0.2','950','80','writing','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fountain pen','0.4','350','400','writing','22',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ballpoint pen','0.3','750','60','writing','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('gel pen','0.2','850','50','writing','42',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('mechanical pencil','0.5','450','100','writing','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lead refill','0.1','1000','20','writing','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('pen case','0.3','400','70','accessory','28',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('desk organizer','0.4','300','250','accessory','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('paperweight','0.2','500','40','accessory','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bookmark','0.3','600','30','accessory','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('magnifying glass','0.4','250','150','tool','18',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('desk lamp','0.5','200','500','furniture','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('office chair','0.6','100','1000','furniture','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('file cabinet','0.4','150','800','furniture','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bookcase','0.3','100','1500','furniture','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('desk','0.5','50','2000','furniture','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('laptop stand','0.4','300','250','accessory','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tablet holder','0.3','400','200','accessory','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('phone stand','0.2','500','100','accessory','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cable organizer','0.3','600','50','accessory','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('mouse pad','0.4','250','70','accessory','22',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('keyboard cover','0.5','300','60','accessory','18',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('laptop sleeve','0.6','200','300','accessory','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('backpack','0.4','150','500','bag','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('messenger bag','0.3','100','600','bag','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tote bag','0.2','200','400','bag','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('duffel bag','0.4','100','700','bag','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('gym bag','0.5','50','800','bag','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('travel bag','0.6','30','900','bag','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('wallet','0.3','500','100','accessory','22',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('pencil case','0.2','600','80','accessory','28',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('card holder','0.4','300','120','accessory','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('keychain','0.3','400','30','accessory','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lanyard','0.2','700','20','accessory','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('usb drive','0.4','200','150','electronics','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('external hard drive','0.5','100','700','electronics','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('power bank','0.3','250','500','electronics','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('wireless mouse','0.2','300','200','electronics','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('keyboard','0.4','150','300','electronics','18',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('monitor','0.5','100','1000','electronics','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('headphones','0.3','200','400','electronics','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('speakers','0.4','100','600','electronics','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('webcam','0.2','300','150','electronics','22',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('microphone','0.3','200','250','electronics','18',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tripod','0.4','150','200','electronics','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ring light','0.5','100','300','electronics','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('smart watch','0.6','50','1000','electronics','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fitness tracker','0.4','100','800','electronics','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('action camera','0.3','200','600','electronics','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('drone','0.5','50','1500','electronics','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('robot vacuum','0.6','30','2000','home appliance','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('air purifier','0.4','100','1200','home appliance','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('humidifier','0.3','150','800','home appliance','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dehumidifier','0.5','50','1000','home appliance','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('blender','0.4','200','500','kitchen appliance','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('coffee maker','0.3','100','700','kitchen appliance','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('toaster','0.2','150','300','kitchen appliance','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('microwave','0.4','100','800','kitchen appliance','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('oven','0.5','50','1000','kitchen appliance','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('air fryer','0.6','30','1200','kitchen appliance','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rice cooker','0.3','200','400','kitchen appliance','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('slow cooker','0.4','100','600','kitchen appliance','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('pressure cooker','0.5','50','800','kitchen appliance','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('food processor','0.6','30','1000','kitchen appliance','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('kettle','0.2','300','150','kitchen appliance','18',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('mixer','0.3','200','300','kitchen appliance','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('stand mixer','0.4','100','700','kitchen appliance','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('waffle maker','0.5','50','400','kitchen appliance','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('popcorn maker','0.6','30','500','kitchen appliance','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('juicer','0.3','200','600','kitchen appliance','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ice cream maker','0.4','100','800','kitchen appliance','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('yogurt maker','0.5','50','700','kitchen appliance','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bread maker','0.6','30','900','kitchen appliance','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dishwasher','0.4','100','1200','home appliance','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('washing machine','0.3','150','1500','home appliance','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dryer','0.5','50','1300','home appliance','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('vacuum cleaner','0.6','30','1000','home appliance','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('steam mop','0.2','200','400','home appliance','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('iron','0.3','150','200','home appliance','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garment steamer','0.4','100','300','home appliance','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('sewing machine','0.5','50','800','home appliance','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('air conditioner','0.6','30','2000','home appliance','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('heater','0.3','200','600','home appliance','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fan','0.4','150','400','home appliance','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ceiling fan','0.5','50','700','home appliance','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('table fan','0.2','300','150','home appliance','18',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('floor fan','0.3','200','250','home appliance','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tower fan','0.4','100','300','home appliance','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('pedestal fan','0.5','50','400','home appliance','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bed','0.6','30','2000','furniture','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('mattress','0.4','100','1500','furniture','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('pillow','0.3','200','300','bedding','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('blanket','0.5','50','500','bedding','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('duvet','0.6','30','700','bedding','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('sheet set','0.4','100','200','bedding','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('comforter','0.3','150','400','bedding','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('pillowcase','0.2','300','50','bedding','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('pillow protector','0.3','200','80','bedding','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('mattress protector','0.4','100','150','bedding','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bed frame','0.5','50','600','furniture','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('nightstand','0.6','30','300','furniture','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('wardrobe','0.4','100','1000','furniture','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dresser','0.3','150','800','furniture','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('vanity','0.5','50','700','furniture','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('mirror','0.6','30','400','furniture','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rug','0.4','100','600','home decor','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('curtains','0.3','150','300','home decor','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('blinds','0.2','300','200','home decor','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('wall art','0.5','50','400','home decor','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('vase','0.6','30','200','home decor','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('throw pillow','0.4','100','150','home decor','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('candle','0.3','200','100','home decor','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lamp','0.5','50','300','home decor','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('clock','0.2','150','200','home decor','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('picture frame','0.3','100','50','home decor','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('flower pot','0.4','200','80','home decor','18',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('planter','0.5','100','150','home decor','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden gnome','0.6','30','200','home decor','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bird feeder','0.4','50','100','garden','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hose','0.3','100','50','garden','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('watering can','0.2','150','30','garden','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rake','0.5','50','60','garden','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('shovel','0.6','30','80','garden','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden gloves','0.4','100','20','garden','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('wheelbarrow','0.3','50','100','garden','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lawnmower','0.2','30','200','garden','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hedge trimmer','0.5','20','150','garden','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('pruning shears','0.6','10','50','garden','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('safety goggles','0.3','100','30','tools','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('work gloves','0.4','50','20','tools','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('toolbox','0.5','30','100','tools','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hammer','0.2','150','50','tools','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('screwdriver','0.3','200','40','tools','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('wrench','0.4','100','60','tools','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('pliers','0.5','50','70','tools','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('saw','0.6','30','90','tools','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('drill','0.4','100','150','tools','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tape measure','0.3','200','20','tools','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('level','0.5','50','30','tools','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('sandpaper','0.6','30','10','tools','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('brush','0.4','100','20','tools','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('paint roller','0.3','50','15','tools','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('paint tray','0.2','100','10','tools','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('step ladder','0.5','20','100','tools','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('extension cord','0.6','30','50','tools','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('duct tape','0.4','50','20','tools','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('nail gun','0.3','10','200','tools','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compressor','0.2','5','300','tools','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('welding machine','0.5','5','400','tools','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('generator','0.6','3','500','tools','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('desk chair','0.3','50','800','furniture','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bookshelf','0.4','30','1200','furniture','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('sofa','0.2','20','3000','furniture','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('coffee table','0.5','40','700','furniture','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dining table','0.4','15','2500','furniture','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dining chair','0.3','50','400','furniture','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bar stool','0.2','70','600','furniture','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tv stand','0.6','20','1500','furniture','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('recliner','0.5','25','2000','furniture','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('office desk','0.4','30','1000','furniture','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('wall shelf','0.3','100','300','home decor','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('area rug','0.5','60','1200','home decor','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('chandelier','0.4','15','2500','home decor','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('floor lamp','0.6','25','1500','home decor','3',0,0);


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


