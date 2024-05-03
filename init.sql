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
CREATE TABLE bitch (
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
VALUES("Notpotato");
