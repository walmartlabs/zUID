# System Requirements and Considerations

The following information covers the basic requirements and configuration items that must be considered for hosting this service. Specific configuration values will vary from user ot user, so many of these items reflect areas of focus and general guidelines for implementation.

## Minimum Requirements

The following items represent the barest minimum of requirements to run the zUID service.

- z/OS 1.12
- HLASM 5
- COBOL 4.2
- CICS/TS 4.2
- z/OS Parallel Sysplex (CF for CICS Named Counter Server)

## Recommended Requirements

In order to get the most out of this service, we strongly recommend setting up your hosting environment to be elastic and highly-available. This includes:

- Setting up clusters of CICS regions (with multi-tenant hosting)
- Enable WLM-managed Dynamic Sysplex Distribution
- Define Shared Ports for your CICS region clusters
- Employ DNS CNAME records to abstract consumer-view URIs from the DNS A records assigned to the DVIPA

## Configuration Items

Particular configuration values that need to be reviewed and adjusted for your expected usage include the following items. These settings are complementary, and must be considered in unison.

### CICS

- MAXOPENTCBS - Specified in CICS Resource Definitions, controls the maximum number of open TCBs for threadsafe applications
- MAXSSLTCBS - Specified in CICS Resource Definitions, controls the maximum number of TCBs for SSL and TLS handshake processing

### z/OS

- MAXPROCSYS - Specified in BPXPMRxx, controls the maximum number of processes per system or LPAR
- MAXPROCUSER - Specified in BPXPRMxx, controls the maximum number of processes per user ID, or region ID in this case

## Additional Considerations

In addition to the previous settings, these items should be reviewed for applicability:

### WLM
- LPAR Weighting
- Service Classes
- ASID Weights

### Other
- Capacity Planning
- Monitoring
- Coordination with other components (.e.g. DNS changes)


## Additional Info

Most of these configuration considerations are covered in a bit more detail in a couple of Redbooks published by IBM in collaboration with the Walmart SMEs. Please refer to these publications for additional information:

#### Creating IBM z/OS Cloud Services
http://www.redbooks.ibm.com/redbooks/pdfs/sg248324.pdf

#### How Walmart Became a Cloud Services Provider with IBM CICS 
http://www.redbooks.ibm.com/redbooks/pdfs/sg248347.pdf
