CREATE TABLE IF NOT EXISTS `players` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) NOT NULL,
  `license` VARCHAR(50) NOT NULL,
  `firstname` VARCHAR(50) NOT NULL,
  `lastname` VARCHAR(50) NOT NULL,
  `cash` INT NOT NULL DEFAULT 5000,
  `bank` INT NOT NULL DEFAULT 15000,
  -- Appended native fallback strings to prevent profile insertion faults
  `job` LONGTEXT NOT NULL DEFAULT '{"name":"unemployed","grade":0,"onDuty":true}',
  `gang` LONGTEXT NOT NULL DEFAULT '{"name":"none","grade":0}',
  `metadata` LONGTEXT NOT NULL DEFAULT '{"hunger":100,"thirst":100,"isdead":false,"inlaststand":false}',
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizenid` (`citizenid`),
  KEY `license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
