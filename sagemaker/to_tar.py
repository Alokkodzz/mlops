import tarfile
import boto3

with tarfile.open("model.tar.gz", "w:gz") as tar:
    tar.add("model/artifacts/intent_model.pkl")
    tar.add("inference.py")

print("model.tar.gz is created")


s3 = boto3.client('s3')
s3.upload_file('model.tar.gz', 'mlops-sagemaker-alok', 'model.tar.gz')