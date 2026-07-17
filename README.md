# ETL_Data-WareHouse
A modern data ware house with SQl server following ETL processes , data modeling,and analytics


# Data Warehouse and Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository! 

This project showcases an end-to-end data warehousing and analytics solution — from designing and building a data warehouse to producing meaningful business insights. Built as a portfolio piece, it reflects real-world best practices used in data engineering and analytics.

---

## 🏗️ Data Architecture

The architecture of this project is based on the **Medallion Architecture**, structured into three layers: Bronze, Silver, and Gold.

![image alt](https://github.com/Fahadkhan2450/SQL_Data-WareHouse/blob/b516d97702c9aad4bfbf9f45725953e60461171f/docs/DataWarehouse%20structure%20and%20Flow.drawio.png)



   

- **Bronze Layer** — Holds raw, unprocessed data exactly as it comes from the source systems. Data is loaded from CSV files directly into a SQL Server database.
- **Silver Layer** — Applies data cleansing, standardization, and normalization so the data is ready for downstream analysis.
- **Gold Layer** — Contains business-ready data, structured into a star schema to support reporting and analytics.

---

## 📖 Project Overview

This project covers the following areas:

- **Data Architecture** — Designing a modern data warehouse built on the Bronze, Silver, and Gold layer model.
- **ETL Pipelines** — Extracting, transforming, and loading data from source systems into the warehouse.

![image alt](https://github.com/Fahadkhan2450/SQL_Data-WareHouse/blob/b516d97702c9aad4bfbf9f45725953e60461171f/docs/Data_flow.drawio.png)

- **Data Modeling** — Building fact and dimension tables optimized for analytical queries.
- **Analytics & Reporting** — Writing SQL-based reports and dashboards that surface actionable insights.

🎯 This repository serves as a strong reference for anyone looking to build or demonstrate skills in:

- SQL Development
- Data Architecture
- Data Engineering
- ETL Pipeline Development
- Data Modeling
- Data Analytics

---

## 🛠️ Important Links & Tools

Everything used in this project is completely free!

- **Datasets** — The project's source data, provided as CSV files.
- **SQL Server Express** — A lightweight edition of SQL Server for hosting your database.
- **SQL Server Management Studio (SSMS)** — A graphical interface for managing and querying your database.
- **Draw.io** — A free tool for designing architecture diagrams, data models, and flowcharts.
- **Notion** 

---

## 🚀 Project Requirements

### Building the Data Warehouse 

**Objective**
Build a modern data warehouse using SQL Server that consolidates sales data from multiple sources, enabling reliable analytical reporting and better decision-making.

**Specifications**
- **Data Sources**: Import data from two source systems — ERP and CRM — supplied as CSV files.
- **Data Quality**: Identify and resolve data quality issues before the data is analyzed.
- **Integration**: Merge both sources into a single, easy-to-use data model built for analytical queries.
- **Scope**: Work with the most current dataset only; historical tracking of data changes is not required.
- **Documentation**: Deliver clear, well-organized documentation of the data model for both business stakeholders and analytics teams.

### BI: Analytics & Reporting (Data Analysis)

**Objective**
Build SQL-based analytics that provide clear insight into:

- Customer Behavior
- Product Performance
- Sales Trends

These insights give stakeholders the key metrics they need to make informed, strategic decisions.


---

## 📂 Repository Structure

```
ETL_data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)
│
├── docs/                               # Project documentation and architecture details
│   ├──                     # Draw.io file illustrating the various ETL techniques and methods
│   ├── data_architecture and flow.drawio        # Draw.io file showing the project's overall architecture
│   ├── data_flow.png                # Catalog of datasets, including field descriptions and metadata
│   ├── Silver_layer.drawio.png                # Draw.io file for the data flow diagram
│   ├── Star_Schema.drawio.png              # Draw.io file for the data models (star schema)
│   ├── integration_model.draw.io.png           # Naming guidelines for tables, columns, and files
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├── bronze/                         # Scripts for extracting and loading raw data
│   ├── silver/                         # Scripts for cleaning and transforming data
│   ├── gold/                           # Scripts for building analytical models
│
├── tests/                              # Test scripts and data quality checks
│
├── README.md                           # Project overview and instructions
├── LICENSE                             # License information for the repository
├── .gitignore                          # Files and directories excluded from Git tracking
└── requirements.txt                    # Dependencies and requirements for the project
```
