# cloudera_automated_install
Cloudera Automated Installation using Templates


Steps:

	1. Set cloudera local repo
	2. Install CM
		a. ./cloudera-manager-installer.bin --skip_repo_package=1 --i-agree-to-all-licenses --noprompt --noreadme --nooptions
	3. Install cloudera-manager-agentyum install -y cloudera-manager-agent
	4. Set CM host in  -    "/etc/cloudera-scm-agent/config.ini"
	5. Start agent service
	6. Set parcel repository
	$curl -u admin:admin "http://node2.example.com:7180/api/v12/cm/config" > /tmp/repo.json
	Modify file - 
	$curl -X PUT -H "Content-Type:application/json" -u admin:admin -X PUT --data @/tmp/repo.json http://192.168.56.112:7180/api/v19/cm/config

#Export existing cluster template using below command -
$curl -u adminuser:adminpass "http://myCluster-1.myDomain.com:7180/api/v12/clusters/Cluster1/export

curl -X POST -H "Content-Type: application/json" -d @cdh.json  http://admin:admin@node2.example.com:7180/api/v12/cm/importClusterTemplate

curl -X POST -H "Content-Type: application/json" http://admin:admin@192.168.56.112:7180/api/v19/clusters/demo/parcels/products/CDH/versions/5.14.0-1.cdh5.14.0.p0.24/commands/startDownload

#######Check parcel status using below command
$curl -u admin:admin http://192.168.56.112:7180/api/v19/clusters/demo/parcels

curl -X POST -H "Content-Type: application/json" http://admin:admin@192.168.56.112:7180/api/v19/clusters/demo/parcels/products/CDH/versions/5.14.0-1.cdh5.14.0.p0.24/commands/startDistribution

curl -X POST -H "Content-Type: application/json" http://admin:admin@192.168.56.112:7180/api/v19/clusters/demo/parcels/products/CDH/versions/5.14.0-1.cdh5.14.0.p0.24/commands/activate

#curl -X POST -H "Content-Type: application/json" -d @cdh.json  http://admin:admin@node2.example.com:7180/api/v12/cm/importClusterTemplate
