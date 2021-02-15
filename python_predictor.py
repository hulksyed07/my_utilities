# https://towardsdatascience.com/step-by-step-guide-building-a-prediction-model-in-python-ac441e8b9e8b
# RUN python3 -m pip install pandas numpy keras tensorflow==2.2 matplotlib sklearn


import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
# %matplotlib inline
from matplotlib.pylab import rcParams
rcParams['figure.figsize']=20,10
from keras.models import Sequential
from keras.layers import LSTM,Dropout,Dense
from sklearn.preprocessing import MinMaxScaler
# import tensorflow as tf
import pdb
import json

import pandas as pd
df = pd.read_csv('HistoricalQuotes.csv')
# pdb.set_trace()

## Data Manipulation
df = df[['Date', 'Close/Last']]
df = df.replace({'\$':''}, regex = True)
df = df.astype({"Close/Last": float})
df["Date"] = pd.to_datetime(df.Date, format="%m/%d/%Y")
# df.dtypes

df.index = df['Date']

## Data Visualization
plt.plot(df["Close/Last"],label='Close Price history')
# plt.show()


## LSTM Prediction Model
# Data Preparation
df = df.sort_index(ascending=True,axis=0)
data = pd.DataFrame(index=range(0,len(df)),columns=['Date','Close/Last'])
for i in range(0,len(data)):
    data["Date"][i]=df['Date'][i]
    data["Close/Last"][i]=df["Close/Last"][i]
# pdb.set_trace()
data.head()

# MinMaxScaler
scaler=MinMaxScaler(feature_range=(0,1))
data.index=data.Date
data.drop("Date",axis=1,inplace=True)
final_data = data.values
train_data=final_data[0:200,:]
valid_data=final_data[200:,:]
scaler=MinMaxScaler(feature_range=(0,1))
scaled_data=scaler.fit_transform(final_data)
x_train_data,y_train_data=[],[]
for i in range(60,len(train_data)):
    x_train_data.append(scaled_data[i-60:i,0])
    y_train_data.append(scaled_data[i,0])

# pdb.set_trace()

# LSTM Model
lstm_model=Sequential()
lstm_model.add(LSTM(units=50,return_sequences=True,input_shape=(np.shape(x_train_data)[1],1)))
lstm_model.add(LSTM(units=50))
lstm_model.add(Dense(1))
model_data=data[len(data)-len(valid_data)-60:].values
model_data=model_data.reshape(-1,1)
model_data=scaler.transform(model_data)

# Train and Test Data
lstm_model.compile(loss='mean_squared_error',optimizer='adam')
x_train_data = np.array(x_train_data)
y_train_data = np.array(y_train_data)
x_train_data = np.reshape(x_train_data,(x_train_data.shape[0], x_train_data.shape[1], 1))
y_train_data = np.reshape(y_train_data,(y_train_data.shape[0], 1))
lstm_model.fit(x=x_train_data,y=y_train_data,epochs=1,batch_size=1,verbose=2)
X_test=[]
for i in range(60,model_data.shape[0]):
    X_test.append(model_data[i-60:i,0])
X_test=np.array(X_test)
X_test=np.reshape(X_test,(X_test.shape[0],X_test.shape[1],1))

# Prediction Function
predicted_stock_price=lstm_model.predict(X_test)
predicted_stock_price=scaler.inverse_transform(predicted_stock_price)

# Prediction Result
train_data=data[:200]
valid_data=data[200:]
valid_data['Predictions']=predicted_stock_price

# pdb.set_trace()
plt.plot(train_data["Close/Last"])
plt.plot(valid_data[['Close/Last',"Predictions"]])

# Converting to Dict and storing
train_dict = train_data.to_dict('index')
pred_dict = valid_data.to_dict('index')

train_dict_clean = {}
for key in train_dict.keys():
  if type(key) is not str:
    train_dict_clean[str(key)] = train_dict[key]

pred_dict_clean = {}
for key in pred_dict.keys():
  if type(key) is not str:
    pred_dict_clean[str(key)] = pred_dict[key]

train_json = json.dumps(train_dict_clean, indent = 3)
pred_json = json.dumps(pred_dict_clean, indent = 3)

f = open("predict_train_data.json", "a")
f.write(train_json)
f.close()

f = open("predict_result_data.json", "a")
f.write(pred_json)
f.close()
