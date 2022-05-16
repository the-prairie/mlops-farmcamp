# MLOps



## Syllabus

This is a draft and will change. 


### [Module 1: Introduction](01-intro)

* What is MLOps
* MLOps maturity model
* Running example: NY Taxi trips dataset
* Why do we need MLOps
* Course overview
* Environment preparation
* Homework

[More details](01-intro)

### Module 2: Experiment tracking

* Experiment tracking intro
* Getting started with MLflow
* Experiment tracking with MLflow
* Saving and loading models with MLflow
* Model registry
* MLflow in practice
* Homework


### Module 3: Orchestration and ML Pipelines

* ML Pipelines: introduction
* Prefect
* Turning a notebook into a pipeline
* Kubeflow Pipelines
* Homework 


### Module 4: Model Deployment 

* Batch vs online
* For online: web services vs streaming
* Serving models in Batch mode
* Web services
* Streaming (Kinesis/SQS + AWS Lambda)
* Homework


### Module 5: Model Monitoring

* ML monitoring vs software monitoring 
* Data quality monitoring
* Data drift / concept drift 
* Batch vs real-time monitoring 
* Tools: Evidently, Prometheus and Grafana
* Homework 


### Module 6: Best Practices

* Devops
* Virtual environments and Docker
* Python: logging, linting
* Testing: unit, integration, regression 
* CI/CD (github actions)
* Infrastructure as code (terraform, cloudformation)
* Cookiecutter
* Makefiles
* Homework


### Module 7: Processes

* CRISP-DM, CRISP-ML
* ML Canvas
* Data Landscape canvas
* [MLOps Stack Canvas](https://miro.com/miroverse/mlops-stack-canvas/)
* Documentation practices in ML projects (Model Cards Toolkit)


### Project

* End-to-end project with all the things above


## Running example

To make it easier to connect different modules together, we’d like to use the same running example throughout the course.

Possible candidates: 

* [https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page](https://www1.nyc.gov/site/tlc/about/tlc-trip-record-data.page) - predict the ride duration or if the driver is going to be tipped or not


## Instructors

- Larysa Visengeriyeva
- Cristian Martinez
- Kevin Kho
- Theofilos Papapanagiotou 
- Alexey Grigorev
- Emeli Dral
- Sejal Vaidya


## Other courses from DataTalks.Club:

- [Machine Learning Zoomcamp - free 4-month course about ML Engineering](https://github.com/alexeygrigorev/mlbookcamp-code/tree/master/course-zoomcamp)
- [Data Engineering Zoomcamp - free 9-week course about Data Engineering](https://github.com/DataTalksClub/data-engineering-zoomcamp/)


## FAQ

**I want to start preparing for the course. What can I do?**

If you haven't used Flask or Docker

* Check [Module 5](https://github.com/alexeygrigorev/mlbookcamp-code/tree/master/course-zoomcamp/05-deployment) form ML Zoomcamp
* The [section about Docker](https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/week_1_basics_n_setup/2_docker_sql) from Data Engineering Zoomcamp could also be useful

If you have no previous experience with ML

* Check [Module 1](https://github.com/alexeygrigorev/mlbookcamp-code/tree/master/course-zoomcamp/01-intro) from ML Zoomcamp for an overview
* [Module 3](https://github.com/alexeygrigorev/mlbookcamp-code/tree/master/course-zoomcamp/03-classification) will also be helpful if you want to learn Scikit-Learn (we'll use it in this course)
* We'll also use XGBoost. You don't have to know it well, but if you want to learn more about it, refer to [module 6](https://github.com/alexeygrigorev/mlbookcamp-code/tree/master/course-zoomcamp/06-trees) of ML Zoomcamp
