import os
import pandas as pd
import joblib
from sklearn.ensemble import RandomForestClassifier

train = pd.read_csv("data/derived/train.csv")

# one-hot encode categorical columns
X = pd.get_dummies(train.drop(columns=["encounter_id", "patient_nbr", "readmitted", "readmitted30"]))
y = train["readmitted30"]

rf = RandomForestClassifier(n_estimators=500, min_samples_leaf=5, n_jobs=-1,random_state=123)
rf.fit(X, y)

# most important variables
importance = pd.DataFrame({"variable": X.columns, "importance": rf.feature_importances_})
print(importance.sort_values("importance", ascending=False).head(15))
importance.to_csv("data/derived/rf_importance.csv", index=False)

os.makedirs("models", exist_ok=True)
joblib.dump(rf, "models/rf.joblib")