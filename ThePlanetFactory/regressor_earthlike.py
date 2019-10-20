import numpy as np
from sklearn.svm import SVR
from sklearn.neural_network import MLPRegressor
from sklearn.preprocessing import StandardScaler
from sklearn.feature_selection import SelectKBest, mutual_info_regression

N_FEATURES = 7
OUTPUT_COLUMN = 8

clf = N_FEATURES*[None]
scaler = None
feature_score = N_FEATURES*[1]
_feature_mask = list(range(N_FEATURES))
_o = OUTPUT_COLUMN

def scoreFeatures(training_data):
    features = SelectKBest(mutual_info_regression, k='all').fit(training_data[:, _feature_mask], training_data[:,_o].astype(np.int))
    scores_of_features = features.scores_
    return np.array(scores_of_features)

def train(training_data):
    # data is N-samples long and 9 columns wide - 2 last columns are the target
    
    feature_score = scoreFeatures(training_data)
    feature_score = feature_score/np.sum(feature_score) # Normalize to 1
    
#    # Keep equal number of earthlike-planets

#    earthlike_indx = np.where(training_data[:,_o] > 0.65)[0] 
###    habitable = np.where(training_data[:,8] == 2)[0]
#    nonearthlike_indx = np.random.choice(np.where(training_data[:,_o] < 0.4)[0], len(earthlike_indx), replace = False)
#    training_data = np.concatenate((training_data[nonearthlike_indx], training_data[earthlike_indx]))
    
    scaler = StandardScaler()
    data = scaler.fit_transform(training_data[:, _feature_mask])
    target_data_c = training_data[:, _o].astype(np.float)

    for c in range(len(clf)):
        train_data_c = data[:,c].reshape(-1, 1) # Get the nth column to train
        clf[c] = MLPRegressor(hidden_layer_sizes=(20,10), max_iter=1500, solver = 'adam', learning_rate_init = 0.01)
#        clf[c] = SVR(C = 1, epsilon = 0.05)
        clf[c].fit(train_data_c, target_data_c)
    
    return clf, scaler, feature_score
    
def predict(input_vec, classifier = None, st_scaler = None):
    # input_vec is a 7 dimensional vector with the data
    results = []
    if classifier == None:
        classifier = clf
        
    if st_scaler == None:
        st_scaler = scaler
    
    input_v_scaled = st_scaler.transform([input_vec[:_o]]) 
    for c in range(len(classifier)):
        input_v_scaled_c = input_v_scaled[:,c].reshape(-1,1) # Get the nth column to train
        results.append(classifier[c].predict(input_v_scaled_c))

    return results
    
def evaluate(evaluation_data, classifier = None, st_scaler = None):
    results = []
    if classifier == None:
        classifier = clf
        
    if st_scaler == None:
        st_scaler = scaler
    
    data = st_scaler.transform(evaluation_data[:, _feature_mask])
    target_data_c = evaluation_data[:, _o].astype(np.int) #[7,8]]
    
    results = []
    
    for c in range(len(clf)):
        train_data_c = data[:,c].reshape(-1, 1) # Get the nth column to train
        results.append(clf[c].score(train_data_c, target_data_c))

    return results
    
def estimateEarthLike(input_v, classifier = None, st_scaler = None, f_score = None):
    # Use the feature scores to weight the results of the classifier
    probs = predict(input_v, classifier, st_scaler)
#    print(probs.shape)
    final_score = 0
    for p in range(len(probs)):
        p_total = probs[p][0] #[1] + 2*probs[p][0][2] # todo
        final_score += f_score[p] * p_total
        
    return 2*final_score, probs

def initialize(training_data):
    return train(training_data)