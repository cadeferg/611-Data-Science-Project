import pandas as pd
import joblib
 
test = pd.read_csv("data/derived/test.csv")
rf = joblib.load("models/rf.joblib")
 
# one-hot encode then line up columns with what the model was trained on
X = pd.get_dummies(test.drop(columns=["encounter_id", "patient_nbr", "readmitted", "readmitted30"]))
X = X.reindex(columns=rf.feature_names_in_, fill_value=0)
 
# predicted prob of readmission
predictions = pd.DataFrame({"encounter_id": test["encounter_id"],"rf": rf.predict_proba(X)[:, 1]})
 
predictions.to_csv("data/derived/rf_predictions.csv", index=False)
print(predictions["rf"].describe())
 