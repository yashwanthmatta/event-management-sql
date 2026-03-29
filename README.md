# Event Management System — SQL Database Design

> **Relational database design and implementation** for a real-world event planning company — 8 normalized tables, full Oracle SQL schema, 190+ sample records, and 8 analytical business queries.

---

## Project Overview

Event Ease Planners manages hundreds of weddings, conferences, workshops, and private parties every year — but was running entirely on spreadsheets and emails. Scheduling conflicts, payment errors, and data inconsistency were costing the business time and money.

This project designs and implements a **centralized relational database** that brings every operation into one place: client bookings, venue scheduling, vendor coordination, staff assignment, invoice tracking, and payment management.

**Built for:** DBMS Course | University of Colorado Denver
**Platform:** Oracle Autonomous Database (Oracle Cloud)
**Author:** Yashwanth Goud Matta

---

## Database Schema

8 fully normalized tables with primary keys, foreign keys, and CHECK constraints:

```
CLIENT ──────────────── EVENT ─────────────── VENUE
                          │
                    EVENT_VENDOR ──────────── VENDOR
                          │
                       INVOICE
                          │
                       PAYMENT

STAFF (assigned to events via EventStaffAssignments)
```

### Table Definitions

| Table | Rows (sample) | Purpose |
|---|---|---|
| CLIENT | 10 | Client contact details and preferences |
| VENUE | 5 | Venue capacity, location, availability status |
| VENDOR | 6 | External service providers by category |
| STAFF | 5 | Internal team members and roles |
| EVENT | 6 | Core event records — links client, venue, type, date, budget |
| EVENT_VENDOR | 12 | Junction table — vendors assigned to events with costs |
| INVOICE | 6 | Billing per event — amount, date, status |
| PAYMENT | 3 | Deposits and final payments per invoice |

---

## Schema Design Highlights

**Normalization:** All tables in 3NF — no transitive dependencies, no repeating groups

**Constraints used:**
- `PRIMARY KEY` on all tables
- `FOREIGN KEY` with referential integrity across EVENT → CLIENT, VENUE; EVENT_VENDOR → EVENT, VENDOR; INVOICE → EVENT; PAYMENT → INVOICE
- `CHECK` constraints enforcing valid values: availability status, event type, payment method, service type
- `UNIQUE` constraint on client and staff email
- `DEFAULT` values for status fields

**Junction table:** `EVENT_VENDOR` resolves the many-to-many relationship between events and vendors, storing scope of work and agreed cost per assignment

---

## Sample Data

```sql
-- Client example
INSERT INTO CLIENT VALUES (201,'Alice','Johnson','alice@acme.com','303-555-1001','Denver');

-- Event example (Wedding, $50K budget, 200 guests)
INSERT INTO EVENT VALUES (601,201,301,'WEDDING',DATE '2025-06-15',DATE '2025-06-14',200,'CONFIRMED',50000);

-- Vendor assignment with cost
INSERT INTO EVENT_VENDOR VALUES (601,401,'Full catering package — 200 guests', 18000);

-- Invoice and deposit payment
INSERT INTO INVOICE VALUES (701,601,52000,DATE '2025-06-01','PARTIAL');
INSERT INTO PAYMENT VALUES (801,701,26000,DATE '2025-06-05','CREDIT');
```

---

## Analytical Queries

8 business-intelligence queries built to answer real operational questions:

| Query | Business Question |
|---|---|
| 1. Upcoming events | All events with client, venue, date, and status |
| 2. Budget utilization | Vendor costs vs. event budget — % spent per event |
| 3. Outstanding balances | Invoice total, amount paid, balance due per client |
| 4. Vendor utilization | Events assigned, total revenue, avg. cost per vendor |
| 5. Venue occupancy | Booking count and total guests per venue |
| 6. Revenue by event type | Total and average budget across wedding, conference, etc. |
| 7. Repeat clients | Clients with multiple bookings and total spend |
| 8. Gap analysis | Events with no vendor assigned (operational risk) |

### Sample query output — Budget Utilization

```sql
SELECT
    e.event_id,
    e.event_type,
    e.budget                          AS total_budget,
    SUM(ev.agreed_cost)               AS total_vendor_cost,
    e.budget - SUM(ev.agreed_cost)    AS remaining_budget,
    ROUND(SUM(ev.agreed_cost)/e.budget*100,1) AS pct_spent
FROM EVENT e
JOIN EVENT_VENDOR ev ON e.event_id = ev.event_id
GROUP BY e.event_id, e.event_type, e.budget
ORDER BY pct_spent DESC;
```

---

## Business Problems Solved

| Problem | Database Solution |
|---|---|
| Double-booked venues | `VENUE.availability` CHECK constraint + status tracking |
| Missed payments | INVOICE + PAYMENT tables with balance calculation queries |
| Vendor conflicts | EVENT_VENDOR junction table prevents double-assignment |
| No reporting capability | 8 analytical SQL queries covering all key business metrics |
| Spreadsheet chaos | Single normalized schema replaces all disconnected spreadsheets |

---

## How to Run

**Option 1 — Oracle Autonomous Database (original platform):**
1. Create a free Oracle Cloud account at cloud.oracle.com
2. Provision an Autonomous Database (Always Free tier available)
3. Open Database Actions → SQL Worksheet
4. Paste and run `event_management_schema.sql`

**Option 2 — Local Oracle XE:**
```bash
sqlplus admin@localhost/FREEPDB1 @event_management_schema.sql
```

**Option 3 — Adapt for PostgreSQL:**
Replace `NUMBER` → `INTEGER`, `VARCHAR2` → `VARCHAR`, remove `/` PL/SQL block delimiters

---

## Tech Stack

| Category | Detail |
|---|---|
| Database | Oracle Autonomous Database (Cloud) |
| Language | Oracle SQL / PL/SQL |
| Schema Design | 3NF normalization, ERD, relational modeling |
| Constraints | PRIMARY KEY, FOREIGN KEY, CHECK, UNIQUE, DEFAULT |
| Analytics | 8 business intelligence queries with JOINs, aggregations, subqueries |

---

## Project Structure

```
event-management-sql/
│
├── event_management_schema.sql    # Full schema: DROP, CREATE, INSERT, queries
├── README.md
└── docs/
    └── project_proposal.pdf       # Business requirements and entity design
```

---

## About

**Yashwanth Goud Matta**
M.S. Business Analytics — University of Colorado Denver (2025)
B.Tech Computer Science — Bennett University (2024)


