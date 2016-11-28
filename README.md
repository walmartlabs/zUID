# Synopsis

zUID is a cloud enabled service in the z/OS environment that generates a unique identifier using a specialized patent-pending algorithm. It is guaranteed to generate 100% unique identifiers until the year 34,000 without requiring a database system to manage.

Service returns the UID in 3 different hex formats, plain, guid and ess in plain text format. They are not wrapped in XML or JSON structures.
- plain:	32 bytes, 1234567890abcdef1234567890abcdef
- ess:		34 bytes, 12345678-90abcdef12345678-90abcdef
- guid:		36 bytes, 12345678-90ab-cdef-1234-567890abcdef

No authorization is needed for this service.

In addition to being web enabled you can call this routine directly using a CICS LINK command in your COBOL programs. The HTTP interface was designed to make it available for more consumers outside the z/OS environment.


# Code Examples

In each of the examples the **_@path@_** variable is defined by the team that sets up the zUID service and the **_hostname:port_** values are all site specific.

## curl:
- ```curl -X GET "http://hostname:port@path@?options(format=guid)"```
	
## COBOL CICS:
All the examples are written in COBOL CICS for two reasons, 1) you can only make web service calls from CICS and 2) the actual routine has CICS API's in it so you can only link to it from a CICS program. Not able to call the routine directly from a batch environment.
	
- Refer to [readme_COBOL_service](./readmd_COBOL_service.md). Calls zUID as a service.
- Refer to [readme_COBOL_link](./readme_COBOL_link.md). Calls zUID with LINK PROGRAM API.
	
## standard browser (Chrome, IE, Safari):
- Request a "plain" UID from the service.
	http://hostname:port@path@
	
- Request a "ESS" UID from the service.
	http://hostname:port@path@?options(format=ess)
	
- Request a "GUID" UID from the service.
	http://hostname:port@path@?options(format=guid)
	
## Javascript:
- Show how to issue GET request for a new zUID value.
```javascript
	var svc = new XMLHttpRequest();
	var url = "http://hostname:port@path@?options(format=guid)";
	svc.open( "GET", url, false );
	svc.send( null );
	alert( "zUID response=" + svc.responseText );
```

# HTTP Status Codes (Web service calls only)
- 200 - Success
- 400 - Invalid Query String Option
- 405 - Invalid Request Only GET Allowed
- 503 - Unable to access CICS Named Counter


# LINK Status Codes (returned on LINK PROGRAM calls)
These are returned in the COMMAREA. Make sure the COMMAREA is properly initialized with the text "LINK" as the first 4 characters.

- 200 - Success
- 405 - Invalid Request Only LINK Allowed
- 409 - Invalid COMMAREA length calling via LINK PROGRAM. Must be 160 bytes.
- 415 - Invalid format, expecting plain, ess or guid. These are case sensitive and must be upper case.
- 503 - Unable to access CICS Named Counter
    
    
# Installation

Refer to the [installation instructions](./Installation.md) for complete setup in the z/OS environment.


# API Reference

## HTTP Calls:
- These can all be executed via the browser. Only supported method is "GET". The **_@path@_** variable is defined in the setup of the requested service.
	http://hostname:port@path@
	http://hostname:port@path@?options(format=plain)
	http://hostname:port@path@?options(format=ess)
	http://hostname:port@path@?options(format=guid)
	
## LINK PROGRAM Calls:
- The program routine name is ZUID001 and requires a fixed length 160 byte COMM AREA. Examples above are provided to show a complete program using this method.
	
	Comm Area Layout: Must be 160 bytes in length.
	- The first 4 bytes of the comm area must be uppercase "LINK". If not you will get unexpected results.
	- The status codes listed above are returned in CA-STATUS-CODE.
	- Set the CA-FORMAT field to the desired format. These are case sensitive and must be upper case.
	- If status code = 200 the UID is returned in the CA-UID field.
```COBOL
	01  ZUID-COMM-AREA.                                  
	    05  FILLER             PIC  X(04) VALUE 'LINK'. 
	    05  CA-STATUS-CODE     PIC  X(03).              
	    05  FILLER             PIC  X(09).              
	    05  CA-FORMAT          PIC  X(05) VALUE 'PLAIN'.
	        88  CA-FORMAT-PLAIN     VALUE 'PLAIN'.      
	        88  CA-FORMAT-ESS       VALUE 'ESS'.        
	        88  CA-FORMAT-GUID      VALUE 'GUID'.       
	    05  FILLER             PIC  X(11).              
	    05  CA-UID             PIC  X(36).              
            05  FILLER             PIC  X(92).              
            
         CICS API to call routine.
         EXEC CICS LINK                             
	      PROGRAM( 'ZUID001' )                  
	      COMMAREA( ZUID-COMM-AREA )            
	      LENGTH  ( LENGTH OF ZUID-COMM-AREA )  
	      NOHANDLE                              
         END-EXEC.                                  
```


# Contributors

- **_Randy Frerking_**,	Walmart Stores Inc.
- **_Rich Jackson_**, Walmart Stores Inc.
- **_Michael Karagines_**, Walmart Stores Inc.


# Additional Info

Most of these configuration considerations are covered in a bit more detail in a couple of Redbooks published by IBM in collaboration with the 
Walmart SMEs. Please refer to these publications for additional information:

### Creating IBM z/OS Cloud Services
http://www.redbooks.ibm.com/redbooks/pdfs/sg248324.pdf

### How Walmart Became a Cloud Services Provider with IBM CICS 
http://www.redbooks.ibm.com/redbooks/pdfs/sg248347.pdf
