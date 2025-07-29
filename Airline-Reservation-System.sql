CREATE DATABASE AIRLINE_RESERVATION_SYSTEM;
USE AIRLINE_RESERVATION_SYSTEM;

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 1. Design Schema.

-- Flights Table
CREATE TABLE Flights (
    FlightID INT PRIMARY KEY AUTO_INCREMENT,
    FlightNumber VARCHAR(10),
    DepartureAirport VARCHAR(50),
    ArrivalAirport VARCHAR(50),
    DepartureTime DATETIME,
    ArrivalTime DATETIME
);

-- Customers Table
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100)
);

-- Seats Table
CREATE TABLE Seats (
    SeatID INT PRIMARY KEY AUTO_INCREMENT,
    FlightID INT,
    SeatNumber VARCHAR(10),
    IsBooked BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (FlightID) REFERENCES Flights(FlightID)
);

-- Bookings Table
CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    FlightID INT,
    SeatID INT,
    BookingDate DATETIME,
    Status ENUM('Booked', 'Cancelled') DEFAULT 'Booked',
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (FlightID) REFERENCES Flights(FlightID),
    FOREIGN KEY (SeatID) REFERENCES Seats(SeatID)
);

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 2. Normalize Schema and Define Constraints:

-- 3NF normalization achieved by separating flights, customers, seats, and bookings.
-- Constraints used: FOREIGN KEY on CustomerID, FlightID, and SeatID, ENUM for status, AUTO_INCREMENT for primary keys, Boolean IsBooked in Seats.

-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- 3. Inserting Sample Data.

INSERT INTO Flights (FlightNumber, DepartureAirport, ArrivalAirport, DepartureTime, ArrivalTime) VALUES
('AI101', 'Mumbai', 'Delhi', '2025-07-22 08:00:00', '2025-07-22 10:00:00'),
('AI102', 'Delhi', 'Bangalore', '2025-07-23 09:30:00', '2025-07-23 12:00:00'),
('AI103', 'Mumbai', 'Chennai', '2025-07-24 07:00:00', '2025-07-24 09:45:00'),
('AI104', 'Kolkata', 'Hyderabad', '2025-07-25 14:00:00', '2025-07-25 16:30:00'),
('AI105', 'Bangalore', 'Pune', '2025-07-26 10:15:00', '2025-07-26 11:45:00'),
('AI106', 'Hyderabad', 'Mumbai', '2025-07-27 17:00:00', '2025-07-27 19:00:00');

INSERT INTO Customers (FirstName, LastName, Email) VALUES
('Andrew', 'Garfield', 'andrew.garfield@example.com'),
('Ben', 'Tennyson', 'ben.tennyson@example.com'),
('Clark', 'Kent', 'clark.kent@example.com'),
('Peter', 'Parker', 'peter.parker@example.com'),
('Gwen', 'Stacy', 'gwen.stacy@example.com'),
('Franklin', 'Richards', 'franklin.richards@example.com');

-- Seats for all Flights
INSERT INTO Seats (FlightID, SeatNumber) VALUES
-- FlightID 1
(1, '1A'), (1, '1B'), (1, '1C'),

-- FlightID 2
(2, '1A'), (2, '1B'), (2, '1C'), (2, '2A'), (2, '2B'),

-- FlightID 3
(3, '1A'), (3, '1B'), (3, '1C'), (3, '2A'), (3, '2B'),

-- FlightID 4
(4, '1A'), (4, '1B'), (4, '2A'),

-- FlightID 5
(5, '1A'), (5, '1B'), (5, '1C'),

-- FlightID 6
(6, '1A'), (6, '1B'), (6, '1C');

-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 4. Writing queries.

-- Available Seats on Flight 2:
SELECT SeatNumber
FROM Seats
WHERE FlightID = 2 AND IsBooked = FALSE;

-- Search Flights from Hyderabad to Mumbai:
SELECT * 
FROM Flights
WHERE DepartureAirport = 'Hyderabad' AND ArrivalAirport = 'Mumbai';

-- ---------------------------------------------------------------------------------------------------------------------------------------------
-- 5. Add Triggers

-- Mark seat as booked after booking
DELIMITER //
CREATE TRIGGER AfterBookingInsert
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
    UPDATE Seats SET IsBooked = TRUE WHERE SeatID = NEW.SeatID;
END;
//
DELIMITER 

-- Mark seat as available after cancellation
DELIMITER //
CREATE TRIGGER AfterBookingUpdate
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Cancelled' THEN
        UPDATE Seats SET IsBooked = FALSE WHERE SeatID = NEW.SeatID;
    END IF;
END;
//
DELIMITER ;

-- ----------------------------------------------------------------------------------------------------------------------------------------------
-- 6. Generate Booking Summary Report:

SELECT 
    b.BookingID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    f.FlightNumber,
    s.SeatNumber,
    b.BookingDate,
    b.Status
FROM Bookings b
JOIN Customers c ON b.CustomerID = c.CustomerID
JOIN Flights f ON b.FlightID = f.FlightID
JOIN Seats s ON b.SeatID = s.SeatID;

-- --------------------------------------------------------------------------------------------------------------------------------------------
-- 7. Flight Availability Views (optional): 

CREATE VIEW FlightAvailability AS
SELECT f.FlightNumber, f.DepartureAirport, f.ArrivalAirport, f.DepartureTime, f.ArrivalTime, s.SeatNumber
FROM Flights f
JOIN Seats s ON f.FlightID = s.FlightID
WHERE s.IsBooked = FALSE;

-- Show available seats using the view
SELECT * FROM FlightAvailability;

