CREATE TABLE IF NOT EXISTS `multijob` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `player_cid` VARCHAR(50) NOT NULL,
    `job` VARCHAR(50) NOT NULL,
    `grade` INT NOT NULL,
    PRIMARY KEY (`id`),
    INDEX (`player_cid`),
    FOREIGN KEY (`player_cid`) REFERENCES `players`(`citizenid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
