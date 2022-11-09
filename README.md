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
apiVersion: platform.confluent.io/v1beta1
kind: Connect
metadata:
  name: connect
spec:
  
  replicas: 1
  image:
    application: mong-sink:latest.     (Utilize mongosink image created above)
    init: confluentinc/confluent-init-container:2.4.1
  podTemplate:
   resources:
     requests:
       cpu: 1000m
       memory: 512Mi
   probe:
     liveness:
       periodSeconds: 10
       failureThreshold: 5
       timeoutSeconds: 30
       initialDelaySeconds: 100
     readiness:
       periodSeconds: 10
       failureThreshold: 5
       timeoutSeconds: 30
       initialDelaySeconds: 100
   podSecurityContext:
     fsGroup: <>
     runAsUser: <>
     runAsNonRoot: true

            
  dependencies:
    kafka:
     bootstrapEndpoint: <host>:9092
     authentication:
       type: plain
       jaasConfig:
         secretRef: ccloud-credentials
     tls:
        enabled: true
        ignoreTrustStoreConfig: true
   schemaRegistry:
       url: <your_schema_registry_url>
       authentication:
         type: basic
         basic:
           secretRef: ccloud-sr-credentials

Deploy the connect with the following:
kubectl apply -f ./connect.yaml


Deploy Connector configuration
==========================
apiVersion: platform.confluent.io/v1beta1
kind: Connector
metadata:
  name: mongodb-atlas-sink3
  namespace: confluent
spec:
  class: "com.mongodb.kafka.connect.MongoSinkConnector"
  taskMax: 1
  connectClusterRef:
    name: connect
    namespace: confluent
  configs:
    
    "topics": "topic_0"
    "connection.uri": "mongodb+srv://<userid>:<pswd>@<host>”
    "database": “<db>”
    "collection": “<coll>“
    "tasks.max": "1"

Deploy the connector with the following:
kubectl apply -f ./connector.yaml
