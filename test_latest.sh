# script to pull the relevant code from the repositories
# VyPRServer, which requires VyPR
# VyPRAnalysis, which requires VyPR
# SampleWebService, which requires VyPR

# we may want to use virtual environments for dependencies at some point...
# at the moment we don't need it, but it's worth considering.

echo "Working in:";
pwd;

if [ $# -eq 2 ] && [ "$2" == "refresh" ]; then
	echo "Pulling all code again."
	# remove current versions
	rm -rf VyPRServer VyPRAnalysis SampleWebService;
	# clone the new versions
	echo "Cloning VyPRServer...";
	git clone git@github.com:$1/VyPRServer.git;
	if [ ! $? -eq 0 ]; then
		echo "git pull failed.  Defaulting to pyvypr version."
		git clone git@github.com:pyvypr/VyPRServer.git;
	fi
	echo "Cloning VyPRAnalysis...";
	git clone git@github.com:$1/VyPRAnalysis.git;
	if [ ! $? -eq 0 ]; then
                echo "git pull failed.  Defaulting to pyvypr version."
		git clone git@github.com:pyvypr/VyPRAnalysis.git;
        fi
	echo "Cloning SampleWebService...";
	git clone git@github.com:$1/SampleWebService.git;
	if [ ! $? -eq 0 ]; then
                echo "git pull failed.  Defaulting to pyvypr version."
		git clone git@github.com:pyvypr/SampleWebService.git;
        fi
	echo "Cloning VyPR into VyPRServer, VyPRAnalysis and SampleWebService...";
	# when we clone VyPR, we always clone from the main repository - there aren't any forks at the moment
	cd VyPRServer;
	git clone git@github.com:pyvypr/VyPR.git;
	cd ../VyPRAnalysis;
	git clone git@github.com:pyvypr/VyPR.git;
	cd ../SampleWebService;
	git clone git@github.com:pyvypr/VyPR.git;
	echo "All cloning is finished.  Running tests.";
else
	echo "Not pulling code again.  Just running tests."
fi

# move back to the root of the testing environment
# cd ../;

# we use tmux to manage sessions so we can have the monitored service in one,
# the VyPR verdict server running in another, and send HTTP requests with curl
# from a third

# Note: when a tmux session is created, it's starting directory is the current
# working directory, so we don't have to cd anywhere.

# new detached session for the verdict server
tmux new -d -s verdict_server;
tmux send-keys -t verdict_server 'cd VyPRServer/' Enter;
tmux send-keys -t verdict_server 'rm verdicts.db' Enter;
tmux send-keys -t verdict_server 'sqlite3 verdicts.db < verdict-schema.sql' Enter;
tmux send-keys -t verdict_server 'python run_service.py' Enter;
echo "Verdict server setup."

# delay a bit to give the server a chance to get started
sleep 3;

tmux list-sessions;

# new detached session for the monitored program
tmux new -d -s monitored;
tmux send-keys -t monitored 'cd SampleWebService/' Enter;
tmux send-keys -t monitored 'mkdir instrumentation_maps/ binding_spaces/ index_hash/' Enter;
tmux send-keys -t monitored 'python VyPR/instrument.py' Enter;
tmux send-keys -t monitored 'python run.py' Enter;
echo "Monitored service running."

# again, delay a bit to make sure the server is started
sleep 3;

tmux list-sessions;

echo "Sending requests to monitored service."

# verdict server and monitored service are now running in separate sessions
tmux new -d -s requests;
tmux send-keys -t requests 'curl http://0.0.0.0:8888/paths_branching_test/11/' Enter;
tmux send-keys -t requests 'curl http://0.0.0.0:8888/paths_branching_test/12/' Enter;
tmux send-keys -t requests 'curl http://0.0.0.0:8888/paths_branching_test/5/' Enter;
tmux send-keys -t requests 'curl http://0.0.0.0:8888/paths_branching_test/6/' Enter;

# give the server a chance to respond before we close this session
sleep 5;

tmux list-sessions;

# requests sent - the verdict database should have been populated now,
# so we stop the servers and end the sessions
# TODO: add end point to verdict server for clean monitoring thread exit
# basically what I did for the TACAS VM

# send the ctrl-c command to the verdict server to stop it
#tmux send -t verdict_server C-c Enter;
#tmux send -t verdict_server exit Enter;
# the same for the monitored service
#tmux send -t monitored C-c Enter;
#tmux send -t monitored exit Enter;

# exit the requests thread
#tmux send -t requests exit Enter;


# all done - time for testing the analysis library...
cd IntegrationTesting/;
python run_tests.py;
echo "Testing finished.";


# clean exit of all sessions
tmux kill-server;

