# Requirements Document

## Introduction

This document outlines the requirements for integrating a PostgreSQL database (Neon) with the Smart Air Monitor Next.js application. The system monitors air quality through CO2, CO, and dust sensors, provides control mechanisms for ventilation fans, and sends notifications based on air quality status.

## Glossary

- **Application**: The Smart Air Monitor Next.js web application
- **Database**: The PostgreSQL database hosted on Neon cloud platform
- **Sensor Data**: Real-time measurements of CO2, CO, and dust levels
- **Control System**: The fan control mechanism with AUTO and MANUAL modes
- **Notification System**: Alert mechanism for air quality warnings
- **API Routes**: Next.js server-side endpoints for database operations

## Requirements

### Requirement 1

**User Story:** As a developer, I want to establish a secure database connection, so that the application can communicate with the PostgreSQL database

#### Acceptance Criteria

1. THE Application SHALL store the database connection string in environment variables
2. THE Application SHALL establish a connection to the Database using the provided PostgreSQL connection string
3. WHEN the Application starts, THE Application SHALL verify the Database connection is successful
4. IF the Database connection fails, THEN THE Application SHALL log the error with connection details

### Requirement 2

**User Story:** As a user, I want to view the latest sensor readings, so that I can monitor current air quality

#### Acceptance Criteria

1. THE Application SHALL retrieve the most recent Sensor Data from the Database
2. THE Application SHALL display CO2 levels with their category classification
3. THE Application SHALL display CO levels with their category classification
4. THE Application SHALL display dust levels with their category classification
5. THE Application SHALL display the overall air quality status based on all sensor readings

### Requirement 3

**User Story:** As a user, I want to view historical sensor data, so that I can analyze air quality trends over time

#### Acceptance Criteria

1. THE Application SHALL retrieve historical Sensor Data for a specified time period
2. THE Application SHALL support querying data from the last 1 hour to 24 hours
3. THE Application SHALL display historical data in chronological order
4. THE Application SHALL include category classifications for each historical reading

### Requirement 4

**User Story:** As a user, I want to control the ventilation fan, so that I can manage air circulation

#### Acceptance Criteria

1. THE Application SHALL retrieve the current Control System status from the Database
2. THE Application SHALL allow toggling the fan between ON and OFF states
3. THE Application SHALL allow switching between AUTO and MANUAL modes
4. WHEN a control change is made, THE Application SHALL update the Control System record in the Database
5. THE Application SHALL record the timestamp of each control change

### Requirement 5

**User Story:** As a user, I want to receive notifications about air quality, so that I can be alerted to dangerous conditions

#### Acceptance Criteria

1. THE Application SHALL retrieve unread notifications from the Notification System
2. THE Application SHALL display notifications with title, message, and type
3. THE Application SHALL support notification types: warning, danger, info, and success
4. THE Application SHALL allow marking notifications as read
5. WHEN a notification is marked as read, THE Application SHALL update the is_read status in the Database

### Requirement 6

**User Story:** As a developer, I want to use database helper functions, so that air quality calculations are consistent

#### Acceptance Criteria

1. THE Application SHALL utilize the get_co2_category function for CO2 classification
2. THE Application SHALL utilize the get_co_category function for CO classification
3. THE Application SHALL utilize the get_dust_category function for dust classification
4. THE Application SHALL utilize the get_air_quality_status function for overall status
5. THE Application SHALL utilize the get_latest_reading function for current data retrieval
6. THE Application SHALL utilize the get_historical_data function for historical data retrieval
