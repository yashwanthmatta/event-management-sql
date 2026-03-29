-- =============================================================================
-- Event Management System — Event Ease Planners
-- Database Management Systems (DBMS) Course Project
-- University of Colorado Denver
-- Author: Yashwanth Goud Matta
-- Platform: Oracle Autonomous Database (Oracle Cloud)
-- =============================================================================
-- SCHEMA OVERVIEW:
--   CLIENT        — client personal details and contact info
--   VENUE         — venue details, capacity, availability status
--   VENDOR        — service providers (catering, decoration, photography)
--   STAFF         — internal team members and their roles
--   EVENT         — core event records linking clients, venues, and details
--   EVENT_VENDOR  — junction table: vendors assigned to events
--   INVOICE       — billing records per event
--   PAYMENT       — deposit and final payment tracking per invoice
-- =============================================================================


-- =============================================================================
-- STEP 1: DROP TABLES (clean slate for re-runs)
-- =============================================================================

BEGIN
  FOR t IN (SELECT table_name FROM user_tables
            WHERE table_name IN (
              'PAYMENT','INVOICE','EVENT_VENDOR',
              'EVENT','STAFF','VENDOR','VENUE','CLIENT'
            ))
  LOOP
    EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
  END LOOP;
END;
/


-- =============================================================================
-- STEP 2: CREATE TABLES
-- =============================================================================

-- Clients
CREATE TABLE CLIENT (
  client_id   NUMBER        CONSTRAINT pk_client   PRIMARY KEY,
  first_name  VARCHAR2(40)  NOT NULL,
  last_name   VARCHAR2(40)  NOT NULL,
  email       VARCHAR2(120) CONSTRAINT uq_client_email UNIQUE,
  phone       VARCHAR2(20),
  city        VARCHAR2(60)
);

-- Venues
CREATE TABLE VENUE (
  venue_id     NUMBER        CONSTRAINT pk_venue    PRIMARY KEY,
  venue_name   VARCHAR2(120) NOT NULL,
  city         VARCHAR2(60)  NOT NULL,
  state        VARCHAR2(30)  NOT NULL,
  capacity     NUMBER        CONSTRAINT ck_venue_cap CHECK (capacity > 0),
  availability VARCHAR2(20)  DEFAULT 'AVAILABLE'
                             CONSTRAINT ck_venue_avail
                             CHECK (availability IN ('AVAILABLE','BOOKED','MAINTENANCE'))
);

-- Vendors (external service providers)
CREATE TABLE VENDOR (
  vendor_id    NUMBER        CONSTRAINT pk_vendor   PRIMARY KEY,
  vendor_name  VARCHAR2(120) NOT NULL,
  service_type VARCHAR2(40)  NOT NULL
                             CONSTRAINT ck_vendor_type
                             CHECK (service_type IN ('CATERING','DECORATION',
                                                      'PHOTOGRAPHY','MUSIC',
                                                      'TRANSPORT','OTHER')),
  email        VARCHAR2(120),
  phone        VARCHAR2(20)
);

-- Staff (internal team)
CREATE TABLE STAFF (
  staff_id   NUMBER        CONSTRAINT pk_staff    PRIMARY KEY,
  first_name VARCHAR2(40)  NOT NULL,
  last_name  VARCHAR2(40)  NOT NULL,
  role       VARCHAR2(60)  NOT NULL,
  email      VARCHAR2(120) CONSTRAINT uq_staff_email UNIQUE,
  phone      VARCHAR2(20)
);

-- Events (core table)
CREATE TABLE EVENT (
  event_id     NUMBER        CONSTRAINT pk_event    PRIMARY KEY,
  client_id    NUMBER        NOT NULL,
  venue_id     NUMBER        NOT NULL,
  event_type   VARCHAR2(40)  NOT NULL
                             CONSTRAINT ck_event_type
                             CHECK (event_type IN ('WEDDING','CONFERENCE',
                                                    'WORKSHOP','PARTY','OTHER')),
  event_date   DATE          NOT NULL,
  setup_date   DATE,
  guest_count  NUMBER        CONSTRAINT ck_guest_count CHECK (guest_count > 0),
  status       VARCHAR2(20)  DEFAULT 'PLANNED'
                             CONSTRAINT ck_event_status
                             CHECK (status IN ('PLANNED','CONFIRMED',
                                               'COMPLETED','CANCELLED')),
  budget       NUMBER        CONSTRAINT ck_event_budget CHECK (budget >= 0),
  CONSTRAINT fk_event_client FOREIGN KEY (client_id) REFERENCES CLIENT(client_id),
  CONSTRAINT fk_event_venue  FOREIGN KEY (venue_id)  REFERENCES VENUE(venue_id)
);

-- Event-Vendor Assignments (junction table)
CREATE TABLE EVENT_VENDOR (
  event_id      NUMBER        NOT NULL,
  vendor_id     NUMBER        NOT NULL,
  scope_of_work VARCHAR2(200),
  agreed_cost   NUMBER        CONSTRAINT ck_ev_cost CHECK (agreed_cost >= 0),
  CONSTRAINT pk_event_vendor  PRIMARY KEY (event_id, vendor_id),
  CONSTRAINT fk_ev_event      FOREIGN KEY (event_id)  REFERENCES EVENT(event_id),
  CONSTRAINT fk_ev_vendor     FOREIGN KEY (vendor_id) REFERENCES VENDOR(vendor_id)
);

-- Invoices
CREATE TABLE INVOICE (
  invoice_id   NUMBER        CONSTRAINT pk_invoice  PRIMARY KEY,
  event_id     NUMBER        NOT NULL,
  amount_total NUMBER        CONSTRAINT ck_invoice_amount CHECK (amount_total >= 0),
  invoice_date DATE          NOT NULL,
  status       VARCHAR2(20)  DEFAULT 'PENDING'
                             CONSTRAINT ck_invoice_status
                             CHECK (status IN ('PENDING','PARTIAL','PAID','OVERDUE')),
  CONSTRAINT fk_invoice_event FOREIGN KEY (event_id) REFERENCES EVENT(event_id)
);

-- Payments
CREATE TABLE PAYMENT (
  payment_id     NUMBER        CONSTRAINT pk_payment  PRIMARY KEY,
  invoice_id     NUMBER        NOT NULL,
  amount         NUMBER        CONSTRAINT ck_payment_amount CHECK (amount > 0),
  payment_date   DATE          NOT NULL,
  payment_method VARCHAR2(20)  CONSTRAINT ck_pay_method
                               CHECK (payment_method IN ('CREDIT','DEBIT',
                                                          'CASH','WIRE','CHECK')),
  CONSTRAINT fk_payment_invoice FOREIGN KEY (invoice_id) REFERENCES INVOICE(invoice_id)
);


-- =============================================================================
-- STEP 3: INSERT SAMPLE DATA
-- =============================================================================

-- Clients (10 records)
INSERT INTO CLIENT VALUES (201,'Alice','Johnson','alice@acme.com','303-555-1001','Denver');
INSERT INTO CLIENT VALUES (202,'Bob','Martinez','bob@gmail.com','303-555-1002','Aurora');
INSERT INTO CLIENT VALUES (203,'Carol','Smith','carol@outlook.com','720-555-1003','Lakewood');
INSERT INTO CLIENT VALUES (204,'David','Lee','david.lee@yahoo.com','720-555-1004','Boulder');
INSERT INTO CLIENT VALUES (205,'Emma','Wilson','emma.w@corp.com','303-555-1005','Denver');
INSERT INTO CLIENT VALUES (206,'Frank','Brown','frank.b@biz.com','720-555-1006','Arvada');
INSERT INTO CLIENT VALUES (207,'Grace','Taylor','grace.t@mail.com','303-555-1007','Denver');
INSERT INTO CLIENT VALUES (208,'Henry','Anderson','henry.a@web.com','720-555-1008','Westminster');
INSERT INTO CLIENT VALUES (209,'Iris','Thomas','iris.t@net.com','303-555-1009','Thornton');
INSERT INTO CLIENT VALUES (210,'Jack','Jackson','jack.j@org.com','720-555-1010','Denver');

-- Venues (5 records)
INSERT INTO VENUE VALUES (301,'Skyline Ballroom','Denver','CO',420,'AVAILABLE');
INSERT INTO VENUE VALUES (302,'Mountain View Conference Center','Boulder','CO',300,'AVAILABLE');
INSERT INTO VENUE VALUES (303,'Lakewood Garden Hall','Lakewood','CO',180,'AVAILABLE');
INSERT INTO VENUE VALUES (304,'Aurora Grand Events','Aurora','CO',500,'BOOKED');
INSERT INTO VENUE VALUES (305,'Denver Tech Hub','Denver','CO',250,'AVAILABLE');

-- Vendors (6 records)
INSERT INTO VENDOR VALUES (401,'TasteBuds Catering','CATERING','hello@tastebuds.com','720-555-1111');
INSERT INTO VENDOR VALUES (402,'Blooms & Decor','DECORATION','info@bloomsdecor.com','303-555-2222');
INSERT INTO VENDOR VALUES (403,'Moments Photography','PHOTOGRAPHY','shoot@moments.com','720-555-3333');
INSERT INTO VENDOR VALUES (404,'Elite Sound & Music','MUSIC','book@elitesound.com','303-555-4444');
INSERT INTO VENDOR VALUES (405,'Swift Transport Co.','TRANSPORT','fleet@swift.com','720-555-5555');
INSERT INTO VENDOR VALUES (406,'AllEvent Services','OTHER','help@allevent.com','303-555-6666');

-- Staff (5 records)
INSERT INTO STAFF VALUES (501,'Anita','Patel','Event Manager','anita@eep.com','720-666-1001');
INSERT INTO STAFF VALUES (502,'Brian','Nguyen','Assistant Manager','brian@eep.com','720-666-1002');
INSERT INTO STAFF VALUES (503,'Clara','Rodriguez','Coordinator','clara@eep.com','720-666-1003');
INSERT INTO STAFF VALUES (504,'Derek','Kim','Finance Lead','derek@eep.com','720-666-1004');
INSERT INTO STAFF VALUES (505,'Ellen','Park','Client Relations','ellen@eep.com','720-666-1005');

-- Events (6 records)
INSERT INTO EVENT VALUES (601,201,301,'WEDDING',   DATE '2025-06-15',DATE '2025-06-14',200,'CONFIRMED',50000);
INSERT INTO EVENT VALUES (602,202,302,'CONFERENCE',DATE '2025-07-10',DATE '2025-07-09',150,'PLANNED',  30000);
INSERT INTO EVENT VALUES (603,203,303,'PARTY',     DATE '2025-08-20',DATE '2025-08-20', 80,'PLANNED',  12000);
INSERT INTO EVENT VALUES (604,204,305,'WORKSHOP',  DATE '2025-09-05',DATE '2025-09-05',100,'PLANNED',  15000);
INSERT INTO EVENT VALUES (605,205,301,'WEDDING',   DATE '2025-10-12',DATE '2025-10-11',250,'PLANNED',  65000);
INSERT INTO EVENT VALUES (606,206,302,'CONFERENCE',DATE '2025-11-18',DATE '2025-11-17',200,'PLANNED',  40000);

-- Event-Vendor Assignments
INSERT INTO EVENT_VENDOR VALUES (601,401,'Full catering package — 200 guests',        18000);
INSERT INTO EVENT_VENDOR VALUES (601,402,'Wedding floral decoration and setup',        8000);
INSERT INTO EVENT_VENDOR VALUES (601,403,'Full-day wedding photography + album',       5500);
INSERT INTO EVENT_VENDOR VALUES (601,404,'Live band — 6 hours',                       4000);
INSERT INTO EVENT_VENDOR VALUES (602,401,'Lunch buffet for 150 conference attendees',  9000);
INSERT INTO EVENT_VENDOR VALUES (602,403,'Event photography — half day',              2500);
INSERT INTO EVENT_VENDOR VALUES (603,401,'Cocktail catering — 80 guests',             4500);
INSERT INTO EVENT_VENDOR VALUES (603,402,'Party decoration package',                  3000);
INSERT INTO EVENT_VENDOR VALUES (604,406,'Workshop logistics and AV support',         3500);
INSERT INTO EVENT_VENDOR VALUES (605,401,'Premium catering — 250 guests',            22000);
INSERT INTO EVENT_VENDOR VALUES (605,402,'Premium wedding decor',                    10000);
INSERT INTO EVENT_VENDOR VALUES (605,403,'Full wedding photography + videography',    8000);

-- Invoices
INSERT INTO INVOICE VALUES (701,601,52000,DATE '2025-06-01','PARTIAL');
INSERT INTO INVOICE VALUES (702,602,31000,DATE '2025-07-01','PENDING');
INSERT INTO INVOICE VALUES (703,603,13000,DATE '2025-08-01','PENDING');
INSERT INTO INVOICE VALUES (704,604,16000,DATE '2025-09-01','PENDING');
INSERT INTO INVOICE VALUES (705,605,68000,DATE '2025-10-01','PENDING');
INSERT INTO INVOICE VALUES (706,606,42000,DATE '2025-11-01','PENDING');

-- Payments (deposits received)
INSERT INTO PAYMENT VALUES (801,701,26000,DATE '2025-06-05','CREDIT');
INSERT INTO PAYMENT VALUES (802,702,15500,DATE '2025-07-03','WIRE');
INSERT INTO PAYMENT VALUES (803,703, 6500,DATE '2025-08-03','DEBIT');

COMMIT;


-- =============================================================================
-- STEP 4: ANALYTICAL QUERIES
-- =============================================================================

-- Query 1: All upcoming events with client and venue details
SELECT
    e.event_id,
    c.first_name || ' ' || c.last_name  AS client_name,
    v.venue_name,
    e.event_type,
    e.event_date,
    e.guest_count,
    e.status,
    e.budget
FROM EVENT e
JOIN CLIENT c ON e.client_id = c.client_id
JOIN VENUE  v ON e.venue_id  = v.venue_id
ORDER BY e.event_date;


-- Query 2: Total vendor costs per event vs. event budget (budget utilization)
SELECT
    e.event_id,
    e.event_type,
    e.budget                          AS total_budget,
    SUM(ev.agreed_cost)               AS total_vendor_cost,
    e.budget - SUM(ev.agreed_cost)    AS remaining_budget,
    ROUND(SUM(ev.agreed_cost) / e.budget * 100, 1) AS pct_spent
FROM EVENT e
JOIN EVENT_VENDOR ev ON e.event_id = ev.event_id
GROUP BY e.event_id, e.event_type, e.budget
ORDER BY pct_spent DESC;


-- Query 3: Invoice and payment status — outstanding balances
SELECT
    i.invoice_id,
    e.event_type,
    c.first_name || ' ' || c.last_name  AS client_name,
    i.amount_total                       AS invoice_total,
    NVL(SUM(p.amount), 0)               AS total_paid,
    i.amount_total - NVL(SUM(p.amount), 0) AS balance_due,
    i.status
FROM INVOICE i
JOIN EVENT  e ON i.event_id  = e.event_id
JOIN CLIENT c ON e.client_id = c.client_id
LEFT JOIN PAYMENT p ON i.invoice_id = p.invoice_id
GROUP BY i.invoice_id, e.event_type, c.first_name, c.last_name,
         i.amount_total, i.status
ORDER BY balance_due DESC;


-- Query 4: Vendor utilization — how many events each vendor is assigned to
SELECT
    v.vendor_name,
    v.service_type,
    COUNT(ev.event_id)        AS total_events,
    SUM(ev.agreed_cost)       AS total_revenue,
    ROUND(AVG(ev.agreed_cost),0) AS avg_per_event
FROM VENDOR v
LEFT JOIN EVENT_VENDOR ev ON v.vendor_id = ev.vendor_id
GROUP BY v.vendor_id, v.vendor_name, v.service_type
ORDER BY total_revenue DESC NULLS LAST;


-- Query 5: Venue booking status and capacity utilization
SELECT
    v.venue_name,
    v.city,
    v.capacity,
    v.availability,
    COUNT(e.event_id)       AS events_scheduled,
    NVL(SUM(e.guest_count),0) AS total_guests_served
FROM VENUE v
LEFT JOIN EVENT e ON v.venue_id = e.venue_id
GROUP BY v.venue_id, v.venue_name, v.city, v.capacity, v.availability
ORDER BY events_scheduled DESC;


-- Query 6: Revenue summary by event type
SELECT
    event_type,
    COUNT(*)                    AS total_events,
    SUM(budget)                 AS total_budget,
    ROUND(AVG(budget), 0)       AS avg_budget,
    MIN(budget)                 AS min_budget,
    MAX(budget)                 AS max_budget
FROM EVENT
GROUP BY event_type
ORDER BY total_budget DESC;


-- Query 7: Clients with multiple bookings (repeat customers)
SELECT
    c.client_id,
    c.first_name || ' ' || c.last_name  AS client_name,
    c.city,
    COUNT(e.event_id)                   AS total_bookings,
    SUM(e.budget)                       AS total_spend
FROM CLIENT c
JOIN EVENT e ON c.client_id = e.client_id
GROUP BY c.client_id, c.first_name, c.last_name, c.city
HAVING COUNT(e.event_id) >= 1
ORDER BY total_spend DESC;


-- Query 8: Events with no vendor assigned (gap analysis)
SELECT
    e.event_id,
    e.event_type,
    e.event_date,
    e.status
FROM EVENT e
WHERE NOT EXISTS (
    SELECT 1 FROM EVENT_VENDOR ev
    WHERE ev.event_id = e.event_id
)
ORDER BY e.event_date;
