###############################################################################
# File: load_data.py
# Description: Load the training data from the data.csv
#
# Author: Beun Team Twente
# Creation Data: Saturday oktober 19 2019.
# Revision: -
###############################################################################


import numpy as np
import pandas as pd

features = ['P_MASS', 'P_RADIUS', 'P_GRAVITY', 'P_DISTANCE', 'P_FLUX',
       'P_TEMP_EQUIL', 'P_TYPE_TEMP', 'P_HABITABLE', 'P_ESI']

hot_cold_mapping = {'Cold': 0,
                    'Warm': 1,
                    'Hot': 2,
                    np.nan: np.nan}

def load_data(filename = 'data.csv'):
    # Load the training data from csv. It replaces NaN with the mean of the feature.
    csv = pd.read_csv(filename)
    data = csv[features].to_numpy()
    
    # Replace hot-warm-cold with the mapping above
    for d in range(len(data[:,features.index('P_TYPE_TEMP')])):
        data[d, features.index('P_TYPE_TEMP')] = hot_cold_mapping[data[d, features.index('P_TYPE_TEMP')]]
    
    # Replace NaN with mean values for each column
    ids_nan = np.where(pd.isnull(csv[features]).to_numpy())
    mean_val = np.nanmean(data, axis=0)  # Ignore NaN in mean
    data[ids_nan] = np.take(mean_val, ids_nan[1])

    return data