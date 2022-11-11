import pytest
from flask import request, jsonify
from app import app

def test_predict():
    with app.test_client() as c:
        resp = c.post('/predict', json={
            "CHAS":{
                "0":0
            },
            "RM":{
                "0":6.575
            },
            "TAX":{
                "0":296.0
            },
            "PTRATIO":{
                "0":15.3
            },
            "B":{
                "0":396.9
            },
            "LSTAT":{
                "0":4.98
            }
        })
        print(resp)
        json_data = resp.get_json()
        assert json_data['prediction'] == [2.431574790057212]
