1. bid history and bidding do not work for bottoms, shoesm and search. Vamsi was working on it. they should work after he finishes.
   + few adjustments might need in searchResults, bidHistory,
   + but I am sure it will work after setting up bidding inside the shoes and bottoms.
2. I added one new table to schema.



'CREATE TABLE `tops` (
`topIdValue` int NOT NULL AUTO_INCREMENT,
`buyerIdValue` int DEFAULT NULL,
`auctionSellerIdValue` int DEFAULT NULL,
`genderValue` varchar(250) DEFAULT NULL,
`sizeValue` varchar(250) DEFAULT NULL,
`colorValue` varchar(250) DEFAULT NULL,
`frontLengthValue` float DEFAULT NULL,
`chestLengthValue` float DEFAULT NULL,
`sleeveLengthValue` float DEFAULT NULL,
`descriptionValue` varchar(250) DEFAULT NULL,
`conditionValue` varchar(250) DEFAULT NULL,
`minimumBidPriceValue` float DEFAULT NULL,
`startingOrCurrentBidPriceValue` float DEFAULT NULL,
`auctionCloseDateValue` varchar(250) DEFAULT NULL,
`auctionCloseTimeValue` varchar(250) DEFAULT NULL,
`imagePathValue` varchar(250) DEFAULT NULL,
PRIMARY KEY (`topIdValue`),
KEY `buyerIdValue` (`buyerIdValue`),
KEY `auctionSellerIdValue` (`auctionSellerIdValue`),
CONSTRAINT `tops_ibfk_1` FOREIGN KEY (`buyerIdValue`) REFERENCES `users` (`userIdValue`),
CONSTRAINT `tops_ibfk_2` FOREIGN KEY (`auctionSellerIdValue`) REFERENCES `users` (`userIdValue`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci'

'CREATE TABLE `bottoms` (
`bottomIdValue` int NOT NULL AUTO_INCREMENT,
`buyerIdValue` int DEFAULT NULL,
`auctionSellerIdValue` int DEFAULT NULL,
`genderValue` varchar(250) DEFAULT NULL,
`sizeValue` varchar(250) DEFAULT NULL,
`colorValue` varchar(250) DEFAULT NULL,
`waistLengthValue` varchar(250) DEFAULT NULL,
`inseamLengthValue` varchar(250) DEFAULT NULL,
`outseamLengthValue` varchar(250) DEFAULT NULL,
`hipLengthValue` varchar(250) DEFAULT NULL,
`riseLengthValue` varchar(250) DEFAULT NULL,
`descriptionValue` varchar(250) DEFAULT NULL,
`conditionValue` varchar(250) DEFAULT NULL,
`minimumBidPriceValue` float DEFAULT NULL,
`auctionCloseDateValue` varchar(250) DEFAULT NULL,
`auctionCloseTimeValue` varchar(250) DEFAULT NULL,
`imagePathValue` varchar(250) DEFAULT NULL,
`startingOrCurrentBidPriceValue` float DEFAULT ''0'',
PRIMARY KEY (`bottomIdValue`),
KEY `buyerIdValue` (`buyerIdValue`),
KEY `auctionSellerIdValue` (`auctionSellerIdValue`),
CONSTRAINT `bottoms_ibfk_1` FOREIGN KEY (`buyerIdValue`) REFERENCES `users` (`userIdValue`),
CONSTRAINT `bottoms_ibfk_2` FOREIGN KEY (`auctionSellerIdValue`) REFERENCES `users` (`userIdValue`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci'

'CREATE TABLE `shoes` (
`shoeIdValue` int NOT NULL AUTO_INCREMENT,
`buyerIdValue` int DEFAULT NULL,
`auctionSellerIdValue` int DEFAULT NULL,
`genderValue` varchar(250) DEFAULT NULL,
`sizeValue` varchar(250) DEFAULT NULL,
`colorValue` varchar(250) DEFAULT NULL,
`descriptionValue` varchar(250) DEFAULT NULL,
`conditionValue` varchar(250) DEFAULT NULL,
`minimumBidPriceValue` float DEFAULT NULL,
`auctionCloseDateValue` varchar(250) DEFAULT NULL,
`auctionCloseTimeValue` varchar(250) DEFAULT NULL,
`imagePathValue` varchar(250) DEFAULT NULL,
`startingOrCurrentBidPriceValue` float DEFAULT ''0'',
PRIMARY KEY (`shoeIdValue`),
KEY `buyerIdValue` (`buyerIdValue`),
KEY `auctionSellerIdValue` (`auctionSellerIdValue`),
CONSTRAINT `shoes_ibfk_1` FOREIGN KEY (`buyerIdValue`) REFERENCES `users` (`userIdValue`),
CONSTRAINT `shoes_ibfk_2` FOREIGN KEY (`auctionSellerIdValue`) REFERENCES `users` (`userIdValue`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci'

'CREATE TABLE `users` (
`userIdValue` int NOT NULL AUTO_INCREMENT,
`usernameValue` varchar(50) DEFAULT NULL,
`passwordValue` varchar(50) DEFAULT NULL,
PRIMARY KEY (`userIdValue`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci'

'CREATE TABLE `incrementbids` (
`bidIdValue` int NOT NULL AUTO_INCREMENT,
`buyerIdValue` int DEFAULT NULL,
`newBidValue` float DEFAULT NULL,
`bidIncrementValue` varchar(250) DEFAULT NULL,
`bidMaxValue` varchar(250) DEFAULT NULL,
`itemTypeValue` varchar(20) NOT NULL DEFAULT ''tops'',
`itemIdValue` int DEFAULT NULL,
PRIMARY KEY (`bidIdValue`),
KEY `buyerIdValue` (`buyerIdValue`),
CONSTRAINT `incrementbids_ibfk_2` FOREIGN KEY (`buyerIdValue`) REFERENCES `users` (`userIdValue`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci'
