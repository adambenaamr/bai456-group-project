/*
TABLE: DEPARTMENT
PURPOSE:
  Stores organziational departments within the company.
  Each department represents a function unit resposible
  for a specific service (e.g., Cloud, Cybersecurity, etc.)

DESIGN NOTES:
  - `DEPT_ID` is a manually assigned unique identifier.
  - `DEPT_NAME` is unique to prevent duplicate departments.
  - `LOCATION` and `STATE` are separated for normalization.
  - `BUDGET` represents annual allocated funds.

CONSTRAINTS:
  Primary Key: `DEPT_ID`
  Unique: `DEPT_NAME`

  All fields are required (NOT NULL).
*/
CREATE TABLE DEPARTMENT(
  DEPT_ID NUMBER(4) PRIMARY KEY,
  DEPT_NAME VARCHAR2(50) NOT NULL UNIQUE,
  DEPT_LOCATION VARCHAR2(20) NOT NULL,
  DEPT_STATE VARCHAR2(2) NOT NULL,
  DEPT_BUDGET NUMBER(10, 2) NOT NULL
);

/*
TABLE: CLIENT
PURPOSE:
  Stores all client organizations that purchase services
  and software licenses from the comapny.

DESIGN NOTES:
  - `CLIENT_TIER` represents service level (e.g., Basic, Pro, Enterprise).
  - `CLIENT_EMIAL` must be unique to prevent duplicate accounts.
  - `CLIENT_PHONE` uses fixed format (XXX-XXX-XXXX).

CONSTRAINTS:
  Primary Key: `CLIENT_ID`
  Unique: `CLIENT_EMAIL`

  All fields are required (NOT NULL).
*/
CREATE TABLE CLIENT(
  CLIENT_ID NUMBER(6) PRIMARY KEY,
  CLIENT_NAME VARCHAR2(100) NOT NULL,
  CLIENT_INDUSTRY VARCHAR2(50) NOT NULL,
  CLIENT_EMAIL VARCHAR2(100) NOT NULL UNIQUE,
  CLIENT_PHONE CHAR(12) NOT NULL,
  CLIENT_STATE CHAR(2) NOT NULL,
  CLIENT_JOIN_DATE DATE NOT NULL,
  CLIENT_TIER VARCHAR2(20) NOT NULL
);

/*
TABLE: EMPLOYEE
PURPOSE:
  Stores employee records including role, salary, and
  departmental assignment.

DESIGN NOTES:
  - Each employee must belong to exactly one department.
  - Certifications are optional (NULL allowed).
  - Email uniquely identifies employees.

RELATIONSHIPS:
  - Many-to-One with DEPARTMENT

CONSTRAINTS:
  Primary Key: `EMP_ID`
  Foreign Key: `DEPT_ID` -> `DEPARTMENT`
*/
CREATE TABLE EMPLOYEE(
  EMP_ID NUMBER(6) PRIMARY KEY,
  EMP_FNAME VARCHAR2(50) NOT NULL,
  EMP_LNAME VARCHAR2(50) NOT NULL,
  EMP_EMAIL VARCHAR2(100) NOT NULL UNIQUE,
  EMP_ROLE VARCHAR2(50) NOT NULL,
  EMP_HIRE_DATE DATE NOT NULL,
  EMP_SALARY NUMBER(10, 2) NOT NULL,
  EMP_CERT VARCHAR2(100) NULL,
  DEPT_ID NUMBER(4) NOT NULL,
  CONSTRAINT FK_EMP_DEPT FOREIGN KEY (DEPT_ID) REFERENCES DEPARTMENT(DEPT_ID)
);

/*
TABLE: SOFTWARE
PURPOSE:
  Stores all software products offered to clients.

DESIGN NOTES:
  - `SW_ID` uses standardized prefix format (`SW_XXXX`).
  - `SW_UNIT_COST` internal cost.
  - `SW_UNIT_PRICE` client-facing price (profit margin implied).

CONSTRAINTS:
  Primary Key: `SW_ID`

  All fields are required (NOT NULL).
*/
CREATE TABLE SOFTWARE(
  SW_ID VARCHAR2(10) PRIMARY KEY,
  SW_NAME VARCHAR2(100) NOT NULL,
  SW_VENDOR VARCHAR2(50) NOT NULL,
  SW_CATEGORY VARCHAR2(50) NOT NULL,
  SW_VERSION VARCHAR2(20) NOT NULL,
  SW_UNIT_COST NUMBER(8, 2) NOT NULL,
  SW_UNIT_PRICE NUMBER(8, 2) NOT NULL
);

/*
TABLE: LICENSE
PURPOSE:
  Tracks software licenses purchased by clients.

DESIGN NOTES:
  - A client may hold multiple licenses (for different products).
  - `LIC_SEATS` defines number of users allowed.
  - `LIC_END_DATE` expiration date of the license.

RELATIONSHIPS:
  - Many-to-One with CLIENT
  - Many-to-One with SOFTWARE

CONSTRAINTS:
  Primary Key: `LIC_ID`
  Foreign Key: `CLIENT_ID` -> `CLIENT`
  Foreign Key: `SW_ID` -> `SOFTWARE`

  All fields are required (NOT NULL).
*/
CREATE TABLE LICENSE(
  LIC_ID NUMBER(8) PRIMARY KEY,
  CLIENT_ID NUMBER(6) NOT NULL,
  CONSTRAINT FK_LIC_CLIENT FOREIGN KEY (CLIENT_ID) REFERENCES CLIENT(CLIENT_ID),
  SW_ID VARCHAR2(10) NOT NULL,
  CONSTRAINT FK_LIC_SW FOREIGN KEY (SW_ID) REFERENCES SOFTWARE(SW_ID),
  LIC_SEATS NUMBER(5) NOT NULL,
  LIC_START_DATE DATE NOT NULL,
  LIC_END_DATE DATE NOT NULL
);

/*
TABLE: TICKET
PURPOSE:
  Tracks support tickets submitted by clients.

DESIGN NOTES:
  - Supports lifecycle: Open -> In Progress -> Resolved/Closed.
  - Some tickets intentionally remain unresolved (NULL resolve date).
  - Includes priority and category classification.

RELATIONSHIPS:
  - Many-to-One with CLIENT
  - Many-to-One with EMPLOYEE

CONSTRAINTS:
  Primary Key: `TICKET_ID`
  Foreign Key: `CLIENT_ID` -> `CLIENT`
  Foreign Key: `EMP_ID` -> `EMPLOYEE`

  Some fields are not required (NULL allowed).
*/
CREATE TABLE TICKET(
  TICKET_ID NUMBER(8) PRIMARY KEY,
  CLIENT_ID NUMBER(6) NOT NULL,
  CONSTRAINT FK_TICKET_CLIENT FOREIGN KEY (CLIENT_ID) REFERENCES CLIENT(CLIENT_ID),
  EMP_ID NUMBER(6) NOT NULL,
  CONSTRAINT FK_TICKET_EMP FOREIGN KEY (EMP_ID) REFERENCES EMPLOYEE(EMP_ID),
  TICKET_DATE DATE NOT NULL,
  TICKET_CATEGORY VARCHAR2(50) NOT NULL,
  TICKET_PRIORITY VARCHAR2(10) NOT NULL,
  TICKET_STATUS VARCHAR2(20) NOT NULL,
  TICKET_RESOLVE_DATE DATE NULL
);

/*
TABLE: PROJECT
PURPOSE:
  Represents consulting or implementation projects for clients.

DESIGN NOTES:
  - Some projects are ongoing (`PROJ_END_DATE` is NULL).
  - `PROJ_BUDGET` enforced via data population logic.

RELATIONSHIPS:
  - Many-to-One with CLIENT
  - Many-to-One with EMPLOYEE

CONSTRAINTS:
  Primary Key: `PROJ_ID`
  Foreign Key: `CLIENT_ID` -> `CLIENT`
  Foreign Key: `EMP_ID` -> `EMPLOYEE`

  All fields are required (NOT NULL).
*/
CREATE TABLE PROJECT(
  PROJ_ID NUMBER(6) PRIMARY KEY,
  CLIENT_ID NUMBER(6) NOT NULL,
  CONSTRAINT FK_PROJ_CLIENT FOREIGN KEY (CLIENT_ID) REFERENCES CLIENT(CLIENT_ID),
  EMP_ID NUMBER(6) NOT NULL,
  CONSTRAINT FK_PROJ_EMP FOREIGN KEY (EMP_ID) REFERENCES EMPLOYEE(EMP_ID),
  PROJ_NAME VARCHAR2(100) NOT NULL,
  PROJ_START_DATE DATE NOT NULL,
  PROJ_END_DATE DATE NULL,
  PROJ_BUDGET NUMBER(10, 2) NOT NULL
);

/*
TABLE: INVOICE
PURPOSE:
  Stores billing records for client transactions.

DESIGN NOTES:
  - Tracks payment lifecycle (Paid, Pending, Overdue).
  - Ensures each client has at least one invoice.

RELATIONSHIPS:
  - Many-to-One with CLIENT

CONSTRAINTS:
  Primary Key: `INV_ID`
  Foreign Key: `CLIENT_ID` -> `CLIENT`

  All fields are required (NOT NULL).
*/
CREATE TABLE INVOICE(
  INV_ID NUMBER(8) PRIMARY KEY,
  CLIENT_ID NUMBER(6) NOT NULL,
  CONSTRAINT FK_INV_CLIENT FOREIGN KEY (CLIENT_ID) REFERENCES CLIENT(CLIENT_ID),
  INV_DATE DATE NOT NULL,
  INV_DUE_DATE DATE NOT NULL,
  INV_AMOUNT NUMBER(10, 2) NOT NULL,
  INV_STATUS VARCHAR2(20) NOT NULL
);


/*
SECTION: Data Population (Step 3)

PURPOSE:
  Populate all tables with realistic, relationally consistent
  sample data that satisfies project constraints outlined in
  the assignment instructions.

GLOBAL REQUIREMENTS:
  - Minimum row counts per table
  - Referential integrity is preserved across all FK relationships
  - Data distributions intentionally meet constraints:
    - LICENSE -> ≥ 15% expired
    - TICKET -> ≥ 20% unresolved (NULL resolve date)
    - PROJECT -> ≥ 2 ongoing (NULL end date)
    - INVOICE -> ≥ 25% overdue
    - All categorical fields include full value coverage

DESIGN STRATEGY:
  - IDs grouped by entity type for readability.
  - Dates chosen to simulate realistic business timelines.
  - Clients reused across tables to demonstrate relationships.
*/

/*
POPULATE: DEPARTMENT

PURPOSE:
  Insert core organizational units required for employee
  assignment and operational structure.

NOTES:
  - Exactly 5 departments inserted
  - Covers all major service areas (including: Cloud services, Cybersecurity, etc.)
*/
INSERT INTO DEPARTMENT VALUES (1101, 'Cloud Services', 'Boston', 'MA', 850000);
INSERT INTO DEPARTMENT VALUES (1102, 'Cybersecurity', 'Austin', 'TX', 920000);
INSERT INTO DEPARTMENT VALUES (4103, 'Technical Support', 'Providence', 'RI', 650000);
INSERT INTO DEPARTMENT VALUES (4104, 'Software Licensing', 'San Diego', 'CA', 540000);
INSERT INTO DEPARTMENT VALUES (4105, 'IT Consulting', 'New York', 'NY', 780000);

/*
POPULATE: CLIENT

PURPOSE:
  Insert a diverse set of clients across industries and tiers.

REQUIREMENTS:
  - ≥ 15 clients
  - Multiple industries represented
  - Tier distribution includes: Basic, Pro, Enterprise

DESIGN NOTES:
  - Geographic diversity included (multiple states)
  - Join dates span multiple years for realism
*/
INSERT INTO CLIENT VALUES (110001, 'TechPeak Corp', 'Technology', 'contact@techpeak.com', '512-555-0101', 'TX', DATE '2020-03-15', 'Enterprise');
INSERT INTO CLIENT VALUES (110002, 'Greenfield Health', 'Healthcare', 'info@greenfield.com', '617-555-0202', 'MA', DATE '2021-07-01', 'Pro');
INSERT INTO CLIENT VALUES (410003, 'Pacific Retail Group', 'Retail', 'support@pacificretail.com', '619-555-0303', 'CA', DATE '2022-02-12', 'Enterprise');
INSERT INTO CLIENT VALUES (410004, 'OceanView Finance', 'Finance', 'it@oceanviewfinance.com', '212-555-0404', 'NY', DATE '2019-11-20', 'Enterprise');
INSERT INTO CLIENT VALUES (410005, 'Rhody Manufacturing', 'Manufacturing', 'admin@rhodymfg.com', '401-555-0505', 'RI', DATE '2023-01-05', 'Basic');
INSERT INTO CLIENT VALUES (410006, 'Lone Star Logistics', 'Transportation', 'help@lonestarlogistics.com', '214-555-0606', 'TX', DATE '2020-08-18', 'Pro');
INSERT INTO CLIENT VALUES (410007, 'Sunrise Clinics', 'Healthcare', 'tech@sunriseclinics.com', '305-555-0707', 'FL', DATE '2021-04-22', 'Pro');
INSERT INTO CLIENT VALUES (410008, 'Cascade Analytics', 'Data Analytics', 'contact@cascadeanalytics.com', '206-555-0808', 'WA', DATE '2022-09-10', 'Enterprise');
INSERT INTO CLIENT VALUES (410009, 'Prairie Foods', 'Food Services', 'it@prairiefoods.com', '312-555-0909', 'IL', DATE '2023-05-14', 'Basic');
INSERT INTO CLIENT VALUES (410010, 'Peachtree Legal', 'Legal Services', 'support@peachtreelegal.com', '404-555-1010', 'GA', DATE '2021-12-03', 'Pro');
INSERT INTO CLIENT VALUES (410011, 'Carolina Biotech', 'Biotechnology', 'info@carolinabiotech.com', '919-555-1111', 'NC', DATE '2020-06-28', 'Enterprise');
INSERT INTO CLIENT VALUES (410012, 'Desert Solar LLC', 'Energy', 'admin@desertsolar.com', '602-555-1212', 'AZ', DATE '2022-03-09', 'Pro');
INSERT INTO CLIENT VALUES (410013, 'MileHigh Education', 'Education', 'tech@milehighedu.com', '303-555-1313', 'CO', DATE '2023-08-19', 'Basic');
INSERT INTO CLIENT VALUES (410014, 'BayBridge Media', 'Media', 'contact@baybridgemedia.com', '415-555-1414', 'CA', DATE '2019-02-25', 'Enterprise');
INSERT INTO CLIENT VALUES (410015, 'Boston Research Labs', 'Research', 'help@bostonresearch.com', '857-555-1515', 'MA', DATE '2024-01-11', 'Pro');
INSERT INTO CLIENT VALUES (410016, 'Austin Robotics', 'Technology', 'it@austinrobotics.com', '737-555-1616', 'TX', DATE '2022-10-30', 'Enterprise');
INSERT INTO CLIENT VALUES (410017, 'Newport Hospitality', 'Hospitality', 'admin@newporthospitality.com', '401-555-1717', 'RI', DATE '2021-03-17', 'Basic');
INSERT INTO CLIENT VALUES (410018, 'Everglade Insurance', 'Insurance', 'support@evergladeins.com', '786-555-1818', 'FL', DATE '2020-12-08', 'Pro');
INSERT INTO CLIENT VALUES (410019, 'Seattle Cloudware', 'Software', 'info@seattlecloudware.com', '425-555-1919', 'WA', DATE '2023-11-06', 'Enterprise');
INSERT INTO CLIENT VALUES (410020, 'Atlanta Design Co', 'Design', 'hello@atlantadesign.com', '678-555-2020', 'GA', DATE '2024-04-02', 'Basic');

/*
POPULATE: EMPLOYEE

PURPOSE:
  Insert employees across all departments to support
  ticket handling and project assignments.

REQUIREMENTS:
  - Employees mapped to valid `DEPT_ID` values
  - Mix of roles and certifications

DESIGN NOTES:
  - Ensures each department has coverage
  - Some employees have NULL certifications
*/
INSERT INTO EMPLOYEE VALUES (110001, 'Sarah', 'Nguyen', 's.nguyen@technexus.com', 'Cloud Services', DATE '2019-04-10', 112000, 'AWS-SAA', 1101);
INSERT INTO EMPLOYEE VALUES (110002, 'Marcus', 'Webb', 'm.webb@technexus.com', 'Cybersecurity', DATE '2020-09-01', 98000, 'CISSP', 1102);
INSERT INTO EMPLOYEE VALUES (410003, 'Alicia', 'Rivera', 'a.rivera@technexus.com', 'IT Consultant', DATE '2021-06-15', 72000, NULL, 4103);
INSERT INTO EMPLOYEE VALUES (410004, 'David', 'Patel', 'd.patel@technexus.com', 'Software Licensing', DATE '2018-02-12', 89000, 'Microsoft Licensing Specialist', 4104);
INSERT INTO EMPLOYEE VALUES (410005, 'Emily', 'Chen', 'e.chen@technexus.com', 'IT Consultant', DATE '2022-01-24', 95000, 'PMP', 4105);
INSERT INTO EMPLOYEE VALUES (410006, 'Jordan', 'King', 'j.king@technexus.com', 'Cloud Services', DATE '2021-10-04', 102000, 'Azure Administrator', 1101);
INSERT INTO EMPLOYEE VALUES (410007, 'Priya', 'Shah', 'p.shah@technexus.com', 'Cybersecurity', DATE '2023-03-13', 99000, NULL, 1101);
INSERT INTO EMPLOYEE VALUES (410008, 'Thomas', 'Brooks', 't.brooks@technexus.com', 'Cybersecurity', DATE '2019-07-22', 108000, 'Security+', 1102);
INSERT INTO EMPLOYEE VALUES (410009, 'Nia', 'Johnson', 'n.johnson@technexus.com', 'Cybersecurity', DATE '2022-11-07', 94000, NULL, 1102);
INSERT INTO EMPLOYEE VALUES (410010, 'Kevin', 'Miller', 'k.miller@technexus.com', 'Technical Support', DATE '2020-05-18', 76000, 'CompTIA A+', 4103);
INSERT INTO EMPLOYEE VALUES (410011, 'Grace', 'Kim', 'g.kim@technexus.com', 'Technical Support', DATE '2023-09-05', 68000, NULL, 4103);
INSERT INTO EMPLOYEE VALUES (410012, 'Omar', 'Hassan', 'o.hassan@technexus.com', 'Software Licensing', DATE '2021-01-29', 81000, NULL, 4104);
INSERT INTO EMPLOYEE VALUES (410013, 'Maya', 'Collins', 'm.collins@technexus.com', 'Technical Support', DATE '2022-08-16', 83000, NULL, 4104);
INSERT INTO EMPLOYEE VALUES (410014, 'Daniel', 'Lopez', 'd.lopez@technexus.com', 'IT Consultant', DATE '2018-12-11', 101000, 'ITIL Foundation', 4105);
INSERT INTO EMPLOYEE VALUES (410015, 'Hannah', 'Reed', 'h.reed@technexus.com', 'IT Consultant', DATE '2024-02-20', 87000, NULL, 4105);

/*
POPULATE: SOFTWARE

PURPOSE:
  Define available software products for licensing.

REQUIREMENTS:
  - Multiple categories included:
    - Productivity
    - Security
    - Cloud
    - Collaboration

DESIGN NOTES:
  - Vendors diversified across industry
*/
INSERT INTO SOFTWARE VALUES ('SW-MS365', 'Microsoft 365', 'Microsoft', 'Productivity', '2024.1', 8.00, 15.00);
INSERT INTO SOFTWARE VALUES ('SW-CRWD', 'CrowdStrike Falcon', 'CrowdStrike', 'Security', '6.5', 18.50, 35.00);
INSERT INTO SOFTWARE VALUES ('4-AWS', 'Amazon Web Services', 'Amazon', 'Cloud', '2024.3', 22.00, 42.00);
INSERT INTO SOFTWARE VALUES ('4-ZOOM', 'Zoom Workplace', 'Zoom', 'Collaboration', '5.17', 7.50, 14.00);
INSERT INTO SOFTWARE VALUES ('4-SLACK', 'Slack Business Plus', 'Salesforce', 'Collaboration', '4.36', 6.00, 13.00);
INSERT INTO SOFTWARE VALUES ('4-SNOW', 'ServiceNow ITSM', 'ServiceNow', 'Cloud', 'Utah', 30.00, 55.00);
INSERT INTO SOFTWARE VALUES ('4-OKTA', 'Okta Workforce Identity', 'Okta', 'Security', '2024.2', 12.00, 27.00);
INSERT INTO SOFTWARE VALUES ('4-ADOBE', 'Adobe Creative Cloud', 'Adobe', 'Productivity', '2024.0', 25.00, 48.00);
INSERT INTO SOFTWARE VALUES ('4-ACR', 'Acronis Cyber Protect', 'Acronis', 'Security', '16.0', 9.00, 22.00);
INSERT INTO SOFTWARE VALUES ('4-JIRA', 'Atlassian Jira', 'Atlassian', 'Collaboration', '9.12', 5.00, 12.00);

/*
POPULATE: LICENSE

PURPOSE:
  Assign software licenses to clients.

REQUIREMENTS:
  - ≥ 20 records
  - ≥ 15% expired licenses
  - Clients may hold multiple licenses

DESIGN NOTES:
  - Same client appears multiple times with different `SW_ID`s
  - Expired licenses use past end dates
*/
INSERT INTO LICENSE VALUES (11000001, 110001, 'SW-MS365', 50, DATE '2023-01-15', DATE '2026-01-15');
INSERT INTO LICENSE VALUES (11000002, 110001, 'SW-CRWD', 50, DATE '2023-01-15', DATE '2026-01-15');
INSERT INTO LICENSE VALUES (11000003, 110001, 'SW-CRWD', 25, DATE '2023-02-01', DATE '2026-02-01');
INSERT INTO LICENSE VALUES (11000004, 110002, 'SW-MS365', 40, DATE '2023-03-10', DATE '2026-03-10');
INSERT INTO LICENSE VALUES (11000005, 110002, 'SW-CRWD', 35, DATE '2023-04-12', DATE '2026-04-12');
INSERT INTO LICENSE VALUES (11000006, 410003, 'SW-MS365', 60, DATE '2023-05-01', DATE '2026-05-01');
INSERT INTO LICENSE VALUES (11000007, 410003, 'SW-CRWD', 45, DATE '2023-06-15', DATE '2026-06-15');
INSERT INTO LICENSE VALUES (11000008, 410004, 'SW-MS365', 20, DATE '2023-07-20', DATE '2026-07-20');
INSERT INTO LICENSE VALUES (11000009, 410004, 'SW-CRWD', 30, DATE '2023-08-18', DATE '2026-08-18');
INSERT INTO LICENSE VALUES (11000010, 410005, 'SW-MS365', 55, DATE '2023-09-01', DATE '2026-09-01');
INSERT INTO LICENSE VALUES (11000011, 410006, 'SW-CRWD', 50, DATE '2023-10-10', DATE '2026-10-10');
INSERT INTO LICENSE VALUES (11000012, 410006, 'SW-MS365', 45, DATE '2023-11-11', DATE '2026-11-11');
INSERT INTO LICENSE VALUES (11000013, 410007, 'SW-CRWD', 25, DATE '2023-12-01', DATE '2026-12-01');
INSERT INTO LICENSE VALUES (11000014, 410007, 'SW-MS365', 30, DATE '2023-12-15', DATE '2026-12-15');

-- Expired LICENSES
INSERT INTO LICENSE VALUES (11000015, 410008, 'SW-MS365', 20, DATE '2020-01-01', DATE '2022-01-01');
INSERT INTO LICENSE VALUES (11000016, 410009, 'SW-CRWD', 15, DATE '2021-03-01', DATE '2023-03-01');
INSERT INTO LICENSE VALUES (11000017, 410010, 'SW-MS365', 10, DATE '2019-05-01', DATE '2021-05-01');

-- Remaining active licenses
INSERT INTO LICENSE VALUES (11000018, 410008, 'SW-CRWD', 35, DATE '2023-01-01', DATE '2026-01-01');
INSERT INTO LICENSE VALUES (11000019, 410009, 'SW-MS365', 40, DATE '2023-02-01', DATE '2026-02-01');
INSERT INTO LICENSE VALUES (11000020, 410010, 'SW-CRWD', 50, DATE '2023-03-01', DATE '2026-03-01');

/*
POPULATE: TICKET

PURPOSE:
  Simulate client support requests handled by employees.

REQUIREMENTS:
  - ≥ 25 records
  - ≥ 20% unresolved (NULL for `TICKET_RESOLVE_DATE`)
  - All categories included:
    - Network
    - Security
    - Software
    - Hardware
  - All priorities included:
    - Low
    - Medium
    - High
    - Critical

DESIGN NOTES:
  - Status aligns with resolve date (NULL = unresolved)
  - Mix of resolved and ongoing tickets
*/
INSERT INTO TICKET VALUES (11000001, 110001, 110001, DATE '2024-01-01', 'Network', 'Low', 'Resolved', DATE '2024-01-02');
INSERT INTO TICKET VALUES (11000002, 110002, 110002, DATE '2024-01-02', 'Security', 'Medium', 'Resolved', DATE '2024-01-05');
INSERT INTO TICKET VALUES (11000003, 410003, 410003, DATE '2024-01-03', 'Software', 'High', 'Resolved', DATE '2024-01-06');
INSERT INTO TICKET VALUES (11000004, 410004, 410004, DATE '2024-01-04', 'Hardware', 'Critical', 'Resolved', DATE '2024-01-08');
INSERT INTO TICKET VALUES (11000005, 410005, 410005, DATE '2024-01-05', 'Network', 'Low', 'Closed', DATE '2024-01-07');
INSERT INTO TICKET VALUES (11000006, 410006, 410006, DATE '2024-01-06', 'Security', 'Medium', 'Closed', DATE '2024-01-10');
INSERT INTO TICKET VALUES (11000007, 410007, 410007, DATE '2024-01-07', 'Software', 'High', 'Closed', DATE '2024-01-11');
INSERT INTO TICKET VALUES (11000008, 410008, 410008, DATE '2024-01-08', 'Hardware', 'Critical', 'Closed', DATE '2024-01-12');
INSERT INTO TICKET VALUES (11000009, 410009, 410009, DATE '2024-01-09', 'Network', 'Medium', 'Resolved', DATE '2024-01-12');
INSERT INTO TICKET VALUES (11000010, 410010, 410010, DATE '2024-01-10', 'Security', 'High', 'Resolved', DATE '2024-01-14');
INSERT INTO TICKET VALUES (11000011, 110001, 110001, DATE '2024-01-11', 'Software', 'Low', 'Closed', DATE '2024-01-13');
INSERT INTO TICKET VALUES (11000012, 110002, 110002, DATE '2024-01-12', 'Hardware', 'Medium', 'Closed', DATE '2024-01-15');
INSERT INTO TICKET VALUES (11000013, 410003, 410004, DATE '2024-01-13', 'Network', 'High', 'Resolved', DATE '2024-01-17');
INSERT INTO TICKET VALUES (11000014, 410004, 410005, DATE '2024-01-14', 'Security', 'Critical', 'Resolved', DATE '2024-01-18');
INSERT INTO TICKET VALUES (11000015, 410005, 410006, DATE '2024-01-15', 'Software', 'Medium', 'Closed', DATE '2024-01-19');
INSERT INTO TICKET VALUES (11000016, 410006, 410007, DATE '2024-01-16', 'Hardware', 'Low', 'Closed', DATE '2024-01-20');
INSERT INTO TICKET VALUES (11000017, 410007, 410008, DATE '2024-01-17', 'Network', 'Critical', 'Resolved', DATE '2024-01-21');
INSERT INTO TICKET VALUES (11000018, 410008, 410009, DATE '2024-01-18', 'Security', 'High', 'Resolved', DATE '2024-01-22');
INSERT INTO TICKET VALUES (11000019, 410009, 410010, DATE '2024-01-19', 'Software', 'Medium', 'Closed', DATE '2024-01-23');
INSERT INTO TICKET VALUES (11000020, 410010, 110001, DATE '2024-01-20', 'Hardware', 'Low', 'Closed', DATE '2024-01-24');

-- Unresolved tickets
INSERT INTO TICKET VALUES (11000021, 110001, 110001, DATE '2024-02-01', 'Network', 'High', 'Open', NULL);
INSERT INTO TICKET VALUES (11000022, 110002, 410003, DATE '2024-02-02', 'Security', 'Critical', 'Open', NULL);
INSERT INTO TICKET VALUES (11000023, 410003, 410004, DATE '2024-02-03', 'Software', 'Medium', 'In Progress', NULL);
INSERT INTO TICKET VALUES (11000024, 410004, 410005, DATE '2024-02-04', 'Hardware', 'Low', 'Open', NULL);
INSERT INTO TICKET VALUES (11000025, 410005, 410006, DATE '2024-02-05', 'Network', 'Critical', 'In Progress', NULL);

/*
POPULATE: PROJECT

PURPOSE:
  Represent consulting and implementation work for clients.

REQUIREMENTS:
  - ≥ 12 records
  - ≥ 2 ongoing projects (NULL for `PROJ_END_DATE`)
  - Budget range:
    - $5,000 to $250,000

DESIGN NOTES:
  - Mix of short-term and long-term engagements
*/
INSERT INTO PROJECT VALUES (130001, 110001, 110001, 'Cloud Migration', DATE '2024-01-01', DATE '2024-06-01', 50000);
INSERT INTO PROJECT VALUES (130002, 110002, 110002, 'Security Audit', DATE '2024-01-05', DATE '2024-04-15', 50000);
INSERT INTO PROJECT VALUES (130003, 410003, 410003, 'Software Deployment', DATE '2024-01-10', DATE '2024-05-20', 75000);
INSERT INTO PROJECT VALUES (130004, 410004, 410004, 'Network Upgrade', DATE '2024-01-15', DATE '2024-07-01', 120000);
INSERT INTO PROJECT VALUES (130005, 410005, 410005, 'IT Infrastructure Setup', DATE '2024-02-01', DATE '2024-08-01', 200000);
INSERT INTO PROJECT VALUES (130006, 410006, 410006, 'Cloud Optimization', DATE '2024-02-10', DATE '2024-06-30', 65000);
INSERT INTO PROJECT VALUES (130007, 410007, 410007, 'Disaster Recovery Plan', DATE '2024-02-15', DATE '2024-09-01', 90000);
INSERT INTO PROJECT VALUES (130008, 410008, 410008, 'Cybersecurity Upgrade', DATE '2024-03-01', DATE '2024-07-15', 150000);
INSERT INTO PROJECT VALUES (130009, 410009, 410009, 'Help Desk System', DATE '2024-03-10', DATE '2024-06-10', 25000);
INSERT INTO PROJECT VALUES (130010, 410010, 410010, 'Data Center Migration', DATE '2024-03-20', DATE '2024-10-01', 180000);

-- Ongoing projects with no end dates
INSERT INTO PROJECT VALUES (130011, 110001, 110002, 'AI Integration Initiative', DATE '2024-04-01', NULL, 220000);
INSERT INTO PROJECT VALUES (130012, 110002, 410003, 'Enterprise System Overhaul', DATE '2024-04-10', NULL, 240000);

/*
POPULATE: INVOICE

PURPOSE:
  Track billing and payment status for clients.

REQUIREMENTS:
  - ≥ 20 records
  - ≥ 25% overdue
  - Each client has at least one invoice

DESIGN NOTES:
  - Status distribution includes:
    - Paid
    - Pending
    - Overdue
  - Overdue invoices use past due dates
*/
INSERT INTO INVOICE VALUES (14000001, 110001, DATE '2024-01-01', DATE '2024-01-30', 5000, 'Paid');
INSERT INTO INVOICE VALUES (14000002, 110002, DATE '2024-01-02', DATE '2024-02-01', 7500, 'Paid');
INSERT INTO INVOICE VALUES (14000003, 410003, DATE '2024-01-03', DATE '2024-02-02', 12000, 'Paid');
INSERT INTO INVOICE VALUES (14000004, 410004, DATE '2024-01-04', DATE '2024-02-03', 9000, 'Paid');
INSERT INTO INVOICE VALUES (14000005, 410005, DATE '2024-01-05', DATE '2024-02-04', 15000, 'Paid');
INSERT INTO INVOICE VALUES (14000006, 410006, DATE '2024-01-06', DATE '2024-02-05', 11000, 'Paid');
INSERT INTO INVOICE VALUES (14000007, 410007, DATE '2024-01-07', DATE '2024-02-06', 8000, 'Paid');
INSERT INTO INVOICE VALUES (14000008, 410008, DATE '2024-01-08', DATE '2024-02-07', 9500, 'Paid');
INSERT INTO INVOICE VALUES (14000009, 410009, DATE '2024-01-09', DATE '2024-02-08', 13000, 'Paid');
INSERT INTO INVOICE VALUES (14000010, 410010, DATE '2024-01-10', DATE '2024-02-09', 14000, 'Paid');
INSERT INTO INVOICE VALUES (14000011, 410011, DATE '2024-02-01', DATE '2024-03-01', 6000, 'Pending');
INSERT INTO INVOICE VALUES (14000012, 410012, DATE '2024-02-02', DATE '2024-03-02', 7000, 'Pending');
INSERT INTO INVOICE VALUES (14000013, 410013, DATE '2024-02-03', DATE '2024-03-03', 10000, 'Pending');
INSERT INTO INVOICE VALUES (14000014, 410014, DATE '2024-02-04', DATE '2024-03-04', 8500, 'Pending');

-- Overdue invoices
INSERT INTO INVOICE VALUES (14000015, 410015, DATE '2023-10-01', DATE '2023-11-01', 20000, 'Overdue');
INSERT INTO INVOICE VALUES (14000016, 410016, DATE '2023-10-02', DATE '2023-11-02', 18000, 'Overdue');
INSERT INTO INVOICE VALUES (14000017, 410017, DATE '2023-10-03', DATE '2023-11-03', 22000, 'Overdue');
INSERT INTO INVOICE VALUES (14000018, 410018, DATE '2023-10-04', DATE '2023-11-04', 16000, 'Overdue');
INSERT INTO INVOICE VALUES (14000019, 410019, DATE '2023-10-05', DATE '2023-11-05', 21000, 'Overdue');

INSERT INTO INVOICE VALUES (14000020, 410020, DATE '2024-02-10', DATE '2024-03-10', 17000, 'Pending');

-- Grants SELECT access to user `BAI456_22` to all tables
GRANT SELECT ON DEPARTMENT TO BAI456_22;
GRANT SELECT ON CLIENT TO BAI456_22;
GRANT SELECT ON EMPLOYEE TO BAI456_22;
GRANT SELECT ON SOFTWARE TO BAI456_22;
GRANT SELECT ON LICENSE TO BAI456_22;
GRANT SELECT ON TICKET TO BAI456_22;
GRANT SELECT ON PROJECT TO BAI456_22;
GRANT SELECT ON INVOICE TO BAI456_22;

-- This loop deletes every single table that's in the schema
-- BEGIN
-- FOR c IN (SELECT table_name FROM user_tables) LOOP
-- EXECUTE IMMEDIATE ('DROP TABLE "' || c.table_name || '" CASCADE CONSTRAINTS');
-- END LOOP;
-- END;
