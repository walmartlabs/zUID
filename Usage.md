#Usage
# Code Examples

In each of the examples the **_@path@_** variable is defined by the team that sets up the zUID service and the **_hostname:port_** values are all site specific.

## curl:
- ```curl -X GET "http://hostname:port@path@?options(format=guid)"```
	
## COBOL CICS:
All the examples are written in COBOL CICS for two reasons, 1) you can only make web service calls from CICS and 2) the actual routine has CICS API's in it so you can only link to it from a CICS program. Not able to call the routine directly from a batch environment.
	
- Refer to [readme_COBOL_service](./readme_COBOL_service.md). Calls zUID as a service.
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



