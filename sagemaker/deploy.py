from sagemaker.sklearn.model import SKLearnModel

model = SKLearnModel(
    model_data='s3://my-bucket/my-model/model.tar.gz',
    role='arn:aws:iam::123456789012:role/SageMakerExecutionRole',
    entry_point='inference.py',
    framework_version='0.23-1'
)

predictor = model.deploy(
    initial_instance_count=1,
    instance_type='ml.t2.medium'
)