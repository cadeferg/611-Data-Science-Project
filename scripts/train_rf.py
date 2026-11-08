import os
import pandas as pd
import joblib
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import GridSearchCV

train = pd.read_csv("data/derived/train.csv")

# one-hot encode categorical columns
X = pd.get_dummies(train.drop(columns=["encounter_id", "patient_nbr", "readmitted", "readmitted30"]))
y = train["readmitted30"]

param_grid = {"min_samples_leaf": [5, 20, 50], "max_features": ["sqrt", 0.2]}

search = GridSearchCV(RandomForestClassifier(n_estimators=300, random_state=123), param_grid, cv=3, scoring="roc_auc", n_jobs=-1)
search.fit(X, y)

print(pd.DataFrame(search.cv_results_)[["params", "mean_test_score"]])
print("Best settings:", search.best_params_)

rf = search.best_estimator_

# most important variables
importance = pd.DataFrame({"variable": X.columns, "importance": rf.feature_importances_})
print(importance.sort_values("importance", ascending=False).head(15))
importance.to_csv("data/derived/rf_importance.csv", index=False)

os.makedirs("models", exist_ok=True)
joblib.dump(rf, "models/rf.joblib", compress=3)