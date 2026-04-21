# Database Project
# Running the script

```zsh
sqlite3 db.sqlite < script.sql
```

## Step 3: Populate the Database
### Checklist
- [x] Department (Min records: 5 records)
	- [x] Cloud services
	- [x] Cybersecurity
	- [x] Technical support
	- [x] Software licensing
	- [x] IT consulting
- [x] Client (Min records: 20 records)
	- [x] At least 6 different states:
		- [x] TX
		- [x] CA
	- [x] `CLIENT_ID 10001 (TechPeak Corp, Austin TX, Enterprise tier)`
	- [x] `CLIENT_ID 10002 (Greenfield Health, Boston MA, Pro tier)`
- [x] Employee (Min records: 15 records)
	- [x] 2 employees in cloud services
	- [x] 4 employees in cybersecurity
	- [x] 3 employees in technical support
	- [x] 2 employees in software licensing
	- [x] 4 employees in IT consulting
	- [x] At least 3 must have a certification
- [x] Software (Min records: 10 records)
	- [x] SW_CATEGORY must include:
		- [x] Security
		- [x] Productivity
		- [x] Cloud
		- [x] Collaboration
	- [x] Include:
		- [x] `SW-MS365` for Microsoft 365
		- [x] `SW-CRWD` for CrowdStrike Falcon
- [x] License (Min records: 20 records)
	- [x] At least 15% of licenses must be expired
	- [x] some clients may hold licenses for multiple software products
- [x] Ticket (Min records: 25 records)
	- [x] At least 20% of tickets must remain unresolved (`TICKET_RESOLVE_DATE = NULL`)
	- [x] Include all 4 `TICKET_PRIORITY` values:
		- [x] Low
		- [x] Medium
		- [x] High
		- [x] Critical
	- [x] Include all 4 `TICKET_CATEGORY` values:
		- [x] Network
		- [x] Security
		- [x] Software
		- [x] Hardware
- [x] Project (Min records: 12 records)
	- [x] At least 2 projects must have no end date (ongoing)
	- [x] `PROJ_BUDGET` must range from $5,000 to $250,000
- [x] Invoice (Min records: 20 records)
	- [x] At least 25% of invoices must have `INV_STATUS = 'Overdue'`
	- [x] Each client must have at least one invoice
