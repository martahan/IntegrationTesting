# script to pull the relevant code from the repositories
# VyPRServer, which requires VyPR
# VyPRAnalysis, which requires VyPR
# SampleWebService, which requires VyPR

cd /int-testing/;

echo "Working in:";
pwd;

if [ $# -eq 2 ] && [ "$2" == "refresh" ]; then
	echo "Pulling all code again."
	# remove current versions
	rm -rf VyPRServer VyPRAnalysis SampleWebService;
	# clone the new versions
	echo "Cloning VyPRServer...";
	git clone git@github.com:$1/VyPRServer.git;
	echo "Cloning VyPRAnalysis...";
	git clone git@github.com:$1/VyPRAnalysis.git;
	echo "Cloning SampleWebService...";
	git clone git@github.com:$1/SampleWebService.git;
	echo "Cloning VyPR into VyPRServer, VyPRAnalysis and SampleWebService...";
	# when we clone VyPR, we always clone from the main repository - there aren't any forks at the moment
	cd VyPRServer;
	git clone git@github.com:pyvypr/VyPR.git;
	cd ../VyPRAnalysis;
	git clone git@github.com:pyvypr/VyPR.git;
	cd ../SampleWebService;
	git clone git@github.com:pyvypr/VyPR.git;
	echo "All cloning is finished.  Running tests.";
	cd /int-testing/;
else
	echo "Not pulling code again.  Just running tests."
fi

python run_tests.py;
echo "Testing finished.";
