# zUID

zUID is a cloud enabled service in the z/OS environment that generates a unique identifier using a specialized patent-pending algorithm. It is guaranteed to generate 100% unique identifiers until the year 34,000 without requiring a database system to manage.

Service returns the UID in 3 different hex formats, plain, guid and ess in plain text format. They are not wrapped in XML or JSON structures.
- plain:	32 bytes, 1234567890abcdef1234567890abcdef
- ess:		34 bytes, 12345678-90abcdef12345678-90abcdef
- guid:		36 bytes, 12345678-90ab-cdef-1234-567890abcdef

No authorization is needed for this service.

In addition to being web enabled you can call this routine directly using a CICS LINK command in your COBOL programs. The HTTP interface was designed to make it available for more consumers out side the z/OS environment.

## About this project 

Please refer to the following locations for additional info regarding this project:

- [System Requirements and Considerations.md](./System Requirements and Considerations.md) for minimum software version requirements and key environment configuration considerations
- [Installation.md](./Installation.md) for instructions on installing and setting up this service
- [Usage.md](./Usage.md) for API descriptions, sample code snippets for consuming the service, other usage related details

### Contributors

- **_Randy Frerking_**,	Walmart Technology
- **_Rich Jackson_**, Walmart Technology
- **_Michael Karagines_**, Walmart Technology
- **_Trey Vanderpool_**, Walmart Technology
