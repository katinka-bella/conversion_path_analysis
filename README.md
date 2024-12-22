## Conversion Path Analysis 
### Motivation
This project focuses on performing conversion path analysis using a series of Jupyter notebooks. The goal is to understand the journey of users through different stages of a conversion funnel, identifying key drop-off points and optimizing the conversion process.

### Project Structure
The project consists of three main Jupyter Notebooks and one SQL script, located in "notebooks" folder, each responsible for a different stage of the analysis:

#### 00_data_extract.sql

Description: This SQL script is designed to extract and preprocess raw GA4 data stored in BigQuery for conversion path analysis. 

#### 01_data_preparation.ipynb

Description: This notebook is dedicated to preparing the data for analysis. It involves cleaning, transforming, and organizing data into a structured format suitable for further analysis.

#### 02_data_analysis.ipynb

Description: This notebook performs the core data analysis. It includes exploratory data analysis (EDA), identification of key metrics, and the extraction of insights related to the conversion paths.

#### 03_data_visualisation.ipynb

Description: This notebook focuses on visualizing the results of the data analysis. It includes various charts and graphs that help in understanding the conversion paths and the effectiveness of different stages in the funnel.


### Getting Started

1. Connect GA4 to BigQuery

Ensure that your GA4 account is connected to BigQuery. You can follow Google's guide to set this up.

2. Use Predefined SQL Query

The SQL query required to extract the data is saved in the file 00_data_extract.sql.
Use this query in BigQuery to create a view of the required dataset. This will ensure the data is in the correct structure for analysis.

3. Clone the repository:

```
git clone https://github.com/katinka-bella/conversion_path_analysis.git
``` 

4. Set up the environment:

#### Windows
```
# install python package 
pip install virtualenv

# navigate to local repository
cd conversion_path_analysis

# create virtual environment
virtualenv .venv

# activate venv
.\.venv\Scripts\activate

# install Python packages 
pip install -r requirements.txt
```

#### Mac
```
# navigate to local repository
cd conversion_path_analysis 

# create virtual environment
python -m venv .venv

# activate venv (mac)
source .venv/bin/activate

# install Python packages 
pip install -r requirements.txt
```

5. Run Jupyter-Notebook / Jupyterlab

```
# run jupyter-notebook
jupyter notebook
```
