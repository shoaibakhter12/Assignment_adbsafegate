1. Architectural Choices

For the local Kubernetes environment, I chose Kind because it is lightweight and easy to run on a local machine or EC2 instance.

I used Kubernetes to deploy a simple two-tier application:

Web tier: Nginx
Database tier: PostgreSQL
ConfigMap: Used for non-sensitive database configuration such as database name, username, and host.
Secret: Used for the database password.
PVC: Used to provide persistent storage for PostgreSQL.
Resource requests and limits: Used for both web and database pods to control CPU and memory usage.
Metrics Server: Used as a lightweight monitoring solution to check CPU and memory usage using kubectl top.

For the CI/CD part, I used GitHub Actions with Docker Compose because it is simpler and lighter than running a Kubernetes cluster inside the CI/CD pipeline. The pipeline builds the Docker image, starts the application, and performs a smoke test using curl.


2. Scalability

The current setup is a single-node local Kubernetes cluster, which is suitable for learning and testing but not for production.

To transition this architecture to a production-ready AWS environment, I would use Amazon EKS (Elastic Kubernetes Service).

The changes would be:

Use Amazon EKS instead of a single-node Kind cluster.
Use multiple worker nodes across different Availability Zones for high availability.
Run multiple replicas of the web application so traffic can continue if one pod or node fails.
Use an AWS Load Balancer to distribute traffic to the web pods.
Use Amazon RDS for PostgreSQL instead of running PostgreSQL directly inside Kubernetes.
Use Amazon EBS or another AWS storage service for persistent storage where required.
Use AWS Secrets Manager or AWS Systems Manager Parameter Store for sensitive information.
Use Horizontal Pod Autoscaler (HPA) to automatically increase or decrease web pod replicas based on resource usage.
Use Amazon CloudWatch for monitoring, logs, and alerts.
Use IAM roles and policies to provide least-privilege access to AWS resources.




3. Failure Analysis / Post-Mortem

During the local implementation, I faced two main issues.

Issue 1: PostgreSQL Pod in Pending State

The PostgreSQL pod initially remained in the Pending state because the required PersistentVolumeClaim (PVC) was not available.

I created the required PVC, after which Kubernetes was able to provide storage and the PostgreSQL pod started successfully.


Issue 2: Incorrect PostgreSQL Image

I initially used an incorrect PostgreSQL image name. Kubernetes was unable to pull the image, which resulted in image-pull errors and the pod restarting.

I fixed this by correcting the PostgreSQL image name in the Deployment.

Single Point of Failure

The main SPOF in the current local architecture is the single Kubernetes node.

If that node fails, both the web and database pods can become unavailable.

In AWS, I would mitigate this by using Amazon EKS with multiple worker nodes across multiple Availability Zones.

For the web tier, I would run multiple replicas so that if one node fails, another web pod can continue serving traffic.

For the database, I would use Amazon RDS for PostgreSQL with Multi-AZ deployment instead of running the database inside the Kubernetes cluster. This would reduce the dependency on a single Kubernetes node and provide higher availability.

4. Trade-offs

Since this project was designed for local execution, I made some compromises to keep it simple and lightweight.

Security

For the local environment, I used Kubernetes Secrets for the database password.

In a production AWS environment, I would use AWS Secrets Manager and IAM permissions instead of keeping credentials directly in Kubernetes configuration.

For the Docker application, I used a non-root user to follow the Principle of Least Privilege.

Performance

The local Kind cluster has limited CPU, memory, and storage because it is designed for development.

In AWS, I would use appropriately sized EKS worker nodes and configure proper resource requests and limits based on application requirements.

Availability

The local environment has only one node, so it does not provide high availability.

In AWS, I would use multiple EKS nodes across Availability Zones and multiple web replicas.

Complexity

I intentionally avoided a full Prometheus/Grafana stack and used Metrics Server because it is lightweight.

For production AWS, I would use CloudWatch and other AWS monitoring services for more complete monitoring and alerting.

Overall

The local solution sacrifices some security, scalability, performance, and availability in exchange for simplicity and low resource usage.
