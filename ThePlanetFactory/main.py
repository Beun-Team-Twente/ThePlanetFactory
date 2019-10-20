###############################################################################
# File: main.py
# Description: The main file that communicates with the processing program that
# visualizes the data. This file imports the data input data from the UI and
# and using machine learning to validate the data.
#
# Author: Beun Team Twente
# Creation Data: Saturday oktober 19 2019.
# Revision: -
###############################################################################

# import ...
import numpy as np
import pickle
import sys

from load_data import *
import classifier_habitable as clf_habitable
import regressor_earthlike as clf_earthlike

#print("Hello World... Literally")

train_data_from_scratch = False # if True, it trains new classifiers from 'data.csv' and saves them in "models.pkl"
                                # if False, it loads the trained classifiers from "models.pkl"

def save_classifier_data(filename="models.pkl"):
    # Save the classifiers, scalers and f_scores in a pickle file
    obj_data = {
        'reg_earthlike': clf_e,
        'reg_scaler': scaler_e,
        'reg_f_score': f_score_e,
        'clf_habitable': clf_h,
        'clf_scaler': scaler_h,
        'clf_f_score': f_score_h
    }
    
    with open(filename, 'wb') as handle:
        pickle.dump(obj_data, handle, protocol=pickle.HIGHEST_PROTOCOL)
    
def load_classifier_data(filename="models.pkl"):
    # Load the classifier data
    with open(filename, 'rb') as handle:
        obj_data = pickle.load(handle)
        return obj_data

clf_e = None
scaler_e = None
f_score_e = None
clf_h = None
scaler_h = None
f_score_h = None

if train_data_from_scratch == True: # Train classifiers from 'data.csv'
    data = load_data('data.csv')
    clf_e, scaler_e, f_score_e = clf_earthlike.train(data)
    clf_h, scaler_h, f_score_h = clf_habitable.train(data)
    save_classifier_data() # Save to file
else:
    obj_data = load_classifier_data() # Load from file
    clf_e = obj_data["reg_earthlike"]
    scaler_e = obj_data["reg_scaler"]
    f_score_e = obj_data["reg_f_score"]
    clf_h = obj_data["clf_habitable"]
    scaler_h = obj_data["clf_scaler"]
    f_score_h = obj_data["clf_f_score"]


# Command-line input
x = [float(i) for i in sys.argv[1:8]]

# Examples:
#earth_params = [1, 1, 270, 1, 0.9973, 1, 1]
#x = earth_params

# (earth-like planet)
#x = [1.0488323999999998, 4.191425871296586, 14.44020930473511, 0.0252, 1.2141138, 267.42977, 1]
#print([1, 0.93120767]) # Habitability and Earth-like index

# (non-habitable planet)
#x = [165.27056000000002, 14.7972, 0.75480786, 0.054496790999999996, 687.5577599999999, 1304.5845, 2]
#print([0, 0.062711769]) # Habitability and Earth-like index
 
 
print("{}-{}".format(clf_habitable.estimateHabitability(x, clf_h, scaler_h, f_score_h)[0],clf_earthlike.estimateEarthLike(x, clf_e, scaler_e, f_score_e)[0]))