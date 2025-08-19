# Personal Electric Vehicle Registration System

A comprehensive blockchain-based system for managing registration, insurance, and safety compliance of personal electric vehicles including e-bikes, e-scooters, and other personal EVs.

## Overview

This system provides a decentralized platform for:
- **Vehicle Registration**: Secure registration of personal electric vehicles with unique identification
- **Insurance Management**: Tracking insurance policies, claims, and coverage details
- **Safety Inspections**: Mandatory safety checks and maintenance requirement tracking
- **Theft Protection**: Vehicle recovery assistance and theft reporting
- **Accident Reporting**: Transparent accident documentation and liability determination

## Smart Contracts

### 1. Vehicle Registration Contract (`vehicle-registration.clar`)
- Manages vehicle registration with unique IDs
- Stores vehicle specifications, owner information, and registration status
- Handles registration renewals and transfers

### 2. Insurance Management Contract (`insurance-management.clar`)
- Tracks insurance policies linked to registered vehicles
- Manages premium payments and policy renewals
- Handles insurance claims and payouts

### 3. Safety Inspection Contract (`safety-inspection.clar`)
- Records mandatory safety inspections
- Tracks maintenance schedules and compliance
- Issues safety certificates and violation notices

### 4. Theft Protection Contract (`theft-protection.clar`)
- Manages theft reporting and recovery processes
- Coordinates with law enforcement and recovery services
- Tracks stolen vehicle status and recovery rewards

### 5. Accident Reporting Contract (`accident-reporting.clar`)
- Documents accident reports with immutable records
- Manages liability determination and insurance claims
- Provides transparent dispute resolution

## Key Features

- **Decentralized Identity**: Each vehicle gets a unique blockchain-based identity
- **Immutable Records**: All transactions and reports are permanently recorded
- **Automated Compliance**: Smart contracts enforce safety and insurance requirements
- **Transparent Processes**: All stakeholders can verify registration and compliance status
- **Integration Ready**: Designed for integration with traffic management and parking systems

## Data Types

- **Vehicle Types**: E-bike, E-scooter, Personal EV, Electric Skateboard, Electric Unicycle
- **Registration Status**: Active, Expired, Suspended, Revoked
- **Insurance Status**: Active, Expired, Claimed, Cancelled
- **Safety Status**: Compliant, Overdue, Failed, Exempt

## Getting Started

1. Install Clarinet CLI
2. Run `clarinet check` to validate contracts
3. Run `npm test` to execute the test suite
4. Deploy contracts using `clarinet deploy`

## Testing

The system includes comprehensive tests using Vitest covering:
- Contract deployment and initialization
- Vehicle registration workflows
- Insurance policy management
- Safety inspection processes
- Theft reporting and recovery
- Accident documentation

## License

MIT License - See LICENSE file for details
