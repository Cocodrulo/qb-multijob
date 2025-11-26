CREATE TABLE IF NOT EXISTS `player_multijob` (
    `citizenid` VARCHAR(50) NOT NULL,
    `job` VARCHAR(50) NOT NULL,
    `grade` INT NOT NULL,
    PRIMARY KEY (`citizenid`, `job`),
    INDEX `job` (`job`),
    FOREIGN KEY (`citizenid`) REFERENCES `players`(`citizenid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
