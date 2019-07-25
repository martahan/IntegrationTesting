# Continuous Integration for VyPR

To perform the continuous integration pipeline for VyPR, clone this repository and run `test_latest.sh`.  This will pull the necessary files from http://github.com/pyvypr/, perform instrumentation and monitoring, then test the analysis library.

The arguments are `github username` and `refresh`.  `github username` is used to decide from which repositories to take VyPRServer and SampleWebService from.  VyPR will always be taken from the pyvypr repository.
