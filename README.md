# zUID
z/OS-based Unique Identifier generator

A developer approached us looking for the ability to generate UUIDs on z/OS. Unfortunately, the z/OS UUID libraries went away with the removal of DCE a few years back. So, we decided to recreate the capability. However, we elected to develop our own algorithm to generate the value so that we could guarantee uniqueness. We continued to follow the format of the UUID standard so as to maintain familiarity and compatibility with other components, although we provide other formatting options as well. We also chose to primarily expose the capability through HTTP so that it would be accessible to the broadest array of clients, even though it is locally linkable, too.
