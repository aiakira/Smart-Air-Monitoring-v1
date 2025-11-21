# Implementation Plan

- [x] 1. Set up database connection and environment configuration


  - Install `pg` (node-postgres) package for PostgreSQL connectivity
  - Create `.env.local` file with DATABASE_URL environment variable
  - Create `lib/db.ts` with connection pool configuration and query helper functions
  - _Requirements: 1.1, 1.2, 1.3, 1.4_



- [ ] 2. Create TypeScript type definitions
  - Create `lib/types.ts` with interfaces for SensorData, SensorDataWithCategories, KontrolData, and Notification

  - Ensure types match the database schema exactly


  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.1, 3.2, 3.3, 3.4, 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 3. Implement sensor data API routes
  - [x] 3.1 Create `/api/sensors/latest/route.ts` for retrieving the most recent sensor reading


    - Use `get_latest_reading()` database function
    - Return data with categories and air quality status
    - Handle errors and return appropriate status codes

    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 6.1, 6.4, 6.5_


  
  - [ ] 3.2 Create `/api/sensors/historical/route.ts` for retrieving historical data
    - Accept `hours` query parameter (default 24)


    - Use `get_historical_data(hours_back)` database function
    - Return chronologically ordered data with categories
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 6.1, 6.2, 6.3, 6.6_


- [x] 4. Implement control system API routes


  - [ ] 4.1 Create `/api/control/route.ts` with GET handler
    - Retrieve current fan and mode status from kontrol table
    - Return the most recent control record
    - _Requirements: 4.1_


  
  - [ ] 4.2 Add POST handler to `/api/control/route.ts`
    - Accept fan (ON/OFF) and mode (AUTO/MANUAL) in request body

    - Validate input values against allowed options


    - Insert new control record with timestamp
    - Return updated control data
    - _Requirements: 4.2, 4.3, 4.4, 4.5_



- [ ] 5. Implement notifications API routes
  - [ ] 5.1 Create `/api/notifications/route.ts` with GET handler
    - Support optional `unread` query parameter to filter unread notifications
    - Return notifications ordered by created_at descending


    - Include all notification fields (title, message, type, is_read)
    - _Requirements: 5.1, 5.2, 5.3_
  

  - [x] 5.2 Add PATCH handler to `/api/notifications/route.ts`


    - Accept notification id and is_read status in request body
    - Update the notification record in database
    - Return updated notification data
    - _Requirements: 5.4, 5.5_



- [ ] 6. Create custom React hooks for data fetching
  - [ ] 6.1 Create `hooks/use-sensor-data.ts`
    - Implement hook to fetch latest sensor data
    - Add auto-refresh functionality with configurable interval
    - Handle loading and error states


    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 6.2 Create `hooks/use-control.ts`
    - Implement hook to fetch and update control status
    - Provide updateControl function for POST requests
    - Handle loading and error states
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_
  
  - [ ] 6.3 Create `hooks/use-notifications.ts`
    - Implement hook to fetch notifications
    - Provide markAsRead function for PATCH requests
    - Handle loading and error states
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 7. Update dashboard page to use real data
  - [ ] 7.1 Replace simulated data in `app/page.tsx` with useSensorData hook
    - Remove the useEffect that generates random data
    - Use real sensor data from the database
    - Display CO2, CO, and dust values with their categories
    - Show air quality status from database function
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [ ] 7.2 Update FanControl component to use useControl hook
    - Fetch current control status on component mount
    - Update database when fan or mode is changed
    - Show loading state during updates
    - Display error messages if updates fail
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 8. Update or create notifications page
  - [ ] 8.1 Create or update notifications page at `app/notifikasi/page.tsx`
    - Use useNotifications hook to fetch notifications
    - Display notifications with title, message, type, and timestamp
    - Implement mark as read functionality
    - Show unread badge or indicator
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 9. Update or create historical data page
  - [ ] 9.1 Create or update historical page at `app/riwayat/page.tsx`
    - Fetch historical data using the historical API endpoint
    - Display data in a table or chart format
    - Allow users to select time range (1-24 hours)
    - Show categories for each reading
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ] 10. Add error handling and user feedback
  - Display toast notifications for API errors
  - Show loading spinners during data fetches
  - Implement retry mechanisms for failed requests
  - Add error boundaries for component-level errors
  - _Requirements: 1.4_
