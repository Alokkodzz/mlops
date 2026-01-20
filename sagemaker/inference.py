import os
import pickle
import json
import numpy as np

def model_fn(model_dir):
    """ Deserialize and return fitted model. """
    model_file = "intent_model.pkl"
    with open(os.path.join(model_dir, model_file), 'rb') as file:
        model = pickle.load(file)
    return model

def input_fn(request_body, request_content_type):
    """ Deserialize the input data. """
    if request_content_type == 'application/json':
        data = json.loads(request_body)
        # Convert list/dict to numpy array or specific format required by your model
        return np.array(data)
    else:
        raise ValueError(f"Unsupported content type: {request_content_type}")

def predict_fn(input_data, model):
    """ Perform prediction. """
    prediction = model.predict(input_data)
    return prediction

def output_fn(prediction, accept):
    """ Serialize the prediction output. """
    if accept == "application/json":
        # Convert numpy array to list for JSON serialization
        return json.dumps(prediction.tolist()), accept
    else:
        raise ValueError(f"Unsupported accept type: {accept}")
