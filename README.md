# mongodbsink
Create Mongodb sink Image
1. Download Mongodb sink jar from confluent 
https://www.confluent.io/hub/mongodb/kafka-connect-mongodb
 Copy jar from above zip file in to new plugins directory

2. Create Docker file with below 

FROM confluentinc/cp-server-connect:7.2.2
COPY ./plugins/ /usr/share/java/acl/

3. Docker build 

docker build -t mong-sink:latest . 




Deploy confluent operator
================================
helm repo add confluentinc https://packages.confluent.io/helm

helm upgrade --install operator confluentinc/confluent-for-kubernetes -n confluent

Set up Secrets
==============
Create a new file named ccloud-credentials.txt of confluent cloud Kafka cluster

username=<your_cluster_key>
password=<your_cluster_secret>

Create another new file named ccloud-sr-credentials.txt of confluent cloud Kafka cluster schema registry 

username=<your_cluster_schema_registry_key>
password=<your_cluster_schema_registry_key>

Referencing these new text files, you will create Kubernetes secrets that will allow your connector to talk to Confluent Cloud.

kubectl create secret generic ccloud-credentials --from-file=plain.txt=ccloud-credentials.txt

kubectl create secret generic ccloud-sr-credentials --from-file=basic.txt=ccloud-sr-credentials.txt



Deploy Connect pod
===================
Deploy the connect :

kubectl apply -f ./connect.yaml


Deploy Connector configuration
==========================
Deploy the connector :

kubectl apply -f ./connector.yaml
