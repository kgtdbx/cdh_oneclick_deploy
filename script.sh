#!/bin/bash

LOC=`pwd`
PROPS=cluster_cloud.props
source $LOC/$PROPS 2>/dev/null
STACK_VERSION=`echo $CLUSTER_VERSION|cut -c1-3`
AMBARI_HOST=$2
NUMBER_OF_HOSTS=`grep HOST $LOC/$PROPS|grep -v SERVICES|wc -l`
LAST_HOST=`grep HOST $LOC/$PROPS|grep -v SERVICES|head -n $NUMBER_OF_HOSTS|tail -1|cut -d'=' -f2`
grep HOST $LOC/$PROPS|grep -v SERVICES|grep -v $LAST_HOST|cut -d'=' -f2 > $LOC/list
OS_VERSION=`echo $OS|rev|cut -c1|rev`
START_HST_NAME=`grep 'HOST[0-9]*' $LOC/$PROPS|grep -v SERVICES|head -1|cut -d'=' -f1` 2>/dev/null
LAST_HST_NAME=`grep 'HOST[0-9]*' $LOC/$PROPS|grep -v SERVICES|tail -1|cut -d'=' -f1` 2>/dev/null
out_file=cdh

num_of_hosts=`grep HOST /opt/cloudera_automated_install/cluster_cloud.props|grep -v SERVICES|wc -l`
#i=1

#until [ $i -gt $num_of_hosts ]
#do
#	i=$[$i+1]
#	#echo "HOST defined are below"
#	export HOST$i=`grep HOST$i $LOC/$PROPS |grep -v SERVICES| awk -F "=" '{print $2}'`
##	i=`expr $i + 1`
#done

######### Generate Repo #########

echo "{
  \"items\" : [ {
    \"name\" : \"CLUSTER_STATS_START\",
    \"value\" : \"10/22/2012 4:50\",
    \"sensitive\" : false
  }, {
    \"name\" : \"REMOTE_PARCEL_REPO_URLS\",
    \"value\" : "\"$REPO_SERVER\"",
    \"sensitive\" : false
  } ]
}" > $LOC/repo.json
#################################


######### Template Function  #########
cdh_version()
{
echo "{
  \"cdhVersion\" : \"5.14.0\",
  \"displayName\" : \"$CLUSTERNAME\",
  \"cmVersion\" : \"5.14.0\",
  \"repositories\" : [ \"$REPO_SERVER\" ],
  \"products\" : [ {
    \"version\" : \"5.14.0-1.cdh5.14.0.p0.24\",
    \"product\" : \"CDH\"
  } ],"
}

get_services()
{
echo "  \"services\" : [ {
    \"refName\" : \"yarn\",
    \"serviceType\" : \"YARN\",
    \"roleConfigGroups\" : [ {
      \"refName\" : \"yarn-RESOURCEMANAGER-BASE\",
      \"roleType\" : \"RESOURCEMANAGER\",
      \"base\" : true
    }, {
      \"refName\" : \"yarn-JOBHISTORY-BASE\",
      \"roleType\" : \"JOBHISTORY\",
      \"base\" : true
    }, {
      \"refName\" : \"yarn-NODEMANAGER-BASE\",
      \"roleType\" : \"NODEMANAGER\",
      \"base\" : true
    } ]
  }, {
    \"refName\" : \"hdfs\",
    \"serviceType\" : \"HDFS\",
    \"roleConfigGroups\" : [ {
      \"refName\" : \"hdfs-DATANODE-BASE\",
      \"roleType\" : \"DATANODE\",
      \"base\" : true
    }, {
      \"refName\" : \"hdfs-NAMENODE-BASE\",
      \"roleType\" : \"NAMENODE\",
      \"base\" : true
    }, {
      \"refName\" : \"hdfs-BALANCER-BASE\",
      \"roleType\" : \"BALANCER\",
      \"base\" : true
    }, {
      \"refName\" : \"hdfs-SECONDARYNAMENODE-BASE\",
      \"roleType\" : \"SECONDARYNAMENODE\",
      \"base\" : true
    }, {
      \"refName\" : \"hdfs-DATANODE-1\",
      \"roleType\" : \"DATANODE\",
      \"base\" : false
    } ]
  }, {
    \"refName\" : \"zookeeper\",
    \"serviceType\" : \"ZOOKEEPER\",
    \"roleConfigGroups\" : [ {
      \"refName\" : \"zookeeper-SERVER-BASE\",
      \"roleType\" : \"SERVER\",
      \"base\" : true
    } ]
  } ],"
}

get_addhost_template(){
echo "\"hostTemplates\" : [ {
    \"refName\" : \"HostTemplate-$i-from-$HST_NAME_HOSTNAME.$DOMAIN_NAME\",
    \"cardinality\" : 1,
    \"roleConfigGroupsRefNames\" : [ $SERVICES_LIST ]
  }, {"
}

get_addhostadd_template(){
    echo "\"refName\" : \"HostTemplate-$i-from-$HST_NAME_HOSTNAME.$DOMAIN_NAME\",
    \"cardinality\" : 1,
    \"roleConfigGroupsRefNames\" : [ $SERVICES_LIST ]
  }, {"
}

get_last_template(){
echo "    \"refName\" : \"HostTemplate-$i-from-$HST_NAME_HOSTNAME.$DOMAIN_NAME\",
    \"cardinality\" : 1,
    \"roleConfigGroupsRefNames\" : [ $SERVICES_LIST ]
  } ],"
}


instantiator_template(){
echo "\"instantiator\" : {
    \"clusterName\" : \"$CLUSTERNAME\",
    \"hosts\" : [ {"
}

instantiator1_template(){
      echo "\"hostName\" : \"$HST_NAME_HOSTNAME.$DOMAIN_NAME\",
      \"hostTemplateRefName\" : \"HostTemplate-$i-from-$HST_NAME_HOSTNAME.$DOMAIN_NAME\"
    }, {"
}

instantiator_final_template(){
      echo "\"hostNameRange\" : \"$HST_NAME_HOSTNAME.$DOMAIN_NAME\",
      \"hostTemplateRefName\" : \"HostTemplate-$i-from-$HST_NAME_HOSTNAME.$DOMAIN_NAME\"
    } ],
    \"roleConfigGroups\" : [ {
      \"rcgRefName\" : \"hdfs-DATANODE-1\",
      \"name\" : \"\"
    } ]
  }
}"
}


######### Template Function  #########




generate_json()
{
cdh_version > $LOC/$out_file.json
echo -e "\n" >> $LOC/$out_file.json
get_services >> $LOC/$out_file.json
echo -e "\n" >> $LOC/$out_file.json

#---------------------------------------------------------
i=0
for HOST in `grep -w 'HOST[0-9]*' $LOC/$PROPS|tr '\n' ' '`
do
	HST_NAME_VAR=`echo $HOST|cut -d'=' -f1`
        if [ $HST_NAME_VAR == $START_HST_NAME ]
        then
		i=$[$i+1]
		HST_NAME_HOSTNAME=`echo $HOST|cut -d'=' -f2`
        	SERVICES_LIST=`cat $LOC/$PROPS|grep "$HST_NAME_VAR"_SERVICES |awk -F"=" '{print $2}'|sed 's/,/", "/g'|sed -e 's/[^ ]*CLIENT"[^ ]*//ig'|sed 's/" /"/g'`
		SERVICES_LIST=`echo $SERVICES_LIST | sed 's/,$//'`
                get_addhost_template >> $LOC/$out_file.json
        elif [ $HST_NAME_VAR == $LAST_HST_NAME ]
        then
		i=$[$i+1]
		HST_NAME_HOSTNAME=`echo $HOST|cut -d'=' -f2`
        	SERVICES_LIST=`cat $LOC/$PROPS|grep "$HST_NAME_VAR"_SERVICES |awk -F"=" '{print $2}'|sed 's/,/", "/g'|sed -e 's/[^ ]*CLIENT"[^ ]*//ig'|sed 's/" /"/g'`
        	#SERVICES_LIST=`cat $LOC/$PROPS|grep "$HST_NAME_VAR"_SERVICES |awk -F"=" '{print $2}'|sed 's/,/", "/g'|sed -e 's/[^ ]*CLIENT"[^ ]*//ig'|sed 's/" /"/g'|sed 's/ "//g'`
		SERVICES_LIST=`echo $SERVICES_LIST| sed 's/"$//g'`
		SERVICES_LIST=`echo $SERVICES_LIST| sed 's/,$//g'`
                get_last_template >> $LOC/$out_file.json
        else
		i=$[$i+1]
		HST_NAME_HOSTNAME=`echo $HOST|cut -d'=' -f2`
        	SERVICES_LIST=`cat $LOC/$PROPS|grep "$HST_NAME_VAR"_SERVICES |awk -F"=" '{print $2}'|sed 's/,/", "/g'|sed -e 's/[^ ]*CLIENT"[^ ]*//ig'|sed 's/" /"/g'`
        	#SERVICES_LIST=`cat $LOC/$PROPS|grep "$HST_NAME_VAR"_SERVICES |awk -F"=" '{print $2}'|sed 's/,/", "/g'|sed -e 's/[^ ]*CLIENT"[^ ]*//ig'|sed 's/" /"/g'|sed 's/ "//g'`
		SERVICES_LIST=`echo $SERVICES_LIST| sed 's/"$//g'`
		SERVICES_LIST=`echo $SERVICES_LIST| sed 's/,$//g'`
                get_addhostadd_template >> $LOC/$out_file.json
        fi
done
#---------------------------------------------------------

echo -e "\n" >> $LOC/$out_file.json

#---------------------------------------------------------
i=0
for HOST in `grep -w 'HOST[0-9]*' $LOC/$PROPS|tr '\n' ' '`
do
        HST_NAME_VAR=`echo $HOST|cut -d'=' -f1`
        if [ $HST_NAME_VAR == $START_HST_NAME ]
        then
                i=$[$i+1]
                HST_NAME_HOSTNAME=`echo $HOST|cut -d'=' -f2`
		instantiator_template >> $LOC/$out_file.json
		instantiator1_template >> $LOC/$out_file.json
        elif [ $HST_NAME_VAR == $LAST_HST_NAME ]
        then
                i=$[$i+1]
                HST_NAME_HOSTNAME=`echo $HOST|cut -d'=' -f2`
		instantiator_final_template >> $LOC/$out_file.json
        else
                i=$[$i+1]
                HST_NAME_HOSTNAME=`echo $HOST|cut -d'=' -f2`
		instantiator1_template >> $LOC/$out_file.json
        fi
done
#---------------------------------------------------------
}

generate_json


