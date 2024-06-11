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
	order_ID INT NOT NULL UNIQUE AUTO_INCREMENT,
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

-- after_price:
DELIMITER $$
CREATE TRIGGER after_update_price
BEFORE UPDATE ON product
FOR EACH ROW
BEGIN
    SET NEW.selling_price = NEW.discount * NEW.original_price;
    
    UPDATE cart_item
    SET prices = NEW.selling_price * quantity
    WHERE product_ID = OLD.product_ID;
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
INSERT INTO user (account, password, enrollment_date, address, email_address, birthdate) VALUES('aaaaa','aaaaa','2024-05-17','America','nah@gmail.com','1800-08-17');
INSERT INTO user (account, password, enrollment_date, address, email_address, birthdate) VALUES('imgood','notgood','2024-05-17','UK','john@hotmail.com','1999-06-12');
INSERT INTO user (account, password, enrollment_date, address, email_address, birthdate) VALUES('sanford','hanginthere1','2024-05-17','Ohio','sanford@gmail.com','1912-12-12');
INSERT INTO user (account, password, enrollment_date, address, email_address, birthdate) VALUES('notpotato','notpotato','2024-05-17','Taiwan','sansgu119@gmail.com','2000-04-01');
INSERT INTO user (account, password, enrollment_date, address, email_address, birthdate) VALUES('miku','3939beam','2024-05-17','Japan','negi@gmail.com','2007-08-31');
INSERT INTO user (account, password, enrollment_date, address, email_address, birthdate) VALUES('hank','hankstrongest1','2024-05-17','Nevada','hank123@yahoo.com','2009-01-31');

INSERT INTO user_phone VALUES(1,'0987563258');
INSERT INTO user_phone VALUES(2,'0912345678');
INSERT INTO user_phone VALUES(3,'0951113355');
INSERT INTO user_phone VALUES(4,'0945678139');
INSERT INTO user_phone VALUES(5,'0945337788');
INSERT INTO user_phone VALUES(6,'0745889711');
INSERT INTO user_phone VALUES(7,'0912554388');
INSERT INTO user_phone VALUES(8,'0943337658');
INSERT INTO user_phone VALUES(9,'0345778908');
INSERT INTO user_phone VALUES(10,'0563383988');
INSERT INTO user_phone VALUES(11,'0967890232');

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
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('sticky notes','0.2','500','80','stationery','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('paper towels','0.3','600','100','household','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dish soap','0.4','300','50','cleaning','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('sponge','0.5','400','20','cleaning','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garbage bags','0.6','200','150','household','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('kitchen towels','0.2','300','60','kitchen','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('toilet paper','0.3','400','120','bathroom','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hand soap','0.4','200','30','cleaning','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('floss','0.5','500','5','bathroom','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dishwasher pods','0.6','100','200','cleaning','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('air freshener','0.2','350','80','cleaning','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('laundry detergent','0.3','400','150','cleaning','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fabric softener','0.4','200','100','cleaning','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('all-purpose cleaner','0.5','300','70','cleaning','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hand sanitizer','0.6','150','40','cleaning','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('window cleaner','0.2','250','90','cleaning','22',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('stainless steel cleaner','0.3','200','60','cleaning','18',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('toilet cleaner','0.4','150','50','cleaning','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('floor cleaner','0.5','100','80','cleaning','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bleach','0.6','50','30','cleaning','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('pet food','0.2','600','40','pets','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cat litter','0.3','500','25','pets','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dog treats','0.4','400','15','pets','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bird seed','0.5','300','10','pets','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fish food','0.6','200','8','pets','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hamster food','0.2','100','6','pets','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('guinea pig food','0.3','80','6','pets','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rabbit food','0.4','60','6','pets','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('reptile food','0.5','50','7','pets','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('turtle food','0.6','40','8','pets','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('small animal bedding','0.2','300','20','pets','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dog bed','0.3','250','50','pets','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cat bed','0.4','200','40','pets','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fish tank','0.5','150','100','pets','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bird cage','0.6','100','80','pets','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hamster cage','0.2','80','70','pets','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('guinea pig cage','0.3','60','70','pets','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rabbit cage','0.4','50','60','pets','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('reptile cage','0.5','40','80','pets','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('turtle tank','0.6','30','100','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dog collar','0.2','300','15','pets','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cat collar','0.3','250','12','pets','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fish net','0.4','200','5','pets','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bird perch','0.5','150','10','pets','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hamster wheel','0.6','100','8','pets','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('guinea pig wheel','0.2','80','8','pets','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rabbit wheel','0.3','60','8','pets','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('reptile lamp','0.4','50','30','pets','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('turtle lamp','0.5','40','30','pets','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dog leash','0.6','30','20','pets','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cat leash','0.2','300','20','pets','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fish tank heater','0.3','250','40','pets','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bird bath','0.4','200','15','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hamster ball','0.5','150','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('guinea pig ball','0.6','100','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rabbit ball','0.2','80','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('reptile hide','0.3','60','10','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('turtle hide','0.4','50','10','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dog toy','0.5','40','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cat toy','0.6','30','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tropical fish food','0.5','300','8','pets','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('gerbil food','0.6','200','6','pets','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ferret food','0.2','100','8','pets','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hedgehog food','0.3','80','8','pets','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('chinchilla food','0.4','60','7','pets','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('snake food','0.5','50','9','pets','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lizard food','0.6','40','10','pets','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('parrot food','0.2','300','12','pets','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cockatiel food','0.3','250','12','pets','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('budgerigar food','0.4','200','10','pets','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tropical fish tank','0.5','150','120','pets','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('gerbil cage','0.6','100','60','pets','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ferret cage','0.2','80','80','pets','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hedgehog cage','0.3','60','70','pets','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('chinchilla cage','0.4','50','70','pets','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('snake cage','0.5','40','80','pets','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lizard cage','0.6','30','90','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('parrot cage','0.2','300','100','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cockatiel cage','0.3','250','90','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('budgerigar cage','0.4','200','80','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tropical fish net','0.5','150','6','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('gerbil wheel','0.6','100','6','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ferret wheel','0.2','80','8','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hedgehog wheel','0.3','60','8','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('chinchilla wheel','0.4','50','8','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('snake hide','0.5','40','12','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lizard hide','0.6','30','15','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('parrot perch','0.2','300','8','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cockatiel perch','0.3','250','8','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('budgerigar perch','0.4','200','8','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tropical fish tank heater','0.5','150','50','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('gerbil ball','0.6','100','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ferret ball','0.2','80','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hedgehog ball','0.3','60','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('chinchilla ball','0.4','50','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('snake ball','0.5','40','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lizard ball','0.6','30','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('parrot toy','0.2','300','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cockatiel toy','0.3','250','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('budgerigar toy','0.4','200','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ear muffs','0.3','80','15','safety','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('work boots','0.4','200','60','safety','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hard hat','0.5','150','20','safety','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('reflective vest','0.6','120','30','safety','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('first aid kit','0.2','50','40','safety','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fire extinguisher','0.3','40','50','safety','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('safety harness','0.4','30','100','safety','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('caution tape','0.5','80','10','safety','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('safety cones','0.6','60','5','safety','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fire alarm','0.2','30','80','safety','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('gas mask','0.3','20','150','safety','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('safety gloves','0.4','100','20','safety','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('respirator','0.5','70','30','safety','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fall protection','0.6','50','200','safety','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('safety signage','0.2','30','15','safety','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lockout tagout kit','0.3','25','50','safety','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('biohazard bags','0.4','20','10','safety','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('emergency exit sign','0.5','15','30','safety','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('workbench','0.2','50','80','tools','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('shop vac','0.3','40','100','tools','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tool chest','0.4','30','150','tools','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bench grinder','0.5','25','200','tools','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('power drill','0.6','20','80','tools','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('angle grinder','0.2','15','120','tools','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('work light','0.3','10','50','tools','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tool belt','0.4','8','30','tools','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('laser level','0.5','5','100','tools','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('jackhammer','0.6','4','500','tools','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('workbench stool','0.2','10','50','tools','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('soldering iron','0.3','8','30','tools','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('wire stripper','0.4','6','20','tools','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bolt cutter','0.5','5','40','tools','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('plumber wrench','0.6','4','25','tools','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tap and die set','0.2','3','60','tools','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('circular saw','0.3','2','150','tools','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('air compressor','0.4','1','200','tools','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bike','0.2','20','300','sports','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('kayak','0.3','15','400','sports','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tent','0.4','10','100','sports','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fishing rod','0.5','8','50','sports','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('golf clubs','0.6','6','250','sports','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('surfboard','0.2','5','300','sports','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('basketball','0.3','4','20','sports','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('soccer ball','0.4','3','30','sports','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('baseball glove','0.5','2','40','sports','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('volleyball','0.6','1','50','sports','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('weightlifting gloves','0.2','10','20','sports','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bike helmet','0.3','8','30','sports','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tennis racket','0.4','6','40','sports','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('yoga mat','0.5','5','50','sports','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('boxing gloves','0.6','4','60','sports','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('skateboard','0.2','3','70','sports','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('frisbee','0.3','2','80','sports','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ping pong paddle','0.4','1','90','sports','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('LED flashlight','0.2','50','15','tools','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('multi-tool','0.3','40','20','tools','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hacksaw','0.4','30','25','tools','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('plunger','0.5','25','10','tools','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('utility knife','0.6','20','5','tools','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden hose','0.5','5','20','tools','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('leaf blower','0.2','3','50','tools','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden shears','0.3','2','10','tools','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('power washer','0.4','1','100','tools','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('electric screwdriver','0.5','20','25','tools','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('pruning saw','0.6','15','15','tools','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('sledgehammer','0.2','10','20','tools','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('trowel','0.3','8','5','tools','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden rake','0.4','6','10','tools','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fertilizer spreader','0.5','5','20','tools','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden shovel','0.6','4','15','tools','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hose reel','0.2','3','30','tools','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lawn mower','0.6','15','100','tools','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('leaf rake','0.2','10','10','tools','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden hoe','0.3','8','10','tools','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('pruning scissors','0.4','6','5','tools','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden fork','0.5','5','10','tools','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lawn aerator','0.6','4','50','tools','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('weed trimmer','0.2','3','30','tools','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden spade','0.3','2','15','tools','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden trowel','0.4','1','5','tools','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lawn sprinkler','0.5','20','10','tools','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden cultivator','0.6','15','25','tools','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('knee pads','0.3','20','15','sports','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('punching bag','0.4','15','50','sports','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('jump rope','0.5','10','5','sports','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('treadmill','0.6','8','200','sports','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dumbbells','0.2','5','100','sports','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('exercise ball','0.3','4','20','sports','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('boxing bag','0.4','3','150','sports','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('pull-up bar','0.5','2','30','sports','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bench press','0.6','1','250','sports','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rowing machine','0.2','20','300','sports','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('elliptical machine','0.3','15','400','sports','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('exercise bike','0.4','10','100','sports','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('weight bench','0.5','8','150','sports','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('yoga ball','0.6','6','20','sports','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('squat rack','0.3','4','150','sports','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('medicine ball','0.4','3','40','sports','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('skipping rope','0.5','2','10','sports','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fish bowl','0.6','30','90','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rabbit hutch','0.3','250','90','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('guinea pig hutch','0.4','200','80','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rabbit tunnel','0.2','80','8','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('guinea pig tunnel','0.3','60','8','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hamster hide','0.5','40','12','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rabbit hide','0.6','30','15','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('guinea pig hide','0.2','300','8','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hamster toy','0.4','200','8','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rabbit toy','0.5','150','50','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('guinea pig toy','0.6','100','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('reptile terrarium','0.4','50','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('small animal carrier','0.5','40','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fish tank decoration','0.6','30','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('reptile heating pad','0.3','250','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fish tank filter','0.5','150','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('reptile UVB bulb','0.2','80','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('small animal hay','0.3','60','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bird toy','0.5','40','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('small animal food','0.2','300','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fish tank gravel','0.3','250','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bird cage cover','0.4','200','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('reptile substrate','0.5','150','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('small animal treats','0.6','100','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fish tank light','0.2','80','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('small animal hide','0.5','40','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fish tank background','0.6','30','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bird ladder','0.2','300','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('reptile water bowl','0.3','250','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('small animal water bottle','0.4','200','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fish tank thermometer','0.5','150','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bird nest','0.6','100','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('plant fertilizer','0.5','15','20','tools','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lawn edger','0.6','8','35','tools','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('soil tester','0.2','6','8','tools','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('plant pots','0.4','4','12','tools','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('gardening hat','0.5','3','8','tools','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('insect repellent','0.6','2','15','tools','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('plant labels','0.3','20','5','tools','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden cart','0.5','10','50','tools','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('potting soil','0.6','8','10','tools','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compost bin','0.3','6','40','tools','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden trellis','0.4','5','25','tools','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('deck box','0.6','3','80','tools','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('football','0.5','10','15','sports','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('baseball bat','0.6','8','30','sports','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cricket bat','0.4','3','35','sports','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hockey stick','0.5','2','40','sports','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('golf club','0.6','1','50','sports','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('badminton racket','0.2','20','25','sports','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('table tennis racket','0.3','15','15','sports','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bowling ball','0.4','10','40','sports','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dart board','0.5','8','20','sports','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('snowboard','0.4','3','100','sports','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('roller skates','0.5','2','50','sports','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cat scratching post','0.3','30','40','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('gardening scissors','0.5','15','20','tools','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('watering wand','0.6','12','25','tools','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('plant markers','0.2','10','15','tools','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden kneeler','0.6','8','35','tools','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('soil scoop','0.2','6','8','tools','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('planting dibber','0.3','5','10','tools','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden kneepads','0.4','4','12','tools','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('plant cover','0.5','3','8','tools','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('insect trap','0.6','2','15','tools','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('plant support stakes','0.2','1','20','tools','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('gardening apron','0.3','20','5','tools','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('plant caddy','0.4','15','18','tools','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden thermometer','0.5','10','50','tools','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compost tumbler','0.6','8','10','tools','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden marker pen','0.3','6','40','tools','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('plant propagation kit','0.4','5','25','tools','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden tool belt','0.5','4','20','tools','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden wind spinner','0.6','3','80','tools','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tennis balls','0.3','20','50','sports','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('running shoes','0.5','10','15','sports','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('swimming goggles','0.6','8','30','sports','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('jumping shoes','0.2','5','20','sports','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('surfing wetsuit','0.5','2','40','sports','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cycling helmet','0.6','1','50','sports','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rock climbing harness','0.2','20','25','sports','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('snow skiing gloves','0.3','15','15','sports','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('skateboarding helmet','0.4','10','40','sports','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hiking backpack','0.5','8','20','sports','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('canoe paddle','0.6','6','150','sports','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('kayak paddle','0.3','4','60','sports','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('mountain biking gloves','0.4','3','100','sports','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('climbing chalk bag','0.5','2','50','sports','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('sailing gloves','0.6','1','30','sports','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bird food','0.5','20','25','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bird cage stand','0.4','6','5','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cat tree','0.5','5','15','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dog house','0.6','4','40','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hamster bedding','0.4','2','8','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('fish tank stand','0.5','1','25','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cat scratching post deluxe','0.3','100','40','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium plant food','0.4','25','25','tools','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lawn trimmer pro','0.5','8','75','tools','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('advanced soil pH meter','0.2','6','12','tools','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('smart plant pots','0.4','4','20','tools','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('sun hat with neck flap','0.5','3','15','tools','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('mosquito zapper','0.6','2','25','tools','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('reusable plant markers','0.3','20','3','tools','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('heavy-duty garden cart','0.5','10','60','tools','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium potting soil','0.6','8','15','tools','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compost bin deluxe','0.3','6','50','tools','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('expandable garden trellis','0.4','5','30','tools','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('waterproof deck box','0.6','3','100','tools','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional football','0.5','10','30','sports','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('alloy baseball bat','0.6','8','40','sports','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cricket bat pro','0.4','3','45','sports','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional hockey stick','0.5','2','60','sports','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('golf club set','0.6','1','150','sports','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tournament-grade badminton racket','0.2','20','35','sports','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('table tennis racket pro','0.3','15','25','sports','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional bowling ball','0.4','10','60','sports','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('electronic dart board','0.5','8','40','sports','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('snowboard pro','0.4','3','150','sports','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional roller skates','0.5','2','80','sports','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium bird food blend','0.3','30','50','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional pruning shears','0.5','15','35','tools','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('heavy-duty watering wand','0.6','12','30','tools','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bamboo plant markers','0.2','10','10','tools','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden kneeler pro','0.6','8','45','tools','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('heavy-duty soil scoop','0.2','6','15','tools','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional planting dibber','0.3','5','12','tools','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium garden kneepads','0.4','4','15','tools','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('plant frost protection cover','0.5','3','10','tools','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('smart insect trap','0.6','2','20','tools','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium plant support stakes','0.2','1','25','tools','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional gardening apron','0.3','20','10','tools','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('durable plant caddy','0.4','15','20','tools','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('precision garden thermometer','0.5','10','40','tools','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium compost tumbler','0.6','8','20','tools','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional garden marker pen','0.3','6','35','tools','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('advanced plant propagation kit','0.4','5','20','tools','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden tool belt pro','0.5','4','15','tools','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium garden wind spinner','0.6','3','100','tools','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional tennis balls','0.3','20','60','sports','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional running shoes','0.5','10','25','sports','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium swimming goggles','0.6','8','40','sports','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('jumping shoes pro','0.2','5','30','sports','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('advanced surfing wetsuit','0.5','2','60','sports','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium cycling helmet','0.6','1','70','sports','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional rock climbing harness','0.2','20','40','sports','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium snow skiing gloves','0.3','15','20','sports','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('advanced skateboarding helmet','0.4','10','50','sports','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional hiking backpack','0.5','8','25','sports','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium canoe paddle','0.6','6','200','sports','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional kayak paddle','0.3','4','80','sports','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium mountain biking gloves','0.4','3','120','sports','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional climbing chalk bag','0.5','2','60','sports','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('advanced sailing gloves','0.6','1','40','sports','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium bird seed mix','0.5','20','30','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('deluxe bird cage stand','0.4','6','8','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('luxury cat tree','0.5','5','20','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium dog house','0.6','4','50','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hamster bedding premium blend','0.4','2','10','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('aquarium stand deluxe','0.5','1','30','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium bird feeder','0.3','100','45','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('organic plant fertilizer','0.4','25','30','tools','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('electric lawn edger','0.5','8','90','tools','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('digital soil tester','0.2','6','20','tools','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('self-watering plant pots','0.4','4','25','tools','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('sun protection gardening hat','0.5','3','20','tools','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ultrasonic insect repellent','0.6','2','30','tools','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('wooden plant labels','0.3','20','4','tools','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('heavy-duty garden cart with seat','0.5','10','70','tools','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium potting soil mix','0.6','8','20','tools','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rotating compost bin','0.3','6','60','tools','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('expandable garden trellis with planter','0.4','5','40','tools','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('waterproof outdoor deck box','0.6','3','120','tools','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tournament-grade football','0.5','10','40','sports','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional alloy baseball bat','0.6','8','50','sports','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cricket bat elite','0.4','3','50','sports','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ice hockey stick pro','0.5','2','70','sports','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional golf club set','0.6','1','200','sports','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('tournament-grade badminton racket set','0.2','20','50','sports','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional table tennis racket','0.3','15','30','sports','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional bowling ball set','0.4','10','70','sports','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('electronic dart board pro','0.5','8','50','sports','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium snowboard','0.4','3','200','sports','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional roller skates set','0.5','2','100','sports','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('luxury cat scratching post','0.3','30','50','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium gardening scissors','0.5','15','25','tools','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('extendable watering wand','0.6','12','35','tools','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('colorful plant markers','0.2','10','12','tools','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('comfortable garden kneeler','0.6','8','40','tools','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ergonomic soil scoop','0.2','6','10','tools','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium planting dibber','0.3','5','15','tools','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('durable plant cover','0.5','3','10','tools','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('smart insect trap pro','0.6','2','25','tools','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium plant support stakes set','0.2','1','30','tools','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional gardening apron deluxe','0.3','20','15','tools','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('heavy-duty plant caddy','0.4','15','25','tools','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('digital garden thermometer','0.5','10','45','tools','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('smart compost tumbler','0.6','8','15','tools','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional garden marker pen set','0.3','6','40','tools','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('advanced plant propagation kit pro','0.4','5','30','tools','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium garden tool belt','0.5','4','18','tools','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('luxury garden wind spinner','0.6','3','120','tools','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional tennis balls set','0.3','20','70','sports','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium running shoes','0.5','10','30','sports','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('advanced swimming goggles','0.6','8','50','sports','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional jumping shoes','0.2','5','25','sports','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('luxury surfing wetsuit','0.5','2','80','sports','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium cycling helmet set','0.6','1','90','sports','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional rock climbing harness set','0.2','20','60','sports','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium snow skiing gloves set','0.3','15','25','sports','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('advanced skateboarding helmet set','0.4','10','60','sports','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional hiking backpack deluxe','0.5','8','30','sports','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium canoe paddle set','0.6','6','250','sports','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional kayak paddle set','0.3','4','100','sports','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium mountain biking gloves set','0.4','3','150','sports','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional climbing chalk bag set','0.5','2','80','sports','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('advanced sailing gloves set','0.6','1','50','sports','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium bird seed variety pack','0.5','20','35','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('luxury bird cage stand set','0.4','6','10','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('deluxe cat tree set','0.5','5','25','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium dog house with heating','0.6','4','80','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ultra-soft hamster bedding','0.4','2','15','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('aesthetic fish tank stand','0.5','1','40','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium bird bath','0.3','100','60','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('organic plant food','0.4','25','35','tools','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('robotic lawn mower','0.5','8','400','tools','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('soil pH meter','0.2','6','30','tools','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('hanging planters','0.4','4','30','tools','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('wide-brimmed sun hat','0.5','3','25','tools','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bamboo plant stakes','0.3','20','6','tools','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('foldable garden wagon','0.5','10','90','tools','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium orchid mix','0.6','8','25','tools','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('worm compost bin','0.3','6','70','tools','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('decorative garden obelisk','0.4','5','50','tools','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('outdoor storage bench','0.6','3','150','tools','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional basketball','0.5','10','60','sports','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('cricket ball set','0.6','8','20','sports','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ice hockey skates','0.4','3','80','sports','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('golf swing analyzer','0.5','2','150','sports','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('professional tennis racket set','0.6','1','250','sports','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('indoor badminton net','0.2','20','60','sports','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ping pong robot','0.3','15','300','sports','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('bowling shoes','0.4','10','50','sports','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('dartboard cabinet set','0.5','8','100','sports','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium snowboard boots','0.4','3','250','sports','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium scratching post','0.3','30','60','pets','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('adjustable hose nozzle','0.6','12','15','tools','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('colorful plant pots','0.2','10','10','tools','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rolling garden stool','0.6','8','25','tools','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('microgreens grow kit','0.2','6','20','tools','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium garden gloves set','0.3','5','25','tools','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ergonomic knee pads','0.4','4','15','tools','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden netting','0.5','3','20','tools','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('electric weed trimmer','0.6','2','90','tools','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('raised garden bed kit','0.2','1','200','tools','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('plant watering system','0.3','20','30','tools','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('premium garden shears','0.4','15','40','tools','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('solar garden lights','0.5','10','20','tools','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('decorative garden stones','0.6','8','35','tools','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden hose reel','0.3','6','50','tools','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lawn sprinkler system','0.4','5','70','tools','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('garden tool organizer','0.5','4','25','tools','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('automatic plant watering system','0.3','50','60','tools','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('solar-powered garden lights','0.6','20','25','tools','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('foldable camping chair','0.5','15','20','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping stove','0.4','25','40','outdoors','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('waterproof hiking boots','0.3','30','50','footwear','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('durable hiking backpack','0.2','40','60','outdoors','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping tent','0.5','10','100','outdoors','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('insulated camping mug','0.4','35','15','outdoors','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping lantern','0.6','30','20','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('stainless steel camping cookware set','0.5','20','50','outdoors','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lightweight camping hammock','0.4','25','30','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable water filtration system','0.3','20','35','outdoors','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('multi-tool camping shovel','0.2','15','25','outdoors','9',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('inflatable camping pillow','0.6','10','10','outdoors','14',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('emergency survival kit','0.5','5','70','outdoors','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping table','0.4','8','30','outdoors','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping grill','0.3','10','40','outdoors','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('waterproof camping backpack','0.5','15','80','outdoors','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping shower','0.6','12','60','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping chair with cooler','0.4','10','50','outdoors','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('folding camping cot','0.5','8','100','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lightweight camping stove','0.3','6','30','outdoors','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping espresso maker','0.2','4','40','outdoors','9',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ultralight camping tent','0.5','10','120','outdoors','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('waterproof camping tarp','0.6','15','45','outdoors','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping folding table','0.4','20','35','outdoors','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping chair with side table','0.5','25','55','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rechargeable camping lantern','0.6','30','25','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('stainless steel camping utensil set','0.4','35','20','outdoors','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ultralight camping sleeping pad','0.3','40','40','outdoors','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping shower tent','0.2','45','50','outdoors','11',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping cookware set','0.5','50','60','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping hammock stand','0.6','55','70','outdoors','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping coffee maker','0.4','60','35','outdoors','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lightweight camping chair','0.5','65','40','outdoors','9',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping solar panel','0.3','70','80','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping lantern with fan','0.2','75','45','outdoors','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping toilet','0.5','80','100','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping sink','0.6','85','30','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping shower head','0.4','90','20','outdoors','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping propane stove','0.5','95','50','outdoors','14',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('folding camping table with chairs','0.3','100','120','outdoors','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping first aid kit','0.2','45','25','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping water filter','0.5','50','40','outdoors','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping mosquito net','0.6','55','15','outdoors','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping shower bag','0.4','60','20','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping cot with mattress','0.5','65','80','outdoors','9',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping folding chair','0.3','70','35','outdoors','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lightweight camping backpack','0.2','75','40','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping hammock with mosquito net','0.3','40','50','outdoors','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rechargeable camping lantern with power bank','0.4','35','30','outdoors','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping cookware set with folding handles','0.5','30','40','outdoors','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping axe','0.6','25','20','outdoors','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping water container','0.5','20','15','outdoors','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lightweight camping chair with carrying bag','0.4','15','25','outdoors','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping coffee grinder','0.3','10','35','outdoors','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('insulated camping water bottle','0.2','5','20','outdoors','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping spice rack','0.6','15','10','outdoors','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping chair with footrest','0.5','25','40','outdoors','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping tent heater','0.4','35','50','outdoors','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping folding shovel','0.3','45','30','outdoors','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lightweight camping table with storage','0.2','55','45','outdoors','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping grill with carry bag','0.6','65','60','outdoors','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rechargeable camping fan with LED lights','0.5','75','40','outdoors','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping lantern with phone charger','0.4','85','30','outdoors','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping knife set','0.3','95','25','outdoors','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lightweight camping chair with canopy','0.2','100','50','outdoors','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping shower with pump','0.5','80','70','outdoors','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping grill with carrying case','0.4','70','45','outdoors','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping espresso machine','0.3','60','60','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping stove with piezo ignition','0.2','50','35','outdoors','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lightweight camping hammock with tree straps','0.6','40','40','outdoors','30',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping lantern with magnet base','0.5','30','20','outdoors','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rechargeable camping lantern with solar panel','0.4','20','50','outdoors','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping chair with lumbar support','0.3','10','25','outdoors','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping shower with heater','0.2','5','80','outdoors','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping table with cup holders','0.6','15','30','outdoors','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping stove with windscreen','0.5','25','45','outdoors','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping grill with thermometer','0.4','35','50','outdoors','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lightweight camping chair with side table','0.3','45','60','outdoors','70',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping coffee maker with grinder','0.2','55','35','outdoors','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rechargeable camping lantern with USB port','0.6','65','20','outdoors','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping stove with fuel regulator','0.5','75','30','outdoors','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lightweight camping hammock with mosquito net','0.4','85','40','outdoors','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping lantern with hook','0.3','95','25','outdoors','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping chair with cooler','0.2','100','50','outdoors','100',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping shower with rechargeable pump','0.5','80','70','outdoors','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping grill with carrying bag','0.4','70','45','outdoors','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping hammock with stand','0.6','12','80','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('foldable camping table','0.5','8','70','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove windscreen','0.2','4','25','outdoors','9',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping hammock straps','0.5','10','30','outdoors','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping shower enclosure','0.6','15','40','outdoors','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping bucket','0.4','20','15','outdoors','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with umbrella','0.5','25','50','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping sink','0.6','30','60','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping grill grate','0.4','35','35','outdoors','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping chair with canopy','0.3','40','45','outdoors','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lightweight camping hammock with stand','0.2','45','70','outdoors','11',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping lantern with remote control','0.5','50','55','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping chair with table','0.6','55','65','outdoors','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping shower tent','0.5','65','35','outdoors','9',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping chair with footrest','0.3','70','45','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping grill brush','0.2','75','5','outdoors','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping shower pump','0.5','80','30','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping table with storage','0.6','85','55','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping hammock rain fly','0.4','90','40','outdoors','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove stand','0.3','100','20','outdoors','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping shower caddy','0.2','45','15','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with footrest','0.5','50','40','outdoors','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping grill','0.6','55','60','outdoors','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping lantern with fan','0.4','60','45','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping table','0.5','65','35','outdoors','9',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping hammock tree straps','0.3','70','20','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping chair with sunshade','0.2','75','50','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove propane adapter','0.3','40','10','outdoors','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping lantern','0.4','35','25','outdoors','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with shade','0.5','30','60','outdoors','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping lantern with Bluetooth speaker','0.5','20','70','outdoors','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping table and chairs','0.4','15','50','outdoors','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping hammock with mosquito net','0.3','10','45','outdoors','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping chair with footrest and canopy','0.2','5','80','outdoors','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove windscreen shield','0.6','15','30','outdoors','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping lantern with power bank','0.5','25','45','outdoors','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with cooler','0.4','35','50','outdoors','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping lantern with USB charger','0.2','55','25','outdoors','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping chair with cooler bag','0.6','65','35','outdoors','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove fuel','0.5','75','20','outdoors','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with table','0.3','95','25','outdoors','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping stove with grill','0.3','95','25','outdoors','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping sink with faucet','0.5','80','70','outdoors','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping grill with folding legs','0.4','70','45','outdoors','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping table with cup holders','0.5','8','70','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove toaster','0.2','4','25','outdoors','9',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping grill grate','0.5','10','30','outdoors','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping shower','0.6','15','40','outdoors','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping utensil set','0.4','20','15','outdoors','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping cot with canopy','0.5','25','50','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping sink with stand','0.6','30','60','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping grill brush set','0.4','35','35','outdoors','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping chair with umbrella','0.3','40','45','outdoors','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping lantern with timer','0.5','50','55','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping table with adjustable legs','0.6','55','65','outdoors','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping shower kit','0.5','65','35','outdoors','9',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping grill scraper','0.2','75','5','outdoors','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping shower pump','0.5','80','30','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping table with chairs','0.6','85','55','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping hammock tarp','0.4','90','40','outdoors','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove fuel canister','0.3','100','20','outdoors','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping lantern with magnet','0.2','45','15','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with side cooler','0.5','50','40','outdoors','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping grill with case','0.6','55','60','outdoors','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping table with adjustable legs','0.4','60','45','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping hammock with rain cover','0.5','65','35','outdoors','9',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping chair with backrest','0.3','70','45','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove propane tank adapter','0.2','75','5','outdoors','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping lantern with handle','0.5','80','30','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with storage pouch','0.6','45','55','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping lantern with solar panel','0.4','15','40','outdoors','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with canopy and footrest','0.2','5','50','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping shower with privacy tent','0.6','15','30','outdoors','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping lantern with hook and magnet','0.5','25','45','outdoors','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with shade canopy','0.4','35','50','outdoors','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping lantern with phone charger','0.5','20','70','outdoors','35',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping table with cup holders','0.4','15','50','outdoors','40',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping hammock with bug net','0.3','10','45','outdoors','45',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping chair with cooler compartment','0.2','5','80','outdoors','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove windshield','0.6','15','30','outdoors','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping lantern with solar recharge','0.5','25','45','outdoors','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with insulated cooler','0.4','35','50','outdoors','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping lantern with USB port','0.2','55','25','outdoors','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping chair with insulated cooler bag','0.6','65','35','outdoors','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove fuel refill','0.5','75','20','outdoors','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with built-in cooler','0.3','95','25','outdoors','95',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping grill grate cleaner','0.6','25','15','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove wind guard','0.4','5','15','outdoors','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping hammock stand','0.6','30','100','outdoors','20',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping shovel','0.3','20','25','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove griddle','0.4','15','40','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with umbrella holder','0.5','10','50','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping chair with armrest','0.4','30','35','outdoors','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove grill','0.3','15','50','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping lantern with crank','0.2','10','20','outdoors','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with footrest and umbrella','0.4','5','65','outdoors','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping lantern with motion sensor','0.3','40','40','outdoors','22',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping hammock chair','0.6','30','25','outdoors','9',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping pot','0.7','25','20','outdoors','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with canopy and side table','0.5','15','45','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping lantern with hook','0.4','5','70','outdoors','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with shade and footrest','0.5','40','80','outdoors','18',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping grill grate cleaner','0.6','35','15','outdoors','11',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('inflatable camping mattress','0.4','30','30','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping chair','0.5','25','20','outdoors','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping shower hose','0.2','20','25','outdoors','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping hammock bug net','0.6','10','10','outdoors','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove griddle plate','0.4','5','20','outdoors','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping lantern with USB','0.3','40','30','outdoors','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with footrest and cooler','0.4','35','50','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping lantern with fan and radio','0.5','30','60','outdoors','14',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping stove with case','0.2','25','40','outdoors','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping hammock straps with carabiners','0.5','15','15','outdoors','3',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove toaster rack','0.6','10','10','outdoors','2',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping lantern with battery','0.4','5','20','outdoors','1',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with canopy and cooler','0.5','40','30','outdoors','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping grill with case','0.6','35','60','outdoors','14',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('inflatable camping pillow with case','0.4','30','15','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping bucket with handle','0.5','25','20','outdoors','4',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping shower head with hose','0.3','20','25','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove wind guard with windshield','0.4','15','35','outdoors','6',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping hammock stand with straps','0.5','10','100','outdoors','18',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping shower bag with pump','0.2','5','30','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping shovel with handle','0.5','30','25','outdoors','9',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove griddle with handle','0.6','25','40','outdoors','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping chair with umbrella holder and cooler','0.7','20','50','outdoors','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping sink with faucet','0.5','15','60','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove with grill','0.3','15','60','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping chair with footrest','0.5','25','50','outdoors','5',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('stainless steel camping kettle','0.4','35','25','outdoors','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ultralight camping chair','0.3','40','35','outdoors','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping shovel','0.5','50','20','outdoors','7',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping backpack','0.3','70','60','outdoors','8',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping espresso maker with grinder','0.2','75','70','outdoors','9',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('rechargeable camping fan','0.5','80','25','outdoors','10',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('stainless steel camping mug set','0.6','85','15','outdoors','12',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping first aid kit','0.4','90','20','outdoors','15',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping table and chair set','0.5','105','70','outdoors','22',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping hammock with stand and canopy','0.6','110','120','outdoors','25',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('collapsible camping shovel with pickaxe','0.5','115','30','outdoors','28',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ultralight camping tent with footprint','0.5','135','80','outdoors','38',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping grill with propane adapter','0.5','145','60','outdoors','42',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('stainless steel camping utensil set with case','0.2','160','25','outdoors','50',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ultralight camping sleeping pad with pillow','0.5','165','50','outdoors','52',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping shower tent with changing room','0.6','170','70','outdoors','55',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping cookware set with utensils','0.5','175','90','outdoors','58',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping hammock stand with mosquito net','0.4','180','110','outdoors','60',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('camping stove with piezo ignition','0.3','185','55','outdoors','62',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('foldable camping chair with cooler bag','0.2','190','40','outdoors','65',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping grill with carry case','0.5','195','65','outdoors','68',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping hammock with stand and rainfly','0.4','210','150','outdoors','75',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping shovel with saw','0.3','215','25','outdoors','78',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping table with folding chairs','0.2','220','70','outdoors','80',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('lightweight camping chair with headrest','0.5','225','45','outdoors','82',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping stove with fuel adapter','0.6','230','75','outdoors','85',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('ultralight camping tent with vestibule','0.5','235','100','outdoors','88',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('portable camping chair with side pocket','0.4','240','20','outdoors','90',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('compact camping grill with carrying bag','0.3','245','35','outdoors','92',0,0);
INSERT INTO product (product_name, discount, stock, original_price, tags, sales, likes, avg_score) VALUES('stainless steel camping utensil set with bottle opener','0.6','260','30','outdoors','100',0,0);



INSERT INTO cart_item VALUES('1','1','10','700');
INSERT INTO cart_item VALUES('1','4','10','10');
INSERT INTO cart_item VALUES('1','5','10','1350');
INSERT INTO cart_item VALUES('3','3','10','75');
INSERT INTO cart_item VALUES('3','2','10','100');

INSERT INTO liking_list VALUES('3','2');
INSERT INTO liking_list VALUES('2','1');
INSERT INTO liking_list VALUES('5','4');
INSERT INTO liking_list VALUES('5','5');
INSERT INTO liking_list VALUES('1','3');

INSERT INTO orders (order_ID, user_ID, status) VALUES('1','3','0');
INSERT INTO orders (order_ID, user_ID, status) VALUES('2','5','0');
INSERT INTO orders (order_ID, user_ID, status) VALUES('3','4','0');
INSERT INTO orders (order_ID, user_ID, status) VALUES('4','1','0');
INSERT INTO orders (order_ID, user_ID, status) VALUES('5','2','0');
INSERT INTO orders (order_ID, user_ID, status) VALUES('6','8','0');
INSERT INTO orders (order_ID, user_ID, status) VALUES('7','8','0');
INSERT INTO orders (order_ID, user_ID, status) VALUES('8','8','1');
INSERT INTO orders (order_ID, user_ID, status) VALUES('9','6','1');
INSERT INTO orders (order_ID, user_ID, status) VALUES('10','9','1');
INSERT INTO orders (order_ID, user_ID, status) VALUES('11','10','0');
INSERT INTO orders (order_ID, user_ID, status) VALUES('12','11','0');
INSERT INTO orders (order_ID, user_ID, status) VALUES('13','10','1');




INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('5','2','10','10');
INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('4','3','10','7.5');
INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('2','1','10','70');
INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('3','4','10','1');
INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('1','5','10','135');

INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('6','7','15','36');
INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('6','11','1','3');
INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('6','12','2','18');

INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('7','200','5','900');

INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('8','194','2','900');
INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('8','13','13','20');
INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('8','6','5','100');

INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('9','190','1','350');
INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('10','189','2','600');
INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('11','18','6','210');

INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('12','24','1','50');
INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('12','26','1','75');

INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('13','178','1','4.5');
INSERT INTO order_item (order_ID, product_ID, quantity, prices) VALUES('13','179','1','2');




INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('3','123','777','10','2024-05-19');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('4','456','123','75','2024-05-19');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('5','789','456','100','2024-05-19');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('1','963','999','1350','2024-05-19');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('2','258','elon','700','2024-05-19');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('8','123','Ohio','2560','2022-03-10');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('10','258','Taiwan','1200','2020-02-02');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('9','555','America','350','2022-05-09');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('6','999','Ohio','579','2024-04-01');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('12','787','Nevada','125','2019-03-19');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('13','258','Japan','6.5','2022-09-19');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('7','333','Ohio','4500','2023-11-27');
INSERT INTO paying_info (bank_account, bank_num, delivering_address, total_price, time_slot) VALUES('11','258','Japan','1260','2023-08-31');


INSERT INTO paying (order_ID, payment_ID) VALUES('3','1');
INSERT INTO paying (order_ID, payment_ID) VALUES('4','2');
INSERT INTO paying (order_ID, payment_ID) VALUES('5','3');
INSERT INTO paying (order_ID, payment_ID) VALUES('1','4');
INSERT INTO paying (order_ID, payment_ID) VALUES('2','5');
INSERT INTO paying (order_ID, payment_ID) VALUES('8','6');
INSERT INTO paying (order_ID, payment_ID) VALUES('10','7');
INSERT INTO paying (order_ID, payment_ID) VALUES('9','8');
INSERT INTO paying (order_ID, payment_ID) VALUES('6','9');
INSERT INTO paying (order_ID, payment_ID) VALUES('12','10');
INSERT INTO paying (order_ID, payment_ID) VALUES('13','11');
INSERT INTO paying (order_ID, payment_ID) VALUES('7','12');
INSERT INTO paying (order_ID, payment_ID) VALUES('11','13');

INSERT INTO search_history VALUES('1','pen');
INSERT INTO search_history VALUES('1','ruler');
INSERT INTO search_history VALUES('2','pen');
INSERT INTO search_history VALUES('2','paper');
INSERT INTO search_history VALUES('4','magzine');


