## Installation
_Use these instructions if using Git for z/OS to access/manage the source code_

### Installation prerequisite
If you plan on using the supplied assembly and link job, you will need to customize the DFHEITAL proc from the CICS
SDFHPROC library. For further information regarding this proc, see...
http://www.ibm.com/support/knowledgecenter/en/SSGMCP_5.3.0/com.ibm.cics.ts.applicationprogramming.doc/topics/dfhp3_installprog_cicsproc.html

### Security ###
The default CICS userid will need access to run each instance of the transaction ID. It is recommended a block of
transactions be reserved for the service. The supplied definitions assume the zUID transactions will begin with "ID"
giving a range of ID00 to IDZZ.

For those implementations using https and a TCPIPService definition with the AUTHENTICATE parameter set to BASIC, the
authenticated userid will also need access to the transaction.

Administrators should have access to transaction UPLT to define the named counter prior to the first execution.

### Network Considerations ###
The strategy used by this implementation uses a cluster of application owner regions (AORs). No webservice owning
regions (WORs) are employed to route requests over to the AORs. It leverages a combination of sysplex distributor and
port sharing.

The port or ports reserved for this service are defined to a virtual IP address (VIPA) distribute statement (VIPADIST)
and the port is defined as a shared port (SHAREP). Binding the port to the distributed VIPA is optional. With this
arrangement, CICS regions are free to move around and supports more than one region on a LPAR.

The preferred approach is to use a unique host name per instance which will allow a single instance to be moved without
affecting any other instances. The unique host names would be assigned to the VIPA distribute address assigned to the
port(s). An example of unique host name would be zuid01.enterprise-services.mycompany.com matching instance ID01.

The drawback for using a unique host name per instance is certificate handling for https implementations. Either a
wildcard SSL certificate needs to be issued or the SSL certificate needs to have every host name in the subject
alternate name. Using the example above, the wildcard certificate would need to match on
*.enterprise-services.mycompany.com. For the latter scenario, an automated process to add the instance host name to
the subject altername name would be needed to streamline the process.

To provide redundancy across sysplexes a router would be needed to send requests to both sysplexes. Implementing this
level of redundancy requires additional host names to be utilized. There would be the primary host name the application
would use. This host name would be routed across the host name assigned to each sysplex. Using the example above,
the host name supplied to the application would be zuid01.enterprise-services.mycompany.com which would be configured
to be picked up by the router. The router would then choose a sysplex host name to use which could look something like
zuid01.sysplex01.enterprise-services.mycompany.com and zuid01.sysplex02.enterprise-services.mycompany.com. These host
names would be the ones pointing to the VIPA distribute address on their respective sysplex.

### Installation instructions
_These instructions assume that you have the Git for z/OS client installed and configured on your system, and that SSH keys have been set up appropriately._

1. [Fork the repo](https://help.github.com/articles/fork-a-repo/) to your user account.

1. From z/OS, identify a directory in USS to house the project and navigate into it.

1. Clone the project from your forked repo:

        git clone git@github.com:YOURNAME/zUID.git

1. You will now have a local project that contains an association to a remote named `origin`, which is your forked repo. In order to pull subsequent changes from the _original_ repo to your local project, an additional remote named `upstream` should be added to your project. Change into the working directory add the `upstream` remote:

        git remote add upstream git://github.com/walmart/zUID.git

1. In the working directory, there is a script named `Git2zos.exec`. This script will create a PDSE associated with each folder in the working directory and copy the respective files into those PDSE's. To run the script, first identify the values to be used for **@srclib_prfx@** and **@source_vrsn@** (as described several bullets below). These values will be passed as arguments on the script invocation. _From within the working directory_, issue the command like so (the arguments are not case-sensitive):
        
        Git2zos.exec 'YOUR.SOURCELIB.PREFIX' 'V010000'

1. *In the TXT source PDS/PDSE library, locate the CONFIG member and edit it.* This file contains a list of configuration items used
to configure the JCL and source to help match your installation standards. The file itself provides a brief
description of each configuration item. Comments are denoted by leading asterisk in the first word. The first word in non-comment lines is the configuration item and the second word is its value.

    1. **@auth@** is the value of the AUTHENTICATE parameter for the https TCPIPService definition. The values can be
    NO, ASSERTED, AUTOMATIC, AUTOREGISTER, BASIC, CERTIFICATE.

    1. **@certficate@** is for CERTIFICATE parameter in the TCPIPService definition for https. Specify certificate as
    CERTIFICATE(server-ssl-certificate-name).

    1. **@cics_csd@** is the dataset name of the CICS system definition (CSD) file.

    1. **@cics_hlq@** is the high level qualifier for CICS datasets.

    1. **@csd_list@** is the CSD group list name. This is the list name to use for the ZUID group.

    1. **@http_port@** is the http port number to be used for ZUID.

    1. **@https_port@** is the https port number to be used for ZUID.

    1. **@job_parms@** are the parameters following JOB in the JOB card. Be mindful. This substitution will only
    handle one line worth of JOB parameters when customizing jobs.

    1. **@proc_lib@** (Optional) is the dataset containing the customized version of the DFHEITAL proc supplied by IBM.
    If you plan to use the supplied assembly job, the proc library is required.

    1. **@program_lib@** (Optional) is the dataset to be used for zUID programs. If you plan to use the supplied assembly
    job, the program load library is required.
    
    1. **@srclib_prfx@** is the (potentially multi-node) prefix to be used for the various source libraries of the product. This should follow your installation standards. It could be as simple as your TSO PROFILE PREFIX, or could be a multi-node qualifier that represents your team. Of course, standard [z/OS dataset naming constraints](https://www.ibm.com/support/knowledgecenter/SSLTBW_2.1.0/com.ibm.zos.v2r1.idad400/name.htm) still apply. So, keep this to something <= 30 bytes/chars (including dot-separators) to avoid issues. We require up to 14 bytes/chars on the lower qualifier end to uniquely identify the various data stores.
    
    1. **@source_vrsn@** is the version identifier to be used as the LLQ for the collection of source libraries associated with this version of the product. We generally follow [Semantic Versioning](http://semver.org/) guidelines, with an exception for allowing leading zeros on the individual version/release/patch nodes in order to maintain consistency in the DSN LLQ format. The format of the version identifier that we'll follow for the foreseeable future is a 7-character DSN node like V*vvrrpp* where:
    
      _vv_ - represents major versions (i.e. breaking or non-backwards-compatible changes)
      
      _rr_ - represents minor releases (i.e. non-breaking or backwards-compatible feature changes)
      
      _pp_ - represents patches (i.e. non-breaking or backwards-compatible bug fixes)
      
      For example, V010000 is the initial version... and V010100 would represent the next _release_ with non-breaking changes, or V010001 would represent a bug-fix on the original version.

    1. **@tdq@** is the transient data queue (TDQ) for error messages. Must be 4 bytes.

1. Exit and save the CONFIG member in the source library.

1. In the JCL library, locate and edit the CONFIG member. This is the job that will customize the JCL and source
libraries. Because this job performs the customization, it will need to be customized in order to run. The following
customizations will need to be made.

    1. Modify JOB card to meet your system installation standards.

    1. Change all occurrences of the following.
        1. **@srclib_prfx@** is the (multi-node) prefix to be used for the various source libraries of the product. Example. C ALL @srclib_prfx@ CICSTS.ZUID
        1. **@source_vrsn@** to the current version of the product source code. Example. C ALL @source_vrsn@ V010000

1. Submit the CONFIG job. It should complete with return code 0. The remaining jobs and CSD definitions have been
customized.

1. Assemble the source. An assembly and link job has been provided to assemble the programs used for ZUID. You may use
the supplied job or use your own job.
    1. Using ASMZUID. The provided job ASMZUID utilizes the DFHEITAL proc from IBM for tranlating CICS commands. The
    DFHEITAL proc must be customized and available in the library specified earlier in the @proc_lib@ configuration item.
    Submit the ASMZUID job. It should end with return code 0.
    1. Using your own assembly and link jobs. If you wish to use your own assembly jobs, here is a list of programs and
    which require the CICS translator.
        1. ZUIDPLT (requires CICS translator)
        1. ZUIDSTCK
        1. ZUID001 (requires CICS translator)

1. Define the CICS resource definitions for zUID. In the JCL library, submit the CSDZUID member. This will install the
minimum number of definitions for ZUID.

1. Define the http port for zUID (optional). If you plan to use an existing http port (TCPIPService definition), you do
not need to submit this job. If you would like to setup a http port specifically for zUID. Submit the CSDZUIDN member in
the JCL library.

1. Define the https port for zUID (optional). The data provided by zUID is generally not regarded as sensitive data as it
is a random string with no relationship. You may however wish to allocate a https port if you intend web browsers to be
able to invoke the service. A https web page will not be able to call a http service directly. If you would like to setup
a https port specifically for zUID. Submit the CSDZUIDS member in the JCL library.

1. Install the ZUID CSD group. No job has been provided to install the ZUID group on the CSD. How CSD groups are
installed varies wildly from company to company. Cold starting CICS, using CICS Explorer, or using CEDA INSTALL are just
some of the ways to perform this action. If cold starting, you may want to hold off until the ZUIDPLT program is ready
to be picked up as entry in the PLTPI in the next few steps.

1. Define program ZUIDPLT as an entry to the PLTPI table in the regions destined to run the zUID services. Refer to
instructions for PLT-program list table in IBM Knowledge Center for CICS.

1. Invoke the ZUIDPLT program. This can be done by restarting the CICS region or by running the UPLT transaction in one
of the CICS regions.

#### Define a ZUID instance
1. Define an instance of ZUID. In the JCL library, the DEFID## member provides the JCL to define one instance of zUID.
While some parts of the job are customized, some parameters are left untouched so the process on installing a zUID
instance is repeatable. Keep in mind, you will want some method of keeping track of your clients and which instance of
zUID you have created for them. Recording the path as well is a good idea. Edit DEFID## in the JCL library and
customize the following fields.
    1. **@appname@** is the application name using this instance of ZUID. It is the third node of the path.
    1. **@grp_list@** is the CSD group list you wish this instance to be installed.
    1. **@id@** is the two character ZECS instance identifier ranging from 00 to ZZ.
    1. **@org@** is the organization identifier used in the path of the service.
    1. **scheme** is the setting for the SCHEME parameter on the URIMAP definition. Use either http or https.
    *Note: the path is created by the @org@ and @appname@ values; /uid/@org@/@appname@.*

1. Submit the DEFID## job to define the instance.

1. Install the ZUID CSD group. The CSD group name is the transaction ID. No job has been supplied to install the
definitions. Install by cold starting CICS, using CICS Explorer, or using CEDA INSTALL.
