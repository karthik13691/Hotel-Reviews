# Hotel-Reviews
import pandas as pd
df = pd.read_csv('Hotel_Reviews.csv')
df['all_review'] = df.apply(lambda x:x['Positive_Review']+' '+x['Negative_Review'],axis=1)

# Due to it's large size, i'll train a model on 30% of the data and valid the model on 70% of the data

from sklearn.model_selection import train_test_split
train,test1 = train_test_split(df,test_size=0.7,random_state=42)

# I'll train the TDIDF model to test and train data set for sklearn model

from sklearn.feature_extraction.text import TfidfVectorizer
t = TfidfVectorizer(max_features=10000)
train_feats = t.fit_transform(train['all_review'])
test_feats1 = t.transform(test1['all_review'])
from sklearn.ensemble import GradientBoostingRegressor
gbdt = GradientBoostingRegressor(max_depth=5,learning_rate=0.1,n_estimators=150)

# Fit the gradient boosting Regressor with large iterations, fewer estimators

gbdt.fit(train_feats,train['Reviewer_Score'])
words = t.get_feature_names()
importance = gbdt.feature_importances_
impordf = pd.DataFrame({'Word' : words,'Importance' : importance})
impordf = impordf.sort_values(['Importance', 'Word'], ascending=[0, 1])

# Let's check the top 30 most important words
impordf.head(30)

# Words with strong emotion implication (like not, rude.etc) gain higher score in feature importance table.
