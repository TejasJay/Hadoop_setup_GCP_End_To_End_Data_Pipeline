USE taxi;

-- Total Trips
INSERT OVERWRITE LOCAL DIRECTORY '~/reports/total_trips'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT SUM(TripsPerDay) AS total_trips FROM taxi_data;

-- Average Farebox Per Day
INSERT OVERWRITE LOCAL DIRECTORY '~/reports/average_farebox'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT AVG(FareboxPerDay) AS avg_farebox FROM taxi_data;

-- Unique Drivers Count
INSERT OVERWRITE LOCAL DIRECTORY '~/reports/unique_drivers'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT SUM(UniqueDrivers) AS total_unique_drivers FROM taxi_data;

-- Unique Vehicles Count
INSERT OVERWRITE LOCAL DIRECTORY '~/reports/unique_vehicles'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT SUM(UniqueVehicles) AS total_unique_vehicles FROM taxi_data;

-- Average Hours Per Day Per Vehicle
INSERT OVERWRITE LOCAL DIRECTORY '~/reports/avg_hours_per_vehicle'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT AVG(AvgHoursPerDayPerVehicle) AS avg_hours_vehicle FROM taxi_data;

-- Average Hours Per Day Per Driver
INSERT OVERWRITE LOCAL DIRECTORY '~/reports/avg_hours_per_driver'
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
SELECT AVG(AvgHoursPerDayPerDriver) AS avg_hours_driver FROM taxi_data;
