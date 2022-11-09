# Self Managed MongoDB Sink Connector in kubernetes

In this example, you'll set up the following:

* Create extended Mongo Sink image with confluent
 
* Self-managed Kafka Connect cluster connected to Confluent Cloud

* Install and manage the Mongo Sink  connector plugin through the declarative Connector CRD

* Install Mongo Sink Configuration 


Set up Pre-requisites:

Create namespace

kubectl create ns confluent


Create Extended Mongo Sink Image
====================================

Create Mongodb sink Image with confluentinc base server connect

1. Download Mongodb sink jar from confluent 

https://www.confluent.io/hub/mongodb/kafka-connect-mongodb

Copy jar from above zip file in to new plugins directory

2. Create image from Docker file in local and push to image repo

docker build -t mong-sink:latest . 

docker tag mong-sink:latest <repouser>/connect:latest

docker push <repouser>/connect:latest 




Deploy confluent operator in kubernetes
==========================================
Install Helm

helm repo add confluentinc https://packages.confluent.io/helm

helm upgrade --install operator confluentinc/confluent-for-kubernetes -n confluent

validation of confluent operator running in kubernetes
===============================================================
kubectl get all --namespace confluent

NAME                                      READY   STATUS    RESTARTS   AGE

pod/confluent-operator   1/1     Running   0          

NAME                         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                               AGE

service/confluent-operator   ClusterIP   

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE

deployment.apps/confluent-operator   

NAME                                            DESIRED   CURRENT   READY   AGE

replicaset.apps/confluent-operator  


Set up Secrets in kubernetes
==============================
Create a new file named ccloud-credentials.txt of confluent cloud Kafka cluster

username=<your_cluster_key>
password=<your_cluster_secret>

Create another new file named ccloud-sr-credentials.txt of confluent cloud Kafka cluster schema registry 

username=<your_cluster_schema_registry_key>
password=<your_cluster_schema_registry_key>

Referencing these new text files, you will create Kubernetes secrets that will allow your connector to talk to Confluent Cloud.

kubectl create secret generic ccloud-credentials --from-file=plain.txt=ccloud-credentials.txt

kubectl create secret generic ccloud-sr-credentials --from-file=basic.txt=ccloud-sr-credentials.txt



Deploy Connect pod in kubernetes
===================================
Deploy the connect :

kubectl apply -f ./connect.yaml

Validation of Connect in kubernetes
=======================================
kubectl get all --namespace confluent

NAME                                      READY   STATUS    RESTARTS   AGE

pod/confluent-operator   1/1     Running   0          

pod/connect-0                             1/1     Running   0          

NAME                         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                               AGE

service/confluent-operator   ClusterIP   

service/connect              ClusterIP       

service/connect-0-internal   ClusterIP     

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE

deployment.apps/confluent-operator   

NAME                                            DESIRED   CURRENT   READY   AGE

replicaset.apps/confluent-operator  

NAME                       READY   AGE

statefulset.apps/connect   



Deploy Connector configuration in kubernetes
=============================================
Deploy the connector :

kubectl apply -f ./connector.yaml


Validation of all and connector in kubernetes
================================================
kubectl get all --namespace confluent

NAME                                      READY   STATUS    RESTARTS   AGE

pod/confluent-operator   1/1     Running   0          

pod/connect-0                             1/1     Running   0          

NAME                         TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                               AGE

service/confluent-operator   ClusterIP   

service/connect              ClusterIP       

service/connect-0-internal   ClusterIP     

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE

deployment.apps/confluent-operator   

NAME                                            DESIRED   CURRENT   READY   AGE

replicaset.apps/confluent-operator  

NAME                       READY   AGE

statefulset.apps/connect   

NAME                                                  STATUS    CONNECTORSTATUS   TASKS-READY   AGE

connector.platform.confluent.io/mongodb-atlas-sink3   


