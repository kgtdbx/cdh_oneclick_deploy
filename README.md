# cloudera_automated_install
Cloudera Automated Installation using Templates


Steps:

	1. Set cloudera local repo
	2. Install CM
		a. ./cloudera-manager-installer.bin --skip_repo_package=1 --i-agree-to-all-licenses --noprompt --noreadme --nooptions
	3. Install cloudera-manager-agentyum install -y cloudera-manager-agent
	4. Set CM host in  -    "/etc/cloudera-scm-agent/config.ini"
	5. Start agent service
	6. Install Java on all nodes
	7. parcel repository
	$curl -X PUT -H "Content-Type:application/json" -u admin:admin -X PUT --data @/tmp/repo.json http://192.168.56.112:7180/api/v19/cm/config


#Import the template using below command
curl -X POST -H "Content-Type: application/json" -d @cdh.json  http://admin:admin@node2.example.com:7180/api/v12/cm/importClusterTemplate

