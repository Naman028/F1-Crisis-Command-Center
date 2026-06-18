# F1 Crisis Command Center

SAP ABAP RAP project for Formula 1 crisis recovery decision support.

## Project Overview

**F1 Crisis Command Center** is a SAP ABAP RAP and Fiori Elements application designed to support decision-making during Formula 1 race weekend crisis situations.

The application allows a race operations team to create a crisis case, select the race event, define the crisis type and severity, and then generate backend-driven recovery recommendations. The system evaluates recovery options using weighted scoring logic and displays the recommendation, decision logs, crisis factors, and required resources in one Fiori Object Page.

This project was built as part of the SAP ABAP and Cloud project work.

## Problem Statement

Formula 1 teams must react quickly during race weekend disruptions such as weather changes, crash damage, logistics delays, or compliance issues. These decisions usually involve multiple operational factors such as cost, time, risk, feasibility, resource availability, and regulatory impact.

The goal of this project is to create a structured decision-support application where crisis cases can be managed through a SAP Fiori UI and recommendations can be generated using backend ABAP logic.

## Main Objective

The main objective of this project is to build a RAP-based Fiori Elements application that can:

* Create and manage Formula 1 crisis cases.
* Select race events from predefined race master data.
* Generate recovery options dynamically.
* Calculate weighted recommendation scores.
* Select the best recovery option.
* Maintain decision logs for recommendation history.
* Generate crisis factors and case-specific resources.
* Present all information in one clean Fiori Object Page.

## Key Features

### 1. Crisis Case Management

Users can create a crisis case with details such as:

* Case Title
* Race
* Crisis Type
* Severity
* Status

The system automatically generates the Case ID, for example:

```text
CASE001
CASE002
CASE003
```

### 2. Race Value Help

The Race field uses a value help dropdown connected to F1 race master data.

The user selects a race from a clean list, such as:

```text
Australian Grand Prix
Chinese Grand Prix
Japanese Grand Prix
Miami Grand Prix
Monaco Grand Prix
```

After selecting a race, the backend assigns the corresponding Race ID and Race Name.

Example:

```text
Race: Monaco Grand Prix
Race ID: RACE006
```

The Race Name is backend-controlled to avoid manual incorrect input.

### 3. Backend Race Validation

The backend validates the selected Race ID.

Invalid manually entered race values are blocked during save.

Example:

```text
Invalid Race. Please select a race from the Race value help.
```

### 4. Generate Recommendation Action

The application provides a custom RAP action:

```text
Generate Recommendation
```

When the user clicks this action, the backend generates and evaluates recovery options for the crisis case.

### 5. Recovery Option Scoring

Each recovery option is evaluated using weighted scoring.

The scoring areas are:

| Score Area         | Weight |
| ------------------ | -----: |
| Cost Score         |    20% |
| Time Score         |    30% |
| Risk Control Score |    25% |
| Feasibility Score  |    25% |

The final score is calculated by backend ABAP logic.

### 6. Recommendation Rating

The total score is converted into a rating:

| Score Range | Rating    |
| ----------: | --------- |
|    80 - 100 | EXCELLENT |
|     60 - 79 | GOOD      |
|     40 - 59 | MEDIUM    |
|      0 - 39 | WEAK      |

The best option is marked as recommended.

### 7. Decision Logs

Every time a recommendation is generated, a Decision Log entry is created.

The log stores:

* Log Number
* Case ID
* Crisis Type
* Severity
* Recommended Option ID
* Recommended Option Type
* Recommended Score
* Recommended Rating
* Reason Text
* Created By
* Created At

This provides a simple audit trail for the recommendation history.

### 8. Crisis Factors

The system dynamically creates crisis-specific factors based on the crisis type.

Examples:

For `WEATHER`:

```text
TRACK_CONDITION
RAIN_PROBABILITY
SAFETY_RISK
```

For `CRASH`:

```text
DAMAGE_SEVERITY
PARTS_AVAILABILITY
REPAIR_TIME
```

For `LOGISTICS`:

```text
SHIPPING_DELAY
SPARE_PART_ACCESS
CREW_PRESSURE
```

For `COMPLIANCE`:

```text
FIA_APPROVAL
REGULATION_RISK
DOCUMENTATION
```

### 9. Case Resources

The system dynamically creates case-specific resources based on the crisis type.

Examples:

For `WEATHER`:

```text
Wet Tyre Strategy Set
Weather Radar Support
Setup Adjustment Crew
```

For `CRASH`:

```text
Front Wing Replacement Kit
Suspension Repair Kit
Damage Inspection Crew
```

For `LOGISTICS`:

```text
Emergency Air Freight
Local Supplier Backup
Fast Track Customs Support
```

For `COMPLIANCE`:

```text
FIA Documentation Package
Regulation Review Engineer
Scrutineering Support Crew
```

### 10. One Fiori Object Page

The application is designed as one connected Fiori Elements app.

The Crisis Case Object Page contains:

* Crisis Details
* Recommendation
* Scoring Guide
* Recovery Options
* Decision Logs
* Crisis Factors
* Resources

This avoids multiple disconnected apps and keeps the complete crisis workflow in one place.

## Technology Stack

| Layer             | Technology                                 |
| ----------------- | ------------------------------------------ |
| Backend           | SAP ABAP                                   |
| Programming Model | ABAP RESTful Application Programming Model |
| UI                | SAP Fiori Elements                         |
| Service           | OData V4 UI Service                        |
| Data Modeling     | Core Data Services                         |
| Behavior          | RAP Managed Behavior                       |
| Draft Handling    | RAP Draft                                  |
| Version Control   | abapGit and GitHub                         |

## Main RAP Objects

### Database Tables

| Object             | Purpose                     |
| ------------------ | --------------------------- |
| `ZRAP200_CC_CASE`  | Crisis Case root table      |
| `ZRAP200_CC_CASED` | Crisis Case draft table     |
| `ZRAP200_CC_OPT`   | Recovery Option table       |
| `ZRAP200_CC_OPTD`  | Recovery Option draft table |
| `ZRAP200_CC_LOG`   | Decision Log table          |
| `ZRAP200_CC_FACT`  | Crisis Factor table         |
| `ZRAP200_CC_FACTD` | Crisis Factor draft table   |
| `ZRAP200_CC_CRES`  | Case Resource table         |
| `ZRAP200_CC_CRESD` | Case Resource draft table   |
| `ZRAP200_CC_RACE`  | Race master data table      |

### Interface Views

| Object              | Purpose                         |
| ------------------- | ------------------------------- |
| `ZI_RAP200_CC_CASE` | Crisis Case root interface view |
| `ZI_RAP200_CC_OPT`  | Recovery Option interface view  |
| `ZI_RAP200_CC_LOG`  | Decision Log interface view     |
| `ZI_RAP200_CC_FACT` | Crisis Factor interface view    |
| `ZI_RAP200_CC_CRES` | Case Resource interface view    |
| `ZI_RAP200_CC_RACE` | Race master interface view      |

### Projection Views

| Object                     | Purpose                         |
| -------------------------- | ------------------------------- |
| `ZC_RAP200_CC_CASE`        | Crisis Case projection view     |
| `ZC_RAP200_CC_OPT`         | Recovery Option projection view |
| `ZC_RAP200_CC_LOG`         | Decision Log projection view    |
| `ZC_RAP200_CC_FACT`        | Crisis Factor projection view   |
| `ZC_RAP200_CC_CRES`        | Case Resource projection view   |
| `ZC_RAP200_CC_RACE_VH`     | Race value help                 |
| `ZC_RAP200_CC_SCORE_GUIDE` | Scoring guide view              |

### Metadata Extensions

| Object                        | Purpose                                |
| ----------------------------- | -------------------------------------- |
| `ZC_RAP200_CC_CASE_UI`        | Crisis Case Object Page UI annotations |
| `ZC_RAP200_CC_OPT_UI`         | Recovery Option UI annotations         |
| `ZC_RAP200_CC_LOG_UI`         | Decision Log UI annotations            |
| `ZC_RAP200_CC_FACT_UI`        | Crisis Factor UI annotations           |
| `ZC_RAP200_CC_CRES_UI`        | Case Resource UI annotations           |
| `ZC_RAP200_CC_SCORE_GUIDE_UI` | Scoring Guide UI annotations           |

### Behavior Definitions

| Object              | Purpose                                                           |
| ------------------- | ----------------------------------------------------------------- |
| `ZI_RAP200_CC_CASE` | Managed transactional behavior for Crisis Case and child entities |
| `ZC_RAP200_CC_CASE` | Projection behavior for the Fiori app                             |
| `ZI_RAP200_CC_LOG`  | Managed behavior for Decision Logs                                |

### ABAP Classes

| Object                     | Purpose                                                  |
| -------------------------- | -------------------------------------------------------- |
| `ZBP_I_RAP200_CC_CASE`     | Main behavior pool for Crisis Case logic                 |
| `ZBP_I_RAP200_CC_LOG`      | Behavior pool for Decision Log creation                  |
| `ZCL_RAP200_CC_DEC_ENGINE` | Decision engine for option generation and recommendation |
| `ZCL_RAP200_CC_SCORE_SRV`  | Weighted score calculation service                       |
| `ZCL_RAP200_CC_LOG_SRV`    | Decision log helper service                              |
| `ZCL_RAP200_CC_RACE_DATA`  | Race master data generator                               |
| `ZCL_RAP200_CC_DEMO_DATA`  | Demo data generator                                      |
| `ZCL_RAP200_CC_CONSTANTS`  | Common constants                                         |
| `ZCL_RAP200_CC_MOCK_API`   | Mock API helper                                          |

### Service Objects

| Object               | Purpose                     |
| -------------------- | --------------------------- |
| `ZUI_RAP200_F1CC`    | OData service definition    |
| `ZUI_RAP200_F1CC_O4` | OData V4 UI service binding |

## Application Flow

1. User opens the Fiori Elements app.
2. User creates a new Crisis Case.
3. System automatically assigns a Case ID.
4. User selects an F1 race using value help.
5. Backend fills the race information.
6. User selects Crisis Type and Severity.
7. User saves the case.
8. User clicks Generate Recommendation.
9. Backend generates Recovery Options.
10. Backend calculates weighted scores.
11. Backend selects the best recommendation.
12. Backend creates Decision Log.
13. Backend generates Crisis Factors.
14. Backend generates Case Resources.
15. Fiori Object Page displays the complete decision overview.

## Example Scenario

### Input

```text
Case Title: Wet track conditions before race start
Race: Canadian Grand Prix
Crisis Type: WEATHER
Severity: HIGH
```

### Generated Output

Recovery Options are generated and scored.

Crisis Factors:

```text
TRACK_CONDITION
RAIN_PROBABILITY
SAFETY_RISK
```

Resources:

```text
Wet Tyre Strategy Set
Weather Radar Support
Setup Adjustment Crew
```

Recommendation:

```text
Status: RECOMMENDED
Rating: EXCELLENT
Decision Log: Created
```

## Validation Rules

The application includes backend validation rules.

| Validation          | Result          |
| ------------------- | --------------- |
| Empty Race ID       | Save is blocked |
| Invalid Race ID     | Save is blocked |
| Score below 0       | Save is blocked |
| Score above 100     | Save is blocked |
| Missing Option Type | Save is blocked |
| Missing Option Text | Save is blocked |

## Setup Instructions

### 1. Import Repository

Import the repository into the SAP BTP ABAP Environment system using abapGit.

### 2. Activate Objects

Activate the package:

```text
ZRAP200_F1CC
```

Expected result:

```text
0 errors
0 warnings
```

### 3. Generate Race Master Data

Run the race data generator class:

```text
ZCL_RAP200_CC_RACE_DATA
```

Run as Console App.

### 4. Generate Demo Data

Run the demo data generator class if demo cases are required:

```text
ZCL_RAP200_CC_DEMO_DATA
```

### 5. Publish Service Binding

Open the service binding:

```text
ZUI_RAP200_F1CC_O4
```

Refresh and publish the service.

### 6. Preview Fiori App

Open the Fiori Elements preview from the service binding.

## Testing Checklist

| Test                    | Expected Result                            |
| ----------------------- | ------------------------------------------ |
| App opens               | Fiori Elements app loads successfully      |
| Create case             | Case ID is generated automatically         |
| Race value help opens   | Race list is displayed                     |
| Race selection          | Race ID and Race Name are assigned         |
| Invalid race save       | Save is blocked                            |
| Generate Recommendation | Recommendation is created                  |
| Recovery Options        | Options are generated and scored           |
| Decision Logs           | Log entry is created                       |
| Crisis Factors          | Three factors are generated                |
| Resources               | Three resources are generated              |
| Manual score change     | Recommendation recalculates                |
| Duplicate generation    | No duplicate factors/resources are created |

## Project Status

The main backend workflow and Fiori Object Page integration are completed.

Completed areas:

* Crisis Case draft workflow
* Race value help
* Backend race validation
* Recovery option generation
* Weighted recommendation scoring
* Decision logging
* Crisis factor generation
* Case resource generation
* Fiori Object Page integration

## Repository

This repository contains the ABAP RAP backend and Fiori Elements service objects for the F1 Crisis Command Center project.

Package:

```text
ZRAP200_F1CC
```

Main service:

```text
ZUI_RAP200_F1CC
```

Service binding:

```text
ZUI_RAP200_F1CC_O4
```
