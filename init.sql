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

# table part below
create table IF NOT EXISTS User(
	user_ID int primary key not null auto_increment,
    account varchar(50) not null,
    password char(60) not null, # password hash at frontend then pass in
    enrollment_date date, # frontend get current date then pass in
    address varchar(120),
    email_address varchar(80),
	birthdate date not null,
    age int # auto fill in by trigger "user_age"
    #phone_number varchar(18), in another table "user_phone"
);

create table IF NOT EXISTS user_phone(
	user_ID int not null,
    phone_number varchar(18), # phone number storage here
    foreign key(user_ID) references User(user_ID) on delete cascade
    # when delete user, the relate phone_num will be gone
);

create table IF NOT EXISTS paying_info(
	payment_ID int primary key not null auto_increment,
    bank_account varchar(25),
    bank_num varchar(30),
    delivering_address varchar(120) not null,
    total_price decimal(8,2), # front pass the total price in cart back
    time_slot timestamp
);

create table IF NOT EXISTS product(
	product_ID int primary key auto_increment,
    product_name varchar(80),
    discount double, # front end decide value and pass in
    stock int, # auto decrease with trigger "product_stock" when the order is placed
    price decimal(8,2),
    tags varchar(80),
    sales int, # auto increase with trigger "product_stock" when the order is placed
    likes int, # front end pass if anyone likes then +1
    avg_score double # front end pass score 
    # auto update with trigger "product_score" when score is added
);

create table IF NOT EXISTS shopping_cart(
	cart_ID int primary key not null,
    product_ID int,
    quantity int,
    total_price decimal(8,2), # auto update by trigger "cart_price"
    foreign key(cart_ID) references User(user_ID) on delete cascade,
    foreign key(product_ID) references product(product_ID) on delete set null
    # if user got remove, delete whole cart
    # if product got remove before checkout, set it NULL
);

create table IF NOT EXISTS orders(
	order_ID int primary key not null auto_increment,
    payment_ID int,
    product_ID int,
    status int,
    quantity int,
    total_price decimal(8,2), # auto sum by trigger "total_product_price"
    time_slot timestamp,
    foreign key(product_ID) references product(product_ID) on delete set null,
    foreign key(payment_ID) references paying_info(payment_ID)
);

create table IF NOT EXISTS search_history(
	user_ID int not null,
	keyword varchar(80),
    foreign key(user_ID) references User(user_ID) on delete cascade
	# if user got remove, delete whole history to that user
);


# trigger part below
# user_age:
DELIMITER $$
create trigger user_age
before insert on User
for each row
begin
	if(new.age=0)
		then set new.age=0;
	else
		set new.age=TIMESTAMPDIFF(YEAR,new.birthdate,curdate());
	end if;
end;
$$
DELIMITER ;

# cart_price:
/*DELIMITER $$
create trigger cart_price
after insert on shopping_cart
for each row
begin
	-- todo
end;
$$
DELIMITER ;*/

# total_product_price:
/*DELIMITER $$
create trigger total_product_price
before insert on orders
for each row
begin
    set new.total_price=(select price * quantity
						from product p inner join orders o 
                        on p.product_ID=o.product_ID);
end;
$$
DELIMITER ;*/

# product_stock:
/*DELIMITER $$
create trigger product_stock
after insert on orders
for each row
begin
	create temporary table product_join
    (select product_ID, quantity from (product inner join orders) );
    update product
    set stock = stock - product_join.quantity
    where product_join.product_ID = product.product_ID;
    
    update product
    set sales = sales + product_join.quantity
    where product_join.product_ID = product.product_ID;
end;
$$
DELIMITER ;*/

# avg_score:
/*DELIMITER $$
create trigger avg_score
after insert on products
for each row
begin
	--todo
end;
$$
DELIMITER ;*/
