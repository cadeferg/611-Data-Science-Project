import pandas as pd
import joblib
from sklearn.inspection import permutation_importance
 
test = pd.read_csv("data/derived/test.csv")
rf = joblib.load("models/rf.joblib")
 
# one-hot encode then line up columns with what the model was trained on
X = pd.get_dummies(test.drop(columns=["encounter_id", "patient_nbr", "readmitted", "readmitted30"]))
X = X.reindex(columns=rf.feature_names_in_, fill_value=0)
 
# predicted prob of readmission
predictions = pd.DataFrame({"encounter_id": test["encounter_id"],"rf": rf.predict_proba(X)[:, 1]})
 
predictions.to_csv("data/derived/rf_predictions.csv", index=False)
print(predictions["rf"].describe())

# how much AUC drops when each column is shuffled
result = permutation_importance(rf, X, test["readmitted30"], scoring="roc_auc", n_repeats=5, random_state=123, n_jobs=-1)
importance = pd.DataFrame({"variable": X.columns, "importance": result.importances_mean})
print(importance.sort_values("importance", ascending=False).head(15))
importance.to_csv("data/derived/rf_importance.csv", index=False)
 
