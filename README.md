## Conversion Path Analysis 
### Motivation
This project focuses on performing conversion path analysis using a series of Jupyter notebooks. The goal is to understand the journey of users through different stages of a conversion funnel, identifying key drop-off points and optimizing the conversion process.

### Project Structure
The project consists of three main Jupyter Notebooks, located in "notebooks" folder, each responsible for a different stage of the analysis:

#### 01_data_preparation.ipynb

Description: This notebook is dedicated to preparing the data for analysis. It involves cleaning, transforming, and organizing raw data into a structured format suitable for further analysis.

#### 02_data_analysis.ipynb

Description: This notebook performs the core data analysis. It includes exploratory data analysis (EDA), identification of key metrics, and the extraction of insights related to the conversion paths.

#### 03_data_visualisation.ipynb

Description: This notebook focuses on visualizing the results of the data analysis. It includes various charts and graphs that help in understanding the conversion paths and the effectiveness of different stages in the funnel.


### Getting Started
To run the notebooks, follow these steps:

1. Clone the repository:

```
git clone https://github.com/katinka-bella/conversion_path_analysis.git
``` 

2. Set up the environment:

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

3. Run Jupyter-Notebook / Jupyterlab

```
# run jupyter-notebook
jupyter notebook
```
